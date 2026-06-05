%% ===================================================
%% WORKSHOP 4B: Employee Shift Scheduling — โรงงาน 3 กะ
%% ===================================================
%%
%% โจทย์: พนักงาน 10 คน วางแผน 14 วัน
%%   กะ: เช้า (M), บ่าย (E), ดึก (N), หยุด (O)
%%
%% Demand ทุกวัน:
%%   เช้า >= 4 คน, บ่าย >= 3 คน, ดึก >= 2 คน
%%
%% กฎ:
%%   1) ห้ามทำดึกติดกัน 3 คืน
%%   2) หลังกะดึกต้องหยุดอย่างน้อย 1 วัน
%%   3) แต่ละคนทำงานไม่เกิน 6 วันติดต่อกัน
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
%%   5) ท้าทาย: เพิ่ม regular constraint สำหรับ rule ที่ซับซ้อน

include "regular.mzn";

int: n_emp  = 10;
int: n_days = 14;

set of int: EMP  = 1..n_emp;
set of int: DAYS = 1..n_days;

enum SHIFT = { M, E, N, O };  % morning, evening, night, off

array[EMP, DAYS] of var SHIFT: roster;

int: req_M = 4;  % เช้า
int: req_E = 3;  % บ่าย
int: req_N = 2;  % ดึก

%% TODO 1: Demand — ทุกวันต้องมีพนักงานพอ
% constraint forall(d in DAYS)(
%   sum(e in EMP)(roster[e,d] = M) >= req_M /\
%   sum(e in EMP)(roster[e,d] = E) >= req_E /\
%   sum(e in EMP)(roster[e,d] = N) >= req_N
% );

%% TODO 2: หลังกะดึกต้องหยุด (ไม่ใช่วันสุดท้าย)
% constraint forall(e in EMP, d in 1..n_days-1)(
%   roster[e,d] = N -> roster[e,d+1] = O
% );

%% TODO 3: ทำงานไม่เกิน 6 วันติด
%% hint: sum(d in d0..d0+6)(roster[e,d] != O) <= 6
%% หรือใช้ regular constraint

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
