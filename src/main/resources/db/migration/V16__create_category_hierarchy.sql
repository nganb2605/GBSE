-- ============================================================
-- V16: Real category hierarchy
--
-- V15 encoded the catalogue tree into san_pham.danh_muc as a path string
-- ("Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 ...")
-- because the schema had nowhere else to put it. Every consumer then had to
-- split that string to recover the structure. This migration replaces it
-- with a real self-referencing table.
--
-- STRUCTURE
-- ---------
-- The five ranges become root categories (parent_id IS NULL), so ranges and
-- child categories are the same kind of thing and one tree walk serves the
-- mega menu, the catalogue page and the category pages. This retires the
-- hardcoded RANGE_ORDER / RANGE_BRANDS maps in ProductService.
--
-- Root slugs are kept identical to the old range_id values, so existing
-- /products#range-<id> anchors still resolve.
--
-- MEMBERSHIP
-- ----------
-- product_category is a real many-to-many. The catalogue lists the N550
-- surge anticipation valve in two places — as the sole member of "Anti Water
-- Hammer Valves" and again under 1.2 Overpressure Protection. V15 could only
-- honour the first, because danh_muc is a single scalar column. Both are
-- restored here against one product row; no duplicate N550 is created.
--
-- Where a product has several categories, the lowest category id is its
-- primary one for breadcrumb purposes. Categories are inserted in tree
-- order below, so that is the higher placement in the tree — for the N550,
-- "Anti Water Hammer Valves".
--
-- ROW 2
-- -----
-- 'Pilot operated control valves' (V7) was never a real product; it was a
-- placeholder leaf whose name is now a category. V9 set the precedent of
-- deleting such a leaf once its name moves to a category. Its content is not
-- lost: the blurb, the range-wide specification table and the Neptune
-- brochure move onto the pilot-operated-control-valves category, which is
-- why category carries description/specs/documents columns. The category
-- page renders them.
--
-- OLD COLUMNS
-- -----------
-- san_pham.danh_muc and san_pham.range_id are read one last time here to
-- build the membership rows, then drop out of the application entirely. The
-- columns are left in place rather than dropped, following the convention
-- V10 set for `link`: removing a column is a separate decision from
-- superseding it.
-- ============================================================

CREATE TABLE category (
    id          BIGSERIAL    PRIMARY KEY,
    parent_id   BIGINT       REFERENCES category(id),
    slug        VARCHAR(120) NOT NULL UNIQUE,
    name        VARCHAR(200) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,
    description TEXT,
    specs       TEXT,
    documents   TEXT
);

CREATE INDEX idx_category_parent ON category(parent_id);

