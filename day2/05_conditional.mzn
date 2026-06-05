%% ตัวอย่างที่ 5: Conditional Expressions และ bool2int
%% อ้างอิง: docs.minizinc.dev - Conditional Expressions (Section 2.2.3)
%%
%% if-then-else-endif และ bool2int มีประโยชน์มากในการ model จริง

int: n = 6;
array[1..n] of int: demand  = [10, 15, 8, 20, 12, 5];   % ความต้องการแต่ละวัน
array[1..n] of int: regular = [100, 100, 100, 100, 100, 100]; % ต้นทุนปกติ/หน่วย
array[1..n] of int: overtime_cost = [150, 150, 150, 150, 150, 150]; % ต้นทุน OT/หน่วย
int: regular_cap = 12;   % กำลังการผลิตปกติ/วัน

% --- Decision Variables ---
array[1..n] of var 0..30: produce_regular;  % ผลิตปกติ
array[1..n] of var 0..20: produce_overtime; % ผลิต OT

% --- Constraints ---
% ต้องผลิตให้พอกับ demand
constraint forall(d in 1..n)(
  produce_regular[d] + produce_overtime[d] >= demand[d]
);

% ผลิตปกติไม่เกิน capacity
constraint forall(d in 1..n)(
  produce_regular[d] <= regular_cap
);

% --- Objective ---
var int: total_cost = sum(d in 1..n)(
  regular[d] * produce_regular[d] + overtime_cost[d] * produce_overtime[d]
);

solve minimize total_cost;

% --- Output ---
output [
  "=== แผนการผลิต ===\n",
  "วัน\tปกติ\tOT\tDemand\tมี OT?\n"
] ++
[ show(d) ++ "\t" ++ show(produce_regular[d]) ++ "\t" ++
  show(produce_overtime[d]) ++ "\t" ++ show(demand[d]) ++ "\t" ++
  % if-then-else: แสดง "ใช่" ถ้ามี OT
  (if fix(produce_overtime[d]) > 0 then "ใช่" else "-" endif) ++ "\n"
  | d in 1..n ] ++
[
  "ต้นทุนรวม: ", show(total_cost), " บาท\n",
  "วันที่ใช้ OT: ", show(sum(d in 1..n)(bool2int(produce_overtime[d] > 0))), " วัน\n"
];
