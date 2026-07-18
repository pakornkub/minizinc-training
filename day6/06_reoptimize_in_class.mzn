%% ================================================================
%% 06_reoptimize.mzn — Re-optimize from Current State
%% ================================================================
%%
%% แนวคิด: เมื่อสถานการณ์เปลี่ยนกลางแผน วิธีที่ตรงไปตรงมาที่สุด
%%   คือ "อัปเดตข้อมูล แล้ว solve ใหม่"
%%
%% Scenario:
%%   โรงงานมี 3 เครื่อง, 3 ออร์เดอร์, 3 ขั้นตอน
%%   Plan เดิม: M_B (หุ่นเชื่อม) พร้อมใช้งาน → makespan ≈ สั้น
%%   เหตุการณ์: M_B ขัดข้องกลางกะ!
%%   ทำอะไร: solve ใหม่ด้วย M_B_available = false
%%
%% ทดลอง:
%%   1. รันตอนนี้ → ดู makespan หลัง M_B เสีย
%%   2. เปลี่ยน M_B_available = true → รันใหม่ → เปรียบเทียบ
%%
%% ================================================================

include "disjunctive.mzn";

%% ── Data ─────────────────────────────────────────────────────────

enum JOB     = { OrderA, OrderB, OrderC };
enum TASK    = { Cut, Weld, Finish };
enum MACHINE = { M_A, M_B, M_C };

TASK: t_last = max(TASK);

%% *** เปลี่ยนค่านี้เพื่อสลับระหว่าง "ปกติ" และ "M_B เสีย" ***
bool: M_B_available = false;   %% true = ปกติ / false = M_B ขัดข้อง

%% Capability: M_A=เลเซอร์ตัด, M_B=เชื่อม, M_C=เอนกประสงค์
%% M_B_available ถูกฝังใน capable matrix โดยตรง
array[TASK, MACHINE] of bool: capable = array2d(TASK, MACHINE, [
%%  M_A    M_B             M_C
  true,   false,          true,    %% Cut   (M_B ตัดไม่ได้)
  false,  M_B_available,  true,    %% Weld  (M_B ขึ้นกับ flag)
  true,   false,          true,    %% Finish (M_B ขัดผิวไม่ได้)
]);

%% Processing time ต่อ task-machine (0 = ไม่ใช้)
array[TASK, MACHINE] of int: proc_time = array2d(TASK, MACHINE, [
%%  M_A   M_B   M_C
     5,    0,    8,    %% Cut
     0,    6,    9,    %% Weld (M_C ช้ากว่า M_B 50%)
     4,    0,    6,    %% Finish
]);

int: total = sum(t in TASK)(
  max(m in MACHINE where capable[t, m])(proc_time[t, m])
) * card(JOB);

%% ── Variables ───────────────────────────────────────────────────

array[JOB, TASK] of var MACHINE: machine;
array[JOB, TASK] of var 0..total: start;
var 0..total: makespan;

%% ── Constraints ─────────────────────────────────────────────────

%% 1. เลือกเฉพาะเครื่องที่รองรับ
constraint forall(j in JOB, t in TASK)(
  capable[t, machine[j, t]]
);

%% 2. Precedence: ทำตามลำดับภายใน job
constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j, t] + proc_time[t, machine[j, t]] <= start[j, enum_next(TASK, t)]
  ) /\
  start[j, t_last] + proc_time[t_last, machine[j, t_last]] <= makespan
);

%% 3. No-overlap: ทุกคู่ (j1,t1)-(j2,t2) บนเครื่องเดียวกัน
constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
  where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
  machine[j1, t1] = machine[j2, t2] ->
  (start[j1, t1] + proc_time[t1, machine[j1, t1]] <= start[j2, t2] \/
   start[j2, t2] + proc_time[t2, machine[j2, t2]] <= start[j1, t1])
);

%% เพิ่ม constraint สำหรับงานที่ทำไปแล้ว เช่น
%% ในนาทีที่ 5 เครื่องจักร B เสีย 
%% OrderA Cut M_C ที่เวลา 0 -> 8
%% OrderC Cut M_A ที่เวลา 0 -> 5
constraint machine[OrderA, Cut] = M_C;
constraint start[OrderA, Cut] = 0;
constraint machine[OrderC, Cut] = M_A;
constraint start[OrderC, Cut] = 0;

solve minimize makespan;

%% ── Output ───────────────────────────────────────────────────────

output [
  "=================================================\n",
  "Re-optimize: M_B available = ", show(M_B_available), "\n",
  "=================================================\n",
  "Makespan = ", show(makespan), " นาที\n\n",
  "Job\tTask\tเครื่อง\tเริ่ม → เสร็จ\n"
] ++
[ show(j) ++ "\t" ++ show(t) ++ "\t" ++ show(machine[j, t]) ++ "\t" ++
  show(start[j, t]) ++ " → " ++ show(start[j, t] + proc_time[t, machine[j, t]]) ++ "\n"
  | j in JOB, t in TASK ];
