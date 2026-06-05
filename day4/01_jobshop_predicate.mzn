%% ตัวอย่างที่ 1: Job Shop พร้อม predicate
%% อ้างอิง: docs.minizinc.dev - Predicates and Functions (2.3.2)
%%
%% predicate ช่วย encapsulate constraint ที่ใช้ซ้ำหลายครั้ง
%% ทำให้โค้ดอ่านง่ายและนำกลับมาใช้ได้
%%
%% รันด้วย: minizinc 01_jobshop_predicate.mzn 01_jobshop_data.dzn

include "disjunctive.mzn";

enum JOB;
enum TASK;
TASK: t_last = max(TASK);
array[JOB, TASK] of int: d;
int: total = sum(j in JOB, t in TASK)(d[j, t]);

array[JOB, TASK] of var 0..total: s;
var 0..total: makespan;

%% ── predicate: no_overlap ──────────────────────────────
%% บอกว่า 2 task ต้องไม่ overlap กัน
predicate no_overlap(var int: s1, int: d1, var int: s2, int: d2) =
  s1 + d1 <= s2 \/ s2 + d2 <= s1;

%% ── constraints ────────────────────────────────────────
%% 1. Precedence: task ตามลำดับใน job
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    s[j,t] + d[j,t] <= s[j, enum_next(TASK,t)]
  ) /\
  s[j, t_last] + d[j, t_last] <= makespan
);

%% 2. No-overlap ต่อ task (เปรียบเทียบทุกคู่ job)
%% วิธีนี้ใช้ predicate — อีกวิธีคือ disjunctive (ดูด้านล่าง)
constraint forall(t in TASK)(
  forall(j, k in JOB where j < k)(
    no_overlap(s[j,t], d[j,t], s[k,t], d[k,t])
  )
);

%% หมายเหตุ: สามารถแทนที่ด้วย disjunctive ซึ่งเร็วกว่า:
%% constraint forall(t in TASK)(
%%   disjunctive([s[j,t] | j in JOB], [d[j,t] | j in JOB])
%% );

solve minimize makespan;

output ["Makespan = ", show(makespan), "\n"] ++
[ show_int(3, s[j,t]) ++ if t=t_last then "\n" else " " endif
  | j in JOB, t in TASK ];
