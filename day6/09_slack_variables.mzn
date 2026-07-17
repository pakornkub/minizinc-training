%% ================================================================
%% 09_slack_variables.mzn — Slack Variables (Overtime Buffer)
%% ================================================================
%%
%% แนวคิด: เพิ่ม "slack" = ชั่วโมง overtime ที่ใช้ได้ในกรณีฉุกเฉิน
%%
%%   กำลังผลิตจริง = normal_cap[m] + slack[m, p]
%%   แต่ slack มีต้นทุนสูงกว่า (ค่าล่วงเวลา)
%%
%% ประโยชน์:
%%   - รับมือ demand spike โดยไม่ต้อง reject order
%%   - วางแผน overtime ล่วงหน้าได้ในกรณีที่คาดได้
%%   - เห็นชัดว่า period ไหน / เครื่องไหน จะต้องทำ overtime
%%
%% Scenario: demand ของ D4 สูงเกินปกติ (order พิเศษ)
%%   → เครื่องบางตัวต้องทำ overtime เพื่อให้ทันส่ง
%%
%% ทดลอง: ลบ constraint overtime_cost ออก → ดู OT pattern เปลี่ยนยังไง
%%         เปลี่ยน overtime_cost[m] ให้เท่ากัน → OT กระจายยังไง
%%
%% ================================================================

int: n_period  = 5;
int: n_machine = 3;
set of int: PERIOD  = 1..n_period;
set of int: MACHINE = 1..n_machine;

%% ── Capacity ──────────────────────────────────────────────────────

%% ชั่วโมงทำงานปกติต่อเครื่องต่อ period
array[MACHINE] of int: normal_cap  = [40, 35, 30];

%% ชั่วโมง overtime สูงสุด (กำหนดโดย union / กฎแรงงาน)
array[MACHINE] of int: max_overtime = [12, 10, 8];

%% ── ต้นทุน ────────────────────────────────────────────────────────

%% ต้นทุนต่อชั่วโมง (regular ต่ำกว่า overtime เสมอ)
array[MACHINE] of int: regular_cost  = [100, 120, 150];
array[MACHINE] of int: overtime_cost = [175, 210, 260];

%% ── Demand ────────────────────────────────────────────────────────
%% ความต้องการชั่วโมงเครื่องในแต่ละ period
%% Period 4 สูงเกินปกติเพราะ order พิเศษจากลูกค้า VIP
array[MACHINE, PERIOD] of int: hours_needed = array2d(MACHINE, PERIOD, [
%%   P1  P2  P3   P4  P5
     35, 38, 40,  52, 30,   %% Machine 1 (P4 เกิน normal_cap!)
     28, 32, 34,  43, 25,   %% Machine 2
     20, 25, 28,  36, 18,   %% Machine 3
]);

%% ── Variables ───────────────────────────────────────────────────

array[MACHINE, PERIOD] of var 0..100: regular;   %% ชั่วโมงปกติที่ใช้
array[MACHINE, PERIOD] of var 0..20:  overtime;  %% slack = ชั่วโมง OT

%% ── Constraints ─────────────────────────────────────────────────

constraint forall(m in MACHINE, p in PERIOD)(
  %% ใช้ regular ได้ไม่เกิน normal_cap
  regular[m, p]  <= normal_cap[m]  /\
  %% ใช้ overtime ได้ไม่เกิน max_overtime
  overtime[m, p] <= max_overtime[m] /\
  %% regular + overtime ต้องครอบ demand
  regular[m, p] + overtime[m, p] >= hours_needed[m, p]
);

%% ── Objective ───────────────────────────────────────────────────

var int: total_cost = sum(m in MACHINE, p in PERIOD)(
  regular_cost[m]  * regular[m, p] +
  overtime_cost[m] * overtime[m, p]
);

solve minimize total_cost;

%% ── Output ───────────────────────────────────────────────────────

output [
  "=================================================\n",
  "Slack Variables — Overtime Planning\n",
  "=================================================\n",
  "Total cost = ", show(total_cost), " บาท\n\n"
] ++
[ "Machine " ++ show(m) ++ " (normal=" ++ show(normal_cap[m]) ++
  "h, OT_max=" ++ show(max_overtime[m]) ++ "h):\n" ++
  "  Period\tNeed\tRegular\tOvertime\tStatus\n" ++
  concat([
    "  P" ++ show(p) ++ "\t\t" ++ show(hours_needed[m,p]) ++ "\t" ++
    show(regular[m,p]) ++ "\t" ++ show(overtime[m,p]) ++ "\t\t" ++
    if overtime[m,p] > 0 then "OT " ++ show(overtime[m,p]) ++ "h"
    else "ปกติ" endif ++ "\n"
    | p in PERIOD
  ])
  | m in MACHINE ] ++
[ "\nOT cost by machine:\n" ] ++
[ "  Machine " ++ show(m) ++ ": " ++
  show(sum(p in PERIOD)(overtime_cost[m] * overtime[m,p])) ++ " บาท\n"
  | m in MACHINE ];
