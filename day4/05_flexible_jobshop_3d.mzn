%% ===================================================
%% FLEXIBLE JOB SHOP — duration แบบ 3 มิติ
%% 05_flexible_jobshop_3d.mzn
%% ===================================================
%%
%% ปัญหา: มีหลาย job แต่ละ job มีหลาย task ตามลำดับ
%%        แต่ละ task ทำได้บนเครื่องที่รองรับเท่านั้น
%%        เวลาที่ใช้ขึ้นกับ job, task, AND machine
%%        (เช่น งานชิ้นใหญ่ใช้เวลานานกว่าชิ้นเล็กบนเครื่องเดียวกัน)
%%
%% Schema: dur[JOB, TASK, MACHINE] of int
%%   - ถ้า dur[j, t, m] = 0 → เครื่อง m รองรับ task t สำหรับ job j ไม่ได้
%%   - ถ้า dur[j, t, m] > 0 → ใช้เวลานั้น
%%
%% เปรียบเทียบกับ 02_flexible_jobshop.mzn ที่ใช้ capable[TASK,MACHINE]
%% + proc_time[TASK,MACHINE] (duration ไม่ขึ้นกับ job)
%%
%% รันด้วย: minizinc 05_flexible_jobshop_3d.mzn 05_flexible_3d.dzn

include "disjunctive.mzn";

enum JOB;
enum TASK;
enum MACHINE;

TASK: t_last = max(TASK);

%% duration 3 มิติ: 0 = เครื่องรองรับไม่ได้
array[JOB, TASK, MACHINE] of int: dur;

%% Upper bound สำหรับ domain ของ start time และ makespan
%% ใช้ผลรวมของ duration สูงสุดในแต่ละ (job, task)
int: total = sum(j in JOB, t in TASK)(
  max(m in MACHINE)(dur[j, t, m])
);

%% Decision variables
array[JOB, TASK] of var MACHINE: machine;          %% เลือกเครื่องให้แต่ละ (job, task)
array[JOB, TASK] of var 0..total: start;           %% เวลาเริ่มต้น
var 0..total: makespan;                            %% เวลาที่ทุก job เสร็จ

%% ── Constraint 1: Capability ─────────────────────────────
%% เลือกเฉพาะเครื่องที่รองรับ task นั้นของ job นั้น
%% (วิธีตรวจ: dur[j, t, m] > 0 หมายความว่าทำได้)
constraint forall(j in JOB, t in TASK)(
  dur[j, t, machine[j, t]] > 0
);

%% ── Constraint 2: Precedence ─────────────────────────────
%% task ในแต่ละ job ต้องทำตามลำดับ (task ก่อนต้องเสร็จก่อน)
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j, t] + dur[j, t, machine[j, t]] <= start[j, enum_next(TASK, t)]
  )
  /\
  start[j, t_last] + dur[j, t_last, machine[j, t_last]] <= makespan
);

%% ── Constraint 3: No-overlap ─────────────────────────────
%% ทุกคู่ (j1,t1) และ (j2,t2) ที่ใช้เครื่องเดียวกัน ห้าม overlap
%% ครอบคลุมทุกกรณี: j1≠j2 และ j1=j2/t1≠t2
constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
  where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
  machine[j1, t1] = machine[j2, t2] ->
  (  start[j1, t1] + dur[j1, t1, machine[j1, t1]] <= start[j2, t2]
  \/ start[j2, t2] + dur[j2, t2, machine[j2, t2]] <= start[j1, t1])
);

%% ── Objective ────────────────────────────────────────────
solve minimize makespan;

%% ── Output ───────────────────────────────────────────────
output [
  "=== Flexible Job Shop (3D Duration) ===\n",
  "Makespan = ", show(makespan), " นาที\n\n",
  "Job\t\tTask\t\tเครื่อง\tเริ่ม\tเสร็จ\tเวลา\n",
  "----\t\t----\t\t------\t-----\t-----\t----\n"
] ++
[ show(j) ++ "\t" ++ show(t) ++ "\t" ++
  show(machine[j, t]) ++ "\t" ++
  show(start[j, t]) ++ "\t" ++
  show(start[j, t] + dur[j, t, machine[j, t]]) ++ "\t" ++
  show(dur[j, t, machine[j, t]]) ++ " นาที\n"
  | j in JOB, t in TASK ];
