%% ตัวอย่าง 2: Redundant Constraints
%% อ้างอิง: docs.minizinc.dev - Redundant Constraints (2.7.3)
%%
%% Redundant constraint = constraint ที่ "ซ้ำซ้อน" ทางตรรกะ
%% แต่ช่วยให้ solver prune search space ได้เร็วกว่า

include "alldifferent.mzn";

int: n = 8;
set of int: WORKERS = 1..n;
set of int: TASKS   = 1..n;
array[WORKERS, TASKS] of int: cost;  % รับจาก data file
cost = [| 9, 2, 7, 8, 6, 1, 4, 3
        | 1, 5, 8, 2, 9, 4, 7, 6
        | 8, 3, 2, 7, 1, 6, 5, 9
        | 7, 4, 6, 3, 2, 8, 1, 5
        | 5, 7, 1, 9, 3, 2, 8, 4
        | 3, 6, 4, 5, 8, 7, 2, 1
        | 6, 8, 9, 1, 4, 3, 7, 2
        | 2, 1, 3, 4, 7, 5, 6, 8 |];

array[WORKERS] of var TASKS: assigned;
constraint alldifferent(assigned);

%% ── Redundant Constraints ──────────────────────────────
%% ทางตรรกะ ถ้า alldifferent แล้ว constraints ด้านล่างนี้
%% เป็น true อยู่แล้ว แต่ช่วย solver prune ได้เร็วกว่า

%% 1. min cost ของแต่ละ worker เป็น lower bound
constraint sum(w in WORKERS)(min(t in TASKS)(cost[w,t]))
  <= sum(w in WORKERS)(cost[w, assigned[w]]);

%% 2. min cost ของแต่ละ task เป็น lower bound อีกแบบ
constraint sum(t in TASKS)(min(w in WORKERS)(cost[w,t]))
  <= sum(w in WORKERS)(cost[w, assigned[w]]);

solve minimize sum(w in WORKERS)(cost[w, assigned[w]]);

output [
  "=== Assignment with Redundant Constraints ===\n"
] ++
[ "Worker " ++ show(w) ++ " → Task " ++ show(assigned[w]) ++
  " (cost " ++ show(cost[w,assigned[w]]) ++ ")\n"
  | w in WORKERS ] ++
[ "Total cost: ", show(sum(w in WORKERS)(cost[w,assigned[w]])), "\n" ];
