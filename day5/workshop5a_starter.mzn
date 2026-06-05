%% ===================================================
%% WORKSHOP 5A: จัดเส้นทางรถส่งสินค้า (VRP)
%% ===================================================
%%
%% โจทย์: คลัง 1 แห่ง, ลูกค้า 8 ราย, รถ 3 คัน
%%   capacity รถละ 100 กก.
%%   ปริมาณสินค้า: [25, 30, 15, 40, 20, 35, 10, 45] กก.
%%   Minimize ระยะทางรวม
%%
%% รันด้วย: minizinc workshop5a_starter.mzn workshop5a_data.dzn
%%
%% ขั้นตอน:
%%   1) เพิ่ม circuit constraint
%%   2) เพิ่ม capacity constraint (load ไม่เกิน 100 ต่อรถ)
%%   3) solve minimize total distance
%%   4) อ่านผลและตีความ — รถไหนไปลูกค้าไหน?
%%   5) ท้าทาย: เพิ่ม time window สำหรับลูกค้า 3 และ 6

include "circuit.mzn";

int: n_customers;
int: n_vehicles;
int: capacity;

int: n_nodes = n_customers + n_vehicles;
set of int: ALL   = 1..n_nodes;
set of int: CUST  = 1..n_customers;
set of int: DEPOT = n_customers+1..n_nodes;

array[CUST] of int: demand;
array[ALL, ALL] of int: dist;

array[ALL] of var ALL: next;
array[CUST] of var 0..capacity: load;

%% TODO 1: circuit constraint
% constraint ...;

%% TODO 2: Capacity — load ต่อ customer
%% ...

%% TODO 3: solve minimize ระยะทางรวม
solve satisfy;

output [
  "=== VRP Solution ===\n",
  "next = ", show(next), "\n",
  "ระยะทางรวม: ", show(sum(i in ALL)(dist[i, next[i]])), "\n"
];
