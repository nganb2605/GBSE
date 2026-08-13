-- ============================================================
-- V18: Structured descriptions for the ACV range, and the N550 document fix
--
-- DESCRIPTION AS A STRUCTURED BLOCK
-- --------------------------------
-- The product page no longer renders a Features list, so V17's split of the
-- supplied document between mo_ta (prose) and features (bullets) has nowhere
-- to put the bullets. Both halves are merged back into mo_ta, one point per
-- line, and features is cleared for the range.
--
-- mo_ta is therefore a newline-separated list of points, not a paragraph:
-- Product.getDescriptionLines() splits it and the page renders one row per
-- line. Nothing from the supplied document is dropped — the DN/PN/material/
-- accuracy lines V17 filed under features are now description rows.
--
-- Only the ACV range is touched. The other four ranges keep mo_ta as plain
-- prose; a single-line description renders as a single row, so the same
-- template serves both.
--
-- N550 DOCUMENT
-- -------------
-- V17 gave the N550 the Neptune brochure because the catalogue also files it
-- under 1.2 Overpressure Protection, inside the Pilot Operated Control Valves
-- subtree. That was wrong: the brochure covers the pilot operated range, and
-- the N550 has a datasheet of its own (V11). The brochure is removed and the
-- datasheet is its only document. The subtree rule still governs every other
-- product, so the N550 is the one documented exception.
-- ============================================================

-- ── 1. Anti Water Hammer Valves ─────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'The Surge Anticipation Valve is essential for protecting pumps, pumping equipment, and applicable pipelines from dangerous pressure surges caused by rapid changes in flow velocity.
When pumping systems are started and stopped gradually, harmful surges do not occur. However, in the event of a power failure, the sudden stoppage of the pump can cause dangerous pressure surges that may result in severe equipment damage.
A pump power failure usually causes a down surge in pressure, followed by an up surge.
The surge control valve opens during the initial low-pressure wave, diverting the returning high-pressure wave away from the system.
The valve then closes slowly without generating additional pressure surges.'
 WHERE ten = 'N550 - Surge Anticipation Valve';

-- ── 2.1.1 Pressure Reducing Series ──────────────────────────────────────
UPDATE san_pham SET mo_ta =
'Pipeline systems need to provide stable pressure to users.
The pressure reducing valve automatically reduces higher inlet pressure to a stable lower outlet pressure, regardless of changing flow rate and/or varying inlet pressure.
Static pressure reducing: the valve maintains pressure even when flow is zero and no user is consuming water.
Static pressure reduction: less than 10% for one year according to UL static test.
Regulation accuracy: ±5%.
Inlet pressure must be 1.5 bar higher than outlet pressure.'
 WHERE ten = 'N200 / NR200 - Pressure Reducing Valve FB/RB';

UPDATE san_pham SET mo_ta =
'A bypass pressure-reducing pipeline is installed alongside the main pressure-reducing valve.
During periods such as late at night, when the end user requires only a very small flow rate, the main valve closes while the bypass pressure-reducing pipeline opens to maintain stable outlet pressure.'
 WHERE ten = 'N20B / NR20B - Pressure Reducing Valve with Small Flow By-Pass';

UPDATE san_pham SET mo_ta =
'The valve can be set to two different outlet pressures: high pressure for high-demand periods and low pressure for low-demand periods.
A solenoid valve changes the flow path between the two settings.
Reduces leakage.
Reduces the risk of pipe bursts.
Allows high-pressure/low-pressure operation to be selected for different periods.'
 WHERE ten = 'N20D / NR20D - Dual Stage Pressure Reducing Valve';

UPDATE san_pham SET mo_ta =
'An electronic actuator drives the pressure-reducing pilot and changes the pressure setting according to user requirements.
Timely pressure adjustment.
IP68 approval.'
 WHERE ten = 'N20M / NR20M - Pressure Management Valve';

UPDATE san_pham SET mo_ta =
'The main function is the same as the N200, but the outlet pressure can be adjusted to 0.1 - 1.0 bar.'
 WHERE ten = 'N20L / NR20L - Low Outlet Pressure Reducing Valve';

