%% ===================================================
%% WORKSHOP 1B: Production Planning — แบบใช้ Data File
%% ===================================================
%%
%% รันด้วย: minizinc workshop1b_param.mzn workshop1b_data.dzn
%% หรือลอง: minizinc workshop1b_param.mzn workshop1b_data2.dzn

int: labor_hours;   % รับจาก data file
int: raw_material;  % รับจาก data file

int: labor_a;    % แรงงานที่ A ต้องการ (ชม./หน่วย)
int: material_a; % วัตถุดิบที่ A ต้องการ (กก./หน่วย)
int: profit_a;   % กำไร A (บาท/หน่วย)

int: labor_b;
int: material_b;
int: profit_b;

int: min_a;  % จำนวนขั้นต่ำของ A
int: min_b;  % จำนวนขั้นต่ำของ B

var 0..1000: a;
var 0..1000: b;

constraint labor_a   * a + labor_b   * b <= labor_hours;
constraint material_a * a + material_b * b <= raw_material;
constraint a >= min_a;
constraint b >= min_b;

solve maximize profit_a * a + profit_b * b;

output [
  "=== แผนการผลิต (จาก data file) ===\n",
  "ผลิตภัณฑ์ A: ", show(a), " หน่วย\n",
  "ผลิตภัณฑ์ B: ", show(b), " หน่วย\n",
  "กำไรรวม: ", show(profit_a*a + profit_b*b), " บาท\n"
];
