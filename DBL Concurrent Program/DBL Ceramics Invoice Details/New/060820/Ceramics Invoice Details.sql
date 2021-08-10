/* Formatted on 8/6/2020 2:22:42 PM (QP5 v5.354) */
SELECT ac.customer_number,
       ac.customer_name,
       ac.customer_category_code           cust_category,
       (CASE
            WHEN ac.customer_type = 'R' THEN 'External'
            WHEN ac.customer_type = 'I' THEN 'Internal'
            WHEN ac.customer_type = '' THEN 'N/A'
        END)                               c_type,
       ott.name                            order_type,
       oha.order_number,
       ola.line_id,
       TRUNC (oha.ordered_date)            ordered_date,
       TRUNC (ola.actual_shipment_date)    delivery_date,
       oha.freight_terms_code              freight,
       ola.flow_status_code,
       ola.ordered_item,
       msi.description,
       ola.preferred_grade,
       cat.segment2                        item_size,
       cat.category_concat_segs            product_category,
       cay.segment3                        product_type,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               ola.ordered_quantity * (-1)
           ELSE
               ola.ordered_quantity
       END                                 ordered_quantity,
       ola.order_quantity_uom,
       ola.unit_list_price,
       ola.unit_selling_price,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               ola.ordered_quantity2 * (-1)
           ELSE
               ola.ordered_quantity2
       END                                 ordered_quantity2,
       ola.ordered_quantity_uom2,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               (ola.unit_list_price - ola.unit_selling_price) * (-1)
           ELSE
               (  ola.unit_list_price
                - ola.unit_selling_price
                + pav.adjusted_amount)
       END                                 discount_sft,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
                 (  (ola.unit_list_price - ola.unit_selling_price)
                  * ola.ordered_quantity)
               * (-1)
           ELSE
                 (  ola.unit_list_price
                  - ola.unit_selling_price
                  + pav.adjusted_amount)
               * ola.ordered_quantity
       END                                 line_discount,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               ABS (pav.adjusted_amount) * (-1)
           ELSE
               ABS (pav.adjusted_amount)
       END                                 header_dis_sft,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               (ABS (pav.adjusted_amount) * ola.ordered_quantity) * (-1)
           ELSE
               ABS (pav.adjusted_amount) * ola.shipped_quantity
       END                                 header_dis_amt,
       CASE
           WHEN     ola.freight_terms_code = 'DEALER'
                AND ott.transaction_type_id NOT IN (1006, 1014)
           THEN
               ola.shipped_quantity * .8
           ELSE
               0
       END                                 freight_value,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               (ola.unit_list_price - ola.unit_selling_price) * (-1)
           ELSE
                 (ola.unit_list_price - ola.unit_selling_price)
               * ola.ordered_quantity
       END                                 total_discount,
       CASE
           WHEN transaction_type_id IN ('1010', '1008', '1030')
           THEN
               (ola.shipped_quantity * ola.unit_selling_price) * (-1)
           ELSE
               ola.shipped_quantity * ola.unit_selling_price
       END                                 invoice_amount,
       ct.trx_number                       invoice_number,
       rsv.resource_name                   sales_person
  FROM oe_order_headers_all          oha,
       oe_order_lines_all            ola,
       apps.oe_transaction_types_tl  ott,
       inv.mtl_system_items_b        msi,
       ar_customers                  ac,
       mtl_item_categories_v         cat,
       mtl_item_categories_v         cay,
       ra_customer_trx_all           ct,
       ra_customer_trx_lines_all     ctl,
       jtf_rs_salesreps              sal,
       jtf_rs_defresources_v         rsv,
       oe_price_adjustments_v        pav
 WHERE     oha.header_id = ola.header_id
       AND oha.org_id = ola.org_id
       AND oha.order_type_id = ott.transaction_type_id
       AND oha.header_id = pav.header_id
       AND ola.line_id = pav.line_id
       AND ola.inventory_item_id = msi.inventory_item_id
       AND ola.ship_from_org_id = msi.organization_id
       AND oha.sold_to_org_id = ac.customer_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.inventory_item_id = cay.inventory_item_id
       AND pav.adjustment_name = 'SO Header Adhoc Discount'
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND cay.category_set_name = 'Inventory'
       AND TO_CHAR (oha.order_number) =
           TO_CHAR (ctl.interface_line_attribute1)
       AND oha.sold_to_org_id = ct.bill_to_customer_id
       AND ct.customer_trx_id = ctl.customer_trx_id
       AND ola.line_id = ctl.interface_line_attribute6
       AND oha.salesrep_id = sal.salesrep_id
       AND sal.resource_id = rsv.resource_id
       AND sal.org_id = oha.org_id
       AND cay.organization_id = 152
       AND cat.organization_id = cay.organization_id
       AND oha.org_id = 126
       AND ola.flow_status_code = 'CLOSED'
       --AND oha.order_number = 2011020000004
       --AND TRUNC (ola.actual_shipment_date) BETWEEN '01-JUL-20' AND  '31-JUL-20'                                               
       --AND transaction_type_id IN ('1010', '1008', '1030')
       AND oha.org_id = :p_org_id
       AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
       AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
       AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
                                                AND :p_date_to
