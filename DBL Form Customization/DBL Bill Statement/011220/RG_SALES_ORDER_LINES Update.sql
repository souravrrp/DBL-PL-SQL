/* Formatted on 12/1/2020 4:08:09 PM (QP5 v5.287) */
SELECT order_line_no,
       customer_po_number,
       order_number,
       item_code,
       description,
       article_ticket,
       colour_group,
       quantity,
       price,
       VALUE,
       order_id,
       order_line_id,
       inventory_item_id,
       style_number,
       hs_code
  FROM (SELECT order_line_no,
               customer_po_number,
               order_number,
               item_code,
               description,
               article_ticket,
               colour_group,
               quantity,
               price,
               VALUE,
               order_id,
               order_line_id,
               inventory_item_id,
               style_number,
               hs_code
          FROM xxdbl_bs_main_order_line_v
         WHERE     1 = 1
               AND sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
               AND :xxdbl_bill_stat_headers.bill_stat_status = 'NEW'
        UNION ALL
        SELECT order_line_no,
               customer_po_number,
               order_number,
               item_code,
               description,
               article_ticket,
               colour_group,
               quantity,
               price,
               VALUE,
               order_id,
               order_line_id,
               inventory_item_id,
               style_number,
               hs_code
          FROM xxdbl_bs_return_order_line_v
         WHERE     1 = 1
               AND sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
               AND :xxdbl_bill_stat_headers.bill_stat_status NOT IN
                      ('NEW', 'CANCELLED'))
 WHERE     1 = 1
       AND EXISTS
              (SELECT 'X'
                 FROM DUAL
                WHERE xxdbl_shiping_tran_crp_pkg.get_split_line_exists (
                         order_id,
                         order_line_id) = 0)
UNION ALL
SELECT order_line_no,
       customer_po_number,
       order_number,
       item_code,
       description,
       article_ticket,
       colour_group,
       quantity,
       price,
       VALUE,
       order_id,
       order_line_id,
       inventory_item_id,
       style_number,
       hs_code
  FROM APPS.XXDBL_BS_RETURN_APPRV_LINE_V xx
 WHERE     1 = 1
       AND sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
       AND :xxdbl_bill_stat_headers.bill_stat_status NOT IN
              ('NEW', 'CANCELLED')