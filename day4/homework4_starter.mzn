%% ============================================================
%% HOMEWORK 4: ตารางเวรพยาบาลโรงพยาบาลโรงงาน
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 4
%% ============================================================
%%
%% คลินิกโรงงานมีพยาบาล n_nurses คน วางแผน n_days วัน
%% มีกะ 3 กะ: เช้า (D), บ่าย (E), กึ่งดึก (N), หยุด (O)
%%
%% กฎที่ต้องรักษา:
%%   1. ทุกวันต้องมีพยาบาลครบตาม demand แต่ละกะ (req[d, shift])
%%   2. ห้ามทำ N (กึ่งดึก) 2 คืนติดต่อกัน
%%   3. ต้องมีวันหยุดอย่างน้อย 2 วันในทุก 7 วันต่อเนื่อง
%%   4. แต่ละพยาบาลต้องทำ N ไม่น้อยกว่า min_night_shifts ครั้ง
%%      (เพื่อความเป็นธรรม)
%%
%% Objective: Minimize จำนวนกะกึ่งดึกรวม (fairness)
%%            ถ้า minimize เท่ากัน ให้กระจาย N ให้เท่าที่สุด
%%
%% รันด้วย: minizinc homework4_starter.mzn homework4_data.dzn

include "regular.mzn";

int: n_nurses;
int: n_days;
int: min_night_shifts;   % จำนวนกะ N ขั้นต่ำต่อพยาบาล

enum SHIFT = { D, E, N, O };

%% req[day, shift_index]: จำนวนพยาบาลที่ต้องการ
%% shift_index: 1=D, 2=E, 3=N
array[1..n_days, 1..3] of int: req;

%% ── ให้นักศึกษาเพิ่มส่วนต่อไปนี้ ──────────────────────────
%% Decision Variables:
%%   - roster[nurse, day]: var SHIFT
%% Constraints:
%%   - demand ทุกวันทุกกะ
%%   - ห้าม N 2 คืนติด (ลองใช้ regular หรือ forall)
%%   - หยุดอย่างน้อย 2 วัน ในทุก 7 วัน
%%   - แต่ละคนทำ N >= min_night_shifts ครั้ง
%% Objective: minimize total N shifts
