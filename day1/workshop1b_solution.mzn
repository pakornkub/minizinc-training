%% ===================================================
%% WORKSHOP 1B: Production Planning — เฉลย
%% ===================================================

% --- Parameters ---
int: labor_hours  = 120;
int: raw_material = 150;

% --- Decision Variables ---
var 0..40: a;  % A ผลิตได้สูงสุด 40 หน่วย (120 ชม. / 3 ชม./หน่วย)
var 0..24: b;  % B ผลิตได้สูงสุด 24 หน่วย (120 ชม. / 5 ชม./หน่วย)

% --- Constraints ---
constraint 3*a + 5*b <= labor_hours;    % แรงงาน
constraint 5*a + 2*b <= raw_material;   % วัตถุดิบ

% ขั้นตอน 5: minimum production
constraint a >= 5;
constraint b >= 10;

% --- Solve ---
solve maximize 1500*a + 800*b;

% --- Output ---
output [
  "=== เฉลย Workshop 1B ===\n",
  "ผลิตภัณฑ์ A: ", show(a), " หน่วย\n",
  "ผลิตภัณฑ์ B: ", show(b), " หน่วย\n",
  "แรงงานที่ใช้:   ", show(3*a + 5*b), "/", show(labor_hours), " ชม.\n",
  "วัตถุดิบที่ใช้:  ", show(5*a + 2*b), "/", show(raw_material), " กก.\n",
  "กำไรรวม: ", show(1500*a + 800*b), " บาท\n"
];
