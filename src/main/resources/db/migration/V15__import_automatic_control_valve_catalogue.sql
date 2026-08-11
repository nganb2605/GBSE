-- ============================================================
-- V15: Import the Automatic Control Valve catalogue
--
-- Content is transcribed from the supplied Automatic Control Valve
-- catalogue. Nothing is added from outside it: where the catalogue gives no
-- pressure rating, dimension, material, image or datasheet, the column stays
-- NULL rather than carrying a guessed value.
--
-- HIERARCHY
-- ---------
-- The schema carries two levels: range_id (top-level group) and danh_muc
-- (one child category per product). The catalogue is four levels deep, so
-- the three levels below the range are encoded into danh_muc as a path:
--
--   range_id = 'automatic-control-valve'   -> "Automatic Control Valve"
--   danh_muc = 'Pilot Operated Control Valves / 1. Pressure Control Series
--               / 1.1 Pressure Reducing Series'
--
-- This keeps the two top-level groups ("Anti Water Hammer Valves" and
-- "Pilot Operated Control Valves") distinct and preserves the series and
-- sub-series names, which a single flat category name would lose.
-- danh_muc is widened to fit the longest path (116 characters).
--
-- N550
-- ----
-- The catalogue lists the surge anticipation valve twice: once as the sole
-- member of "Anti Water Hammer Valves" and once under 1.2 Overpressure
-- Protection. san_pham has no product-category join table — danh_muc is a
-- single scalar column — so one row cannot sit in two categories, and a
-- second row would be a duplicate product with its own /products/{id}.
--
-- The existing N550 row (added by V9) is therefore reused and placed under
-- "Anti Water Hammer Valves", which is the placement that group needs to
-- exist at all. Its 1.2 listing is not reproduced. Restoring it needs a
-- product-category relationship, which is a schema change, not a data one.
--
-- V14 renamed that row to 'Anti water hammer valves' because V12 had
-- removed the child category and the family name had nowhere else to live.
-- The category exists again here, so the row goes back to its model name.
--
-- 'Pilot operated control valves' (V7) is kept as-is with a NULL danh_muc.
-- It renders as an untitled overview card at the head of the range and is
-- the only carrier of the Neptune range brochure and the range-wide
-- specification table, neither of which the supplied catalogue repeats.
--
-- Mapping used, following V11:
--   "Label: value" lines  -> specs      (JSON [{label,value}])
--   benefit bullets       -> features   (JSON [string])
--   prose sentences       -> mo_ta
--   first sentence, condensed -> short_text (the catalogue card blurb)
--
-- Obvious typos in the source are corrected ("ender user" -> "end user").
-- Images and datasheets: the catalogue supplies none, so hinh_anh and
-- documents stay NULL and every new product renders the shared placeholder.
-- ============================================================

-- The category path is longer than the original flat category name allowed.
ALTER TABLE san_pham ALTER COLUMN danh_muc TYPE VARCHAR(200);

-- ── A. Anti Water Hammer Valves ──────────────────────────────────────────
-- Reuse the V9 row; do not insert a second N550.
UPDATE san_pham
   SET ten      = 'N550 - Surge Anticipation Valve',
       danh_muc = 'Anti Water Hammer Valves'
 WHERE ten = 'Anti water hammer valves'
   AND range_id = 'automatic-control-valve';

-- ── B. Pilot Operated Control Valves ─────────────────────────────────────

INSERT INTO san_pham (ten, danh_muc, range_id, short_text, mo_ta, features, specs) VALUES

-- 1.1 Pressure Reducing Series
('N200 / NR200 - Pressure Reducing Valve FB/RB',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',
 'automatic-control-valve',
 'Automatically reduces a higher inlet pressure to a stable lower outlet pressure, regardless of changing flow rate or varying inlet pressure.',
 'Pipeline systems need to provide a stable pressure to users. Pressure reducing valve automatically reduces a higher inlet pressure to a stable lower outlet pressure, regardless of changing flow rate and/or varying inlet pressure.',
 NULL,
 '[{"label": "Static pressure reducing", "value": "Even the flow is zero and no user is using.\nLess than 10% for one year acc. UL static test."}, {"label": "Regulation accuracy", "value": "±5%"}, {"label": "Inlet pressure", "value": "Need to be 1.5 bar higher than outlet"}]'),

('N20B / NR20B - Pressure Reduce Valve with Small Flow By Pass',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',
 'automatic-control-valve',
 'Pressure reducing valve with a by pass line that holds the outlet pressure stable when demand falls to a very small flow.',
 'Add the by pass pressure reduce pipe line with the main pressure reduce valve. In the middle night or the end user just need very small flow, the main valve is close, only the by pass pressure reduce pipeline is opening to control the stable outlet pressure.',
 NULL,
 NULL),

