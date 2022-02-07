/* Formatted on 9/26/2021 3:55:22 PM (QP5 v5.256.13226.35538) */
SELECT ac.customer_number,
       ac.customer_name,
       ac.customer_category_code cust_category,
       (CASE
           WHEN ac.customer_type = 'R' THEN 'External'
           WHEN ac.customer_type = 'I' THEN 'Internal'
           WHEN ac.customer_type = '' THEN 'N/A'
        END)
          c_type,
       hl.address1,
       oha.order_number,
       ola.line_number || '.' || ola.shipment_number line,
       ott.name order_type,
       TRUNC (oha.ordered_date) ordered_date,
       TRUNC (ola.actual_shipment_date) invoice_date,
       oha.demand_class_code priority,
       oha.freight_terms_code freight,
       oha.flow_status_code,
       ola.flow_status_code,
       ola.ordered_item,
       msi.description,
       oha.shipping_instructions,
       ola.shipping_instructions line_instructions,
       oha.sales_channel_code buyer,
       oha.cust_po_number,
       oha.packing_instructions style,
       oha.attribute4 merchandiser,
       oha.ATTRIBUTE6 brand,
       oha.ATTRIBUTE2 product_group,
       oha.ATTRIBUTE3 assortment,
       oha.ATTRIBUTE5 production_type,
       col.segment3 item_color,
       ola.attribute1 dff_color,
       cat.category_concat_segs product_category,
       cay.segment3 product_type,
       (CASE
           WHEN cay.segment3 = 'SEWING THREAD'
           THEN
              ola.ordered_quantity
           WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
           THEN
              (  100
               / (100 - ola.cust_model_serial_number)
               * (ola.ordered_quantity))
        END)
          ordered_quantity,
       ola.order_quantity_uom,
         ola.ordered_quantity
       * ola.unit_selling_price
       / (CASE
             WHEN cay.segment3 = 'SEWING THREAD'
             THEN
                ola.ordered_quantity
             WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
             THEN
                (  100
                 / (100 - ola.cust_model_serial_number)
                 * (ola.ordered_quantity))
          END)
          unit_list_price,
       ola.unit_selling_price,
       ola.ordered_quantity2,
       ola.ordered_quantity_uom2,
       (CASE
           WHEN cay.segment3 = 'SEWING THREAD'
           THEN
              ola.shipped_quantity
           WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
           THEN
              (  100
               / (100 - ola.cust_model_serial_number)
               * (ola.shipped_quantity))
        END)
          shipped_quantity,
       ola.shipped_quantity traget_qty,
       ola.shipped_quantity2,
       ola.shipped_quantity * ola.unit_selling_price invoice_amount,
       ctl.revenue_amount,
       ct.exchange_rate,
       ctl.revenue_amount * ct.exchange_rate revenue_amount_bdt,
       ct.trx_number invoice_number,
       olv.delivery_challan_number challan_number,
       gcck.concatenated_segments code,
       rsv.resource_name,
       rt.segment2 area,
       rt.segment3 zone,
       rt.segment4 division
  FROM oe_order_headers_all oha,
       oe_order_lines_all ola,
       apps.oe_transaction_types_tl ott,
       inv.mtl_system_items_b msi,
       ar_customers ac,
       apps.hz_cust_accounts hca,
       apps.hz_cust_acct_sites_all hcasa,
       apps.hz_party_sites hps,
       apps.hz_cust_site_uses_all hcsua,
       apps.hz_locations hl,
       mtl_item_categories_v cat,
       mtl_item_categories_v cay,
       mtl_item_categories_v col,
       xxdbl.xxdbl_omshipping_line_v olv,
       jtf_rs_salesreps sal,
       jtf_rs_defresources_v rsv,
       ra_customer_trx_all ct,
       ra_customer_trx_lines_all ctl,
       ra_cust_trx_line_gl_dist_all ladist,
       gl_code_combinations_kfv gcck,
       xxdbl_company_le_mapping_v clm,
       ra_territories rt
 WHERE     oha.header_id = ola.header_id
       AND oha.org_id = ola.org_id
       AND oha.order_type_id = ott.transaction_type_id
       AND ola.inventory_item_id = msi.inventory_item_id
       AND ola.ship_from_org_id = msi.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.inventory_item_id = cay.inventory_item_id
       AND msi.inventory_item_id = col.inventory_item_id
       AND ac.customer_id = hca.cust_account_id
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND cay.category_set_name = 'Inventory'
       AND col.category_set_name = 'DBL_SALES_PLAN_CAT'
       AND cay.organization_id = 150
       AND cat.organization_id = 150
       AND col.organization_id = 150
       AND oha.salesrep_id = sal.salesrep_id
       AND sal.resource_id = rsv.resource_id
       AND sal.org_id = oha.org_id
       AND hcsua.territory_id = rt.territory_id(+)
       AND hca.status = 'A'
       AND hca.cust_account_id = hcasa.cust_account_id(+)
       AND hcasa.status = 'A'
       AND hcsua.status = 'A'
       AND hcasa.party_site_id = hps.party_site_id
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       AND clm.org_id = hcsua.org_id
       AND hps.location_id = hl.location_id
       AND oha.sold_to_org_id = hca.cust_account_id
       AND oha.ship_to_org_id = hcsua.site_use_id
       AND TO_CHAR (oha.order_number) = TO_CHAR (ct.ct_reference)
       AND ct.customer_trx_id = ctl.customer_trx_id
       AND ola.line_id = ctl.interface_line_attribute6
       AND oha.sold_to_org_id = ct.bill_to_customer_id
       AND ola.line_id = olv.order_line_id
       --AND OHA.FLOW_STATUS_CODE = 'BOOKED'
       AND ct.customer_trx_id = ladist.customer_trx_id
       AND ctl.customer_trx_line_id = ladist.customer_trx_line_id
       AND ladist.code_combination_id = gcck.code_combination_id
       AND ola.flow_status_code IN ('CLOSED', 'SHIPPED')
       AND omshipping_line_status NOT IN ('CANCELLED', 'NEW')
       AND primary_onhand_quantity > 0
       AND oha.org_id = 125
       AND oha.org_id = :p_org_id
       AND (   :p_product_category IS NULL
            OR cat.category_concat_segs = :p_product_category)
       AND ( :p_product_type IS NULL OR cay.segment3 = :p_product_type)
       AND (   :p_customer_category IS NULL
            OR ac.customer_category_code = :p_customer_category)
       AND ( :p_sales_person IS NULL OR oha.salesrep_id = :p_sales_person)
       AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
       AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
       AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
                                                AND :p_date_to
