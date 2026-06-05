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
%%   - makespan (เวลาเสร็จรวม)
%% Constraints:
%%   - cumulative สำหรับแรงงาน
%%   - cumulative สำหรับเครน
%%   - precedence: task i ต้องรอทุก task ใน must_wait_for[i] เสร็จก่อน
%% Objective: minimize makespan
