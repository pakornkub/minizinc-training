%% ============================================================
%% HOMEWORK 3: ตารางงานก่อสร้างโรงงานขยาย
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 3
%% ============================================================
%%
%% โรงงานกำลังขยายพื้นที่ โดยมีงานก่อสร้างหลายงานที่ต้องทำ
%% แต่ละงานต้องการแรงงาน (คน) และเครน (เครื่อง) พร้อมกัน
%%
%% ข้อมูล:
%%   - งาน n_tasks งาน แต่ละงานมี duration, workers_needed, cranes_needed
%%   - มีแรงงานรวม total_workers คน และเครน total_cranes เครื่อง
%%   - บาง task ต้องรอ task อื่นเสร็จก่อน (precedence):
%%       must_finish_before[i] = list of tasks ที่ต้องเสร็จก่อน task i
%%
%% Objective: Minimize เวลาเสร็จงานทั้งหมด (makespan)
%%
%% รันด้วย: minizinc homework3_starter.mzn homework3_data.dzn

include "cumulative.mzn";

int: n_tasks;
int: total_workers;
int: total_cranes;

array[1..n_tasks] of int: duration;        % ระยะเวลาแต่ละงาน (วัน)
array[1..n_tasks] of int: workers_needed;  % แรงงานที่ต้องการ
array[1..n_tasks] of int: cranes_needed;   % เครนที่ต้องการ

%% precedence[i] = set ของ tasks ที่ต้องเสร็จก่อนจะเริ่ม task i
array[1..n_tasks] of set of int: must_wait_for;

%% ── ให้นักศึกษาเพิ่มส่วนต่อไปนี้ ──────────────────────────
%% Decision Variables:
%%   - start time ของแต่ละงาน
int: total_time = sum(t in 1..n_tasks)(duration[t]);
array[1..n_tasks] of var 0..total_time: start;
%%   - makespan (เวลาเสร็จรวม)
var 0..total_time: makespan;

%% Constraints:
%%   - cumulative สำหรับแรงงาน
constraint cumulative(start, duration, workers_needed, total_workers);
%%   - cumulative สำหรับเครน
constraint cumulative(start, duration, cranes_needed, total_cranes);
%%   - precedence: task i ต้องรอทุก task ใน must_wait_for[i] เสร็จก่อน
constraint forall(t in 1..n_tasks)(
  forall(p in must_wait_for[t])(
    start[p] + duration[p] <= start[t]
  )
);

%% Objective: minimize makespan
constraint forall(t in 1..n_tasks)(
  start[t] + duration[t] <= makespan
);
solve minimize makespan;

output [
  "===== ตารางงานก่อสร้าง =====\n"
] ++
[
  "Task \(t): start=\(start[t]), end=\(start[t]+duration[t]), " ++
  "duration=\(duration[t]), workers=\(workers_needed[t]), cranes=\(cranes_needed[t])\n"
  | t in 1..n_tasks
] ++
[
  "\nMakespan (เวลาเสร็จงานทั้งหมด) = \(makespan) วัน\n"
];