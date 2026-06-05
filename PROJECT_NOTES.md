# โครงการอบรม MiniZinc สำหรับงานอุตสาหกรรม
## บันทึกสำหรับสานต่องาน

---

## สถานะปัจจุบัน

| วัน | Slides | ไฟล์ .mzn/.dzn | สถานะ |
|-----|--------|----------------|-------|
| วันที่ 1 | Day1_MiniZinc_Slides.pptx | day1/ (9 ไฟล์) | ✅ เสร็จ |
| วันที่ 2 | Day2_MiniZinc_Slides.pptx | day2/ (15 ไฟล์) | ✅ เสร็จ |
| วันที่ 3 | Day3_MiniZinc_Slides.pptx | day3/ (9 ไฟล์) | ✅ เสร็จ |
| วันที่ 4 | Day4_MiniZinc_Slides.pptx | day4/ (10 ไฟล์) | ✅ เสร็จ |
| วันที่ 5 | Day5_MiniZinc_Slides.pptx | day5/ (11 ไฟล์) | ✅ เสร็จ |
| วันที่ 6 | Day6_MiniZinc_Slides.pptx | day6/ (7 ไฟล์) | ✅ เสร็จ |
| หลักสูตรรวม | MiniZinc_Training_Curriculum.docx | — | ✅ เสร็จ |

---

## โครงสร้างไฟล์

```
minizinc/
├── PROJECT_NOTES.md              ← ไฟล์นี้
├── MiniZinc_Training_Curriculum.docx   ← หลักสูตร 6 วัน (overview)
│
├── Day1_MiniZinc_Slides.pptx    ← Slides วันที่ 1 (23 slides)
├── Day2_MiniZinc_Slides.pptx    ← Slides วันที่ 2 (22 slides)
│
├── day1/
│   ├── 01_aust.mzn               ← ตัวอย่าง: Map Coloring
│   ├── 02_cakes.mzn              ← ตัวอย่าง: Maximize กำไร
│   ├── 03_cakes_param.mzn        ← ตัวอย่าง: แบบใช้ Data File
│   ├── 03_pantry.dzn             ← Data สำหรับ cakes_param
│   ├── 03_pantry2.dzn            ← Data ทางเลือก
│   ├── workshop1a_starter.mzn    ← Workshop 1A (ผู้เรียน)
│   ├── workshop1a_solution.mzn   ← Workshop 1A (เฉลย)
│   ├── workshop1b_starter.mzn    ← Workshop 1B (ผู้เรียน)
│   ├── workshop1b_param.mzn      ← Workshop 1B (แบบ data file)
│   ├── workshop1b_solution.mzn   ← Workshop 1B (เฉลย)
│   ├── workshop1b_data.dzn       ← Data Workshop 1B
│   └── workshop1b_data2.dzn      ← Data ทางเลือก Workshop 1B
│
└── day2/
    ├── 01_arrays_intro.mzn       ← ตัวอย่าง: Arrays พื้นฐาน
    ├── 02_forall_sum.mzn         ← ตัวอย่าง: forall, sum, where
    ├── 03_production_generic.mzn ← ตัวอย่าง: Generic model ด้วย Enum
    ├── 03_factory_data.dzn       ← Data (2 สินค้า)
    ├── 03_factory_data2.dzn      ← Data ทางเลือก (4 สินค้า)
    ├── 04_enum_types.mzn         ← ตัวอย่าง: Enum Types
    ├── 05_conditional.mzn        ← ตัวอย่าง: if-then-else + bool2int
    ├── workshop2a_starter.mzn    ← Workshop 2A (ผู้เรียน)
    ├── workshop2a_solution.mzn   ← Workshop 2A (เฉลย)
    ├── workshop2a_data.dzn       ← Data Workshop 2A (4 สินค้า)
    ├── workshop2a_data2.dzn      ← Data ทางเลือก (6 สินค้า)
    ├── workshop2b_starter.mzn    ← Workshop 2B (ผู้เรียน)
    ├── workshop2b_solution.mzn   ← Workshop 2B (เฉลย)
    └── workshop2b_data.dzn       ← Data Workshop 2B
```

---

## เนื้อหาแต่ละวัน (ตามหลักสูตร)

### วันที่ 1 — พื้นฐาน MiniZinc ✅
- **เช้า:** Optimization คืออะไร, ติดตั้ง IDE, Map Coloring (solve satisfy), Parameters vs. Variables
- **บ่าย:** Arithmetic operators, solve maximize/minimize, Data files (.dzn), assert()
- **Workshop 1A:** Map Coloring — เพิ่มรัฐใหม่, เปลี่ยน nc
- **Workshop 1B:** Production Planning — โรงงาน 2 สินค้า, แรงงาน+วัตถุดิบ

