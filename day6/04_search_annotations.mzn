%% ============================================================
%% ตัวอย่าง 4: Search Annotations — รับมือข้อมูลขนาดใหญ่ (เทคนิคที่ 2)
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 6
%% ============================================================
%%
%% ปัญหา: จัดตารางงาน Job Shop (n งาน × m เครื่องจักร)
%%
%% Search Annotation คือ: "บอก solver ว่าควร ค้นหาอย่างไร"
%%   ถ้าไม่บอก → solver ใช้กลยุทธ์ default → อาจช้ากับข้อมูลใหญ่
%%   ถ้าบอกถูกต้อง → เร็วขึ้น 10x–100x ในบางปัญหา
%%
%% Variable selection (เลือก variable ไหนก่อน):
%%   first_fail   — เลือกตัวที่ domain เล็กที่สุด (ขัดแย้งง่าย → แก้ก่อน)
%%   largest      — เลือกตัวที่ domain ใหญ่สุด
%%   input_order  — เลือกตามลำดับ (default)
%%
%% Value selection (เลือกค่าไหนลอง):
%%   indomain_min  — ลองค่าน้อยสุดก่อน (ดีสำหรับ minimization)
%%   indomain_max  — ลองค่ามากสุดก่อน
%%   indomain_random — สุ่ม (ดีสำหรับบางปัญหา)
%%
%% Restart (ค้นหาใหม่เมื่อติด):
%%   restart_luby — Luby sequence (proven efficient สำหรับข้อมูลใหญ่)
%%   restart_geometric(f, n) — restart ทุก f^k × n nodes
%%
%% รันด้วย: minizinc 04_search_annotations.mzn
%% ============================================================

include "cumulative.mzn";

int: n_jobs     = 6;
int: n_machines = 3;
int: horizon    = 50;  % เวลาสูงสุดที่เป็นไปได้

set of int: JOBS     = 1..n_jobs;
set of int: MACHINES = 1..n_machines;

%% เวลาที่ใช้ (งาน × เครื่องจักร) — แต่ละงานต้องผ่านทุกเครื่องตามลำดับ
array[JOBS, MACHINES] of int: proc_time =
  [| 5, 4, 3
   | 3, 6, 2
   | 7, 2, 5
   | 4, 5, 4
   | 2, 3, 6
   | 6, 1, 4 |];

%% ลำดับเครื่องจักรของแต่ละงาน (ต้องทำตามลำดับนี้)
array[JOBS, MACHINES] of int: machine_order =
  [| 1, 2, 3
   | 2, 1, 3
   | 1, 3, 2
   | 3, 1, 2
   | 2, 3, 1
   | 1, 2, 3 |];

%% ── Decision Variables ──────────────────────────────────────
array[JOBS, MACHINES] of var 0..horizon: start;
var 0..horizon: makespan;

%% ── Constraints ─────────────────────────────────────────────

%% 1. ลำดับการทำงานในแต่ละ job (ทำเครื่องถัดไปหลังจากเครื่องก่อนเสร็จ)
constraint forall(j in JOBS, k in 1..n_machines-1)(
  start[j, k+1] >= start[j, k] + proc_time[j, machine_order[j, k]]
);

%% 2. เครื่องจักรแต่ละเครื่องทำได้ทีละ 1 งาน (ไม่ overlap)
constraint forall(m in MACHINES)(
  cumulative(
    [start[j, k] | j in JOBS, k in MACHINES where machine_order[j,k] = m],
    [proc_time[j, k] | j in JOBS, k in MACHINES where machine_order[j,k] = m],
    [1 | j in JOBS, k in MACHINES where machine_order[j,k] = m],
    1
  )
);

%% 3. makespan ต้องครอบคลุมทุกงาน
constraint forall(j in JOBS)(
  makespan >= start[j, n_machines] + proc_time[j, machine_order[j, n_machines]]
);

%% ── ✅ Search Annotation: บอก solver วิธีค้นหา ───────────────
%%
%% สำหรับ Job Shop Scheduling:
%%   - ใช้ first_fail เพื่อเลือก variable ที่ constrained มากที่สุดก่อน
%%   - ใช้ indomain_min เพราะต้องการ minimize makespan
%%   - ใช้ restart_luby เพื่อหลีกเลี่ยง long search branches
%%
solve :: seq_search([
  int_search(
    [start[j,k] | j in JOBS, k in MACHINES],
    first_fail,       %% เลือก variable ที่ domain เล็กสุด
    indomain_min      %% ลองค่าน้อยก่อน (เหมาะกับ minimize)
  ),
  int_search([makespan], input_order, indomain_min)
])
:: restart_luby(50)   %% restart ทุก 50, 100, 200, ... nodes (Luby sequence)
minimize makespan;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== Job Shop Scheduling + Search Annotations ===\n\n",
  "งาน\tเครื่อง1\tเครื่อง2\tเครื่อง3\n",
  "────────────────────────────────────────────────\n"
] ++
[ "งาน " ++ show(j) ++ "\t" ++
  show(start[j,1]) ++ "-" ++ show(start[j,1]+proc_time[j,1]) ++ "\t\t" ++
  show(start[j,2]) ++ "-" ++ show(start[j,2]+proc_time[j,2]) ++ "\t\t" ++
  show(start[j,3]) ++ "-" ++ show(start[j,3]+proc_time[j,3]) ++ "\n"
  | j in JOBS ] ++
[
  "\n⏱ Makespan รวม: ", show(makespan), " หน่วยเวลา\n",
  "\n💡 Search Tips สำหรับข้อมูลใหญ่:\n",
  "   first_fail → แก้ variable ที่ขัดแย้งได้ยากก่อน\n",
  "   restart_luby → ไม่ติดอยู่ใน dead-end นานเกินไป\n",
  "   ลอง: เปลี่ยน first_fail → largest แล้วเปรียบเทียบเวลา\n"
];
