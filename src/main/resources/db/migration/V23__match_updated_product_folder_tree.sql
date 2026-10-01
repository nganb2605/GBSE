-- The folder tree changed after V20. Keep every product ID and its XLSX/PDF
-- content; move only the catalogue location and the source-folder key.

-- Former product folders are now parent groups with one direct-PDF child.
INSERT INTO category (parent_id, slug, name, sort_order)
SELECT id, 'plate-heat-exchanger-product', 'Plate Heat Exchanger', 1
FROM category WHERE slug = 'phe' ON CONFLICT (slug) DO NOTHING;
INSERT INTO category (parent_id, slug, name, sort_order)
SELECT id, 'mag-c', 'MAG-C', 1
FROM category WHERE slug = 'flowmeter' ON CONFLICT (slug) DO NOTHING;
INSERT INTO category (parent_id, slug, name, sort_order)
SELECT id, 'cahp', 'CAHP', 1
FROM category WHERE slug = 'heatpump-air-source' ON CONFLICT (slug) DO NOTHING;

DO $$ BEGIN
IF EXISTS (SELECT 1 FROM (VALUES
  ('plate-heat-exchanger-product', 'phe'),
  ('mag-c', 'flowmeter'),
  ('cahp', 'heatpump-air-source')
) AS expected(slug, parent_slug)
WHERE NOT EXISTS (SELECT 1 FROM category c JOIN category p ON p.id = c.parent_id
                  WHERE c.slug = expected.slug AND p.slug = expected.parent_slug))
THEN RAISE EXCEPTION 'Updated catalogue category conflict'; END IF;
END $$;

-- These existing leaf categories follow the renamed product directories.
UPDATE category SET name = 'DN15-20 Single Jet' WHERE slug = 'water-meter-dn15-20-single-jet';
UPDATE category SET name = 'DN15-50 Multi Jet' WHERE slug = 'water-meter-dn15-50-multi-jet';
UPDATE category SET name = 'DN50-200' WHERE slug = 'water-meter-dn50-200';
UPDATE category SET name = 'DN15-32' WHERE slug = 'energy-meters-dn15-32';
UPDATE category SET name = 'DN15-100' WHERE slug = 'energy-meters-dn15-100';
UPDATE category SET name = 'DN125-800' WHERE slug = 'energy-meters-dn125-800';

-- Fail on an unexpected duplicate before changing paths. The unique index
-- from V20 also prevents a second product from claiming a source folder.
DO $$ BEGIN
IF EXISTS (SELECT 1 FROM (VALUES
  ('1. Plate Heat Exchanger', '1. Plate Heat Exchanger/1.1. Plate Heat Exchanger'),
  ('2. Metering and Measuring/2.1.  Water Meter/2.1.1. Water Meter DN15-20 Single Jet', '2. Metering and Measuring/2.1.  Water Meter/2.1.1. DN15-20 Single Jet'),
  ('2. Metering and Measuring/2.1.  Water Meter/2.1.2. Water Meter DN15-50 Multi Jet', '2. Metering and Measuring/2.1.  Water Meter/2.1.2. DN15-50 Multi Jet'),
  ('2. Metering and Measuring/2.1.  Water Meter/2.1.3. Water Meter DN50-200', '2. Metering and Measuring/2.1.  Water Meter/2.1.3. DN50-200'),
  ('2. Metering and Measuring/2.2. Energy Meter/2.2.1. Energy meters DN15-32', '2. Metering and Measuring/2.2. Energy Meter/2.2.1.  DN15-32'),
  ('2. Metering and Measuring/2.2. Energy Meter/2.2.2. Energy meters DN15-100', '2. Metering and Measuring/2.2. Energy Meter/2.2.2. DN15-100'),
  ('2. Metering and Measuring/2.2. Energy Meter/2.2.3. Energy meters DN125-800', '2. Metering and Measuring/2.2. Energy Meter/2.2.3. DN125-800'),
  ('2. Metering and Measuring/2.3. Flowmeter', '2. Metering and Measuring/2.3. Flowmeter/2.3.1. MAG-C'),
  ('3. Heatpump/3.1. Heatpump Air Source', '3. Heatpump/3.1. Heatpump Air Source/3.1.1. CAHP')
) AS moved(old_path, new_path)
WHERE (SELECT count(*) FROM san_pham WHERE source_folder IN (moved.old_path, moved.new_path)) <> 1)
THEN RAISE EXCEPTION 'Updated catalogue product conflict'; END IF;
END $$;

UPDATE san_pham SET source_folder = '1. Plate Heat Exchanger/1.1. Plate Heat Exchanger'
WHERE source_folder = '1. Plate Heat Exchanger';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.1. DN15-20 Single Jet'
WHERE source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.1. Water Meter DN15-20 Single Jet';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.2. DN15-50 Multi Jet'
WHERE source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.2. Water Meter DN15-50 Multi Jet';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.3. DN50-200'
WHERE source_folder = '2. Metering and Measuring/2.1.  Water Meter/2.1.3. Water Meter DN50-200';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.1.  DN15-32'
WHERE source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.1. Energy meters DN15-32';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.2. DN15-100'
WHERE source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.2. Energy meters DN15-100';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.3. DN125-800'
WHERE source_folder = '2. Metering and Measuring/2.2. Energy Meter/2.2.3. Energy meters DN125-800';
UPDATE san_pham SET source_folder = '2. Metering and Measuring/2.3. Flowmeter/2.3.1. MAG-C', ten = 'MAG-C'
WHERE source_folder = '2. Metering and Measuring/2.3. Flowmeter';
UPDATE san_pham SET source_folder = '3. Heatpump/3.1. Heatpump Air Source/3.1.1. CAHP', ten = 'CAHP'
WHERE source_folder = '3. Heatpump/3.1. Heatpump Air Source';

-- Move only the three products whose former folder became a group.
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id FROM san_pham p JOIN category c ON c.slug = 'plate-heat-exchanger-product'
WHERE p.source_folder = '1. Plate Heat Exchanger/1.1. Plate Heat Exchanger'
ON CONFLICT DO NOTHING;
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id FROM san_pham p JOIN category c ON c.slug = 'mag-c'
WHERE p.source_folder = '2. Metering and Measuring/2.3. Flowmeter/2.3.1. MAG-C'
ON CONFLICT DO NOTHING;
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id FROM san_pham p JOIN category c ON c.slug = 'cahp'
WHERE p.source_folder = '3. Heatpump/3.1. Heatpump Air Source/3.1.1. CAHP'
ON CONFLICT DO NOTHING;

DELETE FROM product_category pc USING san_pham p, category c
WHERE pc.product_id = p.id AND pc.category_id = c.id
  AND ((p.source_folder = '1. Plate Heat Exchanger/1.1. Plate Heat Exchanger' AND c.slug = 'phe')
    OR (p.source_folder = '2. Metering and Measuring/2.3. Flowmeter/2.3.1. MAG-C' AND c.slug = 'flowmeter')
    OR (p.source_folder = '3. Heatpump/3.1. Heatpump Air Source/3.1.1. CAHP' AND c.slug = 'heatpump-air-source'));
