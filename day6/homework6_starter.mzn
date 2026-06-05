%% ============================================================
%% HOMEWORK 6: เลือก Supplier และวางแผนสัญญาจัดซื้อ
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 6
%% ============================================================
%%
%% บริษัทต้องเลือก supplier สำหรับวัตถุดิบ n_materials ชนิด
%% มี supplier n_suppliers ราย แต่ละรายไม่จำเป็นต้องมีทุกวัตถุดิบ
%%
%% ข้อมูล Supplier แต่ละราย:
%%   - unit_price[s, m]: ราคาต่อหน่วย (0 = ไม่มีวัตถุดิบนั้น)
%%   - max_supply[s, m]: ปริมาณสูงสุดที่จัดหาได้
%%   - quality[s, m]: คะแนนคุณภาพ 1–10 (0 = ไม่มี)
%%   - lead_time[s]: lead time (วัน) เหมือนกันทุก material ของ supplier นั้น
%%
%% ข้อกำหนด:
%%   - required[m]: ต้องซื้อวัตถุดิบแต่ละชนิดให้ครบ
%%   - max_lead_time: lead time ยาวสุดที่ยอมรับได้
%%   - min_quality[m]: คะแนนคุณภาพขั้นต่ำของวัตถุดิบแต่ละชนิด
%%   - max_suppliers: จำนวน supplier สูงสุดที่จะทำสัญญาด้วย (ลดความซับซ้อน)
%%
%% Objective: Minimize ต้นทุนรวม พร้อมใช้ tight bounds และ
%%            redundant constraints เพื่อให้ solver ทำงานเร็ว
%%
%% รันด้วย: minizinc homework6_starter.mzn homework6_data.dzn

int: n_materials;
int: n_suppliers;
int: max_lead_time;    % วัน
int: max_suppliers;    % จำนวน supplier สูงสุด

array[1..n_materials] of int: required;       % ปริมาณที่ต้องการ
array[1..n_materials] of int: min_quality;    % คุณภาพขั้นต่ำ

array[1..n_suppliers, 1..n_materials] of int: unit_price;   % 0 = ไม่มี
array[1..n_suppliers, 1..n_materials] of int: max_supply;
array[1..n_suppliers, 1..n_materials] of int: quality;      % 0 = ไม่มี
array[1..n_suppliers] of int: lead_time;

%% ── ให้นักศึกษาเพิ่มส่วนต่อไปนี้ ──────────────────────────
%% Decision Variables:
%%   - order[s, m]: จำนวนที่สั่งจาก supplier s สำหรับ material m
%%   - active[s]: 0/1 ว่าทำสัญญากับ supplier s หรือไม่
%% Constraints:
%%   - ปริมาณรวมครบตาม required
%%   - ไม่เกิน max_supply
%%   - คุณภาพ weighted average >= min_quality (hint: ใช้ sum weighted)
%%   - ถ้าสั่งจาก s แล้ว lead_time[s] <= max_lead_time
%%   - จำนวน active supplier <= max_suppliers
%%   - ถ้า order[s,m] > 0 ต้อง active[s] = 1
%% Effective Modelling:
%%   - คำนวณ upper bound ที่แน่นสำหรับ order[s,m]
%%   - เพิ่ม redundant lower bound constraint ให้ solver
%% Objective: minimize total cost
