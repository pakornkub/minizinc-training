%% ===================================================
%% WORKSHOP 2A: Production Planning แบบ Generic
%% ===================================================
%%
%% โจทย์: สร้างโมเดลที่รองรับจำนวนสินค้าและทรัพยากรที่กำหนดใน data file
%%
%% รันด้วย: minizinc workshop2a_starter.mzn workshop2a_data.dzn
%%
%% ขั้นตอน:
%%   1) กรอก constraint ที่ขาดหายไป (แทนที่ TODO)
%%   2) รันและตรวจสอบผลกับ workshop2a_data.dzn
%%   3) ลองเปลี่ยนเป็น workshop2a_data2.dzn (6 สินค้า) — โมเดลเดิมทำงานได้เลย!
%%   4) ท้าทาย: เพิ่ม constraint ว่าสินค้า A ต้องผลิตอย่างน้อย 3 หน่วย

% --- Enum Types (กำหนดใน data file) ---
enum PRODUCTS;
enum RESOURCES;

% --- Parameters ---
array[PRODUCTS]            of int: profit;
array[RESOURCES]           of int: capacity;
array[PRODUCTS, RESOURCES] of int: consumption;

% Upper bound สำหรับ decision variables
int: max_produce = max(p in PRODUCTS)(
  min(r in RESOURCES where consumption[p,r] > 0)(
    capacity[r] div consumption[p,r]
  )
);

% --- Decision Variables ---
array[PRODUCTS] of var 0..max_produce: produce;

% --- Constraints ---
% TODO: เพิ่ม constraint ว่าทุก resource ต้องไม่เกิน capacity
% Hint: ใช้ forall(r in RESOURCES)( sum(...) <= ... )

% constraint forall(r in RESOURCES)(
%   ???
% );

% --- Solve ---
% TODO: เพิ่ม solve item เพื่อ maximize กำไรรวม
% solve maximize ...;

% --- Output ---
output
  [ show(p) ++ " = " ++ show(produce[p]) ++ " หน่วย\n" | p in PRODUCTS ] ++
  [ "กำไรรวม = " ++ show(sum(p in PRODUCTS)(profit[p]*produce[p])) ++ " บาท\n" ];