### วันที่ 2 — Arrays, Sets, Enum Types ✅
- **เช้า:** Arrays 1D/2D, Sets, forall, sum, list comprehensions, where clause
- **บ่าย:** Enumerated types, conditional expressions (if-then-else), bool2int
- **Workshop 2A:** Generic production — enum PRODUCTS/RESOURCES ใน data file
- **Workshop 2B:** Multi-line production — set of LINES allowed, minimize cost

### วันที่ 3 — Global Constraints ⬜
- **เช้า:** alldifferent, cumulative (resource scheduling), table constraint
- **บ่าย:** disjunctive, Job Shop Scheduling เบื้องต้น
- **Workshop 3A:** Maintenance scheduling ด้วย cumulative
- **Workshop 3B:** Job Shop Scheduling — ไลน์การผลิต 4 ออร์เดอร์

### วันที่ 4 — Scheduling เชิงลึก ⬜
- **เช้า:** Job Shop เชิงลึก, predicate, Flexible Job Shop
- **บ่าย:** Employee Rostering (3 กะ), regular constraint สำหรับ shift patterns
- **Workshop 4A:** Flexible Manufacturing — เครื่องจักรเลือกได้
- **Workshop 4B:** Shift scheduling — 10 คน, 14 วัน, กฎแรงงาน

### วันที่ 5 — Routing และ Packing ⬜
- **เช้า:** TSP (circuit global constraint), Vehicle Routing Problem
- **บ่าย:** Bin Packing, Knapsack (set variables)
- **Workshop 5A:** VRP — รถส่งสินค้า 8 ลูกค้า 3 รถ
- **Workshop 5B:** Bin Packing — จัดคอนเทนเนอร์ 12 รายการ

### วันที่ 6 — Effective Modelling + Capstone ⬜
- **เช้า:** Variable bounds, redundant constraints, symmetry breaking, debugging
- **บ่าย:** Capstone Project — ผู้เรียนทำโมเดลจากงานจริง
- **Workshop 6A:** Debugging challenge (3 กรณี)

---

## วิธีสร้าง Slides (สำหรับวันที่ 3–6)

Slides สร้างด้วย JavaScript + pptxgenjs library

**Setup ที่ต้องมี:**
```bash
# ต้องติดตั้ง Node.js และ pptxgenjs
cd /tmp/work_folder
npm init -y
npm install pptxgenjs
node <script_name>.js
```

**Color palette ที่ใช้ตลอดทั้งหลักสูตร:**
```javascript
const C = {
  navy:    "1A3C5E",   // หัวข้อหลัก
  blue:    "2E86AB",   // section เช้า
  amber:   "F18F01",   // workshop / highlight
  amberLt: "FEF3E2",   // workshop background
  teal:    "0D7680",   // ตัวอย่าง / code accent
  green:   "1A6B47",   // positive / correct
  purple:  "6B46C1",   // section บ่าย / enum types
  codeBg:  "1E2D3D",   // code block background
  codeGn:  "7EC8A4",   // code: keywords green
  codeYl:  "F9E784",   // code: literals yellow
  codeBl:  "7BC8F0",   // code: types blue
  codeOr:  "F4A261",   // code: constraints orange
  codeWh:  "E8EDF2",   // code: general white
  codePu:  "C4B5FD",   // code: special purple
};
```

**Pattern สำคัญ (copy ไปใช้ได้เลย):**
```javascript
// Section label (chip ซ้ายบน)
function sectionLabel(slide, text, color) {
  slide.addShape(pres.shapes.RECTANGLE, { x:0.4, y:0.18, w:2.0, h:0.28, fill:{color:color} });
  slide.addText(text, { x:0.4, y:0.18, w:2.0, h:0.28, fontSize:9.5, color:"FFFFFF",
    fontFace:"Calibri", bold:true, align:"center", margin:0 });
}

// Card with left accent bar
function accentCard(slide, x, y, w, h, accentColor, bgColor) {
  slide.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill:{color:bgColor},
    shadow:{type:"outer",color:"000000",blur:8,offset:3,angle:135,opacity:0.12} });
  slide.addShape(pres.shapes.RECTANGLE, { x, y, w:0.07, h, fill:{color:accentColor} });
}

// Code block (dark background)
function codeBox(slide, x, y, w, h, lines, accentColor) { ... }

// Footer
function addFooter(slide, num, total, section) {
  slide.addText(`วันที่ N: หัวข้อ${section ? " — " + section : ""}`, {
    x:0.4, y:5.3, w:8, h:0.25, fontSize:9, color:"718096", fontFace:"Calibri"
  });
  slide.addText(`${num} / ${total}`, {
    x:9.2, y:5.3, w:0.6, h:0.25, fontSize:9, color:"718096", fontFace:"Calibri", align:"right"
  });
}
```

**ข้อควรระวัง Layout:**
- Slide ขนาด 10" × 5.625" (LAYOUT_16x9)
- Content ควรอยู่ใน y < 5.15 (footer อยู่ที่ y=5.3)
- Card spacing: h=0.85–0.92 ต่อ card, 4 cards ต่อหน้าพอดี
- Code block: แต่ละบรรทัด ~0.18–0.22 นิ้ว ที่ font 10–11pt
- ภาษาไทยแสดงผลถูกต้องใน PowerPoint/Google Slides (LibreOffice preview เท่านั้นที่เป็น ?)

