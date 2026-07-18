%% ===================================================
%% DEBUGGING CHALLENGE 2: โมเดลที่ช้ามาก (Slow Solver)
%% ===================================================
%%
%% โจทย์: Job Shop 6 jobs × 4 tasks — ใช้เวลานานมาก
%% ภารกิจ: เพิ่ม bounds ที่แน่นขึ้นและ symmetry breaking

include "disjunctive.mzn";

int: n_jobs  = 6;
int: n_tasks = 4;
array[1..n_jobs, 1..n_tasks] of int: d =
  [| 8, 5, 3, 7
   | 6, 9, 4, 2
   | 3, 7, 8, 5
   | 5, 4, 6, 9
   | 9, 3, 5, 4
   | 4, 6, 7, 3 |];

%% ❌ bound กว้างเกิน
%% int: total_bad = 200;  % hardcode ค่าสูงโดยไม่คำนวณ
int: total = sum(j in 1..n_jobs, t in 1..n_tasks)(d[j, t]);

int: lb = max(j in 1..n_jobs)(sum(t in 1..n_tasks)(d[j, t]));

array[1..n_jobs, 1..n_tasks] of var 0..total: s;  % ❌
var lb..total: makespan;  % ❌

constraint forall(j in 1..n_jobs)(
  forall(t in 1..n_tasks-1)(s[j,t]+d[j,t] <= s[j,t+1]) /\
  s[j,n_tasks]+d[j,n_tasks] <= makespan
);
constraint forall(t in 1..n_tasks)(
  disjunctive([s[j,t] | j in 1..n_jobs], [d[j,t] | j in 1..n_jobs])
);

solve minimize makespan;
output ["Makespan = ", show(makespan), "\n"];

%% HINT: แก้โดย
%% 1. คำนวณ total = sum(j,t)(d[j,t]) แทน hardcode 200
%% 2. lower bound ของ makespan = max(j)(sum(t)(d[j,t]))
%% 3. เพิ่ม s[j,1] >= 0 เป็น lower bound ชัดเจน
%% 4. ลอง solve satisfy ก่อนตรวจว่า model ถูก แล้วค่อย minimize
