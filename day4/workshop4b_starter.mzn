%% ===================================================
%% WORKSHOP 4B: Employee Shift Scheduling — โรงงาน 3 กะ
%% ===================================================
%%
%% โจทย์: พนักงาน 8 คน วางแผน 7 วัน
%%   กะ: เช้า (M), บ่าย (E), ดึก (N), หยุด (O)
%%
%% Demand ทุกวัน:
%%   เช้า >= 3 คน, บ่าย >= 2 คน, ดึก >= 1 คน
%%
%% กฎ:
%%   1) หลังกะดึกต้องหยุดอย่างน้อย 1 วัน
%%   2) แต่ละคนทำงานไม่เกิน 6 วันติดต่อกัน
%%
%% Objective: minimize จำนวนกะดึกรวม
%%
%% รันด้วย: minizinc workshop4b_starter.mzn workshop4b_data.dzn
%%
%% ขั้นตอน:
%%   1) เพิ่ม demand constraint
%%   2) เพิ่ม rule: หลังดึกต้องหยุด
%%   3) เพิ่ม rule: ไม่เกิน 6 วันทำงานติด
%%   4) solve minimize total_nights
%%   5) ท้าทาย: เพิ่ม constraint ห้ามทำกะดึก 3 คืนติด

include "regular.mzn";

int: n_emp  = 8;
int: n_days = 7;

set of int: EMP  = 1..n_emp;
set of int: DAYS = 1..n_days;

enum SHIFT = { M, E, N, O };  % morning, evening, night, off

array[EMP, DAYS] of var SHIFT: roster;

int: req_M = 3;  % เช้า
int: req_E = 2;  % บ่าย
int: req_N = 1;  % ดึก

%% TODO 1: Demand — ทุกวันต้องมีพนักงานพอ
% constraint ...

%% TODO 2: หลังกะดึกต้องหยุด (ไม่ใช่วันสุดท้าย)
% constraint ...

%% TODO 3: ทำงานไม่เกิน 6 วันติด
% constraint ...

%% TODO 4: solve minimize total_nights
var int: total_nights = sum(e in EMP, d in DAYS)(bool2int(roster[e,d] = N));
solve satisfy;

output [
  "   "
] ++ [ show_int(2,d) ++ " " | d in DAYS ] ++ ["\n"] ++
[ "E" ++ show(e) ++ " " ++
  concat([if fix(roster[e,d])=M then "M "
          elseif fix(roster[e,d])=E then "E "
          elseif fix(roster[e,d])=N then "N "
          else "- " endif | d in DAYS]) ++ "\n"
  | e in EMP ] ++
["กะดึกรวม: ", show(total_nights), "\n"];
