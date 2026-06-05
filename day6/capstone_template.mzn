%% ===================================================
%% CAPSTONE PROJECT: Template สำหรับโมเดลจริง
%% ===================================================
%%
%% ขั้นตอนการสร้างโมเดล:
%%   1) นิยามปัญหา: อะไรคือ decision? objective คืออะไร?
%%   2) กำหนด Decision Variables
%%   3) กำหนด Constraints
%%   4) กำหนด Objective
%%   5) ทดสอบด้วยข้อมูลขนาดเล็กก่อน
%%   6) ขยายขนาดและปรับแต่ง

%% ── ขั้นตอน 1: นิยามปัญหา ──────────────────────────────
%% ปัญหา: [ระบุปัญหาของท่าน]
%% Decision: [อะไรที่ต้องตัดสินใจ เช่น ใครทำอะไร เมื่อไร ที่ไหน]
%% Objective: [minimize/maximize อะไร]
%% Constraints: [กฎอะไรที่ต้องเป็นจริง]

%% ── ขั้นตอน 2: Parameters ──────────────────────────────
%% กำหนด enum และ parameters ที่รับจาก data file

% enum ITEMS;    % ชื่อสิ่งที่เกี่ยวข้อง
% enum PERIODS;  % ช่วงเวลา (วัน, สัปดาห์, ชั่วโมง)

% array[ITEMS] of int: demand;
% int: capacity;
% int: budget;

%% ── ขั้นตอน 3: Decision Variables ─────────────────────
%% กำหนด domain ให้แน่น: ไม่กว้างเกิน ไม่แคบเกิน

% int: upper_bound = ...;  % คำนวณจากข้อมูล
% array[ITEMS] of var 0..upper_bound: quantity;

%% ── ขั้นตอน 4: Constraints ─────────────────────────────
%% เริ่มจาก constraint สำคัญก่อน
%% ทดสอบทีละ constraint

% constraint forall(i in ITEMS)(...);
% constraint sum(i in ITEMS)(quantity[i]) <= capacity;

%% ── ขั้นตอน 5: Objective ───────────────────────────────
%% solve minimize total_cost;
%% หรือ solve maximize total_profit;

solve satisfy;  % เริ่มด้วย satisfy ก่อนเสมอ

%% ── ขั้นตอน 6: Output ──────────────────────────────────
output [
  "=== [ชื่อโครงการ] ===\n",
  "คำตอบ: ...\n"
];

%% ── Checklist ก่อน Submit ──────────────────────────────
%% □ Bounds แน่นพอ? (ไม่ใช้ 0..9999 โดยไม่มีเหตุผล)
%% □ มี assert() ตรวจข้อมูล input?
%% □ ทดสอบกับข้อมูลขนาดเล็กแล้วผลถูกต้อง?
%% □ output อ่านเข้าใจ?
%% □ solve satisfy ได้ผลก่อน เปลี่ยนเป็น minimize/maximize?
