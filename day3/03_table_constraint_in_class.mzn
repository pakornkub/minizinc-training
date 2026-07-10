%% ตัวอย่างที่ 3: table constraint — เลือกจากชุดค่าที่กำหนดไว้
%% อ้างอิง: docs.minizinc.dev - Global Constraints (2.3.1.3)
%%
%% table(x, allowed_tuples)
%% บังคับให้ array x เลือกค่าจาก row ใด row หนึ่งในตาราง allowed_tuples
%%
%% ประยุกต์ใช้: ตารางราคา, spec สินค้า, ชุดค่าที่เป็นไปได้ตามกฎ

include "table.mzn";

%% ── ตัวอย่าง: เลือกวัสดุสำหรับชิ้นส่วน ──
%% แต่ละวัสดุมี spec ที่แตกต่างกัน (ความแข็ง, น้ำหนัก, ราคา)

% ตารางวัสดุที่เป็นไปได้: [material_id, hardness, weight_g, cost_baht]
% material_id: 1=Steel, 2=Aluminum, 3=Titanium, 4=Plastic, 5=Carbon
array[1..5, 1..4] of int: material_table = [|
  1, 90, 800, 50  |  % Steel
  2, 60, 270, 80  |  % Aluminum
  3, 85, 450, 500 |  % Titanium
  4, 30,  50,  15 |  % Plastic
  5, 95, 180, 800 |]; % Carbon Fiber

% ตัวแปร: spec ของวัสดุที่เลือก
var int: mat_id;
var int: hardness;
var int: weight_g;
var int: cost;

% บังคับให้ค่าเป็นไปตามตาราง
% (เขียนเอง)
% constraint exists(i in 1..5)(
%   mat_id = material_table[i, 1] /\
%   hardness = material_table[i, 2] /\
%   weight_g = material_table[i, 3] /\
%   cost = material_table[i, 4]
% );
% (ใช้ global constraint table)
constraint table([mat_id, hardness, weight_g, cost], material_table);

% เงื่อนไข: ต้องการ hardness >= 70 และ weight <= 500
constraint hardness >= 70;
constraint weight_g <= 500;

% Minimize cost
solve minimize cost;

output [
  "=== วัสดุที่เหมาะสม ===\n",
  "Material ID: ", show(mat_id), "\n",
  "Hardness:    ", show(hardness), "\n",
  "Weight:      ", show(weight_g), " g\n",
  "Cost:        ", show(cost), " บาท\n"
];