('N20D / NR20D - Dual Stage Pressure Reducing Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',
 'automatic-control-valve',
 'Pressure reducing valve with two outlet pressure settings, switched by a solenoid valve.',
 'The valve could setting two outlet pressure, high demand with pressure, low demand with low pressure. Solenoid valve change the channel. Reducing leakage and pipe burst risks. Only high pressure/low pressure can be chosen for each period.',
 NULL,
 NULL),

('N20M / NR20M - Pressure Management Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',
 'automatic-control-valve',
 'Pressure reducing valve whose electronic actuator changes the setting pressure to match demand.',
 'Electronic actuator drive the pressure reduce pilot, change the setting pressure timely according to user requirement.',
 NULL,
 '[{"label": "Approval", "value": "IP68"}]'),

('N20L / NR20L - Low Outlet Pressure Reduce Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',
 'automatic-control-valve',
 'Pressure reducing valve for low outlet pressure, from 0.1 to 1.0 bar.',
 'Main function is same as N200, but the outlet pressure can be 0.1-1.0 bar.',
 NULL,
 '[{"label": "Outlet pressure", "value": "0.1 - 1.0 bar"}]'),

-- 1.2 Overpressure Protection and Water Hammer Prevention
('D500 - Direct Acting Safety Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.2 Overpressure Protection and Water Hammer Prevention',
 'automatic-control-valve',
 'Screwed angle type direct acting safety valve, DN15 to DN50, for pipeline overpressure protection.',
 'Screwed angle type safety valve, pipeline overpressure protection. The safety valve opens to discharge excess pressure when the pressure in the pipeline exceeds the setting value. When the pipeline pressure drops to preset pressure, the safety valve is close.',
 NULL,
 '[{"label": "DN", "value": "15 - 50"}, {"label": "Pressure range", "value": "PN10 / PN16 / PN25"}, {"label": "Material option", "value": "SUS304 / SUS316 / SAF2205"}, {"label": "Seals", "value": "PTFE / PCTFE"}]'),

('N500 - Pressure Sustaining / Relief Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.2 Overpressure Protection and Water Hammer Prevention',
 'automatic-control-valve',
 'Discharges excess pressure and holds the upstream pressure at its setting.',
 'It is used to discharge excess pressure and keep the pressure as setting requirement in the upstream.',
 NULL,
 '[{"label": "Opening pressure", "value": "+0.2 bar"}, {"label": "Opening speed", "value": "<0.5 seconds"}, {"label": "Full close pressure", "value": "-1 bar"}]'),

('N520 - Pressure Sustaining and Reduce Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.2 Overpressure Protection and Water Hammer Prevention',
 'automatic-control-valve',
 'Sustains the inlet pressure and then reduces it to the outlet setting, in a single valve.',
 'When the inlet pressure is exceed the setting of sustaining pilot, the valve is open, then pressure reduce pilot keep the outlet setting pressure.',
 NULL,
 NULL),

-- 1.3 Direct Acting Pressure Reducing Valve
('D200 - Direct Acting Pressure Reducing Valve',
 'Pilot Operated Control Valves / 1. Pressure Control Series / 1.3 Direct Acting Pressure Reducing Valve',
 'automatic-control-valve',
 'Direct acting pressure reducing valve holding a stable outlet pressure under changing flow rate and inlet pressure.',
 'It is using for pipeline systems need to provide a stable pressure to users. The Model D200 Pressure Reducing Valve automatically reduces a higher inlet pressure to a stable lower outlet pressure, even if changing flow rate and/or varying inlet pressure.',
 '["The setting pressure can be adjusted by adjusting the screw", "When there is no user using water at the outlet end, it is immediately closed to achieve hydrostatic sealing"]',
 '[{"label": "Change of outlet pressure / change of inlet pressure", "value": "<0.1"}, {"label": "Regulation accuracy", "value": "±5%"}, {"label": "Outlet pressure", "value": "Must higher than 1 bar"}]'),

-- 2. Solenoid Control Series
('N600 - Solenoid Control Valve',
 'Pilot Operated Control Valves / 2. Solenoid Control Series',
 'automatic-control-valve',
 'On-off control valve driven by a solenoid pilot, furnished normally open or normally closed.',
 'Solenoid Control Valve is an on-off control valve that either opens or closes upon receiving an electrical signal to the solenoid pilot control. This valve consists of a main valve and a two-way solenoid valve that alternately applies pressure to or relieves pressure from the diaphragm chamber of the main valve.',
 NULL,
 '[{"label": "Configuration", "value": "Normally open: de-energized solenoid to open\nNormally closed: energized solenoid to open"}]'),