---

## Global Constraints สำหรับวันที่ 3–4 (reference)

| Constraint | include | ใช้กับ |
|-----------|---------|-------|
| `alldifferent(array)` | globals.mzn | Assignment, no-duplicate |
| `cumulative(s,d,r,b)` | cumulative.mzn | Resource scheduling |
| `disjunctive(s,d)` | disjunctive.mzn | Machine no-overlap |
| `table(x, tuples)` | table.mzn | Lookup table |
| `regular(seq,trans,q0,F)` | regular.mzn | Shift patterns |
| `circuit(next)` | circuit.mzn | TSP/VRP |
| `bin_packing(cap,bin_of,w)` | bin_packing.mzn | Bin packing |

---

## Context การอบรม

- **กลุ่มเป้าหมาย:** พนักงานภาคอุตสาหกรรม ไม่มีพื้นฐาน programming
- **จำนวน:** 6 วัน × 6 ชั่วโมง (เช้า 3 ชม. + บ่าย 3 ชม.)
- **เป้าหมายสุดท้าย:** แก้ปัญหา Scheduling, Vehicle Routing, Bin Packing ได้
- **อ้างอิง:** https://docs.minizinc.dev/en/stable/part_2_tutorial.html
- **เครื่องมือ:** MiniZinc IDE (minizinc.org) — ฟรี, รองรับ Windows/Mac/Linux

---

## โครงสร้างไฟล์วันที่ 3 (เพิ่มเติม)

```
day3/
├── 01_alldifferent.mzn      ← SEND+MORE=MONEY (cryptarithmetic)
├── 01b_assignment.mzn       ← มอบหมายงาน minimize เวลา (alldifferent)
├── 02_cumulative.mzn        ← Resource scheduling (enum JOBS)
├── 02_moving_data.dzn       ← Data: ขนย้ายเฟอร์นิเจอร์ (จาก tutorial)
├── 03_table_constraint.mzn  ← เลือกวัสดุจากตาราง spec
├── 04_jobshop_basic.mzn     ← Job Shop พื้นฐาน (disjunctive + precedence)
├── 04_jobshop_data.dzn      ← Data: 3 jobs × 3 tasks
├── workshop3a_starter.mzn   ← Maintenance scheduling (ผู้เรียน)
├── workshop3a_solution.mzn  ← เฉลย
├── workshop3b_starter.mzn   ← Job Shop 4 orders (ผู้เรียน)
└── workshop3b_solution.mzn  ← เฉลย
```

## โครงสร้างไฟล์วันที่ 4 (เพิ่มเติม)

```
day4/
├── 01_jobshop_predicate.mzn  ← Job Shop + predicate no_overlap
├── 01_jobshop_data.dzn       ← Data: 4 jobs × 3 tasks
├── 02_flexible_jobshop.mzn   ← Flexible Job Shop (machine variable)
├── 02_flexible_data.dzn      ← Data: 3 jobs, 2 tasks, 3 machines
├── 03_rostering_basic.mzn    ← Employee Rostering พื้นฐาน
├── 03_rostering_data.dzn     ← Data: 6 พนักงาน 7 วัน
├── 04_regular_constraint.mzn ← Regular constraint (DFA nurse rostering)
├── 04_regular_data.dzn       ← Data: 7 พยาบาล 10 วัน
├── workshop4a_starter.mzn    ← Flexible Manufacturing (ผู้เรียน)
├── workshop4a_data.dzn       ← Data: 4 orders, 3 tasks, 3 machines
├── workshop4a_solution.mzn   ← เฉลย 4A
├── workshop4b_starter.mzn    ← Shift Scheduling 10 คน 14 วัน (ผู้เรียน)
└── workshop4b_solution.mzn   ← เฉลย 4B
```

## Prompt สำหรับเริ่มต่อ (วันที่ 4)

เปิด conversation ใหม่กับ Claude แล้ว:
1. เลือก folder `minizinc/` นี้เป็น workspace
2. บอก Claude ว่า: **"ขอวันที่ 4 ต่อเลย — ดูไฟล์ PROJECT_NOTES.md ก่อน"**
3. Claude จะอ่าน notes นี้และสานต่องานได้ทันที

เนื้อหาวันที่ 6 ที่ต้องทำ:
- Slides: Variable bounds, redundant constraints, symmetry breaking, debugging workflow,
          Capstone Project options, การนำเสนอ
- ไฟล์: 01_bounds_example.mzn (before/after bounds),
         02_redundant_constraints.mzn,
         03_symmetry_breaking.mzn,
         debug_broken_1.mzn / 2 / 3 (debugging challenge),
         capstone_template.mzn (generic template สำหรับ workshop)
