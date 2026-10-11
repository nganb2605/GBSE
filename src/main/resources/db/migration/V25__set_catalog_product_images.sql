-- ============================================================
-- V25: Set catalog product images for all 16 catalog items
--
-- Product images have been placed in static/productsimage/.
-- This migration maps each product to its image file by checking
-- both source_folder (both V20 and V23 paths) and product name (ten).
-- ============================================================

-- ── 1. Plate Heat Exchanger ───────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/plate-heat-exchanger.png'
 WHERE source_folder IN ('1. Plate Heat Exchanger', '1. Plate Heat Exchanger/1.1. Plate Heat Exchanger')
    OR ten ILIKE '%Plate Heat Exchanger%';

-- ── 2. Metering and Measuring ─────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/water-meter-dn15-20-single-jet.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.1.  Water Meter/2.1.1. Water Meter DN15-20 Single Jet',
                         '2. Metering and Measuring/2.1.  Water Meter/2.1.1. DN15-20 Single Jet')
    OR ten ILIKE '%DN15-20 Single Jet%'
    OR ten ILIKE '%Water meter DN15-20 single jet%';

UPDATE san_pham SET hinh_anh = '/productsimage/water-meter-dn15-50-multi-jet.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.1.  Water Meter/2.1.2. Water Meter DN15-50 Multi Jet',
                         '2. Metering and Measuring/2.1.  Water Meter/2.1.2. DN15-50 Multi Jet')
    OR ten ILIKE '%DN15-50 Multi Jet%'
    OR ten ILIKE '%Water meter DN15-50 multi jet%';

UPDATE san_pham SET hinh_anh = '/productsimage/water-meter-dn50-200.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.1.  Water Meter/2.1.3. Water Meter DN50-200',
                         '2. Metering and Measuring/2.1.  Water Meter/2.1.3. DN50-200')
    OR ten ILIKE '%Water meter DN50-200%'
    OR ten = 'DN50-200';

UPDATE san_pham SET hinh_anh = '/productsimage/energy-meters-dn15-32.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.2. Energy Meter/2.2.1. Energy meters DN15-32',
                         '2. Metering and Measuring/2.2. Energy Meter/2.2.1.  DN15-32')
    OR ten ILIKE '%Energy meters DN15-32%'
    OR ten = 'DN15-32';

UPDATE san_pham SET hinh_anh = '/productsimage/energy-meters-dn15-100.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.2. Energy Meter/2.2.2. Energy meters DN15-100',
                         '2. Metering and Measuring/2.2. Energy Meter/2.2.2. DN15-100')
    OR ten ILIKE '%Energy meters DN15-100%'
    OR ten = 'DN15-100';

UPDATE san_pham SET hinh_anh = '/productsimage/energy-meters-dn125-800.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.2. Energy Meter/2.2.3. Energy meters DN125-800',
                         '2. Metering and Measuring/2.2. Energy Meter/2.2.3. DN125-800')
    OR ten ILIKE '%Energy meters DN125-800%'
    OR ten = 'DN125-800';

UPDATE san_pham SET hinh_anh = '/productsimage/flowmeter.png'
 WHERE source_folder IN ('2. Metering and Measuring/2.3. Flowmeter',
                         '2. Metering and Measuring/2.3. Flowmeter/2.3.1. MAG-C')
    OR ten IN ('Flowmeter', 'MAG-C', 'Flow Meter DN15-2000', 'DN15-2000');

-- ── 3. Heat Pumps ─────────────────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/heatpump-air-source.png'
 WHERE source_folder IN ('3. Heatpump/3.1. Heatpump Air Source',
                         '3. Heatpump/3.1. Heatpump Air Source/3.1.1. CAHP')
    OR ten IN ('Heatpump Air Source', 'CAHP');

UPDATE san_pham SET hinh_anh = '/productsimage/cahp-1.5hp.png'
 WHERE source_folder = '3. Heatpump/3.2. Heatpump all in one/3.2.1. CAHP-1.5HP'
    OR ten IN ('CAHP-1.5HP', 'Heatpump all in one');

UPDATE san_pham SET hinh_anh = '/productsimage/hpi-series.png'
 WHERE source_folder = '3. Heatpump/3.2. Heatpump all in one/3.2.2. HPI Series'
    OR ten = 'HPI Series';

-- ── 4. Automatic Control Valve ─────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/anti-water-hammer-valves.png'
 WHERE source_folder = '4. Automatic Control Valve/4.1. Anti water hammer valves'
    OR ten IN ('Anti water hammer valves', 'N550 - Surge Anticipation Valve');

UPDATE san_pham SET hinh_anh = '/productsimage/pilot-operated-control-valves.png'
 WHERE source_folder = '4. Automatic Control Valve/4.2. Pilot operated control valves'
    OR ten = 'Pilot operated control valves';

-- ── 5. HVAC Control Valves ────────────────────────────────────────────────
UPDATE san_pham SET hinh_anh = '/productsimage/pressure-independent-control-valve.png'
 WHERE source_folder = '5. Control valve HVAC/5.1. Pressure Independent Control Valve'
    OR ten IN ('Pressure Independent Control Valve', 'Pressure Independent Control Valve (PICV)');

UPDATE san_pham SET hinh_anh = '/productsimage/motorized-butterfly-valve.png'
 WHERE source_folder = '5. Control valve HVAC/5.2. Motorized Butterfly Valve'
    OR ten = 'Motorized Butterfly Valve';

UPDATE san_pham SET hinh_anh = '/productsimage/motorized-globe-valve.png'
 WHERE source_folder = '5. Control valve HVAC/5.3. Motorized Globe Valve'
    OR ten = 'Motorized Globe Valve';

