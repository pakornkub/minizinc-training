%% ===================================================
%% WORKSHOP 2A: Production Planning Generic — เฉลย
%% ===================================================
%% รันด้วย: minizinc workshop2a_solution.mzn workshop2a_data.dzn

enum PRODUCTS;
enum RESOURCES;

array[PRODUCTS]            of int: profit;
array[RESOURCES]           of int: capacity;
array[PRODUCTS, RESOURCES] of int: consumption;

int: max_produce = max(p in PRODUCTS)(
  min(r in RESOURCES where consumption[p,r] > 0)(
    capacity[r] div consumption[p,r]
  )
);

array[PRODUCTS] of var 0..max_produce: produce;

% ทุก resource ไม่เกิน capacity
constraint forall(r in RESOURCES)(
  sum(p in PRODUCTS)(consumption[p,r] * produce[p]) <= capacity[r]
);

% ขั้นตอน 4 (ท้าทาย): ผลิตสินค้าแรกอย่างน้อย 3 หน่วย
% constraint produce[min(PRODUCTS)] >= 3;

solve maximize sum(p in PRODUCTS)(profit[p] * produce[p]);

output
  [ "=== เฉลย Workshop 2A ===\n" ] ++
  [ show(p) ++ " = " ++ show(produce[p]) ++ " หน่วย (กำไร " ++
    show(profit[p]*produce[p]) ++ ")\n" | p in PRODUCTS ] ++
  [ "กำไรรวม = " ++ show(sum(p in PRODUCTS)(profit[p]*produce[p])) ++ " บาท\n",
    "--- การใช้ทรัพยากร ---\n" ] ++
  [ show(r) ++ ": " ++ show(sum(p in PRODUCTS)(consumption[p,r]*produce[p]))
    ++ "/" ++ show(capacity[r]) ++ " ชม.\n" | r in RESOURCES ];
