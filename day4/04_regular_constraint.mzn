%% ตัวอย่างที่ 4: regular constraint — บังคับ shift pattern ด้วย DFA
%% อ้างอิง: docs.minizinc.dev - Regular Constraint (2.3.1.4)
%%
%% regular(sequence, transition_table, start_state, accepting_states)
%%
%% กฎที่ต้องการ:
%%   - ห้ามทำกะดึก 3 คืนติดต่อกัน
%%   - ในทุก 4 วัน ต้องมีวันหยุดอย่างน้อย 1 วัน
%%   (เหมือนตัวอย่าง nurse rostering ใน tutorial)

include "regular.mzn";

enum NURSE;
enum DAY;
int: req_day;
int: req_night;
int: min_night;

enum SHIFT = { d, n, o };  % d=day, n=night, o=off

%% DFA สำหรับ pattern ที่ถูกต้อง
%% States: S1=start, S2=หลัง d, S3=หลัง n1, S4=หลัง d/n (มี 2 ต่อเนื่อง),
%%         S5=หลัง n2, S6=หลัง d/n ต่อเนื่อง 3 วัน
enum STATE = { S1, S2, S3, S4, S5, S6 };

array[STATE, SHIFT] of opt STATE: t =
  [|      d:  n:  o:
   | S1:  S2, S3, S1
   | S2:  S4, S4, S1
   | S3:  S4, S5, S1
   | S4:  S6, S6, S1
   | S5:  S6, <>, S1   % ห้ามทำดึก 3 คืนติด (<> = illegal)
   | S6:  <>, <>, S1 |]; % ต้องหยุดหลัง 3 วันติด

array[NURSE, DAY] of var SHIFT: roster;

%% Demand per day
constraint forall(day in DAY)(
  sum(n in NURSE)(roster[n,day] = d) = req_day /\
  sum(n in NURSE)(roster[n,day] = n) = req_night
);

%% Pattern ต้องตาม DFA
constraint forall(nurse in NURSE)(
  regular([roster[nurse,day] | day in DAY], t, S1, STATE) /\
  sum(day in DAY)(roster[nurse,day] = n) >= min_night
);

solve satisfy;

output [
  "=== ตารางกะพยาบาล ===\n"
] ++
[ show(nurse) ++ ": " ++
  concat([ show(fix(roster[nurse,day])) ++ " " | day in DAY]) ++ "\n"
  | nurse in NURSE ];
