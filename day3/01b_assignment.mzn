%% ตัวอย่าง 1b: alldifferent — มอบหมายงานให้พนักงาน
%% โจทย์: พนักงาน 4 คน, งาน 4 อย่าง — แต่ละคนรับงานคนละอย่าง
%% Minimize เวลารวม

include "alldifferent.mzn";

int: n = 4;
enum WORKERS = { Alice, Bob, Carol, Dave };
enum TASKS   = { TaskA, TaskB, TaskC, TaskD };

% เวลาที่แต่ละคนใช้ทำแต่ละงาน (ชั่วโมง)
array[WORKERS, TASKS] of int: duration =
  [| TaskA: TaskB: TaskC: TaskD:
   | Alice: 2, 8, 5, 3
   | Bob:   6, 3, 4, 7
   | Carol: 4, 6, 2, 5
   | Dave:  8, 2, 7, 4 |];

% ตัวแปร: งานที่แต่ละคนได้รับมอบหมาย
array[WORKERS] of var TASKS: assigned;

% แต่ละคนได้งานต่างกัน (alldifferent!)
constraint alldifferent(assigned);

% Minimize เวลารวม
solve minimize sum(w in WORKERS)(duration[w, assigned[w]]);

output [
  "=== การมอบหมายงาน ===\n"
] ++
[ show(w) ++ " → " ++ show(assigned[w]) ++
  " (" ++ show(duration[w, assigned[w]]) ++ " ชม.)\n"
  | w in WORKERS ] ++
[ "เวลารวม: " ++ show(sum(w in WORKERS)(duration[w, assigned[w]])) ++ " ชม.\n" ];
