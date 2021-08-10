/* Formatted on 3/16/2020 3:18:12 PM (QP5 v5.287) */
  SELECT                                                  --ABH.BILL_CATEGORY,
         (CASE
             WHEN abh.bill_category = 'Yarn Export' THEN 'Cotton'
             WHEN abh.bill_category = 'Yarn Export Melange' THEN 'Melange'
             WHEN abh.bill_category = 'Yarn Export Synthatic' THEN 'Synthatic'
          END)
            bill_category,
         (CASE
             WHEN ac.customer_type = 'R' THEN 'External'
             WHEN ac.customer_type = 'I' THEN 'Internal'
             WHEN ac.customer_type = '' THEN 'N/A'
          END)
            customer_type,
         SUM (bld.finishing_weight) quantity,
           SUM (
                bld.finishing_weight
              * bld.unit_selling_price
              * NVL (abh.exchance_rate, 1))
         / SUM (bld.finishing_weight)
            avg_price,
         SUM (
              bld.finishing_weight
            * bld.unit_selling_price
            * NVL (abh.exchance_rate, 1))
            total_price_bdt
    FROM xx_ar_bills_headers_all abh,
         xx_ar_bills_lines_all abl,
         xx_ar_bills_line_details_all bld,
         xxdbl.xxdbl_yrn_type_data ytd,
         ar_customers ac
   WHERE     abh.bill_header_id = abl.bill_header_id
         AND abl.bill_line_id = bld.bill_line_id
         AND abh.customer_id = ac.customer_id
         AND bld.item_code = ytd.item_code(+)
         AND abh.org_id = 131
         AND abh.bill_status = 'CONFIRMED'
         --AND TRUNC (ABL.CHALLAN_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
         AND TRUNC (abl.creation_date) BETWEEN '01-JAN-20' AND '31-JAN-20'
         --AND TRUNC (ABL.CHALLAN_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
         --AND TRUNC (abl.CHALLAN_DATE) BETWEEN '01-Jan-2020' AND '31-Jan-2020'
GROUP BY abh.bill_category, ac.customer_type
ORDER BY abh.bill_category