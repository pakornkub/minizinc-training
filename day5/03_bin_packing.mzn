%% ตัวอย่างที่ 3: Bin Packing
%% อ้างอิง: docs.minizinc.dev - Bin Packing
%%
%% Bin Packing: จัดสิ่งของลงกล่อง minimize จำนวนกล่องที่ใช้
%%
%% รันด้วย: minizinc 03_bin_packing.mzn 03_bins_data.dzn

include "bin_packing_capa.mzn";

int: n_items;
array[1..n_items] of int: bin_capacity;
array[1..n_items] of int: item_size;

% Upper bound จำนวนกล่องที่ต้องใช้ (worst case = 1 ชิ้น/กล่อง)
int: max_bins = n_items;
set of int: BINS  = 1..max_bins;
set of int: ITEMS = 1..n_items;

% ตัวแปร: กล่องที่ชิ้นงาน i อยู่
array[ITEMS] of var BINS: bin_of;

% ตัวแปร: กล่องถูกใช้หรือไม่ (1 = ใช้)
array[BINS] of var 0..1: used;

% bin_packing_capa: กล่องแต่ละใบไม่เกิน capacity
constraint bin_packing_capa(bin_capacity, bin_of, item_size);

% Symmetry breaking: ลำดับกล่องต้องเพิ่มขึ้น
% ถ้า item i อยู่ใน bin b ดังนั้น item i+1 อยู่ใน bin <= b+1
constraint forall(i in 1..n_items-1)(bin_of[i] <= bin_of[i+1] + 1);

% กล่องถูกใช้ถ้ามีของอยู่
constraint forall(b in BINS)(
  used[b] = bool2int(exists(i in ITEMS)(bin_of[i] = b))
);

% Minimize จำนวนกล่อง
var int: n_bins_used = sum(b in BINS)(used[b]);
solve minimize n_bins_used;

output [
  "=== Bin Packing ===\n",
  "กล่องที่ใช้: ", show(n_bins_used), " ใบ\n",
  "capacity: ", show(bin_capacity), " กก./ใบ\n\n"
] ++
[ "กล่อง " ++ show(b) ++ ": ชิ้น " ++
  concat([show(i)++" " | i in ITEMS where fix(bin_of[i])=b]) ++
  "(รวม " ++
  show(sum(i in ITEMS where fix(bin_of[i])=b)(item_size[i])) ++
  " กก.)\n"
  | b in 1..fix(n_bins_used) ];
