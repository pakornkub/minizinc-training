%% ตัวอย่างที่ 4: Job Shop Scheduling พื้นฐาน
%% Job Shop: หลาย job แต่ละ job ผ่านหลาย task ตามลำดับ
%% แต่ละ task ใช้เครื่องจักร 1 เครื่อง — ไม่มี 2 task ใช้เครื่องเดียวกันพร้อมกัน
%% แต่ละ job มีลำดับของ task แตกต่างกันได้

include "disjunctive.mzn";

enum JOB = J(1..5);   % แก้: มี 5 jobs ตามข้อมูลใน d/sequence_id (เดิมกำหนดผิดเป็น 1..4)
enum TASK = T(1..3);

array[JOB, TASK] of int: d;
d = [| 9,  8, 12
     | 7, 15,  5
     | 11,  6, 8
     | 6,  10, 12
     | 18,  9, 7
    |];

array[JOB, TASK] of int: sequence_id;
sequence_id = [| 1, 2, 3
               | 3, 2, 1
               | 2, 1, 3
               | 3, 2, 1
               | 1, 3, 2
              |];

int: total = sum(j in JOB, t in TASK)(d[j, t]);

array[JOB, TASK] of var 0..total: start;   % แก้: กำหนดโดเมนให้ start (เดิมเป็น var int ไม่มีขอบเขต)
var 0..total: makespan;                     % แก้: กำหนดโดเมนให้ makespan

% สำหรับแต่ละ job, task จะต้องถูกทำตามลำดับ
constraint
forall(j in JOB, t1 in TASK, t2 in TASK) (
    sequence_id[j,t2] = sequence_id[j,t1] + 1 ->
        start[j,t2] >= start[j,t1] + d[j,t1]
);

constraint forall(j in JOB, t in TASK)(
  start[j, t] + d[j, t] <= makespan
);

% No-overlap: แต่ละ task (= เครื่องจักร) ใช้ได้ทีละหนึ่ง
constraint forall(t in TASK)(
  disjunctive(
    [start[j, t] | j in JOB],
    [d[j, t] | j in JOB]
  )
);

solve minimize makespan;

output
  ["Makespan = ", show(makespan), "\n\n"] ++
  [ "Job \(j)\n" ++
    concat([ "  Task \(t): " ++ show(start[j,t]) ++ " - " ++ show(start[j,t] + d[j,t]) ++ "\n"
             | t in TASK ]) ++ "\n"
    | j in JOB ];
