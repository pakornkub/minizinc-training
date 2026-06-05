%% ตัวอย่างที่ 4: Job Shop Scheduling พื้นฐาน
%% อ้างอิง: docs.minizinc.dev - Complex Constraints (2.2.5), Predicates (2.3.2)
%%
%% Job Shop: หลาย job แต่ละ job ผ่านหลาย task ตามลำดับ
%% แต่ละ task ใช้เครื่องจักร 1 เครื่อง — ไม่มี 2 task ใช้เครื่องเดียวกันพร้อมกัน
%%
%% รันด้วย: minizinc 04_jobshop_basic.mzn 04_jobshop_data.dzn

include "disjunctive.mzn";

enum JOB;
enum TASK;

array[JOB, TASK] of int: d;  % duration ของแต่ละ task

int: total   = sum(j in JOB, t in TASK)(d[j, t]);
TASK: t_last = max(TASK);

% ตัวแปร: เวลาเริ่มต้น
array[JOB, TASK] of var 0..total: s;
var 0..total: makespan;

% 1. Precedence: task แต่ละอันต้องเสร็จก่อน task ถัดไปใน job เดียวกัน
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    s[j, t] + d[j, t] <= s[j, enum_next(TASK, t)]
  ) /\
  s[j, t_last] + d[j, t_last] <= makespan
);

% 2. No-overlap: แต่ละ task ใช้เครื่อง (= TASK) ทีละอย่าง
%    สมมติว่า task ที่ i ใช้เครื่อง i (classic job shop)
constraint forall(t in TASK)(
  disjunctive(
    [s[j, t] | j in JOB],
    [d[j, t] | j in JOB]
  )
);

solve minimize makespan;

output [
  "Makespan = ", show(makespan), "\n"
] ++
[ show_int(3, s[j, t]) ++ " " ++
  if t = t_last then "\n" else "" endif
  | j in JOB, t in TASK ];
