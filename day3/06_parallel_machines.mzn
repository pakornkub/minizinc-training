%% ============================================================
%% ตัวอย่างที่ 6: cumulative → Parallel Machine Scheduling
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 3
%% ============================================================
%%
%% โจทย์: ไลน์ผลิตมีเครื่องจักร CNC 3 เครื่อง (เหมือนกันทุกเครื่อง)
%%   ได้รับออร์เดอร์ 8 ชิ้นงาน แต่ละชิ้นใช้เวลาต่างกัน
%%   แต่ละเครื่องรับงานได้ทีละ 1 ชิ้น
%%   เป้าหมาย: ทำทุกชิ้นให้เสร็จเร็วที่สุด (minimize makespan)
%%
%% ชิ้นงาน:  P1   P2   P3   P4   P5   P6   P7   P8
%% เวลา(นาที): 45  30   60   20   50   35   25   40
%%
%% ทำไมถึงใช้ cumulative?
%%   ในทุกช่วงเวลา ผลรวมของชิ้นงานที่กำลังผลิต ≤ 3 เครื่อง
%%   → cumulative(start, duration, [1,1,...,1], 3)
%%      เพราะแต่ละชิ้นงานใช้เครื่อง 1 เครื่อง และมีเครื่องรวม 3 เครื่อง
%%
%% เปรียบเทียบกับตัวอย่าง 02 (ขนของ):
%%   02: resource_req ต่างกัน (Piano ต้อง 3 คน, Chair ต้อง 1 คน)
%%   06: resource_req เท่ากันหมด (= 1 เครื่อง/ชิ้นงาน)
%%       แต่ capacity = จำนวนเครื่อง → นี่คือ "parallel machine" problem
%%
%% จุดเด่น:
%%   - เห็นความสัมพันธ์ระหว่าง cumulative และ machine scheduling
%%   - เป็น stepping stone ไปสู่ Job Shop (ตัวอย่าง 04)
%%     ความต่าง: Job Shop แต่ละงานต้องผ่านหลายเครื่องตามลำดับ
%%               Parallel Machine แต่ละงานใช้เครื่องเดียว เลือกได้
%%
%% รันด้วย: minizinc 06_parallel_machines.mzn
%% ============================================================

include "cumulative.mzn";

int: n_jobs     = 8;
int: n_machines = 3;
set of int: JOBS = 1..n_jobs;

array[JOBS] of string: job_name = ["P1","P2","P3","P4","P5","P6","P7","P8"];
array[JOBS] of int: duration    = [45,  30,  60,  20,  50,  35,  25,  40];

%% เวลารวมสูงสุดที่เป็นไปได้ (worst case: ทำทีละชิ้น)
int: horizon = sum(j in JOBS)(duration[j]);

%% ── Decision Variables ──────────────────────────────────────
array[JOBS] of var 0..horizon: start;   %% เวลาเริ่มแต่ละชิ้น
var 0..horizon: makespan;               %% เวลาเสร็จทั้งหมด

%% ── Constraints ─────────────────────────────────────────────

%% 1. ในทุกช่วงเวลา ชิ้นงานที่กำลังผลิตต้องไม่เกิน n_machines เครื่อง
%%    resource_req = [1,1,...,1] เพราะแต่ละงานใช้ 1 เครื่อง
constraint cumulative(
  start,
  duration,
  [1 | j in JOBS],   %% แต่ละงานใช้ 1 เครื่อง
  n_machines         %% มีเครื่องรวม 3 เครื่อง
);

%% 2. makespan ต้องครอบคลุมทุกงาน
constraint forall(j in JOBS)(
  start[j] + duration[j] <= makespan
);

%% ── ✅ Lower Bound (Tight Bound) ──────────────────────────────
%% makespan ต้องไม่น้อยกว่า:
%%   - งานที่นานที่สุด (ต้องรอมันเสร็จ)
%%   - เวลารวมทั้งหมด หารจำนวนเครื่อง (throughput limit)
int: lb_longest  = max(j in JOBS)(duration[j]);
int: lb_throughput = (sum(j in JOBS)(duration[j]) + n_machines - 1) div n_machines;
int: lower_bound = max(lb_longest, lb_throughput);

constraint makespan >= lower_bound;

%% ── Objective ────────────────────────────────────────────────
solve minimize makespan;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== Parallel Machine Scheduling ===\n",
  "เครื่องจักร: ", show(n_machines), " เครื่อง\n\n",
  "ชิ้นงาน\tเริ่ม\tเสร็จ\tเวลา\n",
  "────────────────────────────────\n"
] ++
[ job_name[j] ++ "\t" ++ show(start[j]) ++ "\t" ++
  show(start[j]+duration[j]) ++ "\t" ++ show(duration[j]) ++ " นาที\n"
  | j in JOBS ] ++
[
  "────────────────────────────────\n",
  "Makespan: ", show(makespan), " นาที\n",
  "Lower bound: ", show(lower_bound), " นาที\n",
  "Gap: ", show(makespan - lower_bound), " นาที\n\n",
  "💡 เทียบกับ Job Shop (04_jobshop_basic.mzn):\n",
  "   Parallel: แต่ละงานใช้เครื่องเดียว ไม่มีลำดับ\n",
  "   Job Shop: แต่ละงานต้องผ่านทุกสถานีตามลำดับ\n"
];
