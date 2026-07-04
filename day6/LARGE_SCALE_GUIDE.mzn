%% ============================================================
%% แนวทาง: MiniZinc กับข้อมูลขนาดใหญ่ (Large-Scale Guide)
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 6
%% ============================================================
%%
%% เมื่อโมเดลใช้เวลานานหรือ solve ไม่ได้ในเวลาจำกัด
%% ให้ลองเทคนิคต่อไปนี้ตามลำดับ:
%%
%% ─────────────────────────────────────────────────────────────
%% ระดับ 1: Quick Wins (ทำก่อนเสมอ — ไม่ต้องเขียน code เพิ่ม)
%% ─────────────────────────────────────────────────────────────
%%
%%   ✅ 1A. Tight Bounds (ดู 01_bounds_after.mzn)
%%      → var 0..1000000 ช้ากว่า var 0..100 มาก
%%      → คำนวณ bound จริงๆ แทน "เผื่อไว้"
%%
%%   ✅ 1B. Redundant Constraints (ดู 02_redundant_constraints.mzn)
%%      → เพิ่ม constraint ที่ "จริงอยู่แล้ว" แต่ช่วย solver prune
%%      → เช่น sum ≥ lower_bound จาก individual minima
%%
%%   ✅ 1C. ลดข้อมูล (Data Reduction)
%%      → ลบ option ที่เป็นไปไม่ได้ออกก่อน
%%      → เช่น supplier ที่แพงกว่าทุก supplier อื่นในทุกสินค้า → ไม่ต้องใส่
%%
%% ─────────────────────────────────────────────────────────────
%% ระดับ 2: Model Improvements (แก้โมเดล)
%% ─────────────────────────────────────────────────────────────
%%
%%   ✅ 2A. Symmetry Breaking (ดู 03_symmetry_breaking.mzn)
%%      → ตัด "คำตอบเดียวกันในรูปแบบต่างกัน" ออก
%%      → ตัวอย่าง: เรียงลำดับ workers/bins ตาม load
%%      → ลด search space ได้ n! เท่า
%%
%%   ✅ 2B. Global Constraints
%%      → ใช้ alldifferent, cumulative, bin_packing แทนเขียน constraints เอง
%%      → built-in มี propagation algorithm ที่ดีกว่า
%%
%% ─────────────────────────────────────────────────────────────
%% ระดับ 3: Search Strategy (บอก solver วิธีค้นหา)
%% ─────────────────────────────────────────────────────────────
%%
%%   ✅ 3A. Search Annotations (ดู 04_search_annotations.mzn)
%%
%%      Variable ordering:
%%        first_fail   — ตัวที่ domain เล็กสุด (แนะนำสำหรับ scheduling)
%%        dom_w_deg    — ตัวที่ involved ใน constraint ที่ขัดแย้งบ่อย
%%        largest      — ตัวที่ domain ใหญ่สุด
%%
%%      Value ordering:
%%        indomain_min  — ดีสำหรับ minimize
%%        indomain_max  — ดีสำหรับ maximize
%%        indomain_split — binary search ใน domain (ดีสำหรับ large domain)
%%
%%      Restart:
%%        restart_luby(n)       — proven ดีสำหรับปัญหาทั่วไป
%%        restart_geometric(f,n) — เพิ่มขึ้นแบบ geometric
%%
%% ─────────────────────────────────────────────────────────────
%% ระดับ 4: Problem Decomposition (แบ่งปัญหา)
%% ─────────────────────────────────────────────────────────────
%%
%%   ✅ 4A. Sequential Decomposition (ดู 05_decomposition.mzn)
%%      → แก้ "ระดับสูง" ก่อน → fix ผล → แก้ "รายละเอียด" ต่อ
%%      → ตัวอย่าง: โควต้าโรงงาน → แล้วค่อยแจกสินค้า
%%
%%   ✅ 4B. Rolling Horizon
%%      → ข้อมูล 365 วัน → แก้ทีละ 30 วัน แล้ว slide ไปเรื่อยๆ
%%      → เหมาะกับ production planning, inventory management
%%      → ใน MiniZinc: เปลี่ยน data file ทุกรอบ, fix ตัวแปรที่ตัดสินใจแล้ว
%%
%%   ✅ 4C. Column Generation (ขั้นสูง)
%%      → Generate "patterns" ที่มีประโยชน์แทนลองทุก combination
%%      → ใช้กับ cutting stock, vehicle routing ขนาดใหญ่
%%
%% ─────────────────────────────────────────────────────────────
%% ระดับ 5: Architecture (ระบบรอบข้าง)
%% ─────────────────────────────────────────────────────────────
%%
%%   ✅ 5A. Warm Start / Initial Solution
%%      → หาคำตอบ feasible ด้วย heuristic ก่อน
%%      → ส่งให้ MiniZinc เป็นจุดเริ่มต้น (ผ่าน --solution-hint)
%%      → solver ใช้เป็น upper bound → prune ได้มากขึ้น
%%
%%   ✅ 5B. Parallel Solving
%%      → minizinc --parallel N  (ใช้ N threads)
%%      → Gecode รองรับ parallel search โดยตรง
%%
%%   ✅ 5C. Precompute & Cache
%%      → ถ้าข้อมูลบางส่วนไม่เปลี่ยน → solve ครั้งเดียว save ผล
%%      → ใช้ MiniZinc เฉพาะส่วนที่เปลี่ยนแปลง
%%
%% ─────────────────────────────────────────────────────────────
%% Rule of Thumb: ลำดับที่แนะนำ
%% ─────────────────────────────────────────────────────────────
%%
%%   1. ตรวจ bounds ก่อนเสมอ
%%   2. เพิ่ม redundant constraints
%%   3. ใส่ symmetry breaking ถ้ามีสมมาตร
%%   4. ลอง search annotation: first_fail + indomain_min + restart_luby
%%   5. ถ้ายังช้า → decompose ปัญหา
%%   6. ถ้า production → พิจารณา rolling horizon
%%
%% ─────────────────────────────────────────────────────────────

solve satisfy;  %% ไฟล์นี้เป็น guide อย่างเดียว ไม่มี model จริง
output ["โปรดดูไฟล์ 01–05 สำหรับตัวอย่างแต่ละเทคนิค\n"];
