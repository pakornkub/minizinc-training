%% ============================================================
%% ตัวอย่างที่ 7 (บ่าย): การเลือก Supplier พร้อม Volume Discount
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 2
%% ============================================================
%%
%% โจทย์:
%%   โรงงานต้องสั่งซื้อวัตถุดิบ 3 ชนิด (Steel, Plastic, Rubber)
%%   มี Supplier 2 ราย (SupA, SupB) ราคาต่างกัน
%%
%%   ระบบ Volume Discount:
%%     - ถ้าสั่งวัตถุดิบจาก Supplier รายใดรวมมูลค่า >= 100,000 บาท
%%       ได้รับส่วนลด 10% (ราคาลดลง 10%)
%%
%%   เงื่อนไข:
%%     - วัตถุดิบรวม (SupA + SupB) ต้องพอกับความต้องการผลิต
%%     - แต่ละ Supplier มีปริมาณจำกัด (stock_cap)
%%
%%   เป้าหมาย: Minimize ต้นทุนรวมหลังหักส่วนลด
%%
%% จุดเด่น: ใช้ enum + if-then-else + bool2int สำหรับ discount logic
%%
%% รันด้วย: minizinc 07_supplier_discount.mzn
%% ============================================================

enum MATERIALS = { Steel, Plastic, Rubber };
enum SUPPLIERS = { SupA, SupB };

%% ความต้องการวัตถุดิบ (หน่วย)
array[MATERIALS] of int: demand = [300, 500, 200];

%% ราคาปกติ (บาท/หน่วย) ก่อนส่วนลด
array[SUPPLIERS, MATERIALS] of int: unit_price =
  [| Steel: Plastic: Rubber:
   | SupA:   200,    50,     150
   | SupB:   180,    55,     140 |];

%% ปริมาณสูงสุดที่แต่ละ Supplier ส่งได้ (หน่วย)
array[SUPPLIERS, MATERIALS] of int: stock_cap =
  [| Steel: Plastic: Rubber:
   | SupA:   250,    400,    200
   | SupB:   300,    600,    200 |];

%% เกณฑ์ได้รับส่วนลด (มูลค่ารวมจาก Supplier นั้น)
int: discount_threshold = 100000;
int: discount_pct = 10;   % ส่วนลด 10%

%% ── Decision Variables ──────────────────────────────────────
array[SUPPLIERS, MATERIALS] of var 0..600: order;   % จำนวนสั่งซื้อ
array[SUPPLIERS] of var bool: get_discount;          % ได้รับส่วนลดหรือไม่

%% ── Constraints ─────────────────────────────────────────────

%% วัตถุดิบรวมต้องพอกับความต้องการ
constraint forall(m in MATERIALS)(
  sum(s in SUPPLIERS)(order[s, m]) >= demand[m]
);

%% ไม่เกิน stock ของแต่ละ Supplier
constraint forall(s in SUPPLIERS, m in MATERIALS)(
  order[s, m] <= stock_cap[s, m]
);

%% Discount logic: get_discount[s] = true ถ้ายอดรวมก่อนลดถึงเกณฑ์
constraint forall(s in SUPPLIERS)(
  get_discount[s] <->
    sum(m in MATERIALS)(unit_price[s, m] * order[s, m]) >= discount_threshold
);

%% ── Objective ───────────────────────────────────────────────
%% ถ้าได้ discount → คูณ (100 - 10) / 100 = 0.9
%% ใช้ integer arithmetic: คูณ 90 แล้วหาร 100
var int: total_cost = sum(s in SUPPLIERS)(
  let {
    var int: gross = sum(m in MATERIALS)(unit_price[s, m] * order[s, m]);
    var int: rate  = if get_discount[s] then 100 - discount_pct else 100 endif
  } in
  gross * rate div 100
);

solve minimize total_cost;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== แผนการสั่งซื้อวัตถุดิบ ===\n\n",
  "─── Supplier A ───\n",
  "  Steel:   ", show(order[SupA, Steel]),   " หน่วย\n",
  "  Plastic: ", show(order[SupA, Plastic]), " หน่วย\n",
  "  Rubber:  ", show(order[SupA, Rubber]),  " หน่วย\n",
  "  ยอดก่อนลด: ", show(sum(m in MATERIALS)(unit_price[SupA,m]*order[SupA,m])), " บาท",
  if fix(get_discount[SupA]) then "  → ได้ส่วนลด 10%! ✓\n" else "  (ยังไม่ถึงเกณฑ์)\n" endif,

  "\n─── Supplier B ───\n",
  "  Steel:   ", show(order[SupB, Steel]),   " หน่วย\n",
  "  Plastic: ", show(order[SupB, Plastic]), " หน่วย\n",
  "  Rubber:  ", show(order[SupB, Rubber]),  " หน่วย\n",
  "  ยอดก่อนลด: ", show(sum(m in MATERIALS)(unit_price[SupB,m]*order[SupB,m])), " บาท",
  if fix(get_discount[SupB]) then "  → ได้ส่วนลด 10%! ✓\n" else "  (ยังไม่ถึงเกณฑ์)\n" endif,

  "\n══════════════════════════════\n",
  "ต้นทุนรวมสุทธิ: ", show(total_cost), " บาท\n"
];
