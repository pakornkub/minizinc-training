%% ตัวอย่างที่ 3: Production Planning แบบ Generic
%% อ้างอิง: docs.minizinc.dev - Listing 2.2.2 (prod-planning.mzn)
%%
%% รันด้วย: minizinc 03_production_generic.mzn 03_factory_data.dzn
%%
%% จุดเด่น: โมเดลเดิมใช้ได้กับข้อมูลโรงงานทุกแห่ง
%%           เพิ่ม/ลดสินค้าและทรัพยากรได้โดยแก้แค่ data file

% --- Enum Types (กำหนดใน data file) ---
enum PRODUCTS;    % ชนิดสินค้า
enum RESOURCES;   % ชนิดทรัพยากร

% --- Parameters ---
array[PRODUCTS]            of int: profit;       % กำไร/หน่วย
array[RESOURCES]           of int: capacity;     % ทรัพยากรที่มี
array[PRODUCTS, RESOURCES] of int: consumption;  % ทรัพยากรที่ใช้ต่อหน่วยสินค้า

% คำนวณ upper bound สำหรับแต่ละสินค้า
int: max_produce = max(p in PRODUCTS)(
  min(r in RESOURCES where consumption[p,r] > 0)(
    capacity[r] div consumption[p,r]
  )
);

% --- Decision Variables ---
array[PRODUCTS] of var 0..max_produce: produce;

% --- Constraints ---
% ทุก resource ต้องไม่เกิน capacity
constraint forall(r in RESOURCES)(
  sum(p in PRODUCTS)(consumption[p,r] * produce[p]) <= capacity[r]
);

% --- Solve ---
solve maximize sum(p in PRODUCTS)(profit[p] * produce[p]);

% --- Output ---
output
  [ show(p) ++ " = " ++ show(produce[p]) ++ " หน่วย\n" | p in PRODUCTS ] ++
  [ "กำไรรวม = " ++ show(sum(p in PRODUCTS)(profit[p]*produce[p])) ++ " บาท\n" ] ++
  [ "--- การใช้ทรัพยากร ---\n" ] ++
  [ show(r) ++ ": " ++ show(sum(p in PRODUCTS)(consumption[p,r]*produce[p]))
    ++ "/" ++ show(capacity[r]) ++ "\n" | r in RESOURCES ];
