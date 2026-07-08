%% ตัวอย่างที่ 3: Employee Rostering พื้นฐาน
%% อ้างอิง: docs.minizinc.dev - Nurse Rostering
%%
%% โจทย์: จัดตารางกะพนักงาน 3 กะ ให้ครบ demand และยุติธรรม
%%
%% รันด้วย: minizinc 03_rostering_basic.mzn 03_rostering_data.dzn

enum EMPLOYEE;
enum DAY;
enum SHIFT = { morning, evening, night, off };

%% Parameters
array[DAY] of int: req_morning;  % จำนวนพนักงานที่ต้องการกะเช้า
array[DAY] of int: req_evening;  % กะบ่าย
array[DAY] of int: req_night;    % กะดึก
int: max_night_per_period;       % กะดึกสูงสุดต่อคนต่อช่วงวางแผน

%% Decision Variables
array[EMPLOYEE, DAY] of var SHIFT: roster;

%% ── Constraints ────────────────────────────────────────

%% 1. Demand: ทุกวันต้องมีคนครบ
constraint forall(d in DAY)(
  sum(e in EMPLOYEE)(roster[e,d] = morning) >= req_morning[d] /\
  sum(e in EMPLOYEE)(roster[e,d] = evening) >= req_evening[d] /\
  sum(e in EMPLOYEE)(roster[e,d] = night)   >= req_night[d]
);

%% 2. Fairness: แต่ละคนทำกะดึกไม่เกิน max_night_per_period
constraint forall(e in EMPLOYEE)(
  sum(d in DAY)(roster[e,d] = night) <= max_night_per_period
);

%% 3. Rest after night: หลังกะดึกต้องหยุด (ถ้าไม่ใช่วันสุดท้าย)
constraint forall(e in EMPLOYEE, d in DAY where d < max(DAY))(
  roster[e,d] = night -> roster[e, enum_next(DAY,d)] = off
);

%% Objective: minimize กะดึกของทุกคน (เพื่อความเป็นธรรม)
var int: night_bound = max(e in EMPLOYEE)(sum(d in DAY)(
  bool2int(roster[e,d] = night))
);

solve minimize night_bound;

output [
  "=== ตารางกะ ===\n",
  "         "
] ++
[ show(d) ++ " " | d in DAY ] ++ ["\n"] ++
[ show(e) ++ ": " ++
  concat([ if fix(roster[e,d]) = morning then "M "
           elseif fix(roster[e,d]) = evening then "E "
           elseif fix(roster[e,d]) = night then "N "
           else "- " endif
           | d in DAY ]) ++ "\n"
  | e in EMPLOYEE ] ++
["กะดึกมากที่สุด: ", show(night_bound), "\n"];
