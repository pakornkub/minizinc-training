%% ============================================================
%% HOMEWORK 2: วางแผนสั่งซื้อวัตถุดิบประจำเดือน
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 2
%% ============================================================
%%
%% โรงงานผลิตสินค้าหลายชนิด (PRODUCTS) และใช้วัตถุดิบหลายอย่าง (MATERIALS)
%% ต้องสั่งซื้อวัตถุดิบจาก supplier สองราย (ราคาต่างกัน) เพื่อรองรับแผนผลิต
%%
%% ข้อมูล:
%%   - แผนการผลิต: produce[p] หน่วย สำหรับสินค้า p
%%   - วัตถุดิบที่ต้องการ: need[p, m] หน่วย ต่อสินค้า p 1 ชิ้น
%%   - ราคาจาก supplier A และ B: price_a[m], price_b[m]
%%   - คำสั่งขั้นต่ำของแต่ละ supplier: min_order_a, min_order_b (มูลค่ารวม)
%%   - ความจุคลังสินค้าของแต่ละวัตถุดิบ: storage_cap[m]
%%
%% Objective: Minimize ต้นทุนวัตถุดิบรวม
%%
%% รันด้วย: minizinc homework2_starter.mzn homework2_data.dzn

enum PRODUCTS;
enum MATERIALS;

array[PRODUCTS] of int: produce;         % แผนผลิตแต่ละสินค้า (หน่วย)
array[PRODUCTS, MATERIALS] of int: need; % วัตถุดิบที่ต้องการต่อหน่วยสินค้า
array[MATERIALS] of int: price_a;        % ราคาจาก Supplier A (บาท/หน่วย)
array[MATERIALS] of int: price_b;        % ราคาจาก Supplier B (บาท/หน่วย)
int: min_order_a;    % มูลค่าสั่งขั้นต่ำ Supplier A (บาท)
int: min_order_b;    % มูลค่าสั่งขั้นต่ำ Supplier B (บาท)
array[MATERIALS] of int: storage_cap;    % ความจุคลัง (หน่วย)

%% ── ให้นักศึกษาเพิ่มส่วนต่อไปนี้ ──────────────────────────
%% Decision Variables:
%%   - จำนวนวัตถุดิบที่สั่งจาก A และ B สำหรับแต่ละ material
%% Constraints:
%%   - วัตถุดิบรวม (A+B) ต้องพอกับแผนผลิต
%%   - ไม่เกิน storage capacity
%%   - ถ้าสั่งจาก A ต้องสั่งขั้นต่ำ min_order_a (รวมทุก material)
%%   - ถ้าสั่งจาก B ต้องสั่งขั้นต่ำ min_order_b
%% Objective: minimize total cost
