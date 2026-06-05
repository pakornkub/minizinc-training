# MiniZinc Training — Industrial Optimization

หลักสูตรอบรม MiniZinc สำหรับการแก้ปัญหา Optimization ในงานอุตสาหกรรม  
**6 วัน × 6 ชั่วโมง** — ออกแบบสำหรับพนักงานที่ไม่มีพื้นฐานการเขียนโปรแกรม

---

## สารบัญ

| วัน | หัวข้อ | Slides | ไฟล์ |
|-----|--------|--------|------|
| 1 | พื้นฐาน MiniZinc | `Day1_MiniZinc_Slides.pptx` | `day1/` |
| 2 | Arrays, Sets, Enum Types | `Day2_MiniZinc_Slides.pptx` | `day2/` |
| 3 | Global Constraints | `Day3_MiniZinc_Slides.pptx` | `day3/` |
| 4 | Scheduling เชิงลึก & Rostering | `Day4_MiniZinc_Slides.pptx` | `day4/` |
| 5 | Routing & Packing | `Day5_MiniZinc_Slides.pptx` | `day5/` |
| 6 | Effective Modelling & Capstone | `Day6_MiniZinc_Slides.pptx` | `day6/` |

---

## เนื้อหาแต่ละวัน

### วันที่ 1 — พื้นฐาน MiniZinc
- Decision Variables, Parameters, Constraints
- `solve satisfy` / `maximize` / `minimize`
- Data files (`.dzn`), `assert()`
- **Workshop 1A:** Map Coloring | **Workshop 1B:** Production Planning

### วันที่ 2 — Arrays, Sets, Enum Types
- Arrays 1D/2D, `forall`, `sum`, list comprehensions
- Enumerated types, `if-then-else`, `bool2int`
- **Workshop 2A:** Generic Production Planning | **Workshop 2B:** Multi-Line Production

### วันที่ 3 — Global Constraints
- `alldifferent`, `cumulative`, `table`, `disjunctive`
- Job Shop Scheduling พื้นฐาน
- **Workshop 3A:** Maintenance Scheduling | **Workshop 3B:** Job Shop 4 Orders

### วันที่ 4 — Scheduling เชิงลึก
- `predicate`, Flexible Job Shop
- Employee Rostering (3 กะ), `regular` constraint + DFA
- **Workshop 4A:** Flexible Manufacturing | **Workshop 4B:** Shift Scheduling

### วันที่ 5 — Routing & Packing
- TSP / VRP ด้วย `circuit()`, depot copies
- Bin Packing (`bin_packing_capa`), symmetry breaking, Knapsack
- **Workshop 5A:** VRP 8 ลูกค้า 3 รถ | **Workshop 5B:** Bin Packing Containers

### วันที่ 6 — Effective Modelling & Capstone
- Variable bounds, redundant constraints, debugging workflow
- Capstone Project — โมเดลจากปัญหาจริงขององค์กร
- **Workshop 6A:** Debugging Challenge (3 กรณี)

> **หมายเหตุสำหรับวิทยากร:** ไฟล์เฉลย (`*_solution.mzn`) ไม่ได้รวมใน repository นี้  
> เก็บไว้ใน folder ส่วนตัวและแจกจ่ายให้ผู้เรียนหลังทำ workshop แต่ละชุดเสร็จแล้ว

---

## Global Constraints อ้างอิงเร็ว

| Constraint | ใช้กับ | Include |
|-----------|--------|---------|
| `alldifferent(x)` | Assignment, no-duplicate | `globals.mzn` |
| `cumulative(s,d,r,b)` | Resource scheduling | `cumulative.mzn` |
| `disjunctive(s,d)` | Machine no-overlap | `disjunctive.mzn` |
| `table(x, tuples)` | Lookup table | `table.mzn` |
| `regular(seq,tr,q0,F)` | Shift patterns (DFA) | `regular.mzn` |
| `circuit(next)` | TSP / VRP | `circuit.mzn` |
| `bin_packing_capa(c,b,w)` | Bin Packing | `bin_packing_capa.mzn` |

---

## การติดตั้ง

1. ดาวน์โหลด **MiniZinc IDE** จาก [minizinc.org](https://www.minizinc.org/software.html) (ฟรี)
2. เปิดไฟล์ `.mzn` ใน IDE
3. สำหรับไฟล์ที่ต้องการ data: รัน `minizinc model.mzn data.dzn`

---

## อ้างอิง

- [MiniZinc Tutorial](https://docs.minizinc.dev/en/stable/part_2_tutorial.html)
- [MiniZinc Playground](https://play.minizinc.dev)
- [Global Constraints Catalog](https://sofdem.github.io/gccat/)
