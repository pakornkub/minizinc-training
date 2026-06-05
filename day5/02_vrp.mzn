%% ตัวอย่างที่ 2: Vehicle Routing Problem (VRP)
%% อ้างอิง: docs.minizinc.dev - Circuit constraint
%%
%% VRP: หลาย vehicle, หลายลูกค้า, แต่ละ vehicle มี capacity จำกัด
%% Depot (คลัง) แทนด้วย node พิเศษ n_vehicles node (1 ต่อรถ)
%%
%% รันด้วย: minizinc 02_vrp.mzn 02_vrp_data.dzn

include "circuit.mzn";

int: n_customers;
int: n_vehicles;
int: capacity;

set of int: CUSTOMERS = 1..n_customers;
set of int: VEHICLES  = 1..n_vehicles;

% Node: 1..n_customers = ลูกค้า, n_customers+1..n_customers+n_vehicles = depot copy
int: n_nodes = n_customers + n_vehicles;
set of int: NODES = 1..n_nodes;
set of int: DEPOTS = n_customers+1..n_nodes;

array[CUSTOMERS] of int: demand;
array[NODES, NODES] of int: dist;  % รวม depot nodes

% ตัวแปร: เส้นทางถัดไปของแต่ละ node
array[NODES] of var NODES: next;

% circuit: Hamiltonian circuit ครอบทุก node
constraint circuit(next);

% Capacity: รถแต่ละคันต้องไม่บรรทุกเกิน capacity
% (คำนวณโดยติดตามเส้นทางจาก depot แต่ละคัน)
% simplified: ใช้ subcircuit approach
% นับ demand ทุก node ที่อยู่ใน subtour ของแต่ละรถ <= capacity
array[NODES] of var 0..capacity: load;  % load สะสม

constraint forall(i in CUSTOMERS)(
  load[i] = demand[i] +
  (if next[i] in DEPOTS then 0 else load[next[i]] endif)
);
constraint forall(d in DEPOTS)(load[d] = 0);
constraint forall(i in CUSTOMERS)(load[i] <= capacity);

% Minimize ระยะทางรวม
solve minimize sum(i in NODES)(dist[i, next[i]]);

output [
  "=== VRP Solution ===\n",
  "next = ", show(next), "\n",
  "load = ", show([load[i] | i in CUSTOMERS]), "\n",
  "ระยะทางรวม: ", show(sum(i in NODES)(dist[i, next[i]])), "\n"
];
