%% ============================================================
%% ตัวอย่างที่ 2: Flexible Job Shop Scheduling
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 4
%% ============================================================
%%
%% Flexible Job Shop:
%%   - แต่ละ job มีหลาย task ที่ต้องทำตามลำดับ
%%   - แต่ละ task เลือกได้ว่าจะใช้เครื่องจักรไหน
%%     (บางเครื่องทำได้เร็วกว่า บางเครื่องทำไม่ได้เลย)
%%
%% ต่างจาก Job Shop ปกติ (04_jobshop_basic.mzn วันที่ 3) อย่างไร:
%%   Job Shop ปกติ: แต่ละ task ผูกติดกับเครื่องที่กำหนดไว้แน่นอน
%%   Flexible:      แต่ละ task มี "ตัวเลือกเครื่อง" ให้เลือก
%%                  → ต้องตัดสินใจทั้ง "เลือกเครื่องไหน" และ "เริ่มเมื่อไหร่"
%%
%% ─────────────────────────────────────────────────────────────
%% สำคัญ: Machine Capability กำหนดที่ระดับ Task Type × Machine
%% ─────────────────────────────────────────────────────────────
%%   ความสามารถของเครื่อง ขึ้นกับ "ประเภทงาน" — ไม่ขึ้นกับว่าเป็น Job ไหน
%%   เช่น เครื่องตัดเลเซอร์ทำ "ขั้นตอนตัด" ได้ทุก order — ไม่ใช่แค่ order ที่ 1
%%   → capable[task_type, machine] เป็น parameter ระดับโรงงาน
%%   → proc_time[task_type, machine] ก็เช่นกัน (เครื่องเดิม งานประเภทเดิม ใช้เวลาเท่ากัน)
%%
%% รันด้วย: minizinc 02_flexible_jobshop.mzn 02_flexible_data.dzn
%% ============================================================

include "disjunctive.mzn";

enum JOB;
enum TASK;
enum MACHINE;
TASK: t_last = max(TASK);

%% ── Parameters ──────────────────────────────────────────────

%% ✅ Capability: กำหนดที่ระดับ task type × machine (ไม่ขึ้นกับ job)
%%    capable[t, m] = true → เครื่อง m รองรับ task ประเภท t
array[TASK, MACHINE] of bool: capable;

%% เวลาที่ใช้ทำงาน (นาที) — มีความหมายเฉพาะเมื่อ capable[t,m] = true
array[TASK, MACHINE] of int: proc_time;

%% Upper bound สำหรับ start variable
int: total = sum(t in TASK)(
  max(m in MACHINE where capable[t, m])(proc_time[t, m])
) * card(JOB);

%% ── Decision Variables ──────────────────────────────────────
array[JOB, TASK] of var MACHINE: machine;     %% เครื่องที่เลือกสำหรับแต่ละ (job, task)
array[JOB, TASK] of var 0..total: start;      %% เวลาเริ่มต้น
var 0..total: makespan;

%% ── Constraints ─────────────────────────────────────────────

%% 1. เลือกเฉพาะเครื่องที่รองรับ task type นั้น
constraint forall(j in JOB, t in TASK)(
  capable[t, machine[j, t]]
);

%% 2. Precedence: task ในแต่ละ job ต้องทำตามลำดับ
%%    (task ถัดไปเริ่มได้หลัง task ก่อนหน้าเสร็จ)
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j, t] + proc_time[t, machine[j, t]] <= start[j, enum_next(TASK, t)]
  ) /\
  start[j, t_last] + proc_time[t_last, machine[j, t_last]] <= makespan
);

%% 3. ✅ No-overlap ที่ถูกต้อง:
%%    ทุกคู่ (j1,t1) และ (j2,t2) ที่ใช้เครื่องเดียวกัน ต้องไม่ overlap
constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
  where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
  machine[j1, t1] = machine[j2, t2] ->
  (start[j1, t1] + proc_time[t1, machine[j1, t1]] <= start[j2, t2] \/
   start[j2, t2] + proc_time[t2, machine[j2, t2]] <= start[j1, t1])
);

%% ── Objective ────────────────────────────────────────────────
solve minimize makespan;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== Flexible Job Shop ===\n",
  "Makespan = ", show(makespan), " นาที\n\n",
  "Job\tTask\tเครื่อง\t\tเริ่ม\tเสร็จ\n",
  "─────────────────────────────────────────\n"
] ++
[ show(j) ++ "\t" ++ show(t) ++ "\t" ++ show(machine[j, t]) ++ "\t\t" ++
  show(start[j, t]) ++ "\t" ++
  show(start[j, t] + proc_time[t, machine[j, t]]) ++ "\n"
  | j in JOB, t in TASK ] ++
[
  "\n💡 หมายเหตุ: เครื่องเดียวกันไม่มี task ใดทับซ้อนกัน\n",
  "   ไม่ว่า task นั้นจะเป็นประเภทเดียวกันหรือต่างประเภท\n"
];