CREATE TABLE product_category (
    product_id  BIGINT NOT NULL REFERENCES san_pham(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

CREATE INDEX idx_product_category_category ON product_category(category_id);

-- ── Roots ────────────────────────────────────────────────────────────────
-- sort_order reproduces the range order ProductService used to hardcode.
INSERT INTO category (parent_id, slug, name, sort_order) VALUES
    (NULL, 'automatic-control-valve', 'Automatic Control Valve', 1),
    (NULL, 'control-valve-hvac',      'Control valve HVAC',      2),
    (NULL, 'heatpump',                'Heatpump',                3),
    (NULL, 'metering',                'Metering and Measuring',  4),
    (NULL, 'phe',                     'Plate Heat Exchanger',    5);

-- ── Automatic Control Valve ──────────────────────────────────────────────
INSERT INTO category (parent_id, slug, name, sort_order)
SELECT id, 'anti-water-hammer-valves', 'Anti Water Hammer Valves', 1
  FROM category WHERE slug = 'automatic-control-valve';

INSERT INTO category (parent_id, slug, name, sort_order)
SELECT id, 'pilot-operated-control-valves', 'Pilot Operated Control Valves', 2
  FROM category WHERE slug = 'automatic-control-valve';

INSERT INTO category (parent_id, slug, name, sort_order)
SELECT c.id, v.slug, v.name, v.sort_order
  FROM category c
  JOIN (VALUES
      ('pressure-control-series', '1. Pressure Control Series',  1),
      ('solenoid-control-series', '2. Solenoid Control Series',  2),
      ('level-control-series',    '3. Level Control Series',     3),
      ('flow-control-series',     '4. Flow Control Series',      4),
      ('pump-station-check-valve','5. Pump Station Check Valve', 5),
      ('additional-products',     '6. Additional Products',      6)
  ) AS v(slug, name, sort_order) ON TRUE
 WHERE c.slug = 'pilot-operated-control-valves';

INSERT INTO category (parent_id, slug, name, sort_order)
SELECT c.id, v.slug, v.name, v.sort_order
  FROM category c
  JOIN (VALUES
      ('pressure-reducing-series',              '1.1 Pressure Reducing Series',                              1),
      ('overpressure-protection',               '1.2 Overpressure Protection and Water Hammer Prevention',   2),
      ('direct-acting-pressure-reducing-valve', '1.3 Direct Acting Pressure Reducing Valve',                 3)
  ) AS v(slug, name, sort_order) ON TRUE
 WHERE c.slug = 'pressure-control-series';

INSERT INTO category (parent_id, slug, name, sort_order)
SELECT c.id, v.slug, v.name, v.sort_order
  FROM category c
  JOIN (VALUES
      ('check-valves', '6.1 Check Valves', 1),
      ('air-valves',   '6.2 Air Valves',   2)
  ) AS v(slug, name, sort_order) ON TRUE
 WHERE c.slug = 'additional-products';

-- ── Heatpump and Metering ────────────────────────────────────────────────
INSERT INTO category (parent_id, slug, name, sort_order)
SELECT c.id, v.slug, v.name, v.sort_order
  FROM category c
  JOIN (VALUES
      ('heatpump-air-source',  'Heatpump Air Source',  1),
      ('heatpump-all-in-one',  'Heatpump all in one',  2)
  ) AS v(slug, name, sort_order) ON TRUE
 WHERE c.slug = 'heatpump';

INSERT INTO category (parent_id, slug, name, sort_order)
SELECT c.id, v.slug, v.name, v.sort_order
  FROM category c
  JOIN (VALUES
      ('energy-meter', 'Energy Meter', 1),
      ('flowmeter',    'Flowmeter',    2),
      ('water-meter',  'Water Meter',  3)
  ) AS v(slug, name, sort_order) ON TRUE
 WHERE c.slug = 'metering';

-- ── Carry the placeholder row's content onto its category, then drop it ──
UPDATE category
   SET description = (SELECT short_text FROM san_pham WHERE ten = 'Pilot operated control valves'),
       specs       = (SELECT specs      FROM san_pham WHERE ten = 'Pilot operated control valves'),
       documents   = (SELECT documents  FROM san_pham WHERE ten = 'Pilot operated control valves')
 WHERE slug = 'pilot-operated-control-valves';

DELETE FROM san_pham WHERE ten = 'Pilot operated control valves';

-- ── Membership ───────────────────────────────────────────────────────────
-- Products whose danh_muc names a leaf category, mapped path -> slug.
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id
  FROM san_pham p
  JOIN (VALUES
      ('Anti Water Hammer Valves',                                                                                          'anti-water-hammer-valves'),
      ('Pilot Operated Control Valves / 1. Pressure Control Series / 1.1 Pressure Reducing Series',                          'pressure-reducing-series'),
      ('Pilot Operated Control Valves / 1. Pressure Control Series / 1.2 Overpressure Protection and Water Hammer Prevention','overpressure-protection'),
      ('Pilot Operated Control Valves / 1. Pressure Control Series / 1.3 Direct Acting Pressure Reducing Valve',             'direct-acting-pressure-reducing-valve'),
      ('Pilot Operated Control Valves / 2. Solenoid Control Series',                                                         'solenoid-control-series'),
      ('Pilot Operated Control Valves / 3. Level Control Series',                                                            'level-control-series'),
      ('Pilot Operated Control Valves / 4. Flow Control Series',                                                             'flow-control-series'),
      ('Pilot Operated Control Valves / 5. Pump Station Check Valve',                                                        'pump-station-check-valve'),
      ('Pilot Operated Control Valves / 6. Additional Products / 6.1 Check Valves',                                          'check-valves'),
      ('Pilot Operated Control Valves / 6. Additional Products / 6.2 Air Valves',                                            'air-valves'),
      ('Heatpump Air Source',                                                                                               'heatpump-air-source'),
      ('Heatpump all in one',                                                                                               'heatpump-all-in-one'),
      ('Energy Meter',                                                                                                      'energy-meter'),
      ('Flowmeter',                                                                                                         'flowmeter'),
      ('Water Meter',                                                                                                       'water-meter')
  ) AS m(path, slug) ON m.path = p.danh_muc
  JOIN category c ON c.slug = m.slug;

-- Products that sat directly under their range (control valve HVAC, PHE).
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id
  FROM san_pham p
  JOIN category c ON c.slug = p.range_id
 WHERE p.danh_muc IS NULL;

-- The catalogue's second placement for the N550, which V15 could not express.
INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id
  FROM san_pham p, category c
 WHERE p.ten = 'N550 - Surge Anticipation Valve'
   AND c.slug = 'overpressure-protection';