('N660 - Dual Solenoid Control Valve and Manual By Pass',
 'Pilot Operated Control Valves / 2. Solenoid Control Series',
 'automatic-control-valve',
 'Two solenoid valves on the control chamber give quick open, quick close and fixed-opening control, with a manual by pass.',
 'The inlet and outlet end of control chamber are equipped with two solenoid valve to the upper cavity. Also it can keep the main valve quickly open or close, adjust the opening, keep the opening in a fixed position. Work with PLC, pressure sensor, flow meter and pumps, the dual solenoid valve could meet all the control function of pipe system.',
 NULL,
 NULL),

('N66M - All Function Control Valve',
 'Pilot Operated Control Valves / 2. Solenoid Control Series',
 'automatic-control-valve',
 'Control valve with straight stroke opening feedback, combining flow, pressure and fixed-opening regulation.',
 'The valve also have straight stroke sensor for valve opening as 4-20 mA or 0.5-4.5V. Combine with variable frequency pump, flow meter, pressure sensor, PLC, it can realize all functions such as close, flow regulation, pressure regulation, fixed opening control, rough instantaneous flow value and cumulative flow.',
 '["Close", "Flow regulation", "Pressure regulation", "Fixed opening control", "Rough instantaneous flow value", "Cumulative flow"]',
 '[{"label": "Valve opening feedback", "value": "4 - 20 mA or 0.5 - 4.5 V"}]'),

-- 3. Level Control Series
('N100 / NR100 - Float Control Valve',
 'Pilot Operated Control Valves / 3. Level Control Series',
 'automatic-control-valve',
 'Modulating float control valve that holds the water level in tanks, reservoirs and pools.',
 'Level control of water tanks, reservoirs, pools and other storage devices. The Model N100 Level Control Valve is a modulating valve that accurately controls the water level in tanks. The float pilot could be installed separately in the tank or together with the main valve.',
 '["Open when the water level reaches a preset low point", "Close drip-tight when the water level reaches a preset high point"]',
 '[{"label": "Water level difference", "value": "20 mm"}]'),

('N160 / NR160 - Float and Solenoid Control Valve',
 'Pilot Operated Control Valves / 3. Level Control Series',
 'automatic-control-valve',
 'Float control valve with a solenoid valve that takes over open/close duty if the float pilot fails.',
 'The main function same as N100. But when the float pilot fails, it can open/close through the solenoid valve.',
 NULL,
 NULL),

('N10A / NR10A - Altitude Control Valve',
 'Pilot Operated Control Valves / 3. Level Control Series',
 'automatic-control-valve',
 'Altitude control valve for filling and level control of high water towers.',
 'Level control of high water tower. The altitude control valve close drip-tight and stop filling water in the water tower when the water level reaches a high level. And opens automatically and filling water when the water level lower than the low level setting.',
 NULL,
 '[{"label": "Altitude difference", "value": "5 - 150 mm"}, {"label": "Water level control height", "value": "20 - 1000 mm"}]'),

('N10B / NR10B - Bi-Level Control Valve',
 'Pilot Operated Control Valves / 3. Level Control Series',
 'automatic-control-valve',
 'Level control valve with no back pressure in the control chamber, so the main valve can open fully.',
 'The main function same as N100. But there is no back pressure in the control chamber of the main valve. The main valve can be fully open.',
 NULL,
 '[{"label": "Water level difference", "value": "100 - 1000 mm adjustable"}]'),

-- 4. Flow Control Series
('N400 / NR400 - Flow Control Valve',
 'Pilot Operated Control Valves / 4. Flow Control Series',
 'automatic-control-valve',
 'Limits flow to a preselected maximum rate regardless of changing line pressure.',
 'Rate of Flow Control Valve prevents excessive flow by limiting flow to a preselected maximum rate, regardless of changing line pressure. The pilot control responds to the differential pressure produced across an orifice plate installed downstream of the valve. The valve includes an orifice plate with a holder that should be installed one to five pipe diameters downstream of the valve.',
 NULL,
 NULL),

('N420 / NR420 - Flow Control and Pressure Reducing Valve',
 'Pilot Operated Control Valves / 4. Flow Control Series',
 'automatic-control-valve',
 'Holds a preset flow rate and then maintains the outlet setting pressure.',
 'Providing preset flow rate and then keep the outlet setting pressure.',
 NULL,
 NULL),

('N800 / NR800 - Different Pressure Control Valve',
 'Pilot Operated Control Valves / 4. Flow Control Series',
 'automatic-control-valve',
 'Keeps the differential pressure between supply and return pipes in HVAC systems.',
 'In HVAC system, keep the differential pressure between the supply pipe and return pipe.',
 NULL,
 NULL),

