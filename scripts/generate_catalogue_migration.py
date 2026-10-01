"""Generate V19 from the checked-in GBSE workbook; run from the repository root.

The generated SQL guards legacy rows against changes to the fields it replaces.
Keep this script so the workbook-to-migration mapping remains reviewable.
"""

import json
import re
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
WORKBOOK = ROOT / "src/products/GBSE/GBSE-web.xlsx"
MIGRATIONS = ROOT / "src/main/resources/db/migration"
OUTPUT = MIGRATIONS / "V19__sync_gbse_catalogue.sql"
STATIC = ROOT / "src/main/resources/static"
NS = {"s": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


def sheet_cells():
    with zipfile.ZipFile(WORKBOOK) as book:
        shared = ["".join(item.itertext()) for item in ET.fromstring(book.read("xl/sharedStrings.xml")).findall("s:si", NS)]
        root = ET.fromstring(book.read("xl/worksheets/sheet1.xml"))
        out = {}
        for cell in root.findall(".//s:sheetData/s:row/s:c", NS):
            value = cell.find("s:v", NS)
            if value is None:
                continue
            out[cell.attrib["r"]] = shared[int(value.text)] if cell.get("t") == "s" else value.text
        return out


CELLS = sheet_cells()


def cell(column, row):
    return CELLS.get(f"{column}{row}", "").strip()


def sql(value):
    if value is None:
        return "NULL"
    return "'" + str(value).replace("'", "''") + "'"


def data(value):
    return sql(json.dumps(value, ensure_ascii=False)) if value else "NULL"


def lines(value):
    return [part.strip() for part in value.splitlines() if part.strip()]


DOC_FILES = {
    "Brochure_HEX": "brochure-hex.pdf",
    "Water meter DN15-20 - GSD8-RFM": "water-meter-dn15-20-gsd8-rfm.pdf",
    "RFM-MB1": "rfm-mb1.pdf", "RFM-TX1": "rfm-tx1.pdf",
    "IWM-LR3": "iwm-lr3.pdf", "IWM-MB3": "iwm-mb3.pdf",
    "IWM-PL3": "iwm-pl3.pdf", "IWM-TX3": "iwm-tx3.pdf",
    "Water meter DN50-200 - WDE-K50": "water-meter-dn50-200-wde-k50.pdf",
    "IWM-MB4": "iwm-mb4.pdf", "IWM-PL4": "iwm-pl4.pdf", "IWM-TX4": "iwm-tx4.pdf",
    "SonoSelect 10": "sonoselect-10.pdf", "SonoMeter 40": "sonometer-40.pdf",
    "Supercal 5": "supercal-5.pdf", "Sono3500CT": "sono3500ct.pdf",
    "Mag-C": "mag-c.pdf", "CAHP-MC-19": "cahp-mc-19-specification.pdf",
    "CAHP-1.5HP": "cahp-1-5hp.pdf", "HPI Series": "hpi-series.pdf",
    "N550_EN": "n550-en.pdf", "Brochure_Neptune_EN": "brochure-neptune-en.pdf",
    "AB-QM 4.0 Flexo 80": "ab-qm-4-0-flexo-80.pdf",
    "ABQM 4.0": "abqm-4-0.pdf",
    "Actuator selection for PICV": "actuator-selection-for-picv.pdf",
    "Butterfly valve VFH2_DN32-600": "butterfly-valve-vfh2-dn32-600.pdf",
    "VF2 + VF3": "vf2-plus-vf3.pdf", "VRB2 VRB3": "vrb2-vrb3.pdf",
}


def docs(row, only=None):
    labels = only if only is not None else [part for part in lines(cell("E", row)) if not part.startswith(("Tài liệu", "Các tài liệu"))]
    result = []
    for label in labels:
        filename = DOC_FILES.get(label)
        if filename and (STATIC / "docs" / filename).is_file():
            result.append({"label": label, "url": f"/docs/{filename}"})
    return result


def applications(row):
    return lines(cell("C", row))


def content(row, model=None, selected_docs=None, image=None):
    """Every nonempty Excel D line is retained in one visible field."""
    spec = []
    features = []
    description = []
    raw = lines(cell("D", row))
    if model:
        spec.append({"label": "Model", "value": model})
    feature_starts = (
        "Anti magnetic fraud protection", "Unique heat exchanger design",
        "Energy saving", "Smart control", "Integrate design", "Two elements",
        "Patented AES", "Timer setting", "Remote control", "PS safety system",
    )
    for index, line in enumerate(raw):
        if row in (14, 15, 16) and line in ("CAHP-1.5HP", "HPI Series", "Heatpump air to water"):
            description.append(line)
        elif row in (18, 19, 21, 22, 23) and index == 0:
            description.append(line)
        elif row in (9, 10, 11) and (line.startswith("The energy meters consist") or line.startswith("SonoMeter 40 energy meters consist") or line.startswith("Supercal 5 and Sono3500CT")):
            description.append(line)
        elif line.startswith("Model "):
            spec.append({"label": "Model", "value": line.removeprefix("Model ")})
        elif line.startswith(feature_starts):
            features.append(line)
        elif ":" in line:
            label, value = line.split(":", 1)
            spec.append({"label": label.strip(), "value": value.strip()})
        else:
            spec.append({"label": "Detail", "value": line})
    return {
        "mo_ta": sql("\n".join(description) or None),
        "features": data(features),
        "specs": data(spec),
        "applications": data(applications(row)),
        "documents": data(docs(row, selected_docs)),
        "hinh_anh": sql(image),
    }


def old_seed_fields():
    source = (MIGRATIONS / "V11__populate_product_catalogue.sql").read_text(encoding="utf-8")
    result = {}
    for match in re.finditer(r"UPDATE san_pham\s+SET\s+(.*?)\s+WHERE ten = '([^']+)'", source, re.S):
        fields = {}
        for field, value in re.findall(r"(\w+)\s*=\s*'((?:[^']|'')*)'", match.group(1)):
            fields[field] = value.replace("''", "'")
        result[match.group(2)] = fields
    return result


SEED = old_seed_fields()
STATEMENTS = [
    "-- Generated from src/products/GBSE/GBSE-web.xlsx by scripts/generate_catalogue_migration.py.",
    "-- Existing product IDs are retained. Legacy rows are checked before any changes.",
    "ALTER TABLE category ADD COLUMN IF NOT EXISTS applications TEXT;",
    "ALTER TABLE category ADD COLUMN IF NOT EXISTS image_path VARCHAR(255);",
    "ALTER TABLE category ADD COLUMN IF NOT EXISTS visible BOOLEAN NOT NULL DEFAULT TRUE;",
    "ALTER TABLE san_pham ADD COLUMN IF NOT EXISTS visible BOOLEAN NOT NULL DEFAULT TRUE;",
]


def emit(value):
    STATEMENTS.append(value)


OLD_CATEGORY_NAMES = {
    "phe": "Plate Heat Exchanger", "metering": "Metering and Measuring",
    "heatpump": "Heatpump", "automatic-control-valve": "Automatic Control Valve",
    "control-valve-hvac": "Control valve HVAC", "water-meter": "Water Meter",
    "energy-meter": "Energy Meter", "flowmeter": "Flowmeter",
    "heatpump-air-source": "Heatpump Air Source",
    "heatpump-all-in-one": "Heatpump all in one",
    "anti-water-hammer-valves": "Anti Water Hammer Valves",
    "pilot-operated-control-valves": "Pilot Operated Control Valves",
}
OLD_CATEGORY_ORDER = {
    "automatic-control-valve": 1, "control-valve-hvac": 2,
    "heatpump": 3, "metering": 4, "phe": 5,
    "anti-water-hammer-valves": 1, "pilot-operated-control-valves": 2,
    "heatpump-air-source": 1, "heatpump-all-in-one": 2,
    "energy-meter": 1, "flowmeter": 2, "water-meter": 3,
}
FINAL_CATEGORY_ORDER = {
    "phe": 1, "metering": 2, "heatpump": 3,
    "automatic-control-valve": 4, "control-valve-hvac": 5,
    "water-meter": 1, "energy-meter": 2, "flowmeter": 3,
}
CATEGORY_ROWS = {
    "water-meter": (4, None), "energy-meter": (8, None),
    "flowmeter": (12, None), "heatpump": (13, None),
    "heatpump-air-source": (14, "Heatpump Air Source"),
    "heatpump-all-in-one": (15, "Heatpump all in one"),
    "anti-water-hammer-valves": (18, "Anti water hammer valves"),
    "pilot-operated-control-valves": (19, "Neptune – Automatic control valves"),
    "control-valve-hvac": (20, None),
}


def final_category_fields(slug):
    fields = {
        "name": sql({"anti-water-hammer-valves": "Anti water hammer valves",
                     "pilot-operated-control-valves": "Pilot operated control valves"}.get(slug, OLD_CATEGORY_NAMES[slug])),
        "sort_order": str(FINAL_CATEGORY_ORDER.get(slug, OLD_CATEGORY_ORDER[slug])),
        "description": "NULL", "applications": "NULL", "specs": "NULL",
        "documents": "NULL", "image_path": "NULL",
    }
    if slug in CATEGORY_ROWS:
        row, desc = CATEGORY_ROWS[slug]
        fields["description"] = sql(desc)
        fields["applications"] = data(applications(row))
        fields["specs"] = content(row)["specs"] if slug not in ("heatpump", "heatpump-all-in-one") else "NULL"
        fields["documents"] = data(docs(row)) if slug in ("anti-water-hammer-valves", "pilot-operated-control-valves") else "NULL"
        image = {"anti-water-hammer-valves": "image22.png",
                 "pilot-operated-control-valves": "image23.png"}.get(slug)
        fields["image_path"] = sql(f"/catalogue/{image}" if image else None)
    return fields


for slug, name in OLD_CATEGORY_NAMES.items():
    final = final_category_fields(slug)
    final_check = " AND ".join(f"{field} IS NOT DISTINCT FROM {value}" for field, value in final.items())
    emit(f"""DO $$ BEGIN
IF (SELECT count(*) FROM category WHERE slug = {sql(slug)} AND (
 (name = {sql(name)} AND sort_order = {OLD_CATEGORY_ORDER[slug]}
  AND description IS NULL AND specs IS NULL AND documents IS NULL
  AND applications IS NULL AND image_path IS NULL)
 OR ({final_check}))) <> 1
THEN RAISE EXCEPTION 'Catalogue category conflict: {slug}'; END IF;
END $$;""")


LEGACY = [
    ("Plate Heat Exchanger", "phe", "Plate Heat Exchanger", 2),
    ("Single Jet DN15-20", "water-meter", "Water meter DN15-20 single jet", 5),
    ("Multi Jet DN15-50", "water-meter", "Water meter DN15-50 multi jet", 6),
    ("DN50-200", "water-meter", "Water meter DN50-200", 7),
    ("DN15-32", "energy-meter", "Energy meters DN15-32", 9),
    ("DN15-100", "energy-meter", "Energy meters DN15-100", 10),
    ("DN125-800", "energy-meter", "Energy meters DN125-800", 11),
    ("DN15-2000", "flowmeter", "Flow Meter DN15-2000", 12),
    ("CAHP-1.5HP", "heatpump-all-in-one", "CAHP-1.5HP", 15),
    ("HPI Series", "heatpump-all-in-one", "HPI Series", 16),
    ("Pressure Independent Control Valve (PICV)", "control-valve-hvac", "Pressure Independent Control Valve", 21),
    ("Motorized Butterfly Valve", "control-valve-hvac", "Motorized Butterfly Valve", 22),
]

def locator(old, slug):
    return (f"p.ten = {sql(old)} AND EXISTS (SELECT 1 FROM product_category pc "
            f"JOIN category c ON c.id = pc.category_id WHERE pc.product_id = p.id AND c.slug = {sql(slug)})")


for old, slug in [("Heatpump Air Source", "heatpump-air-source"),
                  ("Motorized Globe Valve", "control-valve-hvac")]:
    if old not in SEED:
        raise ValueError(f"No V11 seed found for {old}")
    checks = [f"p.{field} IS NOT DISTINCT FROM {sql(value)}"
              for field, value in SEED[old].items() if field != "hinh_anh"]
    checks.append("p.hinh_anh IS NULL")
    emit(f"""DO $$ BEGIN
IF (SELECT count(*) FROM san_pham p WHERE {locator(old, slug)}) <> 1
OR EXISTS (SELECT 1 FROM san_pham p WHERE {locator(old, slug)}
AND NOT (({' AND '.join(checks)}) OR p.visible = FALSE))
THEN RAISE EXCEPTION 'Catalogue seed conflict: {old}'; END IF;
END $$;""")


# A changed seeded field is a conflict: abort the whole Flyway transaction.
for old, slug, new, row in LEGACY:
    if old not in SEED:
        raise ValueError(f"No V11 seed found for {old}")
    guarded_fields = {"short_text", "mo_ta", "applications", "features", "specs", "documents"}
    guards = [f"p.{field} IS NOT DISTINCT FROM {sql(SEED[old].get(field))}" for field in sorted(guarded_fields)]
    # V13 cleared seeded artwork globally. No other post-V11 migration changes these rows.
    guards = [g for g in guards if not g.startswith("p.hinh_anh ")]
    guards.append("p.hinh_anh IS NULL")
    condition = " AND ".join(guards)
    final_slug = {21: "pressure-independent-control-valve", 22: "motorized-butterfly-valve"}.get(row, slug)
    product_image = {2: "image1.png", 5: "image2.png", 6: "image5.png", 7: "image10.png",
                     9: "image14.png", 10: "image15.png", 11: "image16.png",
                     12: "image18.png", 15: "image20.png", 16: "image21.png",
                     21: "image27.png", 22: "image29.png"}.get(row)
    final_fields = content(row, image=f"/catalogue/{product_image}" if product_image else None)
    final_fields["short_text"] = sql(new)
    final_fields["hinh_anh"] = sql(f"/catalogue/{product_image}" if product_image else None)
    final_fields["visible"] = "TRUE"
    final_condition = " AND ".join(f"p.{field} IS NOT DISTINCT FROM {value}" for field, value in final_fields.items())
    final_locator = locator(new, final_slug)
    emit(f"DO $$ BEGIN\n  IF NOT ("
         f"(SELECT count(*) FROM san_pham p WHERE {locator(old, slug)} AND {condition}) = 1 "
         f"OR (SELECT count(*) FROM san_pham p WHERE {final_locator} AND {final_condition}) = 1) "
         f"THEN RAISE EXCEPTION 'Catalogue seed conflict: {old}'; END IF;\nEND $$;")

# Root order follows the workbook, preserving existing slugs and IDs.
for slug, order in [("phe", 1), ("metering", 2), ("heatpump", 3),
                    ("automatic-control-valve", 4), ("control-valve-hvac", 5)]:
    emit(f"UPDATE category SET sort_order = {order} WHERE slug = {sql(slug)};")
for slug, name, order in [("water-meter", "Water Meter", 1), ("energy-meter", "Energy Meter", 2),
                          ("flowmeter", "Flowmeter", 3)]:
    emit(f"UPDATE category SET name = {sql(name)}, sort_order = {order} WHERE slug = {sql(slug)};")
for slug, name, order in [("anti-water-hammer-valves", "Anti water hammer valves", 1),
                          ("pilot-operated-control-valves", "Pilot operated control valves", 2)]:
    emit(f"UPDATE category SET name = {sql(name)}, sort_order = {order} WHERE slug = {sql(slug)};")

# Category introductions from Excel. N550 remains a distinct, unchanged product.
for slug, row, desc in [
    ("water-meter", 4, None), ("energy-meter", 8, None),
    ("flowmeter", 12, None), ("heatpump", 13, None),
    ("heatpump-air-source", 14, "Heatpump Air Source"),
    ("heatpump-all-in-one", 15, "Heatpump all in one"),
    ("anti-water-hammer-valves", 18, "Anti water hammer valves"),
    ("pilot-operated-control-valves", 19, "Neptune – Automatic control valves"),
    ("control-valve-hvac", 20, None),
]:
    spec = content(row)["specs"]
    if slug in ("heatpump", "heatpump-all-in-one"):
        spec = "NULL"  # child products own the row's technical details
    documents = data(docs(row)) if slug in ("anti-water-hammer-valves", "pilot-operated-control-valves") else "NULL"
    category_image = {"anti-water-hammer-valves": "image22.png",
                      "pilot-operated-control-valves": "image23.png"}.get(slug)
    emit(f"UPDATE category SET description = {sql(desc)}, applications = {data(applications(row))}, "
         f"specs = {spec}, documents = {documents}, "
         f"image_path = {sql('/catalogue/' + category_image) if category_image else 'NULL'} "
         f"WHERE slug = {sql(slug)};")

# Add the one missing branch without replacing the old aggregate product.
emit("""INSERT INTO category (parent_id, slug, name, sort_order)
SELECT parent.id, 'motorized-globe-valve', 'Motorized Globe Valve', 3
FROM category parent WHERE parent.slug = 'control-valve-hvac'
AND NOT EXISTS (SELECT 1 FROM category WHERE slug = 'motorized-globe-valve');""")
emit("""DO $$ BEGIN
IF (SELECT count(*) FROM category c JOIN category p ON c.parent_id = p.id
WHERE c.slug = 'motorized-globe-valve' AND c.name = 'Motorized Globe Valve'
AND c.sort_order = 3 AND p.slug = 'control-valve-hvac') <> 1
THEN RAISE EXCEPTION 'Catalogue category conflict: motorized-globe-valve'; END IF;
END $$;""")

# Previously flat HVAC products become explicit children; their IDs stay stable.
for slug, name, order in [("pressure-independent-control-valve", "Pressure Independent Control Valve", 1),
                          ("motorized-butterfly-valve", "Motorized Butterfly Valve", 2)]:
    emit(f"""INSERT INTO category (parent_id, slug, name, sort_order)
SELECT parent.id, {sql(slug)}, {sql(name)}, {order} FROM category parent
WHERE parent.slug = 'control-valve-hvac' AND NOT EXISTS (SELECT 1 FROM category WHERE slug = {sql(slug)});""")
    emit(f"""DO $$ BEGIN
IF (SELECT count(*) FROM category c JOIN category p ON c.parent_id = p.id
WHERE c.slug = {sql(slug)} AND c.name = {sql(name)}
AND c.sort_order = {order} AND p.slug = 'control-valve-hvac') <> 1
THEN RAISE EXCEPTION 'Catalogue category conflict: {slug}'; END IF;
END $$;""")
for old, cat_slug, new, row in LEGACY:
    target_slug = {21: "pressure-independent-control-valve", 22: "motorized-butterfly-valve"}.get(row, cat_slug)
    if target_slug != cat_slug:
        emit(f"""INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id FROM san_pham p JOIN category c ON c.slug = {sql(target_slug)}
WHERE {locator(old, cat_slug)} AND NOT EXISTS
(SELECT 1 FROM product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);""")
        emit(f"""DELETE FROM product_category pc USING san_pham p, category c
WHERE pc.product_id = p.id AND pc.category_id = c.id AND p.ten = {sql(old)}
AND c.slug = {sql(cat_slug)} AND EXISTS (SELECT 1 FROM product_category pc2
JOIN category c2 ON c2.id = pc2.category_id WHERE pc2.product_id = p.id AND c2.slug = {sql(target_slug)});""")
    product_image = {2: "image1.png", 5: "image2.png", 6: "image5.png", 7: "image10.png",
                     9: "image14.png", 10: "image15.png", 11: "image16.png",
                     12: "image18.png", 15: "image20.png", 16: "image21.png",
                     21: "image27.png", 22: "image29.png"}.get(row)
    fields = content(row, image=f"/catalogue/{product_image}" if product_image else None)
    fields["ten"] = sql(new)
    fields["short_text"] = sql(new)
    fields["visible"] = "TRUE"
    emit("UPDATE san_pham p SET " + ", ".join(f"{key} = {value}" for key, value in fields.items())
         + f" WHERE {locator(old, target_slug)};")

# Heatpump source row represents three models; retain the old aggregate URL.
emit("""UPDATE san_pham p SET visible = FALSE WHERE p.ten = 'Heatpump Air Source'
AND EXISTS (SELECT 1 FROM product_category pc JOIN category c ON c.id = pc.category_id
WHERE pc.product_id = p.id AND c.slug = 'heatpump-air-source');""")


def insert_product(name, category, row, model=None, chosen_docs=None, spec_override=None, image=None):
    fields = content(row, model, chosen_docs, image)
    if spec_override is not None:
        fields["specs"] = spec_override
    columns = ["ten", "short_text", "mo_ta", "applications", "features", "specs", "documents", "hinh_anh", "visible"]
    values = [sql(name), sql(name)] + [fields[k] for k in columns[2:-1]] + ["TRUE"]
    field_values = dict(zip(columns, values))
    check = " AND ".join(f"p.{field} IS NOT DISTINCT FROM {value}" for field, value in field_values.items())
    emit(f"""DO $$ BEGIN
IF EXISTS (SELECT 1 FROM san_pham p WHERE p.ten = {sql(name)} AND NOT EXISTS
 (SELECT 1 FROM product_category pc JOIN category c ON c.id = pc.category_id
  WHERE pc.product_id = p.id AND c.slug = {sql(category)}))
OR (SELECT count(*) FROM san_pham p JOIN product_category pc ON pc.product_id = p.id
 JOIN category c ON c.id = pc.category_id WHERE p.ten = {sql(name)} AND c.slug = {sql(category)}) > 1
OR EXISTS (SELECT 1 FROM san_pham p JOIN product_category pc ON pc.product_id = p.id
 JOIN category c ON c.id = pc.category_id WHERE p.ten = {sql(name)} AND c.slug = {sql(category)}
 AND NOT ({check}))
THEN RAISE EXCEPTION 'Catalogue product name conflict: {name}'; END IF;
END $$;""")
    emit(f"""INSERT INTO san_pham ({', '.join(columns)})
SELECT {', '.join(values)} WHERE NOT EXISTS (
 SELECT 1 FROM san_pham p JOIN product_category pc ON pc.product_id = p.id
 JOIN category c ON c.id = pc.category_id WHERE p.ten = {sql(name)} AND c.slug = {sql(category)});""")
    emit(f"""INSERT INTO product_category (product_id, category_id)
SELECT p.id, c.id FROM san_pham p JOIN category c ON c.slug = {sql(category)}
WHERE p.ten = {sql(name)} AND NOT EXISTS (SELECT 1 FROM product_category pc WHERE pc.product_id = p.id)
AND NOT EXISTS (SELECT 1 FROM product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);""")


for model in ["CAHP-MC-19", "CAHP-HC-42I", "CAHP-HC-84I"]:
    insert_product(model, "heatpump-air-source", 14, model,
                   [model] if model == "CAHP-MC-19" else [])

# Preserve the old Motorized Globe Valve page and its existing two PDFs.
emit("""UPDATE san_pham p SET visible = FALSE WHERE p.ten = 'Motorized Globe Valve'
AND EXISTS (SELECT 1 FROM product_category pc JOIN category c ON c.id = pc.category_id
WHERE pc.product_id = p.id AND c.slug = 'control-valve-hvac');""")
for name, size, pdf in [("VRB2 / VRB3", "DN15-50", "VRB2 VRB3"),
                         ("VF2 / VF3", "DN65-150", "VF2 + VF3")]:
    raw = lines(cell("D", 23))
    own = [part for part in raw if part.startswith(size + ":")]
    spec_entries = [{"label": "Model", "value": name}, {"label": "Size", "value": size}]
    if own:
        spec_entries.append({"label": "Model details", "value": own[0]})
    if len(own) > 1:
        spec_entries.append({"label": "Material", "value": own[1]})
    for line in raw:
        if line.startswith(("Working pressure:", "Actuator:", "Input signal:")):
            label, value = line.split(":", 1)
            spec_entries.append({"label": label, "value": value.strip()})
    spec = data(spec_entries)
    insert_product(name, "motorized-globe-valve", 23, None, [pdf], spec,
                   f"/catalogue/{'image31.png' if size == 'DN15-50' else 'image30.png'}")

# Hide old Neptune series navigation and their products while keeping all URLs.
OLD_NEPTUNE_SLUGS = [
    "pressure-control-series", "solenoid-control-series", "level-control-series",
    "flow-control-series", "pump-station-check-valve", "additional-products",
    "pressure-reducing-series", "overpressure-protection",
    "direct-acting-pressure-reducing-valve", "check-valves", "air-valves",
]
emit("UPDATE category SET visible = FALSE WHERE slug IN (" + ", ".join(map(sql, OLD_NEPTUNE_SLUGS)) + ");")
old_v18 = (MIGRATIONS / "V18__acv_structured_description_and_n550_document.sql").read_text(encoding="utf-8")
old_names = sorted(set(re.findall(r"WHERE ten = '([^']+)'", old_v18)) - {"N550 - Surge Anticipation Valve"})
emit("""UPDATE san_pham p SET visible = FALSE WHERE p.ten IN (""" + ", ".join(map(sql, old_names)) + """ )
AND EXISTS (SELECT 1 FROM product_category pc JOIN category c ON c.id = pc.category_id
WHERE pc.product_id = p.id AND c.slug IN (""" + ", ".join(map(sql, OLD_NEPTUNE_SLUGS)) + "));" )

OUTPUT.write_text("\n\n".join(STATEMENTS) + "\n", encoding="utf-8")
print(f"Wrote {OUTPUT}, {len(STATEMENTS)} statements")
