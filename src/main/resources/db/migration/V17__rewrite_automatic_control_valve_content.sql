-- ============================================================
-- V17: Rewrite the Automatic Control Valve content
--
-- The supplied Automatic Control Valve document is the source of truth for
-- every product in the range. Three things change.
--
-- 1. NO TECHNICAL TABLE
-- ---------------------
-- The range's product pages no longer render a specifications table, so
-- san_pham.specs is cleared for every ACV product. The figures the document
-- gives (DN, PN, accuracies, materials, head loss, ...) are not lost: they
-- move into `features`, which the detail page renders as a plain bullet
-- list. Nothing is invented — every bullet is a line from the document.
--
-- specs stays populated for the other four ranges, whose pages still show
-- the table, so neither the column nor the .spec-table markup is removed.
--
-- 2. ONE SHARED BROCHURE
-- ----------------------
-- Every product under the Pilot Operated Control Valves subtree now carries
-- Brochure_Neptune_EN. The subtree is resolved from category.parent_id
-- rather than from a name list, so products added to a new sub-series pick
-- the brochure up by placement.
--
-- The N550 sits in that subtree (1.2 Overpressure Protection) and also in
-- Anti Water Hammer Valves. It keeps its own datasheet, added by V11 from
-- the Omeax N550 PDF, and gains the brochure alongside it.
--
-- 3. MODEL NAMES
-- --------------
-- Five names are corrected to the spelling the document uses ("Reducing"
-- for "Reduce", "By-Pass" for "By Pass", "Differential" for "Different").
--
-- CATEGORY EDITORIAL COLUMNS
-- --------------------------
-- V16 moved the retired placeholder row's blurb, range specification table
-- and Neptune brochure onto the pilot-operated-control-valves category row,
-- for the category page to render. That page is gone and the brochure now
-- lives on the products themselves, so the three columns have no reader
-- left and the Category entity no longer maps them. They are emptied rather
-- than dropped, following the convention V10 set for `link`: superseding a
-- column and dropping it are separate decisions.
-- ============================================================

-- ── 1. Anti Water Hammer Valves ─────────────────────────────────────────
-- Description is replaced from the document. applications and features stay
-- as V9 transcribed them from the N550 datasheet; the document supplies no
-- replacement for either, and they are real datasheet content.
UPDATE san_pham SET
    mo_ta = 'The Surge Anticipation Valve is essential for protecting pumps, pumping equipment, and applicable pipelines from dangerous pressure surges caused by rapid changes in flow velocity. When pumping systems are started and stopped gradually, harmful surges do not occur. However, in the event of a power failure, the sudden stoppage of the pump can cause dangerous pressure surges that may result in severe equipment damage. A pump power failure usually causes a down surge in pressure, followed by an up surge. The surge control valve opens during the initial low-pressure wave, diverting the returning high-pressure wave away from the system. The valve then closes slowly without generating additional pressure surges.',
    specs = NULL
 WHERE ten = 'N550 - Surge Anticipation Valve';

-- ── 2.1.1 Pressure Reducing Series ──────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'Pipeline systems need to provide stable pressure to users. The pressure reducing valve automatically reduces higher inlet pressure to a stable lower outlet pressure, regardless of changing flow rate and/or varying inlet pressure.',
    features = '["Static pressure reducing: the valve maintains pressure even when flow is zero and no user is consuming water","Static pressure reduction: less than 10% for one year according to UL static test","Regulation accuracy: ±5%","Inlet pressure must be 1.5 bar higher than outlet pressure"]',
    specs = NULL
 WHERE ten = 'N200 / NR200 - Pressure Reducing Valve FB/RB';

UPDATE san_pham SET
    ten = 'N20B / NR20B - Pressure Reducing Valve with Small Flow By-Pass',
    mo_ta = 'A bypass pressure-reducing pipeline is installed alongside the main pressure-reducing valve. During periods such as late at night, when the end user requires only a very small flow rate, the main valve closes while the bypass pressure-reducing pipeline opens to maintain stable outlet pressure.',
    specs = NULL
 WHERE ten = 'N20B / NR20B - Pressure Reduce Valve with Small Flow By Pass';

