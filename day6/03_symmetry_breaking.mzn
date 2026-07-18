%% ============================================================
%% ตัวอย่าง 3: Symmetry Breaking — รับมือข้อมูลขนาดใหญ่ (เทคนิคที่ 1)
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 6
%% ============================================================
%%
%% ปัญหา: จัดสินค้าลงกล่อง (Bin Packing)
%%   - มีสินค้า n ชิ้น น้ำหนักต่างกัน
%%   - กล่องแต่ละกล่องรับน้ำหนักได้สูงสุด capacity
%%   - เป้าหมาย: ใช้กล่องให้น้อยที่สุด
%%
%% ปัญหาความสมมาตร (Symmetry Problem):
%%   ถ้ากล่อง A = [สินค้า1, สินค้า2] และ กล่อง B = [สินค้า3]
%%   กับ กล่อง A = [สินค้า3] และ กล่อง B = [สินค้า1, สินค้า2]
%%   เป็นคำตอบ "เดียวกัน" แต่ solver ต้องค้นหาซ้ำ 2 ครั้ง!
%%
%%   ยิ่งข้อมูลใหญ่ → ความสมมาตรยิ่งมาก → ช้ามาก
%%
%% วิธีแก้: เพิ่ม symmetry breaking constraints
%%   "กล่องที่ใช้ก่อนต้องเต็มกว่ากล่องถัดไป"
%%   → ตัด symmetric solutions ทิ้ง → เหลือ search space น้อยลงมาก
%%
%% รันด้วย: minizinc 03_symmetry_breaking.mzn
%% ============================================================

include "bin_packing_capa.mzn";

int: n_items = 12;          % สินค้า 12 ชิ้น
int: n_bins  = 6;           % กล่องสูงสุด 6 กล่อง (upper bound)
int: capacity = 100;        % ความจุกล่องละ 100 กก.

set of int: ITEMS = 1..n_items;
set of int: BINS  = 1..n_bins;

array[BINS] of int: bin_capacity = [100, 100, 100, 100, 100, 100];
array[ITEMS] of int: weight = [28, 35, 12, 47, 22, 38, 15, 42, 19, 31, 25, 44];

%% ── Decision Variables ──────────────────────────────────────
array[ITEMS] of var BINS: bin;         % สินค้าชิ้น i อยู่ในกล่องไหน
array[BINS]  of var 0..capacity: load; % น้ำหนักรวมในกล่อง b
var 1..n_bins: n_used;                 % จำนวนกล่องที่ใช้จริง

%% ── Basic Constraints ───────────────────────────────────────
constraint bin_packing_capa(bin_capacity, bin, weight);

constraint n_used = max(bin);

%% ── ❌ ถ้าไม่มี Symmetry Breaking ────────────────────────────
%% solver ต้องลองทุก permutation ของกล่อง
%% n_bins! = 720 วิธีที่เทียบเท่ากัน → ช้ามาก

%% ── ✅ Symmetry Breaking: กล่องเรียงตาม load จากมากไปน้อย ─
%% "กล่องหมายเลขน้อยต้องหนักกว่ากล่องหมายเลขมาก"
%% ตัด permutations ทิ้ง → solver ไม่ต้องลองซ้ำ
constraint forall(b in 1..n_bins-1)(load[b] >= load[b+1]);

%% ── ✅ Symmetry Breaking เพิ่มเติม: Value symmetry ──────────
%% สินค้าชิ้นแรกต้องอยู่ในกล่อง 1 เสมอ
%% (เพราะ "สินค้า 1 อยู่กล่อง 1" และ "สินค้า 1 อยู่กล่อง 2" เป็นคำตอบเดียวกัน)
constraint bin[1] = 1;

%% ── Objective ───────────────────────────────────────────────
solve minimize n_used;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== Bin Packing พร้อม Symmetry Breaking ===\n\n",
  "สินค้า\t\tน้ำหนัก\tกล่อง\n",
  "───────────────────────────────\n"
] ++
[ "สินค้า " ++ show(i) ++ "\t" ++ show(weight[i]) ++ " กก.\t→ กล่อง " ++ show(bin[i]) ++ "\n"
  | i in ITEMS ] ++
[
  "\n─── สรุปกล่อง ───\n"
] ++
[ if fix(load[b]) > 0 then
    "กล่อง " ++ show(b) ++ ": " ++ show(fix(load[b])) ++ "/" ++ show(capacity) ++ " กก.\n"
  else "" endif
  | b in BINS ] ++
[
  "\n✅ ใช้กล่องทั้งหมด: ", show(n_used), " กล่อง\n",
  "\n💡 Symmetry Breaking ช่วยลด search space ลงได้ถึง n_bins! = ",
  show(n_bins), "! เท่า\n"
];
