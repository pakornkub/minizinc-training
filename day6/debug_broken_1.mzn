%% ===================================================
%% DEBUGGING CHALLENGE 1: โมเดลที่ UNSATISFIABLE
%% ===================================================
%%
%% โจทย์: Maintenance Scheduling — แต่โมเดลนี้ให้ UNSATISFIABLE
%% ภารกิจ: หาสาเหตุและแก้ไข

include "cumulative.mzn";

int: n = 4;
array[1..n] of int: dur     = [5, 4, 3, 6];
array[1..n] of int: workers = [3, 2, 4, 2];

%% ค่าต่อไปนี้มีปัญหา — หาดูว่าผิดตรงไหน
int: total_workers = 4;
int: deadline      = 8;   %% <-- น่าสงสัย!

array[1..n] of var 0..deadline: start;
var 0..deadline: end_time;

constraint cumulative(start, dur, workers, total_workers);
constraint forall(j in 1..n)(start[j] + dur[j] <= end_time);
constraint end_time <= deadline;

solve minimize end_time;

output ["end_time = ", show(end_time), "\n"];

%% HINT: คำนวณ minimum makespan ก่อน
%% sum(workers_needed * dur) / total_workers = minimum time
%% ถ้า deadline < minimum possible time → UNSATISFIABLE
%%
%% แก้: ลอง deadline = 10, 12, 15 แล้วดูว่า satisfy ที่เท่าไร?
