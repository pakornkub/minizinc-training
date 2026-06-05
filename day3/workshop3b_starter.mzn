%% ===================================================
%% WORKSHOP 3B: Job Shop Scheduling — ไลน์การผลิต
%% ===================================================
%%
%% โจทย์: โรงงานมี 4 ออร์เดอร์ (A,B,C,D) แต่ละออร์เดอร์
%%         ผ่าน 3 สถานี (S1,S2,S3) ตามลำดับเสมอ
%%
%% ระยะเวลา (นาที): A=[10,8,12], B=[7,15,5], C=[12,6,10], D=[9,11,8]
%%
%% กฎ:
%%   - แต่ละออร์เดอร์ต้องทำ S1→S2→S3 ตามลำดับ
%%   - แต่ละสถานีรับออร์เดอร์ได้ทีละ 1 ออร์เดอร์
%%
%% ขั้นตอน:
%%   1) เพิ่ม precedence constraint (S1 ก่อน S2 ก่อน S3)
%%   2) เพิ่ม disjunctive constraint (แต่ละสถานีทีละ 1)
%%   3) solve minimize makespan
%%   4) อ่านผลลัพธ์ — วาด Gantt chart บนกระดาษ
%%   5) ท้าทาย: เพิ่ม order D ต้องเริ่ม S1 ไม่ก่อนนาทีที่ 5

include "disjunctive.mzn";

int: n_jobs  = 4;
int: n_tasks = 3;  % S1, S2, S3

% duration[job, station]
array[1..n_jobs, 1..n_tasks] of int: dur =
  [| 10,  8, 12   % A
   |  7, 15,  5   % B
   | 12,  6, 10   % C
   |  9, 11,  8|];% D

int: total = sum(j in 1..n_jobs, t in 1..n_tasks)(dur[j, t]);

array[1..n_jobs, 1..n_tasks] of var 0..total: s;
var 0..total: makespan;

% TODO 1: Precedence — S1 ก่อน S2 ก่อน S3 ในทุก job
% constraint ...

% TODO 2: Disjunctive — แต่ละสถานีทำออร์เดอร์ได้ทีละ 1
% constraint ...

% TODO 3: solve minimize makespan
solve satisfy;

array[1..n_jobs] of string: job_names = ["A","B","C","D"];
output [
  "Makespan = ", show(makespan), "\n",
  "Job\tS1\tS2\tS3\n"
] ++
[ job_names[j] ++ "\t" ++
  show(s[j,1]) ++ "\t" ++ show(s[j,2]) ++ "\t" ++ show(s[j,3]) ++ "\n"
  | j in 1..n_jobs ];
