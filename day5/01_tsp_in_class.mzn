%% ตัวอย่างที่ 1: Travelling Salesman Problem (TSP)
%% อ้างอิง: docs.minizinc.dev - circuit global constraint
%%
%% TSP: เยี่ยมทุกเมืองครั้งเดียว กลับต้นทาง minimize ระยะทางรวม
%%
%% circuit() บังคับว่า next[] เป็น Hamiltonian circuit
%% (ทุก node ถูกเยี่ยมครั้งเดียว และเชื่อมเป็นวงกลม)

include "circuit.mzn";

int: n = 5;  % จำนวนเมือง (รวมคลัง)
set of int: CITIES = 1..n;

% ระยะทางระหว่างเมือง (สมมาตร)
array[CITIES, CITIES] of int: dist = [|
%    1   2   3   4   5
     0, 10, 12, 18, 25  |  % เมือง 1 (คลัง)
    20,  0,  9, 14, 27  |  % เมือง 2
    12,  9,  0,  6, 15  |  % เมือง 3
     8, 14, 16,  0, 13  |  % เมือง 4
    15, 17, 11, 13,  0  |];% เมือง 5

% ตัวแปร: เมืองถัดไปจากแต่ละเมือง
array[CITIES] of var CITIES: next;

% circuit: ทุกเมืองถูกเยี่ยมครั้งเดียว เป็น Hamiltonian circuit
constraint circuit(next);

% ห้ามอยู่กับที่
constraint forall(i in CITIES)(next[i] != i);

% Minimize ระยะทางรวม
solve minimize sum(i in CITIES)(dist[i, next[i]]);

% Minimax ระยะทาง
% solve minimize max(i in CITIES)(dist[i, next[i]]);

output [
  "=== เส้นทาง TSP ===\n",
  "เส้นทาง: 1"
] ++
[ " → " ++ show(next[i]) | i in [1] ] ++
[ " → " ++ show(next[next[1]]) ] ++
[ " → " ++ show(next[next[next[1]]]) ] ++
[ " → " ++ show(next[next[next[next[1]]]]) ] ++
[ " → 1\n",
  "ระยะทางรวม: ", show(sum(i in CITIES)(dist[i, next[i]])), " กม.\n"
];
