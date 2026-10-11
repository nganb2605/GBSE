-- ============================================================
-- V26: Set product images for remaining CAHP child models
-- ============================================================

UPDATE san_pham 
   SET hinh_anh = '/productsimage/heatpump-air-source.png' 
 WHERE ten IN ('CAHP-MC-19', 'CAHP-HC-42I', 'CAHP-HC-84I')
   AND (hinh_anh IS NULL OR hinh_anh = '');