-- ── 2.1.2 Overpressure Protection and Water Hammer Prevention ───────────
UPDATE san_pham SET mo_ta =
'A screwed-angle-type safety valve designed to protect pipelines against overpressure.
The safety valve opens to discharge excess pressure when pipeline pressure exceeds the preset value. When the pressure drops to the preset level, the valve closes.
DN: 15 - 50.
Pressure range: PN10 / PN16 / PN25.
Material options: SUS304 / SUS316 / SAF2205.
Seals: PTFE / PCTFE.'
 WHERE ten = 'D500 - Direct Acting Safety Valve';

UPDATE san_pham SET mo_ta =
'Used to discharge excess pressure and maintain upstream pressure according to the required setting.
Opening pressure: +0.2 bar.
Opening speed: <0.5 seconds.
Full closing pressure: -1 bar.'
 WHERE ten = 'N500 - Pressure Sustaining / Relief Valve';

UPDATE san_pham SET mo_ta =
'When the inlet pressure exceeds the setting of the sustaining pilot, the valve opens.
The pressure-reducing pilot then maintains the outlet pressure at the preset value.'
 WHERE ten = 'N520 - Pressure Sustaining and Reducing Valve';

-- ── 2.1.3 Direct Acting Pressure Reducing Valve ─────────────────────────
UPDATE san_pham SET mo_ta =
'Designed for pipeline systems that require stable pressure for users.
The D200 automatically reduces higher inlet pressure to a stable lower outlet pressure, even when the flow rate and/or inlet pressure varies.
Change of outlet pressure / change of inlet pressure: <0.1.
Setting pressure can be adjusted using the adjustment screw.
When there is no water consumption at the outlet, the valve closes immediately to achieve hydrostatic sealing.
Regulation accuracy: ±5%.
Outlet pressure must be higher than 1 bar.'
 WHERE ten = 'D200 - Direct Acting Pressure Reducing Valve';

-- ── 2.2 Solenoid Control Series ─────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'The Solenoid Control Valve is an ON/OFF control valve that opens or closes when receiving an electrical signal from the solenoid pilot.
The valve consists of a main valve and a two-way solenoid valve. The solenoid valve alternately applies pressure to or relieves pressure from the diaphragm chamber of the main valve.
Normally open: de-energized solenoid opens the valve.
Normally closed: energized solenoid opens the valve.'
 WHERE ten = 'N600 - Solenoid Control Valve';

UPDATE san_pham SET mo_ta =
'The control chamber is equipped with two solenoid valves.
The valve can quickly open or close the main valve, adjust the valve opening, and maintain the valve at a fixed opening position.
When combined with a PLC, pressure sensor, flow meter and pumps, the dual-solenoid system can perform various pipeline control functions.'
 WHERE ten = 'N660 - Dual Solenoid Control Valve and Manual By-Pass';

UPDATE san_pham SET mo_ta =
'The valve is equipped with a straight-stroke sensor for valve-position feedback with 4 - 20 mA or 0.5 - 4.5 V.
When combined with a variable-frequency pump, flow meter, pressure sensor and PLC, it can perform ON/OFF control, flow regulation, pressure regulation, fixed-opening control, rough instantaneous flow measurement and cumulative flow measurement.'
 WHERE ten = 'N66M - All Function Control Valve';

-- ── 2.3 Level Control Series ────────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'The N100 is a modulating valve designed to accurately control water levels in tanks.
The valve opens when the water level reaches a preset low point and closes drip-tight when the water level reaches a preset high point.
The float pilot can be installed separately inside the tank or together with the main valve.
Water level difference: 20 mm.'
 WHERE ten = 'N100 / NR100 - Float Control Valve';

UPDATE san_pham SET mo_ta =
'The main function is the same as the N100.
If the float pilot fails, the valve can still be opened or closed through the solenoid valve.'
 WHERE ten = 'N160 / NR160 - Float and Solenoid Control Valve';

UPDATE san_pham SET mo_ta =
'The altitude control valve closes drip-tight and stops filling the water tower when the water level reaches the high-level setting.
When the water level falls below the low-level setting, the valve automatically opens and resumes filling.
Altitude difference: 5 - 150 mm.
Water-level control height: 20 - 1000 mm.'
 WHERE ten = 'N10A / NR10A - Altitude Control Valve';

UPDATE san_pham SET mo_ta =
'The main function is the same as the N100.
However, there is no back pressure in the control chamber of the main valve, so the main valve can be fully opened.
Adjustable water-level difference: 100 - 1000 mm.'
 WHERE ten = 'N10B / NR10B - Bi-Level Control Valve';

