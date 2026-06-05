%% ตัวอย่าง 1B: Variable Bounds — แบบ GOOD (bound แน่น)
%% อ้างอิง: docs.minizinc.dev - Variable Bounds (2.7.1)
%%
%% หลักการ:
%%   lower bound = เร็วที่สุดที่เป็นไปได้
%%   upper bound = ช้าที่สุดที่ยอมรับได้ (ไม่เกินความจำเป็น)

include "cumulative.mzn";

int: n_jobs = 5;
array[1..n_jobs] of int: dur     = [8, 5, 12, 3, 7];
array[1..n_jobs] of int: workers = [2, 3,  1, 4, 2];
int: n_workers = 5;

%% ✅ คำนวณ bound ที่แน่น
int: total_dur = sum(j in 1..n_jobs)(dur[j]);          % worst case: ทุกงานทำต่อเนื่อง
int: min_makespan = max(j in 1..n_jobs)(dur[j]);       % best case: ทุกงานทำพร้อมกัน
int: max_start = total_dur - min(j in 1..n_jobs)(dur[j]); % start สูงสุด

array[1..n_jobs] of var 0..max_start: start;  % ✅ bound แน่น
var min_makespan..total_dur: makespan;         % ✅ bound ทั้ง lower และ upper

constraint cumulative(start, dur, workers, n_workers);
constraint forall(j in 1..n_jobs)(start[j] + dur[j] <= makespan);

solve minimize makespan;

output [
  "=== Tight Bounds Example ===\n",
  "total_dur = ", show(total_dur), " (upper bound)\n",
  "min_makespan = ", show(min_makespan), " (lower bound)\n",
  "Actual Makespan = ", show(makespan), "\n"
];
