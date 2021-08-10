/* Formatted on 11/4/2020 12:35:47 PM (QP5 v5.287) */
SELECT bsl.*
  --bsl.*
  FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
 WHERE     1 = 1
       AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
       AND ( :p_org_id IS NULL OR (bsh.org_id = :p_org_id))
       --AND bsh.bill_stat_header_id = 6
       --AND BILL_STAT_STATUS NOT IN ('CONFIRMED','CANCELLED')
       --AND bsh.bill_stat_number IN ( 'BS-66046-000002')
       AND ( :p_bs_number IS NULL OR (bsh.bill_stat_number = :p_bs_number))
       AND ( :p_order_number IS NULL OR (bsl.order_number = :p_order_number))
       ;


select
*
from
xxdbl_bs_main_order_line_v;

--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl_bill_stat_headers
 WHERE 1 = 1                                    --AND bill_stat_header_id = 39
            AND bill_stat_number = 'BS-2024-000001';

SELECT *
  FROM xxdbl_bill_stat_lines
 WHERE 1 = 1 AND bill_stat_header_id = 6