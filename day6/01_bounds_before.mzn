%% ตัวอย่าง 1A: Variable Bounds — แบบ BAD (bound กว้างเกิน)
%% Solver ต้องค้นหาใน space ที่ใหญ่กว่าจำเป็น

include "cumulative.mzn";

int: n_jobs = 5;
array[1..n_jobs] of int: dur     = [8, 5, 12, 3, 7];
array[1..n_jobs] of int: workers = [2, 3,  1, 4, 2];
int: n_workers = 5;

%% ❌ bound กว้างเกิน: solver ต้องค้นหาใน 0..999
array[1..n_jobs] of var 0..999: start;
var 0..999: makespan;

constraint cumulative(start, dur, workers, n_workers);
constraint forall(j in 1..n_jobs)(start[j] + dur[j] <= makespan);

solve minimize makespan;
output ["Makespan = ", show(makespan), "\n"];
