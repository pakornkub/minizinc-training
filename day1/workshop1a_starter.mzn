%% ===================================================
%% WORKSHOP 1A: Map Coloring — ไฟล์เริ่มต้นสำหรับผู้เรียน
%% ===================================================
%%
%% โจทย์: ระบายสีแผนที่ออสเตรเลีย (เริ่มจากโมเดลสำเร็จ)
%%
%% ขั้นตอน:
%%   1) รันโมเดลนี้ดูผลลัพธ์
%%   2) เปลี่ยน nc = 2 แล้วรันใหม่ — เกิดอะไรขึ้น?
%%   3) เพิ่มรัฐใหม่ 'act' ที่ติดกับ nsw และ v
%%   4) (ท้าทาย) เปลี่ยน solve satisfy เป็น solve minimize wa+nt+sa+q+nsw+v+t

int: nc = 3;  % ลอง: เปลี่ยนเป็น 2 แล้วดูผล

var 1..nc: wa;
var 1..nc: nt;
var 1..nc: sa;
var 1..nc: q;
var 1..nc: nsw;
var 1..nc: v;
var 1..nc: t;

% TODO ขั้นตอน 3: เพิ่มตัวแปร act ตรงนี้
% var 1..nc: act;

constraint wa != nt;
constraint wa != sa;
constraint nt != sa;
constraint nt != q;
constraint sa != q;
constraint sa != nsw;
constraint sa != v;
constraint q  != nsw;
constraint nsw != v;

% TODO ขั้นตอน 3: เพิ่ม constraint สำหรับ act ตรงนี้
% constraint act != nsw;
% constraint act != v;

solve satisfy;
% TODO ขั้นตอน 4: เปลี่ยนเป็น solve minimize ...

output [
  "wa=", show(wa), "  nt=", show(nt), "  sa=", show(sa), "\n",
  "q=",  show(q),  "  nsw=", show(nsw), "  v=", show(v), "\n",
  "t=",  show(t),  "\n"
  % TODO ขั้นตอน 3: เพิ่ม act ใน output
];
