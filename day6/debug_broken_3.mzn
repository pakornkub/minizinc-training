%% ===================================================
%% DEBUGGING CHALLENGE 3: ผลลัพธ์ผิด (Wrong Result)
%% ===================================================
%%
%% โจทย์: Production Planning — โมเดล solve ได้ แต่ผลไม่สมเหตุสมผล
%% ภารกิจ: หาว่า constraint ไหนผิดหรือขาดหาย

enum PRODUCTS = { Alpha, Beta, Gamma };
enum RESOURCES = { Labor, Material };

array[PRODUCTS] of int: profit = [800, 1200, 600];
array[RESOURCES] of int: capacity = [100, 150];

%% ❌ consumption matrix กำหนดผิด (แถว/คอลัมน์สลับกัน)
array[PRODUCTS, RESOURCES] of int: consumption =
  [| 3, 5      % Alpha: 3 Labor, 5 Material  ← ถูก
   | 5, 2      % Beta:  5 Labor, 2 Material
   | 2, 8 |];  % Gamma: 2 Labor, 8 Material

array[PRODUCTS] of var 0..100: produce;

%% ❌ constraint เปรียบเทียบ index ผิด
constraint forall(r in RESOURCES)(
  sum(p in PRODUCTS)(consumption[p,r] * produce[p]) <= capacity[r]
);

%% ❌ ลืม assert ตรวจ data
%% ถ้าใส่ค่า consumption ผิดจะรู้ได้ยาก

solve maximize sum(p in PRODUCTS)(profit[p] * produce[p]);

output [
  "=== Production Plan ===\n",
  "Alpha = ", show(produce[Alpha]), "\n",
  "Beta  = ", show(produce[Beta]),  "\n",
  "Gamma = ", show(produce[Gamma]), "\n",
  "กำไรรวม = ", show(sum(p in PRODUCTS)(profit[p]*produce[p])), "\n",
  "--- ตรวจสอบ resource usage ---\n",
  "Labor:    ", show(sum(p in PRODUCTS)(consumption[p,Labor]*produce[p])), "/100\n",
  "Material: ", show(sum(p in PRODUCTS)(consumption[p,Material]*produce[p])), "/150\n",
  "ถ้า Labor หรือ Material เกิน capacity แสดงว่า constraint ผิด!\n"
];

%% HINT: ผลลัพธ์ที่ได้อาจดูสมเหตุสมผล แต่ลองตรวจ:
%% 1. คำนวณ resource usage มือ แล้วเทียบกับ output
%% 2. เพิ่ม assert เพื่อตรวจ data
%% 3. ลอง solve satisfy ด้วยค่า produce เล็กๆ แล้วตรวจ constraint
