%% ===================================================
%% WORKSHOP 5B: Bin Packing — จัดสินค้าลงคอนเทนเนอร์
%% ===================================================
%%
%% โจทย์: สินค้า 12 รายการ น้ำหนัก (กก.):
%%   [15, 22, 8, 30, 11, 25, 18, 7, 33, 14, 20, 9]
%%   คอนเทนเนอร์ความจุ 50 กก./ใบ
%%   Minimize จำนวนคอนเทนเนอร์
%%
%% ขั้นตอน:
%%   1) เพิ่ม bin_packing_capa constraint
%%   2) เพิ่ม symmetry breaking
%%   3) solve minimize n_used
%%   4) ท้าทาย: สินค้า 1, 3, 5 เป็นสินค้าอันตราย ห้ามอยู่ตู้เดียวกัน
%%   5) คำนวณ: ถ้าตู้ใหม่ 80 กก. ราคา 4,500 บาท คุ้มไหม?

include "bin_packing_capa.mzn";
include "all_different.mzn";

int: n_items      = 12;
% array[1..n_items] of int: bin_capacity = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
array[1..n_items] of int: bin_capacity = [80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80];

array[1..n_items] of int: item_size = [15, 22, 8, 30, 11, 25, 18, 7, 33, 14, 20, 9];

set of int: ITEMS = 1..n_items;
set of int: BINS  = 1..n_items;  % worst case

array[ITEMS] of var BINS: bin_of;
array[BINS]  of var 0..1: used;

%% TODO 1: bin_packing_capa
constraint bin_packing_capa(bin_capacity, bin_of, item_size);

% constraint forall(b in BINS)(
%   sum(i in ITEMS where bin_of[i] = b)(item_size[i]) <= bin_capacity[b]
% );

%% TODO 2: Symmetry breaking
constraint forall(i in 1..n_items-1)(
  bin_of[i] <= bin_of[i+1] + 1
);

%% กำหนดว่ากล่องถูกใช้หรือไม่
constraint forall(b in BINS)(
  used[b] = bool2int(exists(i in ITEMS)(bin_of[i] = b))
);

var int: n_used = sum(b in BINS)(used[b]);

%% TODO 3: solve minimize n_used
solve minimize n_used;

%% TODO 4 (ท้าทาย): สินค้าอันตราย ห้ามอยู่ตู้เดียวกัน
constraint all_different([bin_of[1], bin_of[3], bin_of[5]]);

% constraint bin_of[1] != bin_of[3] /\
%            bin_of[3] != bin_of[5] /\
%            bin_of[1] != bin_of[5];
           

output [
  "=== Bin Packing ===\n",
  "คอนเทนเนอร์ที่ใช้: ", show(n_used), " ใบ\n"
] ++
[ "ตู้ " ++ show(b) ++ ": " ++
  concat(["#"++show(i)++"(" ++show(item_size[i])++ "กก.) "
         | i in ITEMS where fix(bin_of[i])=b]) ++
  "= " ++ show(sum(i in ITEMS where fix(bin_of[i])=b)(item_size[i])) ++ " กก.\n"
  | b in 1..fix(n_used) ];
