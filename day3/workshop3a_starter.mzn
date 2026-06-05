%% ===================================================
%% WORKSHOP 3A: Maintenance Scheduling ด้วย cumulative
%% ===================================================
%%
%% โจทย์: โรงงานมีงานซ่อมบำรุง 6 งาน
%%   A: 4 ชม., ต้องการช่าง 3 คน
%%   B: 3 ชม., ต้องการช่าง 2 คน
%%   C: 5 ชม., ต้องการช่าง 2 คน  (ต้องทำหลัง A เสร็จ)
%%   D: 2 ชม., ต้องการช่าง 4 คน
%%   E: 6 ชม., ต้องการช่าง 1 คน
%%   F: 3 ชม., ต้องการช่าง 3 คน
%%
%% ข้อจำกัด:
%%   - มีช่างทั้งหมด 5 คน
%%   - ต้องเสร็จทุกงานภายใน 12 ชั่วโมง
%%   - งาน C ต้องทำหลังงาน A เสร็จ (precedence)
%%
%% ขั้นตอน:
%%   1) เพิ่ม cumulative constraint
%%   2) เพิ่ม precedence: A ก่อน C
%%   3) เพิ่ม constraint ว่าทุกงานเสร็จใน 12 ชม.
%%   4) solve minimize end_time
%%   5) ท้าทาย: เพิ่มว่า D ต้องทำหลัง B เสร็จด้วย

include "cumulative.mzn";

int: n_tasks = 6;
array[1..n_tasks] of int: dur      = [4, 3, 5, 2, 6, 3];
array[1..n_tasks] of int: workers  = [3, 2, 2, 4, 1, 3];
int: total_workers = 5;
int: deadline      = 12;

% ตัวแปร: เวลาเริ่มของแต่ละงาน
array[1..n_tasks] of var 0..deadline: start;
var 0..deadline: end_time;

% TODO 1: cumulative — ทุกเวลา ช่างรวมต้องไม่เกิน total_workers
% constraint cumulative(start, dur, workers, total_workers);

% TODO 2: Precedence — งาน C (index 3) ต้องทำหลัง A (index 1) เสร็จ
% constraint start[???] + dur[???] <= start[???];

% TODO 3: ทุกงานต้องเสร็จก่อน end_time
% constraint forall(i in 1..n_tasks)(start[i] + dur[i] <= end_time);

% TODO 4: solve minimize end_time
solve satisfy;

output [
  "=== ตารางซ่อมบำรุง ===\n",
  "งาน\tเริ่ม\tเสร็จ\tช่าง\n"
] ++
[ "  " ++ show(i) ++ "\t" ++ show(start[i]) ++ "\t" ++
  show(start[i]+dur[i]) ++ "\t" ++ show(workers[i]) ++ "\n"
  | i in 1..n_tasks ] ++
[ "เสร็จทั้งหมดที่: ", show(end_time), " ชม.\n" ];