UNION ALL
SELECT ac.customer_number,
       ac.customer_name,
       ac.customer_category_code
           cust_category,
       ac.customer_type
           c_type,
       ott.name
           order_type,
       oha.order_number,
       ola.line_id,
       TRUNC (oha.ordered_date)
           ordered_date,
       TRUNC (ola.actual_shipment_date)
           delivery_date,
       oha.freight_terms_code
           freight,
       ola.flow_status_code,
       ola.ordered_item,
       msi.description,
       ola.preferred_grade,
       cat.segment2
           item_size,
       cat.category_concat_segs
           product_category,
       cay.segment3
           product_type,
       ola.ordered_quantity,
       ola.order_quantity_uom,
       ola.unit_list_price,
       ola.unit_selling_price,
       ola.ordered_quantity2,
       ola.ordered_quantity_uom2,
       (ola.unit_list_price - ola.unit_selling_price)
           discount_sft,
       (ola.unit_list_price - ola.unit_selling_price) * ola.ordered_quantity
           line_discount,
       NULL
           header_dis_sft,
       NULL
           header_dis_amt,
       CASE
           WHEN     ola.freight_terms_code = 'DEALER'
                AND ott.transaction_type_id NOT IN (1006, 1014)
           THEN
               ola.shipped_quantity * .8
           ELSE
               0
       END
           freight_value,
       (ola.unit_list_price - ola.unit_selling_price) * ola.ordered_quantity
           total_discount,
       ola.shipped_quantity * ola.unit_selling_price
           invoice_amount,
       ct.trx_number
           invoice_number,
       rsv.resource_name
           sales_person
  FROM oe_order_headers_all          oha,
       oe_order_lines_all            ola,
       apps.oe_transaction_types_tl  ott,
       inv.mtl_system_items_b        msi,
       ar_customers                  ac,
       mtl_item_categories_v         cat,
       mtl_item_categories_v         cay,
       ra_customer_trx_all           ct,
       ra_customer_trx_lines_all     ctl,
       jtf_rs_salesreps              sal,
       jtf_rs_defresources_v         rsv
 WHERE     oha.header_id = ola.header_id
       AND oha.org_id = ola.org_id
       AND oha.order_type_id = ott.transaction_type_id
       AND ola.inventory_item_id = msi.inventory_item_id
       AND ola.ship_from_org_id = msi.organization_id
       AND oha.sold_to_org_id = ac.customer_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.inventory_item_id = cay.inventory_item_id
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND cay.category_set_name = 'Inventory'
       AND TO_CHAR (oha.order_number) =
           TO_CHAR (ctl.interface_line_attribute1)
       AND oha.sold_to_org_id = ct.bill_to_customer_id
       AND ct.customer_trx_id = ctl.customer_trx_id
       AND ola.line_id = ctl.interface_line_attribute6
       AND oha.salesrep_id = sal.salesrep_id
       AND sal.resource_id = rsv.resource_id
       AND sal.org_id = oha.org_id
       AND cay.organization_id = 152
       AND cat.organization_id = cay.organization_id
       AND oha.org_id = 126
       AND ola.flow_status_code = 'CLOSED'
       AND ott.transaction_type_id NOT IN (1008,
                                           1010,
                                           1030,
                                           1032,
                                           1034)
       --AND TRUNC (ola.actual_shipment_date) BETWEEN '01-JUL-20' AND  '31-JUL-20'                                              
       AND oha.org_id = :p_org_id
       AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
       AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
       AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
                                                AND :p_date_to
       AND NOT EXISTS
               (SELECT 1
                  FROM oe_price_adjustments_v pav
                 WHERE     ola.line_id = pav.line_id
                       AND pav.adjustment_name = 'SO Header Adhoc Discount')