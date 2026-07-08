%% ===================================================
%% WORKSHOP 2B: Multi-Product Multi-Line — เฉลย
%% ===================================================
%% รันด้วย: minizinc workshop2b_solution.mzn workshop2b_data.dzn

enum PRODUCTS;
enum LINES;

array[PRODUCTS] of int: demand;
array[PRODUCTS, LINES] of int: unit_cost;
array[PRODUCTS] of set of LINES: allowed;
array[LINES] of int: line_capacity;

array[PRODUCTS, LINES] of var 0..1000: produce;

% 1: ผลิตรวมครบ demand
constraint forall(p in PRODUCTS)(
  sum(l in LINES)(produce[p,l]) = demand[p]
);

% 2: ถ้าไลน์ไม่ได้รับอนุญาต ห้ามใช้
constraint forall(p in PRODUCTS, l in LINES)(
  if l in allowed[p] then true else produce[p,l] = 0 endif
);

% 3: แต่ละไลน์ไม่เกิน capacity
constraint forall(l in LINES)(
  sum(p in PRODUCTS)(produce[p,l]) <= line_capacity[l]
);

var int: total_cost = sum(p in PRODUCTS, l in LINES)(unit_cost[p,l] * produce[p,l]);

solve minimize total_cost;

output
  [ "=== เฉลย Workshop 2B ===\n",
    "สินค้า\t\tLine1\tLine2\tLine3\n" ] ++
  [ show(p) ++ "\t" ++ show(produce[p,Line1]) ++ "\t" ++
    show(produce[p,Line2]) ++ "\t" ++ show(produce[p,Line3]) ++ "\n"
    | p in PRODUCTS ] ++
  [ "--- ความจุที่ใช้ ---\n" ] ++
  [ show(l) ++ ": " ++ show(sum(p in PRODUCTS)(produce[p,l])) ++
    "/" ++ show(line_capacity[l]) ++ "\n" | l in LINES ] ++
  [ "ต้นทุนรวม = ", show(total_cost), " บาท\n" ];
