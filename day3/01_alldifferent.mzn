%% ตัวอย่างที่ 1: alldifferent — ทุกค่าต้องต่างกัน
%% อ้างอิง: docs.minizinc.dev - Global Constraints (2.2.2, 2.3.1.1)
%%
%% alldifferent(array) บังคับว่าทุกตัวแปรในอาร์เรย์ต้องมีค่าต่างกัน
%% ดีกว่าเขียน forall(i<j)(x[i] != x[j]) เพราะ solver มี algorithm พิเศษ

include "globals.mzn";

%% ── ตัวอย่าง 1: SEND + MORE = MONEY (Cryptarithmetic) ──
%% แต่ละตัวอักษรแทนตัวเลข 0-9 ที่ต่างกัน

var 1..9: S; var 0..9: E; var 0..9: N; var 0..9: D;
var 1..9: M; var 0..9: O; var 0..9: R; var 0..9: Y;

% ทุกตัวอักษรต้องเป็นตัวเลขต่างกัน
constraint alldifferent([S, E, N, D, M, O, R, Y]);

% ผลรวมต้องถูกต้อง
constraint
  1000*S + 100*E + 10*N + D
+ 1000*M + 100*O + 10*R + E
= 10000*M + 1000*O + 100*N + 10*E + Y;

solve satisfy;

output [
  "  ", show(S), show(E), show(N), show(D), "\n",
  "+ ", show(M), show(O), show(R), show(E), "\n",
  "=", show(M), show(O), show(N), show(E), show(Y), "\n"
];
