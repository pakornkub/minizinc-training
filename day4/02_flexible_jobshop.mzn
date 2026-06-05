%% ตัวอย่างที่ 2: Flexible Job Shop Scheduling
%% อ้างอิง: docs.minizinc.dev - Job Shop Scheduling
%%
%% Flexible Job Shop: แต่ละ task เลือกได้ว่าจะใช้เครื่องจักรไหน
%% Duration และ cost ขึ้นอยู่กับเครื่องที่เลือก
%%
%% รันด้วย: minizinc 02_flexible_jobshop.mzn 02_flexible_data.dzn

include "disjunctive.mzn";

enum JOB;
enum TASK;
enum MACHINE;
TASK: t_last = max(TASK);

%% duration[j,t,m] = เวลาถ้า job j, task t ใช้เครื่อง m
%% (0 หมายความว่าเครื่องนี้ทำ task นี้ไม่ได้)
array[JOB, TASK, MACHINE] of int: dur;

int: total = sum(j in JOB, t in TASK)(max(m in MACHINE)(dur[j,t,m]));

%% Decision Variables
array[JOB, TASK] of var MACHINE: machine;      % เครื่องที่เลือก
array[JOB, TASK] of var 0..total: start;       % เวลาเริ่ม
var 0..total: makespan;

%% ── Constraints ────────────────────────────────────────

%% 1. เลือกเฉพาะเครื่องที่ทำได้ (dur > 0)
constraint forall(j in JOB, t in TASK)(
  dur[j, t, machine[j,t]] > 0
);

%% 2. Precedence: task ตามลำดับใน job เดียวกัน
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j,t] + dur[j,t,machine[j,t]] <= start[j, enum_next(TASK,t)]
  ) /\
  start[j,t_last] + dur[j,t_last,machine[j,t_last]] <= makespan
);

%% 3. No-overlap: 2 task ที่เลือกเครื่องเดียวกันต้องไม่ overlap
constraint forall(t in TASK, m in MACHINE)(
  forall(j, k in JOB where j < k)(
    machine[j,t] = m /\ machine[k,t] = m ->
    (start[j,t] + dur[j,t,m] <= start[k,t] \/
     start[k,t] + dur[k,t,m] <= start[j,t])
  )
);

solve minimize makespan;

output ["Makespan = ", show(makespan), "\n"] ++
[ show(j) ++ ", " ++ show(t) ++ ": " ++
  show(machine[j,t]) ++ " start=" ++ show(start[j,t]) ++ "\n"
  | j in JOB, t in TASK ];
