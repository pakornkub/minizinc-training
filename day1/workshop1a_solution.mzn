%% ===================================================
%% WORKSHOP 1A: Map Coloring — เฉลย (เปิดดูหลังทำเสร็จ!)
%% ===================================================

int: nc = 3;

var 1..nc: wa;
var 1..nc: nt;
var 1..nc: sa;
var 1..nc: q;
var 1..nc: nsw;
var 1..nc: v;
var 1..nc: t;
var 1..nc: act;  % Australian Capital Territory (เพิ่มใหม่)

constraint wa != nt;
constraint wa != sa;
constraint nt != sa;
constraint nt != q;
constraint sa != q;
constraint sa != nsw;
constraint sa != v;
constraint q  != nsw;
constraint nsw != v;

% ACT ติดกับ NSW และ Victoria
constraint act != nsw;
constraint act != v;

% ขั้นตอน 4: minimize sum ของทุกค่า (แต่ยังต้องใช้ nc >= 3)
solve satisfy;

output [
  "=== เฉลย Workshop 1A ===\n",
  "wa=", show(wa), "  nt=", show(nt), "  sa=", show(sa), "\n",
  "q=",  show(q),  "  nsw=", show(nsw), "  v=", show(v), "\n",
  "t=",  show(t),  "  act=", show(act), "\n",
  "ใช้สีทั้งหมด ", show(nc), " สี\n"
];
