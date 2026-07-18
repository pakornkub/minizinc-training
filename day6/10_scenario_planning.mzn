%% ================================================================
%% 10_scenario_planning.mzn — Scenario-based Planning
%% ================================================================
%%
%% แนวคิด: ตัดสินใจ "ตอนนี้" แต่ demand สัปดาห์หน้ายังไม่แน่
%%   → สร้าง scenario ที่เป็นไปได้ แล้วหาแผนที่ minimize ต้นทุนเฉลี่ย
%%
%% Scenario ที่คาดการณ์:
%%   S1 (Normal,   prob=50%): demand เหมือนสัปดาห์ปกติ
%%   S2 (Surge,    prob=30%): demand สูงขึ้น 40% (หลัง promo campaign)
%%   S3 (Decline,  prob=20%): demand ต่ำลง 25% (ช่วง low season)
%%
%% ตัดสินใจ: สั่งวัตถุดิบ / วางแผนผลิตเท่าไหร่ (ก่อนรู้ scenario)
%%
%% ผลลัพธ์ตาม scenario:
%%   ผลิตมากเกิน → เหลือสต็อก (holding cost)
%%   ผลิตน้อยเกิน → ขาย/ส่งพลาด (stockout penalty = เสียลูกค้า)
%%
%% ทดลอง:
%%   ลด stockout_cost → plan ผลิตน้อยลง (รับ stockout มากขึ้น)
%%   เพิ่ม prob[2] (Surge) → plan ผลิตมากขึ้นเพื่อรองรับ surge
%%
%% ================================================================

int: n_product  = 3;
int: n_scenario = 3;

set of int: PRODUCT  = 1..n_product;
set of int: SCENARIO = 1..n_scenario;

%% ── Scenarios ─────────────────────────────────────────────────────

%% ความน่าจะเป็นของแต่ละ scenario (รวม = 100)
array[SCENARIO] of int: prob = [50, 30, 20];

%% Demand ในแต่ละ scenario
array[PRODUCT, SCENARIO] of int: demand = array2d(PRODUCT, SCENARIO, [
%%   S1  S2   S3
    100, 140,  75,   %% Product 1 (flagship)
     60,  84,  45,   %% Product 2
     40,  56,  30,   %% Product 3
]);

%% ── ต้นทุน ────────────────────────────────────────────────────────

array[PRODUCT] of int: unit_cost     = [10,  15,  20];   %% ต้นทุนผลิต/หน่วย
array[PRODUCT] of int: holding_cost  = [ 2,   3,   4];   %% ต้นทุนเก็บสต็อก/หน่วย
array[PRODUCT] of int: stockout_cost = [30,  40,  60];   %% ค่าเสียโอกาส/หน่วย

%% กำลังผลิตรวม (ทุก product รวมกัน)
int: max_total_prod = 350;

%% ── Variables ───────────────────────────────────────────────────

%% ตัดสินใจก่อนรู้ scenario
array[PRODUCT] of var 0..200: produce;

%% ผลลัพธ์หลังรู้ scenario (derived)
array[PRODUCT, SCENARIO] of var 0..300: leftover;   %% เหลือสต็อก
array[PRODUCT, SCENARIO] of var 0..300: unmet;      %% ขายพลาด

%% ── Constraints ─────────────────────────────────────────────────

%% กำลังผลิตรวม
constraint sum(p in PRODUCT)(produce[p]) <= max_total_prod;

%% Inventory balance ในแต่ละ scenario
%% leftover - unmet = produce - demand (รับทั้ง + และ -)
constraint forall(p in PRODUCT, s in SCENARIO)(
  leftover[p, s] - unmet[p, s] = produce[p] - demand[p, s] /\
  leftover[p, s] >= 0 /\
  unmet[p, s]    >= 0
);

%% (Optimizer จะ minimize ทั้ง leftover และ unmet → ทำให้แค่ตัวใดตัวหนึ่ง > 0)

%% ── Objective: Expected Cost ─────────────────────────────────────

var int: expected_cost = (
  sum(s in SCENARIO)(
    prob[s] * (
      sum(p in PRODUCT)(
        unit_cost[p]    * produce[p]      +
        holding_cost[p] * leftover[p, s]  +
        stockout_cost[p] * unmet[p, s]
      )
    )
  )
) div 100;   %% หาร 100 เพราะ prob รวม = 100 (เหมือน weighted average)

solve minimize expected_cost;

%% ── Output ───────────────────────────────────────────────────────

output [
  "=================================================\n",
  "Scenario Planning (3 scenarios)\n",
  "=================================================\n",
  "Expected cost = ", show(expected_cost), " บาท\n\n",
  "=== แผนการผลิต (ตัดสินใจก่อนรู้ scenario) ===\n"
] ++
[ "  Product " ++ show(p) ++ ": ผลิต " ++ show(produce[p]) ++ " หน่วย\n"
  | p in PRODUCT ] ++
[ "\n=== ผลตาม scenario ===\n" ] ++
[ "Scenario " ++ show(s) ++ " (prob=" ++ show(prob[s]) ++ "%):\n" ++
  concat([
    "  P" ++ show(p) ++
    ": demand=" ++ show(demand[p,s]) ++
    "  leftover=" ++ show(leftover[p,s]) ++
    "  unmet=" ++ show(unmet[p,s]) ++
    (if fix(unmet[p,s]) > 0 then "  *** STOCKOUT ***" else "" endif) ++ "\n"
    | p in PRODUCT
  ])
  | s in SCENARIO ] ++
[ "\n=== Cost breakdown per scenario ===\n" ] ++
[ "  S" ++ show(s) ++ " (" ++ show(prob[s]) ++ "%): " ++
  show(sum(p in PRODUCT)(
    unit_cost[p]     * produce[p] +
    holding_cost[p]  * leftover[p,s] +
    stockout_cost[p] * unmet[p,s]
  )) ++ " บาท\n"
  | s in SCENARIO ];
