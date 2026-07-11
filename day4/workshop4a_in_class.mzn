%% ===================================================
%% WORKSHOP 4A: Flexible Manufacturing Scheduling
%% ===================================================
%%
%% โจทย์: 4 ออร์เดอร์ (A-D), แต่ละออร์เดอร์มี 3 ขั้นตอน
%%   แต่ละขั้นตอนทำได้บนเครื่องจักรที่รองรับเท่านั้น
%%   เครื่องแต่ละแบบมีความเร็วต่างกัน
%%   Minimize makespan
%%
%% Machine Capability (กำหนดที่ระดับ task type):
%%   MA (เครื่องเลเซอร์) : ตัด ✓ | เชื่อม ✗ | ขัดผิว ✓
%%   MB (หุ่นเชื่อม)     : ตัด ✗ | เชื่อม ✓ | ขัดผิว ✗
%%   MC (เครื่องอเนกประสงค์): ตัด ✓ | เชื่อม ✓ | ขัดผิว ✓ (แต่ช้ากว่า)
%%
%% รันด้วย: minizinc workshop4a_starter.mzn workshop4a_data.dzn
%%
%% ขั้นตอน:
%%   1) เพิ่ม constraint: เลือกเฉพาะเครื่องที่ capable[t, machine[j,t]] = true
%%   2) เพิ่ม Precedence constraint
%%   3) เพิ่ม No-overlap: ทุกคู่ (j1,t1)≠(j2,t2) บนเครื่องเดียวกันห้าม overlap
%%      ✅ ใช้ where j1<j2 \/ (j1=j2 /\ t1<t2) ครอบคลุมทุกกรณี
%%   4) solve minimize makespan
%%   5) ท้าทาย: เพิ่มเงื่อนไข — ออร์เดอร์ D ต้องเริ่ม Cutting ไม่ก่อนนาทีที่ 5

include "disjunctive.mzn";

enum JOB;
enum TASK;
enum MACHINE;
TASK: t_last = max(TASK);

%% Machine capability: capable[t, m] = true → เครื่อง m รองรับ task ประเภท t
array[TASK, MACHINE] of bool: capable;

%% เวลาที่ใช้ (นาที) — ใช้เฉพาะเมื่อ capable[t,m] = true
array[TASK, MACHINE] of int: proc_time;

int: total = sum(t in TASK)(
  max(m in MACHINE where capable[t, m])(proc_time[t, m])
) * card(JOB);

array[JOB, TASK] of var MACHINE: machine;
array[JOB, TASK] of var 0..total: start;
var 0..total: makespan;

%% TODO 1: เลือกเฉพาะเครื่องที่รองรับ task นั้น
constraint forall(j in JOB, t in TASK)(
  capable[t, machine[j, t]]
);

%% TODO 2: Precedence — task ในแต่ละ job ต้องทำตามลำดับ
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j, t] + proc_time[t, machine[j, t]] <= start[j, enum_next(TASK, t)]
  ) /\
  start[j, t_last] + proc_time[t_last, machine[j, t_last]] <= makespan 
);

%% TODO 3: No-overlap — ทุกคู่ (j1,t1) และ (j2,t2) บนเครื่องเดียวกันห้าม overlap
%%   hint: forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
%%           where j1 < j2 \/ (j1 = j2 /\ t1 < t2))( ... )
predicate no_overlap(var int: s1, var int: d1, var int: s2, var int: d2) =
  s1 + d1 <= s2 \/ s2 + d2 <= s1;

constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK 
  where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
    machine[j1, t1] = machine[j2, t2] ->
    no_overlap(start[j1, t1], proc_time[t1, machine[j1, t1]],
               start[j2, t2], proc_time[t2, machine[j2, t2]])
);


%% TODO 4: solve minimize makespan
solve minimize makespan;

output ["Makespan = ", show(makespan), "\n"] ++
[ show(j) ++ "/" ++ show(t) ++ ": " ++ show(machine[j,t]) ++
  " [" ++ show(start[j,t]) ++ "-" ++
  show(start[j,t] + proc_time[t, machine[j,t]]) ++ "]\n"
  | j in JOB, t in TASK ];
