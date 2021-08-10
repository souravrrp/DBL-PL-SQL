SELECT DISTINCT bh.org_id,
                           bh.bill_header_id invoice_id,
                           bh.bill_number,
                           TRUNC (bh.bill_date) trx_date,
                           TRUNC (bh.bill_date) gl_date,
                           bh.bill_currency invoice_currency_code,
                           NVL (bh.exchance_rate, 1) exchance_rate,
                           'Bill Invoice' attribute_category,
                           bh.bill_header_id attribute6,
                           bh.bill_header_id attribute10,
                           'Sales of Yarn' comments,
                           bh.customer_id,
                           bh.customer_type,
                           bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.org_id = 131
                  AND NVL (bh.process_status, 'U') = 'U'
                  --       AND BH.BILL_NUMBER IN ('MSML/1805')
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = 'MAY-20'--p_period_name
                  AND NOT EXISTS
                             (SELECT 1
                                FROM ra_customer_trx_all ra
                               WHERE     ra.attribute6 =
                                            TO_CHAR (bh.bill_header_id)
                                     AND ra.org_id = bh.org_id)
         ORDER BY invoice_id;
         
         
         SELECT bh.org_id,
                  bh.bill_header_id invoice_id,
                  bl.bill_line_id line_id,
                  bld.bill_line_detail_id,
                  TRUNC (bh.bill_date) trx_date,
                  TRUNC (bh.bill_date) gl_date,
                  bh.bill_currency invoice_currency_code,
                  NVL (bh.exchance_rate, 1) exchance_rate,
                  'Bill Invoice' attribute_category,
                  bh.bill_header_id attribute6,
                  bh.bill_header_id attribute10,
                  'Sales of Yarn' comments,
                  bh.customer_id,
                  bld.item_description,
                  bld.uom uom_code,
                  bld.finishing_weight quantity,
                  bld.unit_selling_price,
                  bld.total_price,
                  bl.challan_number,
                  bl.challan_date,
                  bld.pi_number,
                  bld.order_number,
                  bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.bill_header_id = 27754--p_header_id
                  AND bh.org_id = 131
                  AND NVL (bh.process_status, 'U') = 'U'
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = 'MAY-20'--p_period_name
                  AND NOT EXISTS
                             (SELECT 1
                                FROM ra_customer_trx_all ra
                               WHERE     ra.attribute6 =
                                            TO_CHAR (bh.bill_header_id)
                                     AND ra.org_id = bh.org_id)
         ORDER BY trx_date,
                  invoice_id,
                  line_id,
                  bill_line_detail_id;