-- ── 2.4 Flow Control Series ─────────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'The Flow Control Valve prevents excessive flow by limiting the flow rate to a preset maximum, regardless of changing line pressure.
The pilot control responds to the differential pressure produced across an orifice plate installed downstream of the valve.
The orifice plate and holder should be installed 1 - 5 pipe diameters downstream of the valve.'
 WHERE ten = 'N400 / NR400 - Flow Control Valve';

UPDATE san_pham SET mo_ta =
'Provides a preset flow rate and then maintains the outlet pressure at the preset value.'
 WHERE ten = 'N420 / NR420 - Flow Control and Pressure Reducing Valve';

UPDATE san_pham SET mo_ta =
'Maintains the differential pressure between the supply pipe and the return pipe.'
 WHERE ten = 'N800 / NR800 - Differential Pressure Control Valve';

-- ── 2.5 Pump Station Check Valve ────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'Installed at the outlet of the water pump in the pipeline.
Checks and prevents water hammer.'
 WHERE ten = 'N300 - Check Valve';

UPDATE san_pham SET mo_ta =
'The double-chamber multi-function pump control valve is installed at the pump outlet to prevent and eliminate pipeline surges caused by pump start-up and shutdown.
During pump start-up, inlet pressure gradually enters the valve chamber, allowing the valve to open slowly; the opening speed can be adjusted using the needle valve.
During sudden power failure or pump shutdown, the main disc closes quickly under the combined action of its own gravity and water hammer, while the secondary disc closes slowly to prevent high-pressure water hammer at the rear end from damaging the pump upstream.
Can be fully opened.
Low pressure loss.'
 WHERE ten = 'N745 - Multi-Function Pump Control Valve';

-- ── 2.6.1 Check Valves ──────────────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'Designed to provide smooth and silent flow.
Head loss: 0.6 WMC at 2 m/s.
Backflow velocity: 0.2 s.
Disc: stainless steel + EPDM.
Body & diffuser: epoxy-coated ductile iron.
Valve body: EN-GJS 500-7 or stainless steel.'
 WHERE ten = 'Silent Check Valve';

UPDATE san_pham SET mo_ta =
'The nozzle check valve includes a diffuser to provide smoother and quieter flow.
Head loss: 0.5 WMC at 2 m/s.
Backflow velocity: 0.2 s.
Disc: stainless steel + EPDM.
Body & diffuser: epoxy-coated ductile iron.
Valve body: EN-GJS 500-7 or stainless steel.'
 WHERE ten = 'Nozzle Check Valve';

UPDATE san_pham SET mo_ta =
'Designed for horizontal installation.
The internal channel-nozzle design helps prevent turbulence and reduce pressure loss.
The new design uses a front guide stem and bronze bush guide stem, replacing the previous structure that had only one-sided bush guidance.
In the previous design, when installed horizontally, the valve disc acted as a single-arm beam. This caused slow closing when the valve stopped, improper disc resetting and potential leakage.
Anti-cavitation design in the internal flow channel.'
 WHERE ten = 'Big Size Nozzle Check Valve';

-- ── 2.6.2 Air Valves ────────────────────────────────────────────────────
UPDATE san_pham SET mo_ta =
'2F1F: air release; air intake; pipeline protection; one-level PP float; flush port.
3F2F: mass air release; micro air release; air intake; pipeline protection; two-level PP float; flush port.'
 WHERE ten = 'Micro Air Valve - 2F1F / 3F2F';

UPDATE san_pham SET mo_ta =
'3F2F: mass air release; micro air release; air intake; pipeline protection; two-level PP float; flush port.
4F3F: mass air release; micro air release; anti-hammer; air intake; pipeline protection; three-level PP float; flush port.'
 WHERE ten = 'Air Valve - 3F2F / 4F3F';

-- ── The bullets now live in mo_ta; the column has no reader left ─────────
UPDATE san_pham SET features = NULL WHERE range_id = 'automatic-control-valve';

-- ── N550: its own datasheet, not the pilot operated range brochure ───────
UPDATE san_pham SET
    documents = '[{"label": "N550 surge anticipation valve - datasheet (EN)", "url": "/docs/n550-en.pdf"}]'
 WHERE ten = 'N550 - Surge Anticipation Valve';
