%% ================================================================
%% 08_rolling_horizon.mzn — Rolling Horizon Optimization
%% ================================================================
%%
%% แนวคิด: แทนที่จะ optimize ทั้ง horizon พร้อมกัน
%%   → solve ทีละ "window" แล้วเลื่อนไปข้างหน้า
%%
%% ขั้นตอน:
%%   1. solve window [1..3]  → fix ผลของ Day 1-3
%%   2. รับ demand จริง Day 4 (อาจต่างจากที่คาด)
%%   3. solve window [4..6]  → ใช้ initial_stock จาก Day 3
%%   4. ทำซ้ำ...
%%
%% ข้อดี:
%%   - แก้เร็วกว่า (ปัญหาเล็กลง)
%%   - รับมือ demand ที่เปลี่ยนกลางแผนได้ดีกว่า
%%   - ไม่ต้อง commit กับ plan ไกล ๆ ที่ยังไม่แน่นอน
%%
%% ทดลอง: เปลี่ยน horizon_start = 1 → ดู window แรก
%%         เปลี่ยน horizon_start = 4 → ดู window สอง (ใช้ stock จาก window 1)
%%
%% ================================================================

int: n_period  = 6;
int: n_product = 3;
int: win_size  = 3;     %% ขนาด window

set of int: PERIOD  = 1..n_period;
set of int: PRODUCT = 1..n_product;

%% *** เปลี่ยนตรงนี้เพื่อสลับ window ***
int: horizon_start = 4;    %% 1 = window แรก, 4 = window สอง
int: horizon_end   = min(horizon_start + win_size - 1, n_period);
set of int: WINDOW = horizon_start..horizon_end;

%% ── Demand ────────────────────────────────────────────────────────
%% demand[product, period] — ตัวเลขจริงที่ทราบในแต่ละ window
array[PRODUCT, PERIOD] of int: demand = array2d(PRODUCT, PERIOD, [
%%  D1   D2   D3   D4   D5   D6
    10,  12,  15,  20,  14,  11,   %% Product 1 (spike ที่ D4 เพราะ order พิเศษ!)
     8,   8,  10,   6,  12,  10,   %% Product 2
     5,   7,   9,  11,   8,   6,   %% Product 3
]);

%% กำลังผลิตสูงสุดต่อ product ต่อ period
array[PRODUCT] of int: capacity = [25, 18, 15];

%% ต้นทุนเก็บสต็อก (ต่อหน่วยต่อ period)
array[PRODUCT] of int: holding_cost = [2, 3, 4];

%% ── Stock เริ่มต้นของ window ─────────────────────────────────────
%% Window 1: เริ่มจาก 0
%% Window 2: ใช้ stock ที่เหลือจาก window 1 (ได้จากการ run window 1)
array[PRODUCT] of int: initial_stock =
  if horizon_start = 1 then [0, 0, 0]
  else [3, 0, 2]   %% *** ใส่ค่า stock จริงที่ได้จาก window ก่อนหน้า ***
  endif;

%% ── Variables ───────────────────────────────────────────────────

array[PRODUCT, WINDOW] of var 0..200: produce;
array[PRODUCT, WINDOW] of var 0..100: stock;

%% ── Constraints ─────────────────────────────────────────────────

%% ผลิตไม่เกิน capacity
constraint forall(p in PRODUCT, d in WINDOW)(
  produce[p, d] <= capacity[p]
);

%% Inventory balance — period แรกของ window ใช้ initial_stock
constraint forall(p in PRODUCT)(
  stock[p, horizon_start] = initial_stock[p] + produce[p, horizon_start] - demand[p, horizon_start]
);

%% Inventory balance — periods ถัดไปใน window
constraint forall(p in PRODUCT, d in horizon_start+1..horizon_end)(
  stock[p, d] = stock[p, d-1] + produce[p, d] - demand[p, d]
);

%% ห้าม stockout (stock ติดลบ)
constraint forall(p in PRODUCT, d in WINDOW)(stock[p, d] >= 0);

%% ── Objective ───────────────────────────────────────────────────

var int: total_holding = sum(p in PRODUCT, d in WINDOW)(holding_cost[p] * stock[p, d]);

solve minimize total_holding;

%% ── Output ───────────────────────────────────────────────────────

output [
  "=================================================\n",
  "Rolling Horizon — Window Day ", show(horizon_start), " to ", show(horizon_end), "\n",
  "=================================================\n",
  "Total holding cost = ", show(total_holding), "\n\n"
] ++
[ "Product " ++ show(p) ++ "  (เริ่มต้น stock=" ++ show(initial_stock[p]) ++ "):\n" ++
  "  Day\tผลิต\tDemand\tStock\n" ++
  concat([ "  " ++ show(d) ++ "\t" ++ show(produce[p,d]) ++ "\t" ++
           show(demand[p,d]) ++ "\t" ++ show(stock[p,d]) ++ "\n"
           | d in WINDOW ])
  | p in PRODUCT ] ++
[ "\nStock คงเหลือปลาย window (ส่งต่อให้ window ถัดไป):\n" ] ++
[ "  Product " ++ show(p) ++ ": " ++ show(stock[p, horizon_end]) ++ "\n"
  | p in PRODUCT ];
