/* Formatted on 3/16/2021 1:28:23 PM (QP5 v5.354) */
  SELECT CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         CUTOMER_ADDRESS,
         BILL_STAT_NUMBER,
         BILL_STAT_DATE,
         PI_NUMBER,
         ORDER_NUMBER,
         CUSTOMER_PO_NUMBER,
         --ITEM_CODE,
         ITEM_DESCRIPTION,
         COLOUR_GROUP,
         ARTICLE_TICKET,
         PRODUCT_TYPE,
         SUM (QUANTITY)      QUANTITY,
         PRICE,
         SUM (NET_VALUE)     NET_VALUE,
         BILL_STAT_STATUS,
         HS_CODE,
         M_NAME,
         ARTICLE,
         NET_WEIGHT,
         GROSS_WEIGHT,
         UNIT,
         PRICE_PER_UNIT,
         PAYMENT_TERM,
         BANK_NAME,
         STYLE
    FROM (  SELECT bsh.customer_number,
                   bsh.customer_name,
                   bsh.cutomer_address,
                   bsh.bill_stat_number,
                   bsh.bill_stat_date,
                   bsh.pi_number,
                   bsl.order_number,
                   bsl.customer_po_number,
                   bsl.item_code,
                   bsl.item_description,
                   bsl.article_ticket
                       colour_group,
                   bsl.colour_group
                       article_ticket,
                   cay.segment3
                       product_type,
                   bsl.quantity,
                   bsl.price,
                   ROUND ((bsl.VALUE), 2)
                       net_value,
                   bsh.bill_stat_status,
                   bsl.attribute2
                       hs_code,
                   LISTAGG (oha.attribute4, ',')
                       WITHIN GROUP (ORDER BY oha.attribute4)
                       AS m_name,
                   bsl.article_ticket || '-' || bsl.colour_group
                       article,
                   SUM (ola.ordered_quantity2)
                       net_weight,
                   SUM (ola.ordered_quantity * msi.unit_weight)
                       gross_weight,
                   (CASE
                        WHEN ola.order_quantity_uom = 'CON' THEN 'CONE'
                        WHEN ola.order_quantity_uom = 'KG' THEN 'KG'
                    END)
                       unit,
                   ola.unit_selling_price
                       price_per_unit,
                   :payment_term
                       AS payment_term,
                   :bank_name
                       AS bank_name,
                   LISTAGG (bsl.attribute1, ',')
                       WITHIN GROUP (ORDER BY bsl.attribute1)
                       AS style
              FROM xxdbl_bill_stat_headers bsh,
                   xxdbl_bill_stat_lines bsl,
                   mtl_item_categories_v cay,
                   oe_order_lines_all   ola,
                   oe_order_headers_all oha,
                   mtl_system_items     msi
             WHERE     bsh.org_id = bsl.org_id
                   AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
                   AND bsl.inventory_item_id = cay.inventory_item_id
                   AND cay.category_set_name = 'Inventory'
                   AND cay.organization_id = 150
                   AND cay.segment3 = 'SEWING THREAD'
                   AND bsh.bill_stat_number = :p_bill_stat_number
                   AND ola.header_id = bsl.order_id
                   AND ola.header_id = oha.header_id
                   AND ola.line_id = bsl.order_line_id
                   AND ola.inventory_item_id = cay.inventory_item_id
                   AND ola.inventory_item_id = msi.inventory_item_id
                   AND cay.organization_id = msi.organization_id
          GROUP BY bsh.customer_number,
                   bsh.customer_name,
                   bsh.cutomer_address,
                   bsh.bill_stat_number,
                   bsh.bill_stat_date,
                   bsh.pi_number,
                   bsl.order_number,
                   bsl.customer_po_number,
                   bsl.item_code,
                   bsl.item_description,
                   bsl.article_ticket,
                   bsl.colour_group,
                   cay.segment3,
                   bsl.quantity,
                   bsl.price,
                   ROUND ((bsl.VALUE), 2),
                   bsh.bill_stat_status,
                   bsl.attribute2,
                   ola.order_quantity_uom,
                   ola.unit_selling_price
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
                   SUM (
                       (  100
                        / (100 - ola.cust_model_serial_number)
                        * (bsl.quantity)))
                       quantity,
                     -- bsl.price,
                     --ety.list_price price,
                     SUM (bsl.VALUE)
                   / SUM (
                         (  100
                          / (100 - ola.cust_model_serial_number)
                          * (bsl.quantity)))
                       price,
                   ROUND (SUM (bsl.VALUE), 2)
                       net_value,
                   bsh.bill_stat_status,
                   bsl.attribute2
                       hs_code,
                   LISTAGG (oha.attribute4, ',')
                       WITHIN GROUP (ORDER BY oha.attribute4)
                       AS m_name,
                   bsl.article_ticket || '-' || bsl.colour_group
                       article,
                   SUM (ola.ordered_quantity2)
                       net_weight,
                   SUM (ola.ordered_quantity * msi.unit_weight)
                       gross_weight,
                   (CASE
                        WHEN ola.order_quantity_uom = 'CON' THEN 'CONE'
                        WHEN ola.order_quantity_uom = 'KG' THEN 'KG'
                    END)
                       unit,
                   ola.unit_selling_price
                       price_per_unit,
                   :payment_term
                       payment_term,
                   :bank_name
                       bank_name,
                   LISTAGG (bsl.attribute1, ',')
                       WITHIN GROUP (ORDER BY bsl.attribute1)
                       AS style
              FROM xxdbl_bill_stat_headers bsh,
                   xxdbl_bill_stat_lines bsl,
                   oe_order_lines_all   ola,
                   mtl_item_categories_v cay,
                   oe_order_headers_all oha,
                   mtl_system_items     msi
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
                   AND ola.header_id = bsl.order_id
                   AND ola.header_id = oha.header_id
                   AND ola.inventory_item_id = msi.inventory_item_id
                   AND cay.organization_id = msi.organization_id
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
                   bsh.bill_stat_status,
                   bsl.attribute2,
                   ola.order_quantity_uom,
                   ola.unit_selling_price
          ORDER BY customer_po_number, colour_group)
--WHERE ARTICLE = 'ET01160-COLOUR' AND NET_WEIGHT = '9.4348'
GROUP BY CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         CUTOMER_ADDRESS,
         BILL_STAT_NUMBER,
         BILL_STAT_DATE,
         PI_NUMBER,
         ORDER_NUMBER,
         CUSTOMER_PO_NUMBER,
         --ITEM_CODE,
         ITEM_DESCRIPTION,
         COLOUR_GROUP,
         ARTICLE_TICKET,
         PRODUCT_TYPE,
         PRICE,
         BILL_STAT_STATUS,
         HS_CODE,
         M_NAME,
         ARTICLE,
         NET_WEIGHT,
         GROSS_WEIGHT,
         UNIT,
         PRICE_PER_UNIT,
         PAYMENT_TERM,
         BANK_NAME,
         STYLE