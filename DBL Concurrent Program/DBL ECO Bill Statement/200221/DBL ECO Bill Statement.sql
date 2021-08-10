/* Formatted on 2/20/2021 12:50:16 PM (QP5 v5.354) */
SELECT bsh.customer_number,
       bsh.customer_name,
       bsh.cutomer_address,
       bsh.bill_stat_number,
       bsh.bill_stat_date,
       bsh.pi_number,
       bsl.order_number,
       bsl.customer_po_number,
       bsl.item_code,
       bsl.item_description,
       bsl.article_ticket         colour_group,
       bsl.colour_group           article_ticket,
       cay.segment3               product_type,
       bsl.quantity,
       bsl.price,
       ROUND ((bsl.VALUE), 2)     VALUE,
       bsh.bill_stat_status
  FROM xxdbl_bill_stat_headers  bsh,
       xxdbl_bill_stat_lines    bsl,
       mtl_item_categories_v    cay
 WHERE     bsh.org_id = bsl.org_id
       AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
       AND bsl.inventory_item_id = cay.inventory_item_id
       AND cay.category_set_name = 'Inventory'
       AND cay.organization_id = 150
       AND cay.segment3 = 'SEWING THREAD'
       AND bsh.bill_stat_number = :p_bill_stat_number
UNION ALL
  SELECT bsh.customer_number,
         bsh.customer_name,
         bsh.cutomer_address,
         bsh.bill_stat_number,
         bsh.bill_stat_date,
         bsh.pi_number,
         bsl.order_number,
         bsl.customer_po_number,
         bsl.item_code,
         --bsl.item_description,
         ola.user_item_description
             item_description,
         ola.attribute1
             article_ticket,
         bsl.colour_group,
         cay.segment3
             product_type,
         --bsl.quantity,
         SUM ((100 / (100 - ola.cust_model_serial_number) * (bsl.quantity)))
             quantity,
           -- bsl.price,
           --ety.list_price price,
           SUM (bsl.VALUE)
         / SUM ((100 / (100 - ola.cust_model_serial_number) * (bsl.quantity)))
             price,
         ROUND (SUM (bsl.VALUE), 2)
             VALUE,
         bsh.bill_stat_status
    FROM xxdbl_bill_stat_headers bsh,
         xxdbl_bill_stat_lines  bsl,
         oe_order_lines_all     ola,
         mtl_item_categories_v  cay
   --apps.xxdbl_ety_pl_details ety
   WHERE     bsh.org_id = bsl.org_id
         AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
         AND bsl.order_line_id = ola.line_id
         --AND ola.customer_shipment_number = ety.item_sales_category
         AND ola.ordered_item_id = cay.inventory_item_id
         -- AND ola.price_list_id = ety.list_header_id
         --AND ola.invoice_to_org_id = ety.customer_bill_to_id
         AND cay.category_set_name = 'Inventory'
         AND cay.organization_id = 150
         AND cay.segment3 IN ('DYED FIBER', 'DYED YARN')
         AND bsh.bill_stat_number = :p_bill_stat_number
GROUP BY bsh.customer_number,
         bsh.customer_name,
         bsh.cutomer_address,
         bsh.bill_stat_number,
         bsh.bill_stat_date,
         bsh.pi_number,
         bsl.order_number,
         bsl.customer_po_number,
         bsl.item_code,
         --bsl.item_description,
         ola.user_item_description,
         ola.attribute1,
         bsl.article_ticket,
         bsl.colour_group,
         cay.segment3,
         bsh.bill_stat_status
ORDER BY customer_po_number, colour_group