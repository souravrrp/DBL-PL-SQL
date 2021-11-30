/* Formatted on 11/29/2021 10:54:11 AM (QP5 v5.365) */
SELECT pl.bill_stat_number l_bill_stat_number, pl.VALUE l_bs_value,pl.quantity l_bs_qty
  FROM xxdbl_proforma_headers ph, xxdbl_proforma_lines pl
 WHERE     ph.proforma_header_id = pl.proforma_header_id(+)
       --AND ph.proforma_header_id = :xxdbl_proforma_headers.proforma_header_id
       AND ph.proforma_header_id = :proforma_header_id;



SELECT SUM (bsl.VALUE)     l_bs_act_value,  SUM (bsl.QUANTITY)     l_bs_act_qty
  FROM xxdbl_bill_stat_headers bsh, xxdbl_bill_stat_lines bsl
 WHERE     1 = 1
       AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
       AND bsh.bill_stat_number = :p_bs_number;