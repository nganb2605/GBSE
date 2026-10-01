-- HPI Series is the second child under the XLSX "Heatpump all in one" row.
-- Its own application cell is blank; the parent row specifies Hot water system.
UPDATE san_pham
SET applications = '["Hot water system"]'
WHERE source_folder = '3. Heatpump/3.2. Heatpump all in one/3.2.2. HPI Series'
  AND applications IS NULL;
