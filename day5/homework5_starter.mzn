%% ============================================================
%% HOMEWORK 5: จัดส่งอะไหล่ให้ลูกค้าและจัดบรรจุภัณฑ์
%% วิชา: MiniZinc for Industrial Optimization — วันที่ 5
%% ============================================================
%%
%% บริษัทต้องส่งอะไหล่ให้ลูกค้า n_customers ราย โดยใช้รถ n_vehicles คัน
%% ออกจากคลัง (depot) และกลับคลัง
%%
%% ส่วนที่ 1 — Routing:
%%   - แต่ละรถมี weight_cap กก. (น้ำหนักบรรทุกสูงสุด)
%%   - ลูกค้าแต่ละรายมี demand[c] กก.
%%   - Minimize ระยะทางรวม
%%
%% ส่วนที่ 2 — Packing (แยกต่างหากหรือรวมก็ได้):
%%   - อะไหล่มี n_items รายการ แต่ละชิ้นมี weight และ category
%%   - กล่องบรรจุความจุ box_cap กก.
%%   - อะไหล่ category "fragile" ห้ามอยู่กล่องเดียวกับ "heavy"
%%   - Minimize จำนวนกล่อง
%%
%% รันด้วย: minizinc homework5_starter.mzn homework5_data.dzn

include "circuit.mzn";
include "bin_packing_capa.mzn";

%% ── Routing ──────────────────────────────────────────────────
int: n_customers;
int: n_vehicles;
int: weight_cap;   % กก./คัน

array[1..n_customers] of int: demand;

%% dist[i,j]: i,j ∈ 1..n_customers+n_vehicles
%% nodes 1..n_customers = ลูกค้า, nodes n_customers+1..end = depot copies
int: n_nodes = n_customers + n_vehicles;
array[1..n_nodes, 1..n_nodes] of int: dist;

%% ── Packing ──────────────────────────────────────────────────
int: n_items;
int: box_cap;   % กก./กล่อง

array[1..n_items] of int: item_weight;
set of int: fragile_items;   % index ของอะไหล่ที่แตกง่าย
set of int: heavy_items;     % index ของอะไหล่หนัก

%% ── ให้นักศึกษาเพิ่มส่วนต่อไปนี้ ──────────────────────────
%% Routing: circuit + load tracking + minimize distance
%% Packing: bin_packing_capa + incompatibility constraint + minimize boxes
%% (สามารถแก้แยก 2 ส่วน หรือรวม solve เดียวก็ได้)