-- 5. Pump Station Check Valve
('N300 - Check Valve',
 'Pilot Operated Control Valves / 5. Pump Station Check Valve',
 'automatic-control-valve',
 'Pump outlet check valve that checks backflow and prevents water hammer.',
 'Installed on the outlet of the water pump on the line, check and prevent water hammer.',
 NULL,
 NULL),

('N745 - Multi-Function Pump Control Valve',
 'Pilot Operated Control Valves / 5. Pump Station Check Valve',
 'automatic-control-valve',
 'Double-chamber pump control valve that prevents and eliminates the pipeline surges caused by pump starting and stopping.',
 'The double-chamber multi-function pump control valve is installed at the outlet of the pump to prevent and eliminate pipeline surges caused by the starting and stopping of the pump. When the water pump is opened, the inlet pressure gradually enters the valve cavity, so that the valve opens slowly, and the opening speed can be adjusted by the needle valve. When the pump suddenly loses power or stops, the main disc closes quickly under the combined action of its own gravity and the water hammer. The secondary disc closes slowly to prevent the damage of the high-pressure water hammer at the rear end to the front pump. It can be fully opened with less pressure loss.',
 NULL,
 NULL),

-- 6.1 Check Valves
('Silent Check Valve',
 'Pilot Operated Control Valves / 6. Additional Products / 6.1 Check Valves',
 'automatic-control-valve',
 'Check valve built so that the flow can be smooth and silent.',
 'Silent check valve so that the flow can be smooth and silent.',
 NULL,
 '[{"label": "Head loss", "value": "0.6 WMC at 2 m/s"}, {"label": "Velocity of backflow", "value": "0.2 s"}, {"label": "Disc", "value": "Stainless steel + EPDM"}, {"label": "Body & diffuser", "value": "Epoxy coated ductile iron"}, {"label": "Valve body", "value": "EN-GJS 500-7 or stainless steel"}]'),

('Nozzle Check Valve',
 'Pilot Operated Control Valves / 6. Additional Products / 6.1 Check Valves',
 'automatic-control-valve',
 'Check valve with an internal diffuser for smoother and quieter flow.',
 'There is a diffuser in the nozzle check valve so that the flow can be more smooth and silent.',
 NULL,
 '[{"label": "Head loss", "value": "0.5 WMC at 2 m/s"}, {"label": "Velocity of backflow", "value": "0.2 s"}, {"label": "Disc", "value": "Stainless steel + EPDM"}, {"label": "Body & diffuser", "value": "Epoxy coated ductile iron"}, {"label": "Valve body", "value": "EN-GJS 500-7 or stainless steel"}]'),

('Big Size Nozzle Check Valve',
 'Pilot Operated Control Valves / 6. Additional Products / 6.1 Check Valves',
 'automatic-control-valve',
 'Horizontally loaded nozzle check valve with a twin bush guide stem and an anti-cavitation flow channel.',
 'It is horizontally loaded. In the previous design, the valve disc acted as a single-arm beam when installed horizontally, causing a slow closing speed when the valve stopped. Additionally, the disc could not reset properly, leading to leakage.',
 '["With a channel nozzle design inside and outside to avoid turbulence and reduce pressure loss", "With a front and bronze bush guide stem replacing the old structure, which had only one side bush guide stem", "With an anti-cavitation design in the internal flow channel"]',
 NULL),

-- 6.2 Air Valves
('Micro Air Valve - 2F1F / 3F2F',
 'Pilot Operated Control Valves / 6. Additional Products / 6.2 Air Valves',
 'automatic-control-valve',
 'Micro air valve in 2F1F and 3F2F versions, with a one or two level PP float and a flush port.',
 NULL,
 NULL,
 '[{"label": "2F1F", "value": "Air release\nAir breath into and protect pipeline\nOne level PP float\nFlush port"}, {"label": "3F2F", "value": "Mass air release\nMicro air release\nAir breath into and protect pipeline\nTwo level PP float\nFlush port"}]'),

('Air Valve - 3F2F / 4F3F',
 'Pilot Operated Control Valves / 6. Additional Products / 6.2 Air Valves',
 'automatic-control-valve',
 'Air valve in 3F2F and 4F3F versions, the 4F3F adding anti-hammer and a three level PP float.',
 NULL,
 NULL,
 '[{"label": "3F2F", "value": "Mass air release\nMicro air release\nAir breath into and protect pipeline\nTwo level PP float\nFlush port"}, {"label": "4F3F", "value": "Mass air release\nMicro air release\nAnti-hammer\nAir breath into and protect pipeline\nThree level PP float\nFlush port"}]');
