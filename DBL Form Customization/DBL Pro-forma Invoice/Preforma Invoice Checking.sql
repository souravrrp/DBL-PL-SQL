/* Formatted on 1/13/2021 11:14:07 AM (QP5 v5.287) */
SELECT --ph.*
  pl.*
  FROM xxdbl_proforma_headers ph, xxdbl_proforma_lines pl
 WHERE     1 = 1
       AND ph.proforma_header_id = pl.proforma_header_id
       AND ( :p_org_id IS NULL OR (ph.org_id = :p_org_id))
       AND ( :p_customer_no IS NULL OR (ph.customer_number = :p_customer_no))
       --AND pl.bill_stat_number in ('bs-2009-000020')
       --AND ph.attribute9 in ('dpcdak892692')
       AND ( :p_pi_number IS NULL OR (ph.proforma_number = :p_pi_number))
       AND ( :p_lc_number IS NULL OR (ph.attribute7 = :p_lc_number))
       AND ( :p_b2b_lc_number IS NULL OR (ph.attribute9 = :p_b2b_lc_number));

--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl_proforma_headers ph
 WHERE     1 = 1
       AND ( :p_pi_number IS NULL OR (ph.proforma_number = :p_pi_number))
       AND ( :p_manual_pi IS NULL OR (ph.manual_pi_no = :p_manual_pi));

SELECT *
  FROM xxdbl_proforma_lines pl
 WHERE     1 = 1
       AND EXISTS
              (SELECT 1
                 FROM xxdbl_proforma_headers ph
                WHERE     ph.proforma_header_id = pl.proforma_header_id
                      AND (   :p_pi_number IS NULL
                           OR (ph.proforma_number = :p_pi_number)));