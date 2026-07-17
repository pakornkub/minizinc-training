%% ================================================================
%% DYNAMIC_GUIDE.mzn
%% รับมือการเปลี่ยนแปลงระหว่างแผน (Dynamic Re-optimization)
%% ================================================================
%%
%% ปัญหาจริงไม่หยุดนิ่ง — สิ่งที่เกิดได้กลางแผน:
%%   - ยอด order เพิ่ม / ลดกะทันหัน
%%   - เครื่องจักรขัดข้อง
%%   - พนักงานลาป่วย
%%   - วัตถุดิบมาช้า
%%   - ลูกค้า VIP ขอให้เร่ง
%%
%% คำถาม: MiniZinc ช่วยรับมือได้อย่างไร?
%%
%% ================================================================
%%
%% TECHNIQUE 1: Re-optimize from Current State  [→ 06_reoptimize.mzn]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   1. อัปเดตข้อมูล (เครื่องที่เสีย, demand ใหม่)
%%   2. รัน solver ใหม่ด้วยข้อมูลที่อัปเดต
%%   3. ถ้ามีงานที่เริ่มไปแล้ว: fix start time ของงานนั้น
%%
%% เหมาะกับ: เหตุการณ์ไม่คาดฝัน ที่ต้องการ plan ใหม่ทั้งหมด
%% ข้อดี: ได้ plan ที่ optimal ที่สุดสำหรับสถานการณ์ใหม่
%% ข้อเสีย: plan อาจเปลี่ยนมาก → สับสนใน shop floor
%%
%% ตัวอย่าง:
%%   bool: M_B_available = false;   %% แค่เปลี่ยนบรรทัดเดียว แล้ว re-run
%%
%% ================================================================
%%
%% TECHNIQUE 2: Penalize Changing the Plan  [→ 07_penalize_changes.mzn]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   เพิ่ม penalty ใน objective สำหรับทุกการเปลี่ยนแปลงจาก plan เดิม
%%   Objective = makespan + alpha * disruption
%%
%%   disruption = sum(j in JOB, t in TASK)(
%%     bool2int(machine[j,t] != orig_machine[j,t])
%%   )
%%
%% เหมาะกับ: ต้องการความ "ต่อเนื่อง" — ลดการสื่อสาร / re-training
%% ปรับ alpha:
%%   alpha = 0  → optimize ใหม่โดยไม่สนใจ plan เดิม
%%   alpha สูง  → รักษา plan เดิมเป็นหลัก (ยอม makespan บวมขึ้น)
%%
%% เพิ่มเติม: ลงโทษ start time ที่เปลี่ยนด้วยก็ได้
%%   penalty += beta * sum(j,t)(|start[j,t] - orig_start[j,t]|)
%%
%% ================================================================
%%
%% TECHNIQUE 3: Rolling Horizon Optimization  [→ 08_rolling_horizon.mzn]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   แทนที่จะ optimize ทั้ง horizon (เช่น 30 วัน) พร้อมกัน
%%   → ตัด horizon เป็น window (เช่น 3-5 วัน) แล้ว solve ทีละ window
%%   → เมื่อ window ปัจจุบันเสร็จ เลื่อนไปข้างหน้า (slide)
%%
%%   solve [D1..D3] → fix → รับ demand จริง D4 → solve [D4..D6] → ...
%%
%% เหมาะกับ: demand ไม่แน่นอนในระยะไกล / ปัญหา long horizon
%% ข้อดี: solve เร็วกว่า, รับ demand ใหม่ได้ทุก window
%% ข้อเสีย: อาจไม่ global optimal (greedy ในแต่ละ window)
%%
%% Tip: ทำ window ซ้อนกัน (overlap) เพื่อ lookahead
%%   solve [D1..D5] แต่ fix แค่ D1..D3 → slide ไป D3..D7 ฯลฯ
%%
%% ================================================================
%%
%% TECHNIQUE 4: Add Slack Variables  [→ 09_slack_variables.mzn]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   เพิ่ม "slack" = buffer capacity ที่ใช้ได้ในกรณีฉุกเฉิน
%%   (overtime, extra shift, outsourcing)
%%
%%   capacity_actual[m, p] = normal_cap[m] + slack[m, p]
%%   Objective = regular_cost * regular + overtime_cost * slack
%%
%% เหมาะกับ: demand spike ที่รู้ล่วงหน้า / รับ order พิเศษ
%% ข้อดี:
%%   - ไม่ต้อง reject order เพราะ capacity เต็ม
%%   - เห็นชัดว่าต้นทุน overtime เป็นเท่าไหร่
%%   - ตอบได้ว่า "รับ order ได้ไหม ราคาเท่าไหร่"
%%
%% ================================================================
%%
%% TECHNIQUE 5: Scenario-based Planning  [→ 10_scenario_planning.mzn]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   กำหนด scenario ที่คาดการณ์ได้ (พร้อม probability)
%%   หาแผน "here-and-now" ที่ minimize expected cost ทุก scenario
%%
%%   min  sum_s prob[s] * cost(plan, scenario_s)
%%   s.t. แผนเดียวกันใช้กับทุก scenario (คือตัดสินใจก่อนรู้ scenario)
%%
%% เหมาะกับ: ต้องสั่งวัตถุดิบ / จ้างคนล่วงหน้า ก่อนรู้ demand จริง
%% เพิ่มเติม: Robust optimization — minimize worst-case แทน expected
%%   แทน: sum_s prob[s] * cost(...)
%%   ด้วย: max(s in SCENARIO)(cost(plan, scenario_s))
%%
%% ================================================================
%%
%% TECHNIQUE 6: Warm Starting  [ขึ้นกับ solver]
%% ─────────────────────────────────────────────────────────────────
%%
%% วิธี:
%%   ให้ solution เดิมเป็น "initial hint" แก่ solver
%%   → solver ใช้ hint เป็นจุดเริ่มต้น ไม่ต้อง explore จาก scratch
%%
%% Gecode (MiniZinc default):
%%   ใช้ search annotation: `:: int_search([...], first_fail, indomain_median)`
%%   แล้ว fix variable ที่รู้ค่าด้วย constraint ชั่วคราว:
%%   constraint machine[OrderA, Cut] = M_A;   %% hint
%%
%% Solver-specific flags:
%%   OR-Tools: `--cp_model_presolve_np=...` (hint via FlatZinc)
%%   Gurobi/CPLEX: MIPStart / Advanced Start
%%
%% ใน MiniZinc ทำแบบง่าย:
%%   1. run ปัญหาเล็ก → ได้ solution
%%   2. add constraint fix solution บางส่วน
%%   3. run ปัญหาใหญ่ → solver เริ่มจากจุดที่ดีกว่า
%%
%%   %% ตัวอย่าง warm start hint:
%%   constraint machine[OrderA, Cut] = M_A;
%%   constraint start[OrderA, Cut]   = 0;
%%
%% ================================================================
%%
%% สรุป: เลือก Technique ไหน?
%%
%%   สถานการณ์                          | Technique ที่แนะนำ
%%   ────────────────────────────────── | ───────────────────────
%%   เครื่องเสีย / demand spike ฉุกเฉิน  | 1 (Re-optimize)
%%   ต้องการ plan เปลี่ยนน้อย             | 2 (Penalize changes)
%%   Horizon ยาว / demand ไม่แน่นอนไกล  | 3 (Rolling horizon)
%%   รับ order พิเศษ / overtime ได้        | 4 (Slack variables)
%%   ตัดสินใจล่วงหน้า ใต้ uncertainty    | 5 (Scenario planning)
%%   ปัญหาใหญ่ / solve ซ้ำบ่อย           | 6 (Warm start)
%%
%% ในทางปฏิบัติ: ใช้หลาย technique ผสมกัน
%%   เช่น Rolling Horizon + Penalize Changes + Slack Variables
%%
%% ================================================================

%% (ไฟล์นี้เป็น guide — ไม่มี model ที่ run ได้ตรง ๆ)
%% รันไฟล์ตัวอย่างแต่ละ technique แทน:
%%   minizinc 06_reoptimize.mzn
%%   minizinc 07_penalize_changes.mzn
%%   minizinc 08_rolling_horizon.mzn
%%   minizinc 09_slack_variables.mzn
%%   minizinc 10_scenario_planning.mzn
