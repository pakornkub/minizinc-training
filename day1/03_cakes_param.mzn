%% ตัวอย่างที่ 3: การอบเค้ก — แบบ Parameterized (ใช้ Data File)
%% อ้างอิง: docs.minizinc.dev - Datafiles and Assertions
%%
%% รันด้วย: minizinc 03_cakes_param.mzn 03_pantry.dzn
%%
%% ข้อดี: เปลี่ยนวัตถุดิบโดยแก้ data file ไม่ต้องแก้โมเดล

% --- Parameters (รับค่าจาก .dzn file) ---
int: flour;   % แป้ง (กรัม)
int: banana;  % กล้วย (ลูก)
int: sugar;   % น้ำตาล (กรัม)
int: butter;  % เนย (กรัม)
int: cocoa;   % โกโก้ (กรัม)

% ตรวจสอบว่าข้อมูลสมเหตุสมผล
constraint assert(flour  >= 0, "แป้งต้องไม่ติดลบ");
constraint assert(banana >= 0, "กล้วยต้องไม่ติดลบ");
constraint assert(sugar  >= 0, "น้ำตาลต้องไม่ติดลบ");
constraint assert(butter >= 0, "เนยต้องไม่ติดลบ");
constraint assert(cocoa  >= 0, "โกโก้ต้องไม่ติดลบ");

% --- Decision Variables ---
var 0..100: b;  % จำนวนเค้กกล้วย
var 0..100: c;  % จำนวนเค้กช็อกโกแลต

% --- Constraints ---
constraint 250*b + 200*c <= flour;
constraint 2*b            <= banana;
constraint 75*b  + 150*c  <= sugar;
constraint 100*b + 150*c  <= butter;
constraint 75*c            <= cocoa;

% --- Solve ---
solve maximize 400*b + 450*c;

% --- Output ---
output [
  "=== แผนการอบเค้ก ===\n",
  "วัตถุดิบที่มี: แป้ง=", show(flour), "g, กล้วย=", show(banana),
  " ลูก, น้ำตาล=", show(sugar), "g, เนย=", show(butter), "g, โกโก้=", show(cocoa), "g\n",
  "เค้กกล้วย:     ", show(b), " ชิ้น\n",
  "เค้กช็อกโกแลต: ", show(c), " ชิ้น\n",
  "กำไรรวม:       ", show(400*b + 450*c), " บาท\n"
];
