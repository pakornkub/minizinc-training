%% ============================================================
%% ตัวอย่างที่ 6 (เช้า): การจัดสรรงบโฆษณา — Media Planning
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 2
%% ============================================================
%%
%% โจทย์:
%%   บริษัทมีงบโฆษณาประจำเดือน 500,000 บาท
%%   ต้องจัดสรรให้ช่องทางสื่อ 5 ประเภท
%%   แต่ละช่องมี "ค่าใช้จ่ายต่อครั้ง" และ "จำนวนผู้เข้าถึงต่อครั้ง" (reach)
%%
%%   เงื่อนไข:
%%     - ช่อง TV ต้องลงอย่างน้อย 2 ครั้ง (สร้าง brand awareness)
%%     - Social Media ลงได้ไม่เกิน 20 ครั้ง
%%     - ลงโฆษณาสื่อสิ่งพิมพ์ (Print) ได้ไม่เกิน 3 ครั้ง
%%     - รวมทุกช่องต้องลงอย่างน้อย 10 ครั้ง
%%
%%   เป้าหมาย: Maximize จำนวนผู้เข้าถึงรวม (total reach)
%%
%% จุดเด่น: ใช้ arrays + forall + sum กับโจทย์ที่เข้าใจง่าย
%%
%% รันด้วย: minizinc 06_media_planning.mzn
%% ============================================================

int: n = 5;
set of int: MEDIA = 1..n;

%% ข้อมูลสื่อแต่ละประเภท
array[MEDIA] of string: name = ["TV", "Radio", "Social", "Online", "Print"];
array[MEDIA] of int: cost_per_slot  = [80000, 15000, 5000, 8000, 20000]; % บาท/ครั้ง
array[MEDIA] of int: reach_per_slot = [500000, 80000, 60000, 90000, 40000]; % คน/ครั้ง
array[MEDIA] of int: max_slots = [5, 10, 20, 15, 3]; % จำนวนครั้งสูงสุดที่ลงได้

int: budget = 500000;   % งบรวม (บาท)
int: min_total = 10;    % จำนวนครั้งขั้นต่ำรวมทุกสื่อ
int: tv = 1;            % index ของ TV
int: social = 3;        % index ของ Social
int: print = 5;         % index ของ Print

%% ── Decision Variables ──────────────────────────────────────
array[MEDIA] of var 0..20: slots;   % จำนวนครั้งที่ลงแต่ละสื่อ

%% ── Constraints ─────────────────────────────────────────────

%% งบประมาณรวม
constraint sum(m in MEDIA)(cost_per_slot[m] * slots[m]) <= budget;

%% ไม่เกิน max_slots ของแต่ละสื่อ
constraint forall(m in MEDIA)(slots[m] <= max_slots[m]);

%% TV อย่างน้อย 2 ครั้ง
constraint slots[tv] >= 2;

%% รวมทุกช่องอย่างน้อย 10 ครั้ง
constraint sum(m in MEDIA)(slots[m]) >= min_total;

%% ── Objective ───────────────────────────────────────────────
var int: total_reach = sum(m in MEDIA)(reach_per_slot[m] * slots[m]);
solve maximize total_reach;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== แผนโฆษณาที่ดีที่สุด ===\n",
  "สื่อ\t\tครั้ง\tReach\t\tค่าใช้จ่าย\n",
  "─────────────────────────────────────────\n"
] ++
[ name[m] ++ "\t\t" ++ show(slots[m]) ++ "\t" ++
  show(reach_per_slot[m] * fix(slots[m])) ++ "\t\t" ++
  show(cost_per_slot[m] * fix(slots[m])) ++ " บาท\n"
  | m in MEDIA ] ++
[
  "─────────────────────────────────────────\n",
  "รวม reach:   ", show(total_reach), " คน\n",
  "รวมค่าใช้จ่าย: ",
  show(sum(m in MEDIA)(cost_per_slot[m] * slots[m])),
  "/", show(budget), " บาท\n",
  "รวมครั้ง:    ", show(sum(m in MEDIA)(slots[m])), " ครั้ง\n"
];
