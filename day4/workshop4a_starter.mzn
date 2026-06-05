%% ===================================================
%% WORKSHOP 4A: Flexible Manufacturing Scheduling
%% ===================================================
%%
%% โจทย์: 4 ออร์เดอร์ (A-D), แต่ละออร์เดอร์มี 3 ขั้นตอน
%%   แต่ละขั้นตอนทำได้บนเครื่องจักร 2-3 แบบ
%%   เครื่องแต่ละแบบมีความเร็วต่างกัน
%%   Minimize makespan
%%
%% รันด้วย: minizinc workshop4a_starter.mzn workshop4a_data.dzn
%%
%% ขั้นตอน:
%%   1) เพิ่ม constraint: dur[j,t,machine[j,t]] > 0 (เลือกเฉพาะที่ทำได้)
%%   2) เพิ่ม Precedence constraint
%%   3) เพิ่ม No-overlap constraint (2 task เครื่องเดียวกันห้าม overlap)
%%   4) solve minimize makespan
%%   5) ท้าทาย: ลอง disjunctive แทน pairwise no_overlap

include "disjunctive.mzn";

enum JOB;
enum TASK;
enum MACHINE;
TASK: t_last = max(TASK);

array[JOB, TASK, MACHINE] of int: dur;
int: total = sum(j in JOB, t in TASK)(max(m in MACHINE)(dur[j,t,m]));

array[JOB, TASK] of var MACHINE: machine;
array[JOB, TASK] of var 0..total: start;
var 0..total: makespan;

%% TODO 1: เลือกเฉพาะเครื่องที่ทำ task นั้นได้
% constraint ...

%% TODO 2: Precedence (task ตามลำดับใน job เดียวกัน)
% constraint ...

%% TODO 3: No-overlap (สองงานที่ใช้เครื่องเดียวกันห้าม overlap)
% constraint ...

%% TODO 4: solve minimize makespan
solve satisfy;

output ["Makespan = ", show(makespan), "\n"] ++
[ show(j) ++ "/" ++ show(t) ++ ": " ++ show(machine[j,t]) ++
  " [" ++ show(start[j,t]) ++ "-" ++
  show(start[j,t] + dur[j,t,machine[j,t]]) ++ "]\n"
  | j in JOB, t in TASK ];
