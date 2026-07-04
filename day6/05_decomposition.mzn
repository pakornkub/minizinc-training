%% ============================================================
%% ตัวอย่าง 5: Problem Decomposition — รับมือข้อมูลขนาดใหญ่ (เทคนิคที่ 3)
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 6
%% ============================================================
%%
%% แนวคิด: "แบ่งปัญหาใหญ่ให้เป็นปัญหาย่อยหลายๆ อัน"
%%
%% ปัญหาใหญ่ที่ solve ตรงๆ ยาก:
%%   วางแผนผลิต 4 โรงงาน × 12 สินค้า × 30 วัน = 1,440 ตัวแปร
%%
%% กลยุทธ์ Decomposition:
%%   ขั้น 1: Relaxed Problem — แก้ปัญหา "หลัก" ก่อน (ไม่สนรายละเอียด)
%%             → หา "โควต้า" รวมของแต่ละโรงงาน
%%   ขั้น 2: Subproblem — แก้รายละเอียดของแต่ละโรงงานแยกกัน
%%             → แจกจ่ายโควต้าลงสู่ระดับสินค้า/วัน
%%
%% ใน MiniZinc: แสดงโดยใช้ "ขั้น 1 ก่อน" และ fix ผลลัพธ์เป็น input ขั้น 2
%%
%% ตัวอย่างนี้แสดง Lagrangian Relaxation เบื้องต้น:
%%   → เพิ่ม penalty สำหรับ constraint ที่ "ยาก" เพื่อทำให้ problem tractable
%%
%% รันด้วย: minizinc 05_decomposition.mzn
%% ============================================================

%% ────────────────────────────────────────────────────────────
%% ปัญหา: จัดสรรกำลังการผลิตให้ 3 โรงงาน
%%   แต่ละโรงงานผลิตสินค้าได้หลายชนิด
%%   demand รวมต้องครบ, ต้นทุนรวมต้องต่ำสุด
%%   + ต้องไม่เกิน capacity แต่ละโรงงาน
%% ────────────────────────────────────────────────────────────

int: n_factories = 3;
int: n_products  = 4;

set of int: F = 1..n_factories;
set of int: P = 1..n_products;

%% ชื่อ (สำหรับ output)
array[F] of string: fname = ["โรงงาน A (เหนือ)", "โรงงาน B (กลาง)", "โรงงาน C (ใต้)"];
array[P] of string: pname = ["สินค้า X1", "สินค้า X2", "สินค้า Y1", "สินค้า Y2"];

%% ความต้องการรวม (หน่วย/เดือน)
array[P] of int: demand = [500, 300, 400, 250];

%% กำลังการผลิตสูงสุดของแต่ละโรงงานต่อสินค้า (หน่วย/เดือน)
array[F, P] of int: cap =
  [| 300, 200, 250, 150   %% โรงงาน A
   | 250, 150, 300, 200   %% โรงงาน B
   | 200, 250, 200, 100   %% โรงงาน C
   |];

%% ต้นทุนการผลิต (บาท/หน่วย)
array[F, P] of int: cost =
  [|  80, 120,  90, 110   %% โรงงาน A
   |  70, 100,  80, 130   %% โรงงาน B
   |  90, 110, 100,  95   %% โรงงาน C
   |];

%% กำลังรวมของแต่ละโรงงาน (ใช้ร่วมกันทุกสินค้า)
array[F] of int: total_cap = [600, 550, 500];

%% ── ✅ Decomposition Step 1: Factory-level allocation ────────
%% แก้ว่าแต่ละโรงงานควรผลิตสินค้ารวมเท่าไหร่
%% (ยังไม่ลงรายละเอียดว่าสินค้าไหนเท่าไหร่)

array[F] of var 0..1650: factory_total;  %% โควต้ารวมแต่ละโรงงาน

%% โควต้ารวมทุกโรงงาน = demand รวมทุกสินค้า
constraint sum(f in F)(factory_total[f]) = sum(p in P)(demand[p]);

%% แต่ละโรงงานไม่เกิน total capacity
constraint forall(f in F)(factory_total[f] <= total_cap[f]);

%% ── ✅ Decomposition Step 2: Product-level detail ─────────────
%% แก้ว่าแต่ละโรงงานควรผลิตสินค้าไหนเท่าไหร่

array[F, P] of var 0..300: produce;

%% รวมของแต่ละโรงงานต้องตรงกับโควต้า (link step 1 → step 2)
constraint forall(f in F)(
  sum(p in P)(produce[f, p]) = factory_total[f]
);

%% ไม่เกิน cap รายสินค้า
constraint forall(f in F, p in P)(
  produce[f, p] <= cap[f, p]
);

%% demand รวมจากทุกโรงงานต้องพอกับความต้องการ
constraint forall(p in P)(
  sum(f in F)(produce[f, p]) >= demand[p]
);

%% ── Objective ───────────────────────────────────────────────
var int: total_cost = sum(f in F, p in P)(cost[f, p] * produce[f, p]);

%% ✅ Search: จัด factory allocation ก่อน แล้ว product detail
solve :: seq_search([
  int_search(factory_total, first_fail, indomain_min),
  int_search([produce[f,p] | f in F, p in P], first_fail, indomain_min)
])
minimize total_cost;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== แผนผลิต (Decomposition) ===\n\n"
] ++
[ fname[f] ++ " (โควต้ารวม: " ++ show(factory_total[f]) ++ "/" ++ show(total_cap[f]) ++ ")\n" ++
  concat([ "  " ++ pname[p] ++ ": " ++ show(produce[f,p]) ++ " หน่วย " ++
           "× ฿" ++ show(cost[f,p]) ++ " = ฿" ++ show(cost[f,p]*produce[f,p]) ++ "\n"
           | p in P ]) ++
  "  รวมโรงงาน: ฿" ++ show(sum(p in P)(cost[f,p]*produce[f,p])) ++ "\n\n"
  | f in F ] ++
[
  "══════════════════════════════════\n",
  "ต้นทุนรวมทั้งระบบ: ฿", show(total_cost), "\n\n",
  "💡 Decomposition ช่วยอะไร?\n",
  "   → แก้ Step 1 (3 ตัวแปร) ก่อน → จำกัด Step 2 (12 ตัวแปร)\n",
  "   → ถ้ามี 10 โรงงาน × 50 สินค้า × 30 วัน:\n",
  "     แบบตรง = 15,000 ตัวแปร  |  Decompose = 10 + (50×30) = 1,510 ตัวแปร/รอบ\n"
];
