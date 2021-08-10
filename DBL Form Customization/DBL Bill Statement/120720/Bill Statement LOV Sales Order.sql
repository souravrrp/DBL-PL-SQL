SELECT      e.line_number
         || DECODE (e.shipment_number, NULL, NULL, '.' || e.shipment_number)
         || DECODE (e.option_number, NULL, NULL, '.' || e.option_number)
                                                                order_line_no,
         e.cust_po_number customer_po_number, d.order_number,
         c.concatenated_segments item_code, c.description,
         a.segment1 article_ticket, b.segment2 colour_group,
         TO_NUMBER (DECODE (e.line_category_code,
                            'RETURN', -1
                             * e.ordered_quantity /*e.customer_job*/,
                            e.ordered_quantity              /*e.customer_job*/
                           )
                   ) quantity,
         e.unit_list_price price,
           DECODE (e.line_category_code,
                   'RETURN', -1 * e.ordered_quantity,
                   e.ordered_quantity
                  )
         * e.unit_list_price VALUE,
         d.header_id order_id, e.line_id order_line_id, e.inventory_item_id,
         d.packing_instructions style_number, c.attribute5 hs_code
    FROM mtl_item_categories_v a,
         mtl_categories b,
         mtl_system_items_kfv c,
         oe_order_headers_all d,
         oe_order_lines_all e,
         oe_transaction_types_all f,
         oe_transaction_types_tl g
   WHERE a.category_set_name = 'DBL_SALES_CAT_SET'
     AND a.organization_id IN (SELECT organization_id
                                 FROM org_organization_definitions ood
                                WHERE ood.operating_unit = fnd_global.org_id)
     AND a.category_id = b.category_id
     AND a.inventory_item_id = c.inventory_item_id
     AND a.organization_id = c.organization_id
     AND d.header_id = e.header_id
     AND e.inventory_item_id = c.inventory_item_id
     AND e.ship_from_org_id = c.organization_id
     AND e.flow_status_code NOT IN ('CANCELLED', 'ENTERED')
     AND d.order_type_id = f.transaction_type_id
     AND f.transaction_type_id = g.transaction_type_id
     /*AND g.NAME NOT LIKE '%FOC%'*/
     AND NVL (f.attribute2, 'N') != 'Y'
     AND e.org_id = fnd_global.org_id
     AND d.org_id = fnd_global.org_id
     AND e.sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
     AND NOT EXISTS (
            SELECT 'X'
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsl.order_line_id = e.line_id
               AND xbsh.bill_stat_status <> 'CANCELLED')
     AND :xxdbl_bill_stat_headers.bill_stat_status = 'NEW'
     AND xxdbl_shiping_tran_crp_pkg.get_split_line_exists (e.header_id,
                                                           e.line_id
                                                          ) = 0
UNION ALL
SELECT      e.line_number
         || DECODE (e.shipment_number, NULL, NULL, '.' || e.shipment_number)
         || DECODE (e.option_number, NULL, NULL, '.' || e.option_number)
                                                                order_line_no,
         e.cust_po_number customer_po_number, d.order_number,
         c.concatenated_segments item_code, c.description,
         a.segment1 article_ticket, b.segment2 colour_group,
         TO_NUMBER (DECODE (e.line_category_code,
                            'RETURN', -1
                             * e.ordered_quantity /*e.customer_job*/,
                            e.ordered_quantity              /*e.customer_job*/
                           )
                   ) quantity,
         e.unit_list_price price,
           DECODE (e.line_category_code,
                   'RETURN', -1 * e.ordered_quantity,
                   e.ordered_quantity
                  )
         * e.unit_list_price VALUE,
         d.header_id order_id, e.line_id order_line_id, e.inventory_item_id,
         d.packing_instructions style_number, c.attribute5 hs_code
    FROM mtl_item_categories_v a,
         mtl_categories b,
         mtl_system_items_kfv c,
         oe_order_headers_all d,
         oe_order_lines_all e,
         oe_transaction_types_all f,
         oe_transaction_types_tl g
   WHERE a.category_set_name = 'DBL_SALES_CAT_SET'
     AND a.organization_id IN (SELECT organization_id
                                 FROM org_organization_definitions ood
                                WHERE ood.operating_unit = fnd_global.org_id)
     AND a.category_id = b.category_id
     AND a.inventory_item_id = c.inventory_item_id
     AND a.organization_id = c.organization_id
     AND d.header_id = e.header_id
     AND e.inventory_item_id = c.inventory_item_id
     AND e.ship_from_org_id = c.organization_id
     AND e.flow_status_code NOT IN ('CANCELLED', 'ENTERED')
     AND d.order_type_id = f.transaction_type_id
     AND f.transaction_type_id = g.transaction_type_id
     AND g.NAME LIKE '%Replacement%'
     /*AND e.line_category_code = 'RETURN'*/
     AND e.org_id = fnd_global.org_id
     AND d.org_id = fnd_global.org_id
     AND e.sold_to_org_id = :xxdbl_bill_stat_headers.customer_id
     AND NOT EXISTS (
            SELECT 'X'
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsl.order_line_id = e.line_id
               AND xbsh.bill_stat_status <> 'CANCELLED')
     AND :xxdbl_bill_stat_headers.bill_stat_status NOT IN
                                                         ('NEW', 'CANCELLED')
     AND xxdbl_shiping_tran_crp_pkg.get_split_line_exists (e.header_id,
                                                           e.line_id
                                                          ) = 0
ORDER BY 11, 12