UPDATE san_pham SET
    mo_ta = 'The valve can be set to two different outlet pressures: high pressure for high-demand periods and low pressure for low-demand periods. A solenoid valve changes the flow path between the two settings.',
    features = '["Reduces leakage","Reduces the risk of pipe bursts","Allows high-pressure/low-pressure operation to be selected for different periods"]',
    specs = NULL
 WHERE ten = 'N20D / NR20D - Dual Stage Pressure Reducing Valve';

UPDATE san_pham SET
    mo_ta = 'An electronic actuator drives the pressure-reducing pilot and changes the pressure setting according to user requirements.',
    features = '["Timely pressure adjustment","IP68 approval"]',
    specs = NULL
 WHERE ten = 'N20M / NR20M - Pressure Management Valve';

UPDATE san_pham SET
    ten = 'N20L / NR20L - Low Outlet Pressure Reducing Valve',
    mo_ta = 'The main function is the same as the N200, but the outlet pressure can be adjusted to 0.1 - 1.0 bar.',
    specs = NULL
 WHERE ten = 'N20L / NR20L - Low Outlet Pressure Reduce Valve';

-- ── 2.1.2 Overpressure Protection and Water Hammer Prevention ───────────
UPDATE san_pham SET
    mo_ta = 'A screwed-angle-type safety valve designed to protect pipelines against overpressure. The safety valve opens to discharge excess pressure when pipeline pressure exceeds the preset value. When the pressure drops to the preset level, the valve closes.',
    features = '["DN: 15 - 50","Pressure range: PN10 / PN16 / PN25","Material options: SUS304 / SUS316 / SAF2205","Seals: PTFE / PCTFE"]',
    specs = NULL
 WHERE ten = 'D500 - Direct Acting Safety Valve';

UPDATE san_pham SET
    mo_ta = 'Used to discharge excess pressure and maintain upstream pressure according to the required setting.',
    features = '["Opening pressure: +0.2 bar","Opening speed: <0.5 seconds","Full closing pressure: -1 bar"]',
    specs = NULL
 WHERE ten = 'N500 - Pressure Sustaining / Relief Valve';

UPDATE san_pham SET
    ten = 'N520 - Pressure Sustaining and Reducing Valve',
    mo_ta = 'When the inlet pressure exceeds the setting of the sustaining pilot, the valve opens. The pressure-reducing pilot then maintains the outlet pressure at the preset value.',
    specs = NULL
 WHERE ten = 'N520 - Pressure Sustaining and Reduce Valve';

-- ── 2.1.3 Direct Acting Pressure Reducing Valve ─────────────────────────
UPDATE san_pham SET
    mo_ta = 'Designed for pipeline systems that require stable pressure for users. The D200 automatically reduces higher inlet pressure to a stable lower outlet pressure, even when the flow rate and/or inlet pressure varies.',
    features = '["Change of outlet pressure / change of inlet pressure: <0.1","Setting pressure can be adjusted using the adjustment screw","When there is no water consumption at the outlet, the valve closes immediately to achieve hydrostatic sealing","Regulation accuracy: ±5%","Outlet pressure must be higher than 1 bar"]',
    specs = NULL
 WHERE ten = 'D200 - Direct Acting Pressure Reducing Valve';

-- ── 2.2 Solenoid Control Series ─────────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'The Solenoid Control Valve is an ON/OFF control valve that opens or closes when receiving an electrical signal from the solenoid pilot. The valve consists of a main valve and a two-way solenoid valve. The solenoid valve alternately applies pressure to or relieves pressure from the diaphragm chamber of the main valve.',
    features = '["Normally open: de-energized solenoid opens the valve","Normally closed: energized solenoid opens the valve"]',
    specs = NULL
 WHERE ten = 'N600 - Solenoid Control Valve';

UPDATE san_pham SET
    ten = 'N660 - Dual Solenoid Control Valve and Manual By-Pass',
    mo_ta = 'The control chamber is equipped with two solenoid valves. When combined with a PLC, pressure sensor, flow meter and pumps, the dual-solenoid system can perform various pipeline control functions.',
    features = '["Quickly open or close the main valve","Adjust the valve opening","Maintain the valve at a fixed opening position"]',
    specs = NULL
 WHERE ten = 'N660 - Dual Solenoid Control Valve and Manual By Pass';

