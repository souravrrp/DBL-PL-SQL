/* Formatted on 2/10/2020 12:32:18 PM (QP5 v5.287) */
  SELECT ac.customer_number,
         ac.customer_name,
         CASE
            WHEN ac.customer_type = 'R' THEN 'External'
            WHEN ac.customer_type = 'I' THEN 'Internal'
         END
            customer_type,
         oha.order_number,
         ott.name order_type,
         TRUNC (oha.ordered_date) ordered_date,
         oha.sales_channel_code buyer,
         oha.cust_po_number,
         --cat.segment2 item_color,
         --cat.category_concat_segs product_category,
         cay.segment3 product_type,
         SUM (ola.ordered_quantity) ordered_quantity,
         SUM (ola.ordered_quantity * ola.unit_selling_price) order_amt,
         SUM (ola.shipped_quantity) shipped_quantity,
         SUM (ola.shipped_quantity * ola.unit_selling_price) delivery_amt,
         oha.attribute4 merchandiser,
         rsv.resource_name sales_person,
         rt.segment2 area,
         --RT.SEGMENT3 Zone,
         --RT.SEGMENT4 Division
         bsh.bill_stat_number,
         bsh.bill_stat_date
    -- pih.proforma_number,
    -- pih.proforma_date
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
         jtf_rs_salesreps sal,
         jtf_rs_defresources_v rsv,
         ra_territories rt,
         xxdbl_bill_stat_lines bsl,
         xxdbl_bill_stat_headers bsh
   -- xxdbl_proforma_headers pih,
   -- xxdbl_proforma_lines pil
   WHERE     oha.header_id = ola.header_id
         AND oha.org_id = ola.org_id
         AND oha.order_type_id = ott.transaction_type_id
         AND ola.inventory_item_id = msi.inventory_item_id
         AND ola.ship_from_org_id = msi.organization_id
         AND msi.inventory_item_id = cat.inventory_item_id
         AND msi.inventory_item_id = cay.inventory_item_id
         AND ac.customer_id = hca.cust_account_id
         AND cat.category_set_name = 'DBL_SALES_CAT_SET'
         AND cay.category_set_name = 'Inventory'
         AND cay.organization_id = 150
         AND cat.organization_id = 150
         AND oha.salesrep_id = sal.salesrep_id
         AND sal.resource_id = rsv.resource_id
         AND sal.org_id = oha.org_id
         AND hca.status = 'A'
         AND hca.cust_account_id = hcasa.cust_account_id(+)
         AND hcasa.status = 'A'
         AND hcsua.status = 'A'
         AND hcasa.party_site_id = hps.party_site_id
         AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
         AND hps.location_id = hl.location_id
         AND oha.sold_to_org_id = hca.cust_account_id
         AND oha.ship_to_org_id = hcsua.site_use_id
         AND hcsua.territory_id = rt.territory_id(+)
         AND ola.flow_status_code NOT IN ('CANCELLED', 'ENTERED')
         AND oha.org_id = 125
         AND bsl.bill_stat_header_id = bsh.bill_stat_header_id(+)
         -- AND pih.proforma_header_id = pil.proforma_header_id
         -- AND bsh.bill_stat_header_id = pil.bill_stat_header_id
         -- AND bsl.bill_stat_header_id = pil.bill_stat_header_id
         -- AND bsh.bill_stat_number = pil.bill_stat_number
         AND ola.line_id = bsl.order_line_id(+)
         -- AND bsh.bill_stat_status NOT IN ('CANCELLED','NEW')
         -- AND pih.proforma_status NOT IN ('CANCELLED','NEW')
         AND oha.order_number = 1552060000086
-- AND oha.org_id = :p_org_id
-- AND (:p_product_category IS NULL
-- OR cat.category_concat_segs = :p_product_category)
-- AND (:p_product_type IS NULL OR cay.segment3 = :p_product_type)
-- AND (:p_customer_category IS NULL
-- OR ac.customer_category_code = :p_customer_category)
-- AND (:p_sales_person IS NULL OR oha.salesrep_id = :p_sales_person)
-- AND (:p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
-- AND (:p_order_number IS NULL OR oha.order_number = :p_order_number)
-- AND TRUNC (oha.ordered_date) BETWEEN :p_date_from AND :p_date_to
GROUP BY ac.customer_number,
         ac.customer_name,
         ac.customer_type,
         oha.order_number,
         ott.name,
         TRUNC (oha.ordered_date),
         oha.sales_channel_code,
         oha.cust_po_number,
         cay.segment3,
         oha.attribute4,
         rsv.resource_name,
         rt.segment2,
         bsh.bill_stat_number,
         bsh.bill_stat_date
-- pih.proforma_number,
-- pih.proforma_date