%% ตัวอย่างที่ 4: 0/1 Knapsack — เลือกโปรเจกต์ที่จะลงทุน
%% อ้างอิง: docs.minizinc.dev - Set Variables
%%
%% 0/1 Knapsack: เลือกหรือไม่เลือกแต่ละชิ้น (0 หรือ 1)
%% ทั้ง 2 แบบ: boolean array และ set variable

int: n = 6;
set of int: ITEMS = 1..n;

array[ITEMS] of int: profit = [500, 800, 300, 700, 600, 400];  % กำไร
array[ITEMS] of int: cost   = [200, 350, 150, 280, 220, 180];  % ต้นทุน
array[ITEMS] of int: risk   = [  2,   4,   1,   3,   2,   1];  % ความเสี่ยง 1-5

int: budget   = 700;   % งบประมาณ
int: max_risk = 8;     % ความเสี่ยงรวมสูงสุด

%% ── วิธีที่ 1: Boolean array ──────────────────────────
array[ITEMS] of var 0..1: selected;

constraint sum(i in ITEMS)(cost[i]   * selected[i]) <= budget;
constraint sum(i in ITEMS)(risk[i]   * selected[i]) <= max_risk;

solve maximize sum(i in ITEMS)(profit[i] * selected[i]);

%% ── วิธีที่ 2: Set variable (แสดงใน output ด้วย) ──────
%% var set of ITEMS: chosen;
%% constraint sum(i in chosen)(cost[i])   <= budget;
%% constraint sum(i in chosen)(risk[i])   <= max_risk;
%% solve maximize sum(i in chosen)(profit[i]);

output [
  "=== เลือกโปรเจกต์ ===\n",
  "โปรเจกต์ที่เลือก: " ++
  concat(["P"++show(i)++" " | i in ITEMS where fix(selected[i])=1]) ++ "\n",
  "กำไรรวม: ", show(sum(i in ITEMS)(profit[i]*selected[i])), " บาท\n",
  "ต้นทุนรวม: ", show(sum(i in ITEMS)(cost[i]*selected[i])), "/", show(budget), " บาท\n",
  "ความเสี่ยงรวม: ", show(sum(i in ITEMS)(risk[i]*selected[i])), "/", show(max_risk), "\n"
];
