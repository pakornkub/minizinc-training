%% ตัวอย่างที่ 2: forall, sum และ List Comprehensions
%% อ้างอิง: docs.minizinc.dev - Aggregation functions
%%
%% forall = บังคับ constraint ทุกตัว
%% sum    = รวมค่าในอาร์เรย์
%% [expr | generator] = list comprehension

int: n_machines = 3;
int: n_jobs = 4;

% เวลาที่งาน j ใช้บนเครื่อง m (ชั่วโมง)
array[1..n_jobs, 1..n_machines] of int: processing_time =
  [| 2, 3, 1   % งาน 1
   | 4, 1, 2   % งาน 2
   | 1, 5, 3   % งาน 3
   | 3, 2, 4 |];  % งาน 4

% capacity ของแต่ละเครื่อง (ชั่วโมง/วัน)
array[1..n_machines] of int: machine_capacity = [8, 10, 9];

% --- Decision Variables: แต่ละงานทำหรือไม่ทำ ---
array[1..n_jobs] of var 0..1: selected;  % 1 = ทำ, 0 = ไม่ทำ

% กำไรของแต่ละงาน
array[1..n_jobs] of int: job_profit = [500, 800, 600, 700];

% --- Constraints ---
% forall: ทุกเครื่องจักรต้องไม่ overload
constraint forall(m in 1..n_machines)(
  sum(j in 1..n_jobs)(processing_time[j,m] * selected[j]) <= machine_capacity[m]
);

% --- Solve ---
solve maximize sum(j in 1..n_jobs)(job_profit[j] * selected[j]);

% --- Output ---
output [
  "=== งานที่เลือก ===\n"
] ++
[ if fix(selected[j]) = 1 then "  งาน " ++ show(j) ++ ": กำไร " ++ show(job_profit[j]) ++ " บาท\n"
  else "" endif
  | j in 1..n_jobs ] ++
[
  "กำไรรวม: ", show(sum(j in 1..n_jobs)(job_profit[j] * selected[j])), " บาท\n",
  "เครื่องจักร 1 ใช้ ", show(sum(j in 1..n_jobs)(processing_time[j,1]*selected[j])),
  "/", show(machine_capacity[1]), " ชม.\n"
];
