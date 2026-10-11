-- ============================================================
-- V24: Set product images from productsimage folder
--
-- Product images have been placed in static/productsimage/.
-- This migration maps each product to its image file.
-- ============================================================

-- ── ACV Range: Anti Water Hammer ─────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n550.webp'
 WHERE source_folder = '4. Automatic Control Valve/4.1. Anti water hammer valves';

-- ── ACV Range: Pressure Reducing Series ──────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n200nr200.png'
 WHERE ten = 'N200 / NR200 - Pressure Reducing Valve FB/RB';

UPDATE san_pham SET hinh_anh = '/productsimage/n20b.png'
 WHERE ten = 'N20B / NR20B - Pressure Reducing Valve with Small Flow By-Pass';

UPDATE san_pham SET hinh_anh = '/productsimage/n20d.png'
 WHERE ten = 'N20D / NR20D - Dual Stage Pressure Reducing Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n20m.png'
 WHERE ten = 'N20M / NR20M - Pressure Management Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n20l.png'
 WHERE ten = 'N20L / NR20L - Low Outlet Pressure Reducing Valve';

-- ── ACV Range: Overpressure Protection ───────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/airvalve.png'
 WHERE ten = 'D500 - Direct Acting Safety Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n500.png'
 WHERE ten = 'N500 - Pressure Sustaining / Relief Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n520.png'
 WHERE ten = 'N520 - Pressure Sustaining and Reducing Valve';

-- ── ACV Range: Direct Acting Pressure Reducing ───────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/d200.png'
 WHERE ten = 'D200 - Direct Acting Pressure Reducing Valve';

-- ── ACV Range: Solenoid Control Series ───────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n600.png'
 WHERE ten = 'N600 - Solenoid Control Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n660.png'
 WHERE ten = 'N660 - Dual Solenoid Control Valve and Manual By-Pass';

UPDATE san_pham SET hinh_anh = '/productsimage/n66m.png'
 WHERE ten = 'N66M - All Function Control Valve';

-- ── ACV Range: Level Control Series ──────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n100.png'
 WHERE ten = 'N100 / NR100 - Float Control Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n160.png'
 WHERE ten = 'N160 / NR160 - Float and Solenoid Control Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n10a.png'
 WHERE ten = 'N10A / NR10A - Altitude Control Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n10b.png'
 WHERE ten = 'N10B / NR10B - Bi-Level Control Valve';

-- ── ACV Range: Flow Control Series ───────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n400.png'
 WHERE ten = 'N400 / NR400 - Flow Control Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n420.png'
 WHERE ten = 'N420 / NR420 - Flow Control and Pressure Reducing Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n800.png'
 WHERE ten = 'N800 / NR800 - Differential Pressure Control Valve';

-- ── ACV Range: Pump Station Check Valve ──────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/n300.png'
 WHERE ten = 'N300 - Check Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/n745.png'
 WHERE ten = 'N745 - Multi-Function Pump Control Valve';

-- ── ACV Range: Check Valves ──────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/checkvalves.png'
 WHERE ten = 'Silent Check Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/nozzlecheckvalves.png'
 WHERE ten = 'Nozzle Check Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/bignozzle.png'
 WHERE ten = 'Big Size Nozzle Check Valve';

-- ── ACV Range: Air Valves ────────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/2f1f.png'
 WHERE ten = 'Micro Air Valve - 2F1F / 3F2F';

UPDATE san_pham SET hinh_anh = '/productsimage/3f2f.png'
 WHERE ten = 'Air Valve - 3F2F / 4F3F';