UPDATE san_pham SET
    mo_ta = 'The valve is equipped with a straight-stroke sensor for valve-position feedback with 4 - 20 mA or 0.5 - 4.5 V. When combined with a variable-frequency pump, flow meter, pressure sensor and PLC, it can perform a full range of pipeline control functions.',
    features = '["ON/OFF control","Flow regulation","Pressure regulation","Fixed-opening control","Rough instantaneous flow measurement","Cumulative flow measurement"]',
    specs = NULL
 WHERE ten = 'N66M - All Function Control Valve';

-- ── 2.3 Level Control Series ────────────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'The N100 is a modulating valve designed to accurately control water levels in tanks. The float pilot can be installed separately inside the tank or together with the main valve.',
    applications = '["Water tanks","Reservoirs","Pools","Other water storage facilities"]',
    features = '["Opens when the water level reaches a preset low point","Closes drip-tight when the water level reaches a preset high point","Water level difference: 20 mm"]',
    specs = NULL
 WHERE ten = 'N100 / NR100 - Float Control Valve';

UPDATE san_pham SET
    mo_ta = 'The main function is the same as the N100. If the float pilot fails, the valve can still be opened or closed through the solenoid valve.',
    specs = NULL
 WHERE ten = 'N160 / NR160 - Float and Solenoid Control Valve';

UPDATE san_pham SET
    mo_ta = 'The altitude control valve closes drip-tight and stops filling the water tower when the water level reaches the high-level setting. When the water level falls below the low-level setting, the valve automatically opens and resumes filling.',
    applications = '["Water-level control for high water towers"]',
    features = '["Altitude difference: 5 - 150 mm","Water-level control height: 20 - 1000 mm"]',
    specs = NULL
 WHERE ten = 'N10A / NR10A - Altitude Control Valve';

UPDATE san_pham SET
    mo_ta = 'The main function is the same as the N100. However, there is no back pressure in the control chamber of the main valve, so the main valve can be fully opened.',
    features = '["Adjustable water-level difference: 100 - 1000 mm"]',
    specs = NULL
 WHERE ten = 'N10B / NR10B - Bi-Level Control Valve';

-- ── 2.4 Flow Control Series ─────────────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'The Flow Control Valve prevents excessive flow by limiting the flow rate to a preset maximum, regardless of changing line pressure. The pilot control responds to the differential pressure produced across an orifice plate installed downstream of the valve.',
    features = '["Installation: the orifice plate and holder should be installed 1 - 5 pipe diameters downstream of the valve"]',
    specs = NULL
 WHERE ten = 'N400 / NR400 - Flow Control Valve';

UPDATE san_pham SET
    mo_ta = 'Provides a preset flow rate and then maintains the outlet pressure at the preset value.',
    specs = NULL
 WHERE ten = 'N420 / NR420 - Flow Control and Pressure Reducing Valve';

UPDATE san_pham SET
    ten = 'N800 / NR800 - Differential Pressure Control Valve',
    mo_ta = 'Maintains the differential pressure between the supply pipe and the return pipe.',
    applications = '["HVAC systems"]',
    specs = NULL
 WHERE ten = 'N800 / NR800 - Different Pressure Control Valve';

-- ── 2.5 Pump Station Check Valve ────────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'Installed at the outlet of the water pump in the pipeline. Checks and prevents water hammer.',
    specs = NULL
 WHERE ten = 'N300 - Check Valve';

UPDATE san_pham SET
    mo_ta = 'The double-chamber multi-function pump control valve is installed at the pump outlet to prevent and eliminate pipeline surges caused by pump start-up and shutdown. During pump start-up, inlet pressure gradually enters the valve chamber, allowing the valve to open slowly; the opening speed can be adjusted using the needle valve. During sudden power failure or pump shutdown, the main disc closes quickly under the combined action of its own gravity and water hammer, while the secondary disc closes slowly to prevent high-pressure water hammer at the rear end from damaging the pump upstream.',
    features = '["Can be fully opened","Low pressure loss"]',
    specs = NULL
 WHERE ten = 'N745 - Multi-Function Pump Control Valve';

