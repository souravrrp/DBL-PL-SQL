/* Formatted on 11/30/2021 3:13:46 PM (QP5 v5.365) */
SELECT mll1.pi_number l_pi_number, mll1.pi_value l_pi_value
  FROM xxdbl_master_lc_headers mlh, xxdbl_master_lc_line1 mll1
 WHERE     mlh.master_lc_header_id = mll1.master_lc_header_id(+)
       AND mlh.master_lc_header_id = :xxdbl_master_lc_headers.master_lc_header_id;


SELECT SUM (pl.VALUE)                                                   --INTO
                          l_pi_value
  FROM xxdbl_proforma_headers ph, xxdbl_proforma_lines pl
 WHERE     ph.proforma_header_id = pl.proforma_header_id(+)
       AND ph.proforma_number = :proforma_number;