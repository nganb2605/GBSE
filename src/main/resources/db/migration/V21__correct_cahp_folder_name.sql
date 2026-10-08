-- Row 15 of GBSE-web.xlsx labels the parent group "Heatpump all in one".
-- The direct-PDF folder below it is the CAHP-1.5HP product. Keep the
-- workbook text on its detail page, but use the folder name for the card.
UPDATE san_pham
SET ten = 'CAHP-1.5HP'
WHERE source_folder = '3. Heatpump/3.2. Heatpump all in one/3.2.1. CAHP-1.5HP'
  AND ten = 'Heatpump all in one';
