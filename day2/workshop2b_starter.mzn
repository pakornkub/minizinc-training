%% ===================================================
%% WORKSHOP 2B: ตารางการผลิต Multi-Product Multi-Line
%% ===================================================
%%
%% โจทย์:
%%   โรงงานมีไลน์การผลิต 3 ไลน์ และสินค้า 5 ชนิด
%%   แต่ละสินค้าต้องผ่านไลน์ที่กำหนดเท่านั้น
%%   แต่ละไลน์ผลิตได้ไม่เกิน capacity/วัน
%%   Minimize ต้นทุนการผลิตรวม
%%
%% รันด้วย: minizinc workshop2b_starter.mzn workshop2b_data.dzn
%%
%% ขั้นตอน:
%%   1) เพิ่ม constraint: สินค้าแต่ละชนิดต้องอยู่ใน allowed_lines
%%   2) เพิ่ม constraint: แต่ละไลน์ไม่เกิน line_capacity
%%   3) กำหนด solve minimize total_cost
%%   4) ท้าทาย: เพิ่ม constraint ห้ามใช้ไลน์ 2 และ 3 พร้อมกัน

enum PRODUCTS;
enum LINES;

array[PRODUCTS] of int: demand;          % ต้องผลิตเท่าไร
array[PRODUCTS, LINES] of int: unit_cost; % ต้นทุน/หน่วย บนแต่ละไลน์
array[PRODUCTS] of set of LINES: allowed; % ไลน์ที่ใช้ได้สำหรับสินค้านั้น
array[LINES] of int: line_capacity;       % ความจุสูงสุด/วัน (หน่วย)

% --- Decision Variables ---
% produce[p, l] = จำนวนสินค้า p ที่ผลิตบนไลน์ l
array[PRODUCTS, LINES] of var 0..1000: produce;

% --- Constraints ---
% TODO 1: แต่ละสินค้าต้องผลิตรวมให้ครบ demand
% constraint ...;

% TODO 2: ถ้าไลน์ไม่ได้รับอนุญาต ห้ามใช้
% constraint forall(p in PRODUCTS, l in LINES)(
%   ???
% );

% TODO 3: แต่ละไลน์รวมสินค้าทุกชนิดไม่เกิน capacity
% constraint forall(l in LINES)(
%   ???
% );

% ต้นทุนรวม
var int: total_cost = sum(p in PRODUCTS, l in LINES)(unit_cost[p,l] * produce[p,l]);

% TODO 4: solve minimize total_cost
solve satisfy;  % แก้เป็น minimize

output
  [ "=== แผนการผลิต ===\n" ] ++
  [ show(p) ++ " บน " ++ show(l) ++ ": " ++ show(produce[p,l]) ++ " หน่วย\n"
    | p in PRODUCTS, l in LINES where fix(produce[p,l]) > 0 ] ++
  [ "ต้นทุนรวม = " ++ show(total_cost) ++ " บาท\n" ];