UNION ALL
SELECT ac.customer_number,
       ac.customer_name,
       ac.customer_category_code cust_category,
       (CASE
           WHEN ac.customer_type = 'R' THEN 'External'
           WHEN ac.customer_type = 'I' THEN 'Internal'
           WHEN ac.customer_type = '' THEN 'N/A'
        END)
          c_type,
       hl.address1,
       oha.order_number,
       ola.line_number || '.' || ola.shipment_number line,
       ott.name order_type,
       TRUNC (oha.ordered_date) ordered_date,
       TRUNC (ola.actual_shipment_date) invoice_date,
       oha.demand_class_code priority,
       oha.freight_terms_code freight,
       oha.flow_status_code,
       ola.flow_status_code,
       ola.ordered_item,
       msi.description,
       oha.shipping_instructions,
       ola.shipping_instructions line_instructions,
       oha.sales_channel_code buyer,
       oha.cust_po_number,
       oha.packing_instructions style,
       oha.attribute4 merchandiser,
       oha.ATTRIBUTE6 brand,
       oha.ATTRIBUTE2 product_group,
       oha.ATTRIBUTE3 assortment,
       oha.ATTRIBUTE5 production_type,
       col.segment3 item_color,
       ola.attribute1 dff_color,
       cat.category_concat_segs product_category,
       cay.segment3 product_type,
       (  (CASE
              WHEN cay.segment3 = 'SEWING THREAD'
              THEN
                 ola.ordered_quantity
              WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
              THEN
                 (  100
                  / (100 - ola.cust_model_serial_number)
                  * (ola.ordered_quantity))
           END)
        * (-1))
          ordered_quantity,
       ola.order_quantity_uom,
         ola.ordered_quantity
       * ola.unit_selling_price
       / (CASE
             WHEN cay.segment3 = 'SEWING THREAD'
             THEN
                ola.ordered_quantity
             WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
             THEN
                (  100
                 / (100 - ola.cust_model_serial_number)
                 * (ola.ordered_quantity))
          END)
          unit_list_price,
       ola.unit_selling_price,
       (ola.ordered_quantity2 * (-1)) ordered_quantity2,
       ola.ordered_quantity_uom2,
       (  (CASE
              WHEN cay.segment3 = 'SEWING THREAD'
              THEN
                 ola.shipped_quantity
              WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
              THEN
                 (  100
                  / (100 - ola.cust_model_serial_number)
                  * (ola.shipped_quantity))
           END)
        * (-1))
          shipped_quantity,
       ola.shipped_quantity * (-1) traget_qty,
       ola.shipped_quantity2 * (-1) shipped_quantity2,
       (ola.shipped_quantity * (-1)) * ola.unit_selling_price invoice_amount,
       ctl.revenue_amount,
       ct.exchange_rate,
       ctl.revenue_amount * ct.exchange_rate revenue_amount_bdt,
       ct.trx_number invoice_number,
       NULL challan_number,
       gcck.concatenated_segments code,
       rsv.resource_name,
       rt.segment2 area,
       rt.segment3 zone,
       rt.segment4 division
  FROM oe_order_headers_all oha,
       oe_order_lines_all ola,
       apps.oe_transaction_types_tl ott,
       inv.mtl_system_items_b msi,
       ar_customers ac,
       apps.hz_cust_accounts hca,
       apps.hz_cust_acct_sites_all hcasa,
       apps.hz_party_sites hps,
       apps.hz_cust_site_uses_all hcsua,
       apps.hz_locations hl,
       mtl_item_categories_v cat,
       mtl_item_categories_v cay,
       mtl_item_categories_v col,
       jtf_rs_salesreps sal,
       jtf_rs_defresources_v rsv,
       ra_customer_trx_all ct,
       ra_customer_trx_lines_all ctl,
       ra_cust_trx_line_gl_dist_all ladist,
       gl_code_combinations_kfv gcck,
       xxdbl_company_le_mapping_v clm,
       ra_territories rt
 WHERE     oha.header_id = ola.header_id
       AND oha.org_id = ola.org_id
       AND oha.order_type_id = ott.transaction_type_id
       AND ola.inventory_item_id = msi.inventory_item_id
       AND ola.ship_from_org_id = msi.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.inventory_item_id = cay.inventory_item_id
       AND msi.inventory_item_id = col.inventory_item_id
       AND ac.customer_id = hca.cust_account_id
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND cay.category_set_name = 'Inventory'
       AND col.category_set_name = 'DBL_SALES_PLAN_CAT'
       AND cay.organization_id = 150
       AND cat.organization_id = 150
       AND col.organization_id = 150
       AND oha.salesrep_id = sal.salesrep_id
       AND sal.resource_id = rsv.resource_id
       AND sal.org_id = oha.org_id
       AND hcsua.territory_id = rt.territory_id(+)
       AND hca.status = 'A'
       AND hca.cust_account_id = hcasa.cust_account_id(+)
       AND hcasa.status = 'A'
       AND hcsua.status = 'A'
       AND hcasa.party_site_id = hps.party_site_id
       AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
       AND clm.org_id = hcsua.org_id
       AND hps.location_id = hl.location_id
       AND oha.sold_to_org_id = hca.cust_account_id
       AND oha.ship_to_org_id = hcsua.site_use_id
       AND TO_CHAR (oha.order_number) = TO_CHAR (ct.ct_reference)
       AND ct.customer_trx_id = ctl.customer_trx_id
       AND ola.line_id = ctl.interface_line_attribute6
       AND oha.sold_to_org_id = ct.bill_to_customer_id
       --AND OHA.FLOW_STATUS_CODE = 'BOOKED'
       AND ct.customer_trx_id = ladist.customer_trx_id
       AND ctl.customer_trx_line_id = ladist.customer_trx_line_id
       AND ladist.code_combination_id = gcck.code_combination_id
       AND ola.flow_status_code IN ('CLOSED', 'SHIPPED')
       AND ott.transaction_type_id = 1072
       AND oha.org_id = 125
       AND oha.org_id = :p_org_id
       AND (   :p_product_category IS NULL
            OR cat.category_concat_segs = :p_product_category)
       AND ( :p_product_type IS NULL OR cay.segment3 = :p_product_type)
       AND (   :p_customer_category IS NULL
            OR ac.customer_category_code = :p_customer_category)
       AND ( :p_sales_person IS NULL OR oha.salesrep_id = :p_sales_person)
       AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
       AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
       AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
                                                AND :p_date_to