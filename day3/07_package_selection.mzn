%% ============================================================
%% ตัวอย่างที่ 7: table constraint + Optimization
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 3
%% ============================================================
%%
%% โจทย์: บริษัทต้องการจัดชุดอุปกรณ์ IT สำหรับห้อง 3 ห้อง
%%   แต่ละห้องต้องเลือก 1 "แพ็กเกจ" ที่ประกอบด้วย:
%%     - คอมพิวเตอร์ (PC)
%%     - จอภาพ (Monitor)
%%     - ความเร็ว Internet (Mbps)
%%
%%   แพ็กเกจที่มี (ราคาต่อห้อง/เดือน):
%%   ┌────────┬────┬─────────┬─────────┬──────────┐
%%   │ pkg_id │ PC │ Monitor │ Internet│ ราคา(บาท)│
%%   ├────────┼────┼─────────┼─────────┼──────────┤
%%   │   1    │  1 │   21"   │   100   │  2,500   │
%%   │   2    │  1 │   27"   │   200   │  3,500   │
%%   │   3    │  2 │   21"   │   100   │  4,000   │
%%   │   4    │  2 │   27"   │   300   │  5,000   │
%%   │   5    │  1 │   32"   │   500   │  4,500   │
%%   │   6    │  2 │   32"   │   500   │  6,500   │
%%   └────────┴────┴─────────┴─────────┴──────────┘
%%   (monitor: 21=เล็ก, 27=กลาง, 32=ใหญ่ — หน่วยเป็นนิ้ว × 10)
%%
%%   ความต้องการแต่ละห้อง:
%%     ห้องประชุม A: ต้องการ Monitor >= 270 นิ้ว×10, Internet >= 200 Mbps
%%     ห้องทำงาน B: ต้องการ PC >= 2 เครื่อง
%%     ห้องฝึกอบรม C: ต้องการ Internet >= 300 Mbps, Monitor ไม่สำคัญ
%%
%%   งบประมาณรวม: ไม่เกิน 12,000 บาท/เดือน
%%
%% ทำไมถึงใช้ table?
%%   แพ็กเกจแต่ละชุดมี attributes หลายอย่างที่ linked กัน
%%   ไม่สามารถเลือก PC=2 แต่ monitor=32 ได้อิสระ — ต้องเป็นแพ็กเกจที่มีในรายการ
%%   → table constraint บังคับให้เลือกจาก "ชุดที่อนุญาต" เท่านั้น
%%
%%   เปรียบกับตัวอย่าง 03 (วัสดุ):
%%   03: เลือกวัสดุ 1 ชนิด → table 1 ชุด
%%   07: เลือกแพ็กเกจ 3 ห้อง แต่ละห้องอิสระ + งบรวม → ซับซ้อนขึ้น
%%
%% รันด้วย: minizinc 07_package_selection.mzn
%% ============================================================

include "table.mzn";

int: n_rooms    = 3;
int: n_packages = 6;

set of int: ROOMS    = 1..n_rooms;
set of int: PACKAGES = 1..n_packages;

array[ROOMS] of string: room_name = ["ห้องประชุม A", "ห้องทำงาน B", "ห้องฝึกอบรม C"];

%% ตารางแพ็กเกจ: [pkg_id, n_pc, monitor_size×10, internet_mbps, price]
%% monitor: 210=21", 270=27", 320=32"
array[PACKAGES, 1..5] of int: pkg_table = [|
%%  id  PC  Mon   Net  Price
    1,   1,  210,  100, 2500  |
    2,   1,  270,  200, 3500  |
    3,   2,  210,  100, 4000  |
    4,   2,  270,  300, 5000  |
    5,   1,  320,  500, 4500  |
    6,   2,  320,  500, 6500  |
|];

int: budget = 12000;  %% งบรวมทุกห้อง

%% ── Decision Variables ──────────────────────────────────────
%% แต่ละห้องเลือก 1 แพ็กเกจ — เก็บ attributes ของแพ็กเกจที่เลือก
array[ROOMS] of var 1..6: pkg_id;      %% รหัสแพ็กเกจ
array[ROOMS] of var int: n_pc;         %% จำนวน PC
array[ROOMS] of var int: monitor;      %% ขนาดจอ ×10
array[ROOMS] of var int: internet;     %% ความเร็ว internet
array[ROOMS] of var int: price;        %% ราคา

%% ── table constraint: ทุก room ต้องเลือกจากแพ็กเกจที่มี ────
constraint forall(r in ROOMS)(
  table([pkg_id[r], n_pc[r], monitor[r], internet[r], price[r]], pkg_table)
);

%% ── ความต้องการเฉพาะของแต่ละห้อง ───────────────────────────

%% ห้อง 1 (ประชุม A): monitor >= 27", internet >= 200
constraint monitor[1]  >= 270;
constraint internet[1] >= 200;

%% ห้อง 2 (ทำงาน B): PC >= 2 เครื่อง
constraint n_pc[2] >= 2;

%% ห้อง 3 (ฝึกอบรม C): internet >= 300
constraint internet[3] >= 300;

%% งบประมาณรวม
constraint sum(r in ROOMS)(price[r]) <= budget;

%% ── Objective ────────────────────────────────────────────────
var int: total_cost = sum(r in ROOMS)(price[r]);
solve minimize total_cost;

%% ── Output ──────────────────────────────────────────────────
output [
  "=== แผนจัดชุดอุปกรณ์ IT ===\n\n"
] ++
[ room_name[r] ++ ":\n" ++
  "  แพ็กเกจ #" ++ show(pkg_id[r]) ++
  " | PC: " ++ show(n_pc[r]) ++
  " | Monitor: " ++ show(monitor[r] div 10) ++ "\"" ++
  " | Internet: " ++ show(internet[r]) ++ " Mbps" ++
  " | ราคา: ฿" ++ show(price[r]) ++ "\n"
  | r in ROOMS ] ++
[
  "\n──────────────────────────────\n",
  "งบรวม: ฿", show(total_cost), " / ฿", show(budget), "\n\n",
  "💡 ลองเพิ่ม constraint:\n",
  "   - ห้อง A กับ B ต้องใช้แพ็กเกจเดียวกัน: pkg_id[1] = pkg_id[2]\n",
  "   - ห้อง C ต้องการ PC >= 2 เพิ่มเติม: ดูว่างบพอหรือไม่\n"
];
