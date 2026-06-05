%% ตัวอย่างที่ 1: Arrays และ Sets เบื้องต้น
%% อ้างอิง: docs.minizinc.dev - Arrays and Sets (Section 2.2.1)
%%
%% Arrays ช่วยให้เราจัดการตัวแปรหลายตัวได้พร้อมกัน

% --- Parameters ---
int: n = 5;                              % จำนวนสินค้า
array[1..n] of int: profit = [400, 300, 500, 200, 450];   % กำไรต่อหน่วย
array[1..n] of int: weight = [3, 2, 5, 1, 4];             % น้ำหนักต่อหน่วย
int: capacity = 10;                      % ความจุรวม

% --- Decision Variables ---
array[1..n] of var 0..5: produce;        % ผลิตสินค้าแต่ละชนิดกี่หน่วย

% --- Constraints ---
% น้ำหนักรวมต้องไม่เกิน capacity
constraint sum(i in 1..n)(weight[i] * produce[i]) <= capacity;

% --- Solve ---
solve maximize sum(i in 1..n)(profit[i] * produce[i]);

% --- Output ---
output [
  "=== แผนการผลิต ===\n",
  "สินค้า\tผลิต\tกำไร\n"
] ++
[ "  " ++ show(i) ++ "\t" ++ show(produce[i]) ++ "\t" ++ show(profit[i]*produce[i]) ++ "\n"
  | i in 1..n ] ++
[
  "รวม: กำไร = ", show(sum(i in 1..n)(profit[i]*produce[i])),
  ", น้ำหนัก = ", show(sum(i in 1..n)(weight[i]*produce[i])),
  "/", show(capacity), "\n"
];
