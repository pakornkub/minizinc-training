%% ตัวอย่างที่ 4: regular constraint — บังคับ shift pattern ด้วย DFA
%% อ้างอิง: docs.minizinc.dev - Regular Constraint (2.3.1.4)
%%
%% regular(sequence, transition_table, start_state, accepting_states)
%%
%% กฎที่ต้องการ:
%%   - ห้ามทำกะดึก 2 คืนติดต่อกัน
%%   - ในทุก 4 วัน ต้องมีวันหยุดอย่างน้อย 1 วัน
%%   (เหมือนตัวอย่าง nurse rostering ใน tutorial)

include "regular.mzn";

enum NURSE;
enum DAY;
int: req_day;
int: req_night;
int: min_night;

enum SHIFT = { D, N, O };  % d=day, n=night, o=off

%% DFA สำหรับ pattern ที่ถูกต้อง
%% States: S1=start, S2=หลัง d, S3=หลัง n1, S4=หลัง d/n (มี 2 ต่อเนื่อง),
%%         S5=หลัง n2, S6=หลัง d/n ต่อเนื่อง 3 วัน
enum STATE = { S0, S1, S2, S3, S4, S5, S6 };

array[STATE, SHIFT] of opt STATE: t =
  [|      D:  N:  O:
   | S0:  S1, S4, S0
   | S1:  S2, S5, S0
   | S2:  S3, S6, S0
   | S3:  <>, <>, S0
   | S4:  S2, <>, S0
   | S5:  S3, <>, S0 
   | S6:  <>, <>, S0 |]; % ต้องหยุดหลัง 3 วันติด

array[NURSE, DAY] of var SHIFT: roster;

%% Demand per day
constraint forall(day in DAY)(
  sum(n in NURSE)(bool2int(roster[n,day] = D)) >= req_day /\
  sum(n in NURSE)(bool2int(roster[n,day] = N)) >= req_night
);

%% Pattern ต้องตาม DFA (deterministic finite automata)
constraint forall(nurse in NURSE)(
  regular([roster[nurse,day] | day in DAY], t, S0, STATE) /\
  sum(day in DAY)(bool2int(roster[nurse,day] = N)) >= min_night
);

%% ถ้าไม่ใช่ regular constraint
%%   - ห้ามทำกะดึก 2 คืนติดต่อกัน (ถ้าวันนี้ทำกะดึก พรุ่งนี้ห้ามทำกะดึก
% constraint forall(n in NURSE)(
%   forall(d in DAY where d < max(DAY))(
%     roster[n, d] = N -> roster[n, enum_next(DAY, d)] != N
%   )
% );

%%   - ในทุก 4 วัน ต้องมีวันหยุดอย่างน้อย 1 วัน
% constraint forall(n in NURSE)(
%   forall(i in 1..card(DAY)-3)(
%     exists(k in 0..3)(
%       roster[n, to_enum(DAY, i+k)] = O
%     )
%   )
% );

solve satisfy;

output [
  "=== ตารางกะพยาบาล ===\n"
] ++
[ show(nurse) ++ ": " ++
  concat([ show(fix(roster[nurse,day])) ++ " " | day in DAY]) ++ "\n"
  | nurse in NURSE ];
