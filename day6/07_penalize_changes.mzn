%% ================================================================
%% 07_penalize_changes.mzn — Penalize Deviating from Original Plan
%% ================================================================
%%
%% แนวคิด: แทนที่จะ re-plan ใหม่ทั้งหมด เราอาจต้องการรักษา plan เดิม
%%   ให้มากที่สุด (ลด confusion ใน shop floor, ลดการสื่อสาร)
%%
%% วิธี: เพิ่ม penalty term ใน objective
%%   Objective = makespan + alpha * disruption
%%   disruption = จำนวน task ที่ต้องย้ายเครื่อง
%%
%% Scenario: M_B (หุ่นเชื่อม) เสีย — plan เดิมใช้ M_B ทำ Weld ทุก job
%%   → Weld 3 งาน ต้องย้ายไป M_C ทั้งหมด (disruption = 3)
%%
%% ทดลอง: เปลี่ยน alpha แล้วดูว่า makespan และ disruption เปลี่ยนอย่างไร
%%   alpha = 0  → ไม่สนใจ plan เดิม (เหมือน 06_reoptimize)
%%   alpha = 5  → สมดุลระหว่าง speed และ stability
%%   alpha = 50 → รักษา plan เดิมเป็นหลัก ยอม makespan สูงขึ้น
%%
%% ================================================================

include "disjunctive.mzn";

%% ── Data ─────────────────────────────────────────────────────────

enum JOB     = { OrderA, OrderB, OrderC };
enum TASK    = { Cut, Weld, Finish };
enum MACHINE = { M_A, M_B, M_C };

TASK: t_last = max(TASK);

%% M_B เสียแล้ว (fixed)
array[TASK, MACHINE] of bool: capable = array2d(TASK, MACHINE, [
  true,  false, true,    %% Cut
  false, false, true,    %% Weld: M_B down → M_C เท่านั้น
  true,  false, true,    %% Finish
]);

array[TASK, MACHINE] of int: proc_time = array2d(TASK, MACHINE, [
   5,  0,  8,
   0,  6,  9,
   4,  0,  6,
]);

%% ── Original plan (ก่อน M_B เสีย) ───────────────────────────────
%% ค่าเหล่านี้คือ solution ที่ได้จาก 06_reoptimize ตอน M_B_available=true
array[JOB, TASK] of MACHINE: orig_machine = array2d(JOB, TASK, [
  M_A, M_B, M_A,    %% OrderA: ตัด→M_A, เชื่อม→M_B, ขัด→M_A
  M_A, M_B, M_C,    %% OrderB: ตัด→M_A, เชื่อม→M_B, ขัด→M_C
  M_C, M_B, M_C,    %% OrderC: ตัด→M_C, เชื่อม→M_B, ขัด→M_C
]);

array[JOB, TASK] of int: orig_start = array2d(JOB, TASK, [
   0,  5, 11,    %% OrderA
   5,  5, 15,    %% OrderB
   0, 11, 20,    %% OrderC  (ตัวอย่าง — อาจไม่ใช่ optimal จริง)
]);

%% *** เปลี่ยน alpha เพื่อดูผลของการ tradeoff ***
int: alpha = 5;    %% น้ำหนักของ disruption ต่อ 1 task ที่ย้ายเครื่อง

int: total = sum(t in TASK)(max(m in MACHINE where capable[t,m])(proc_time[t,m])) * card(JOB);

%% ── Variables ───────────────────────────────────────────────────

array[JOB, TASK] of var MACHINE: machine;
array[JOB, TASK] of var 0..total: start;
var 0..total: makespan;

%% disruption = จำนวน task ที่ถูกย้ายเครื่อง (0..card(JOB)*card(TASK))
var 0..card(JOB)*card(TASK): disruption =
  sum(j in JOB, t in TASK)(bool2int(machine[j,t] != orig_machine[j,t]));

%% ── Constraints ─────────────────────────────────────────────────

constraint forall(j in JOB, t in TASK)(capable[t, machine[j, t]]);

constraint forall(j in JOB)(
  forall(t in TASK where t < t_last)(
    start[j, t] + proc_time[t, machine[j, t]] <= start[j, enum_next(TASK, t)]
  ) /\
  start[j, t_last] + proc_time[t_last, machine[j, t_last]] <= makespan
);

constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
  where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
  machine[j1, t1] = machine[j2, t2] ->
  (start[j1, t1] + proc_time[t1, machine[j1, t1]] <= start[j2, t2] \/
   start[j2, t2] + proc_time[t2, machine[j2, t2]] <= start[j1, t1])
);

solve minimize makespan + alpha * disruption;

%% ── Output ───────────────────────────────────────────────────────

output [
  "=================================================\n",
  "Penalize Changes  (alpha = ", show(alpha), ")\n",
  "=================================================\n",
  "Makespan    = ", show(makespan), " นาที\n",
  "Disruption  = ", show(disruption), " task(s) ย้ายเครื่อง\n",
  "Objective   = ", show(makespan + alpha * disruption), "\n\n",
  "Job\tTask\tใหม่\t(เดิม)\t\tสถานะ\n"
] ++
[ show(j) ++ "\t" ++ show(t) ++ "\t" ++
  show(machine[j, t]) ++ "\t(" ++ show(orig_machine[j, t]) ++ ")\t\t" ++
  if fix(machine[j, t]) != orig_machine[j, t] then "*** เปลี่ยน ***"
  else "คงเดิม"
  endif ++ "\n"
  | j in JOB, t in TASK ];