-- ── 2.6.1 Check Valves ──────────────────────────────────────────────────
UPDATE san_pham SET
    mo_ta = 'Designed to provide smooth and silent flow.',
    features = '["Head loss: 0.6 WMC at 2 m/s","Backflow velocity: 0.2 s","Disc: stainless steel + EPDM","Body & diffuser: epoxy-coated ductile iron","Valve body: EN-GJS 500-7 or stainless steel"]',
    specs = NULL
 WHERE ten = 'Silent Check Valve';

UPDATE san_pham SET
    mo_ta = 'The nozzle check valve includes a diffuser to provide smoother and quieter flow.',
    features = '["Head loss: 0.5 WMC at 2 m/s","Backflow velocity: 0.2 s","Disc: stainless steel + EPDM","Body & diffuser: epoxy-coated ductile iron","Valve body: EN-GJS 500-7 or stainless steel"]',
    specs = NULL
 WHERE ten = 'Nozzle Check Valve';

UPDATE san_pham SET
    mo_ta = 'Designed for horizontal installation. The internal channel-nozzle design helps prevent turbulence and reduce pressure loss. The new design uses a front guide stem and bronze bush guide stem, replacing the previous structure that had only one-sided bush guidance. In the previous design, when installed horizontally, the valve disc acted as a single-arm beam. This caused slow closing when the valve stopped, improper disc resetting and potential leakage.',
    features = '["Internal channel-nozzle design that prevents turbulence and reduces pressure loss","Front guide stem and bronze bush guide stem","Anti-cavitation design in the internal flow channel"]',
    specs = NULL
 WHERE ten = 'Big Size Nozzle Check Valve';

-- ── 2.6.2 Air Valves ────────────────────────────────────────────────────
-- The document describes these two only as per-version feature lists, so
-- mo_ta stays NULL and the detail page renders the bullets alone.
UPDATE san_pham SET
    features = '["2F1F: air release; air intake; pipeline protection; one-level PP float; flush port","3F2F: mass air release; micro air release; air intake; pipeline protection; two-level PP float; flush port"]',
    specs = NULL
 WHERE ten = 'Micro Air Valve - 2F1F / 3F2F';

UPDATE san_pham SET
    features = '["3F2F: mass air release; micro air release; air intake; pipeline protection; two-level PP float; flush port","4F3F: mass air release; micro air release; anti-hammer; air intake; pipeline protection; three-level PP float; flush port"]',
    specs = NULL
 WHERE ten = 'Air Valve - 3F2F / 4F3F';

-- ── Shared brochure for the Pilot Operated Control Valves subtree ────────
WITH RECURSIVE pilot_subtree AS (
    SELECT id FROM category WHERE slug = 'pilot-operated-control-valves'
    UNION ALL
    SELECT c.id FROM category c JOIN pilot_subtree p ON c.parent_id = p.id
)
UPDATE san_pham s
   SET documents = '[{"label": "Brochure_Neptune_EN", "url": "/docs/brochure-neptune-en.pdf"}]'
 WHERE s.id IN (SELECT pc.product_id
                  FROM product_category pc
                  JOIN pilot_subtree t ON t.id = pc.category_id)
   AND s.ten <> 'N550 - Surge Anticipation Valve';

-- The N550 keeps the datasheet V11 gave it and gains the shared brochure.
UPDATE san_pham SET
    documents = '[{"label": "N550 surge anticipation valve - datasheet (EN)", "url": "/docs/n550-en.pdf"}, {"label": "Brochure_Neptune_EN", "url": "/docs/brochure-neptune-en.pdf"}]'
 WHERE ten = 'N550 - Surge Anticipation Valve';

-- ── Retire the category editorial columns ───────────────────────────────
UPDATE category
   SET description = NULL, specs = NULL, documents = NULL
 WHERE description IS NOT NULL OR specs IS NOT NULL OR documents IS NOT NULL;
