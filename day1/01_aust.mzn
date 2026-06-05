%% ตัวอย่างที่ 1: การระบายสีแผนที่ออสเตรเลีย
%% อ้างอิง: docs.minizinc.dev - Basic Modelling
%%
%% โจทย์: ระบายสีแผนที่ 7 รัฐ โดยรัฐที่ติดกันต้องมีสีต่างกัน
%% ใช้สีน้อยที่สุดเท่าที่เป็นไปได้

% --- Parameters (ค่าคงที่ที่เราระบุ) ---
int: nc = 3;  % จำนวนสีที่ใช้

% --- Decision Variables (ตัวแปรที่ Solver จะหาค่าให้) ---
var 1..nc: wa;   % Western Australia
var 1..nc: nt;   % Northern Territory
var 1..nc: sa;   % South Australia
var 1..nc: q;    % Queensland
var 1..nc: nsw;  % New South Wales
var 1..nc: v;    % Victoria
var 1..nc: t;    % Tasmania

% --- Constraints (กฎที่ต้องเป็นจริง) ---
% รัฐที่มีพรมแดนติดกันต้องมีสีต่างกัน
constraint wa != nt;
constraint wa != sa;
constraint nt != sa;
constraint nt != q;
constraint sa != q;
constraint sa != nsw;
constraint sa != v;
constraint q  != nsw;
constraint nsw != v;
% Tasmania (t) ไม่ติดกับใคร ดังนั้นไม่มี constraint

% --- Solve ---
solve satisfy;  % หาคำตอบที่เป็นไปได้ใดก็ได้

% --- Output ---
output [
  "=== ผลการระบายสี ===\n",
  "WA  = สี ", show(wa),  "\n",
  "NT  = สี ", show(nt),  "\n",
  "SA  = สี ", show(sa),  "\n",
  "Q   = สี ", show(q),   "\n",
  "NSW = สี ", show(nsw), "\n",
  "V   = สี ", show(v),   "\n",
  "T   = สี ", show(t),   "\n",
  "จำนวนสีที่ใช้ = ", show(nc), "\n"
];
