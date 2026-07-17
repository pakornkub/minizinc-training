%% ================================================================
%% jobshop_model.mzn — Flexible Job Shop
%% ไฟล์โมเดล: รับ parameters ทั้งหมดจากภายนอก (Python / .dzn)
%%
%% Python ส่งค่ามาผ่าน minizinc Python API:
%%   n_job, n_task, n_machine  — ขนาดปัญหา
%%   dur[j,t,m]                — เวลาประมวลผล (0 = ทำไม่ได้)
%%
%% Output: makespan, start[j,t], machine[j,t]
%% ================================================================

int: n_job;
int: n_task;
int: n_machine;

set of int: JOB     = 1..n_job;
set of int: TASK    = 1..n_task;
set of int: MACHINE = 1..n_machine;

%% dur[j, t, m] = เวลา (นาที) ที่ machine m ใช้ทำ task t ของ job j
%% ถ้า dur[j,t,m] = 0 แปลว่า machine m ทำ task t ไม่ได้
array[JOB, TASK, MACHINE] of int: dur;

%% ── Upper bound สำหรับ time variables ──────────────────────────
int: total = sum(j in JOB, t in TASK)(max(m in MACHINE)(dur[j,t,m])) * 2;

%% ── Decision Variables ──────────────────────────────────────────
array[JOB, TASK] of var MACHINE:   machine;   %% เครื่องที่ใช้
array[JOB, TASK] of var 0..total: start;     %% เวลาเริ่ม
var 0..total: makespan;                        %% เวลาสิ้นสุดรวม

%% ── Constraints ─────────────────────────────────────────────────

%% 1. Capability: เลือกเฉพาะ machine ที่รับ task นั้นได้
constraint forall(j in JOB, t in TASK)(
    dur[j, t, machine[j, t]] > 0
);

%% 2. Task sequence: ทำ task ตามลำดับ (precedence)
constraint forall(j in JOB, t in 1..n_task-1)(
    start[j, t] + dur[j, t, machine[j, t]] <= start[j, t+1]
);

%% 3. Makespan: ทุก job ต้องเสร็จก่อน makespan
constraint forall(j in JOB)(
    start[j, n_task] + dur[j, n_task, machine[j, n_task]] <= makespan
);

%% 4. No-overlap: งาน 2 ชิ้นบนเครื่องเดียวกันต้องไม่ overlap
constraint forall(j1 in JOB, t1 in TASK, j2 in JOB, t2 in TASK
    where j1 < j2 \/ (j1 = j2 /\ t1 < t2))(
    machine[j1, t1] = machine[j2, t2] ->
    (   start[j1, t1] + dur[j1, t1, machine[j1, t1]] <= start[j2, t2]
     \/ start[j2, t2] + dur[j2, t2, machine[j2, t2]] <= start[j1, t1])
);

%% ── Search Strategy ─────────────────────────────────────────────
solve
    :: seq_search([
        int_search([machine[j,t] | j in JOB, t in TASK],
                   input_order, indomain_min),
        int_search([start[j,t]   | j in JOB, t in TASK],
                   smallest, indomain_min)
    ])
    minimize makespan;

%% ── Output ───────────────────────────────────────────────────────
%% (Python API อ่านค่าตัวแปรโดยตรง ไม่จำเป็นต้องใช้ output section นี้)
output [
    "makespan = ", show(makespan), "\n",
    "start    = ", show([start[j,t]   | j in JOB, t in TASK]), "\n",
    "machine  = ", show([machine[j,t] | j in JOB, t in TASK]), "\n"
];
