%% ตัวอย่างที่ 2: cumulative — Resource-Constrained Scheduling
%% อ้างอิง: docs.minizinc.dev - Global Constraints (2.3.1.2)
%%
%% cumulative(start, duration, resource_req, capacity)
%% บังคับว่าในทุกช่วงเวลา ผลรวมของ resource ที่ใช้ต้องไม่เกิน capacity
%%
%% รันด้วย: minizinc 02_cumulative.mzn 02_moving_data.dzn

include "cumulative.mzn";

enum OBJECTS;
array[OBJECTS] of int: duration;          % เวลาที่ใช้ขนแต่ละชิ้น (นาที)
array[OBJECTS] of int: handlers_needed;   % จำนวนคนที่ต้องการ
array[OBJECTS] of int: trolleys_needed;   % จำนวนรถเข็นที่ต้องการ

int: available_handlers;   % จำนวนคนทั้งหมด
int: available_trolleys;   % จำนวนรถเข็นทั้งหมด
int: available_time;       % เวลาที่มี (นาที)

% ตัวแปร: เวลาเริ่มต้นของแต่ละงาน
array[OBJECTS] of var 0..available_time: start;
var 0..available_time: end_time;

% cumulative constraints
constraint cumulative(start, duration, handlers_needed, available_handlers);
constraint cumulative(start, duration, trolleys_needed, available_trolleys);

% ทุกงานต้องเสร็จก่อน end_time
constraint forall(o in OBJECTS)(start[o] + duration[o] <= end_time);

solve minimize end_time;

output [
  "=== ตารางการขนย้าย ===\n",
  "เสร็จสิ้นใน: ", show(end_time), " นาที\n\n"
] ++
[ show(o) ++ ": เริ่ม " ++ show(start[o]) ++
  " นาที (ใช้ " ++ show(duration[o]) ++ " นาที)\n"
  | o in OBJECTS ];
