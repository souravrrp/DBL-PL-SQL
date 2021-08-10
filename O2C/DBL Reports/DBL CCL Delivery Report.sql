/* Formatted on 10/1/2020 9:19:50 AM (QP5 v5.287) */
SELECT (CASE
           WHEN ac.customer_type = 'R' THEN 'External'
           WHEN ac.customer_type = 'I' THEN 'Internal'
           WHEN ac.customer_type = '' THEN 'N/A'
        END)
          c_type,
       cay.segment3 product_type,
       ROUND (
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
             END),
          2)
          unit_list_price,
       ROUND (ola.unit_selling_price, 2) unit_selling_price,
       ROUND (
          (CASE
              WHEN cay.segment3 = 'SEWING THREAD'
              THEN
                 ola.shipped_quantity
              WHEN cay.segment3 IN ('DYED FIBER', 'DYED YARN')
              THEN
                 (  100
                  / (100 - ola.cust_model_serial_number)
                  * (ola.shipped_quantity))
           END),
          2)
          shipped_quantity,
       ROUND (ola.shipped_quantity, 2) AS traget_qty,
       ROUND (ola.shipped_quantity2, 2) shipped_quantity2,
       ROUND ( (ola.shipped_quantity * ola.unit_selling_price), 2)
          AS invoice_amount,
       NULL AS RETURN_QTY,
       rsv.resource_name,
       SAL.RESOURCE_ID,
       RT.TERRITORY_ID
  FROM oe_order_headers_all oha,                                            --
       oe_order_lines_all ola,                                              --
       apps.oe_transaction_types_tl ott,
       inv.mtl_system_items_b msi,
       ar_customers ac,                                                     --
       apps.hz_cust_accounts hca,                                           --
       apps.hz_cust_acct_sites_all hcasa,                                   --
       apps.hz_party_sites hps,
       apps.hz_cust_site_uses_all hcsua,                                    --
       apps.hz_locations hl,
       mtl_item_categories_v cat,                                           --
       mtl_item_categories_v cay,                                           --
       mtl_item_categories_v col,                                           --
       xxdbl.xxdbl_omshipping_line_v olv,                                   --
       jtf_rs_salesreps sal,                                                --
       jtf_rs_defresources_v rsv,                                           --
       ra_customer_trx_all ct,
       ra_customer_trx_lines_all ctl,
       ra_cust_trx_line_gl_dist_all ladist,
       gl_code_combinations_kfv gcck,
       xxdbl_company_le_mapping_v clm,
       ra_territories rt                                                    --
 WHERE     oha.header_id = ola.header_id
       AND oha.org_id = ola.org_id
       AND oha.order_type_id = ott.transaction_type_id
       AND ola.inventory_item_id = msi.inventory_item_id
       AND ola.ship_from_org_id = msi.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.inventory_item_id = cay.inventory_item_id
       AND msi.inventory_item_id = col.inventory_item_id
       AND ac.customer_id = hca.cust_account_id
       AND oha.salesrep_id = sal.salesrep_id
       AND sal.resource_id = rsv.resource_id
       AND sal.org_id = oha.org_id
       AND hcsua.territory_id = rt.territory_id(+)
       AND hca.cust_account_id = hcasa.cust_account_id(+)
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
       AND cat.category_set_name = 'DBL_SALES_CAT_SET'
       AND cay.category_set_name = 'Inventory'
       AND col.category_set_name = 'DBL_SALES_PLAN_CAT'
       AND cay.organization_id = 150
       AND cat.organization_id = 150
       AND col.organization_id = 150
       AND hca.status = 'A'
       AND hcasa.status = 'A'
       AND hcsua.status = 'A'
       AND ola.flow_status_code IN ('CLOSED', 'SHIPPED')
       AND olv.omshipping_line_status NOT IN ('CANCELLED', 'NEW')
       AND olv.primary_onhand_quantity > 0
       AND oha.org_id = 125
       AND ola.line_category_code != 'RETURN'
       AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
                                                AND :p_date_to