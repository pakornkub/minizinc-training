%% ตัวอย่างที่ 4: Enumerated Types
%% อ้างอิง: docs.minizinc.dev - Enumerated Types (Section 2.2.4)
%%
%% Enum Types ทำให้โมเดลอ่านง่ายขึ้นมาก
%% เปรียบเทียบ: array[1..3] กับ array[MACHINES]

% --- กำหนด Enum Types ---
enum MACHINES = { LaserCutter, Welder, Assembler };
enum PRODUCTS = { ChairA, ChairB, TableX };

% กำไรต่อหน่วย
array[PRODUCTS] of int: profit = [500, 700, 1200];

% เวลาที่ใช้บนแต่ละเครื่อง (ชั่วโมง/หน่วย)
array[PRODUCTS, MACHINES] of int: time_needed =
  [| LaserCutter: Welder: Assembler:
   | ChairA:      2,      1,       3
   | ChairB:      1,      2,       2
   | TableX:      3,      3,       5 |];

% Capacity ของแต่ละเครื่อง (ชั่วโมง/วัน)
array[MACHINES] of int: machine_cap = [16, 12, 20];

% --- Decision Variables ---
array[PRODUCTS] of var 0..10: produce;

% --- Constraints ---
constraint forall(m in MACHINES)(
  sum(p in PRODUCTS)(time_needed[p,m] * produce[p]) <= machine_cap[m]
);

% --- Solve ---
solve maximize sum(p in PRODUCTS)(profit[p] * produce[p]);

% --- Output ---
output [
  "=== แผนการผลิตเฟอร์นิเจอร์ ===\n",
  "ChairA:  ", show(produce[ChairA]), " หน่วย\n",
  "ChairB:  ", show(produce[ChairB]), " หน่วย\n",
  "TableX:  ", show(produce[TableX]), " หน่วย\n",
  "กำไรรวม: ", show(sum(p in PRODUCTS)(profit[p]*produce[p])), " บาท\n",
  "--- การใช้เครื่องจักร ---\n",
  "LaserCutter: ", show(sum(p in PRODUCTS)(time_needed[p,LaserCutter]*produce[p])),
  "/", show(machine_cap[LaserCutter]), " ชม.\n",
  "Welder:      ", show(sum(p in PRODUCTS)(time_needed[p,Welder]*produce[p])),
  "/", show(machine_cap[Welder]), " ชม.\n",
  "Assembler:   ", show(sum(p in PRODUCTS)(time_needed[p,Assembler]*produce[p])),
  "/", show(machine_cap[Assembler]), " ชม.\n"
];
