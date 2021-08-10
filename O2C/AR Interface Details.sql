/* Formatted on 3/24/2021 12:19:03 PM (QP5 v5.287) */
/* Formatted on 3/24/2021 12:20:17 PM (QP5 v5.287) */
SELECT a.request_id,
       a.org_id,
       ou.name,
       a.interface_line_id,
       a.creation_date,
       a.interface_line_context,
       (SELECT hca.account_number || ' - ' || hp.party_name
          FROM apps.hz_cust_accounts hca, apps.hz_parties hp
         WHERE     hca.party_id = hp.party_id
               AND hca.cust_account_id = a.orig_system_bill_customer_id)
          customer_name,
       a.sales_order,
       (SELECT segment1 || '.' || segment2 || '.' || segment3
          FROM inv.mtl_system_items_b
         WHERE     organization_id = a.warehouse_id
               AND inventory_item_id = a.inventory_item_id)
          item_code,
       a.description,
       a.sales_order_date,
       a.sales_order_source,
       a.interface_line_attribute2,
       a.interface_line_attribute1,
       a.interface_line_attribute6,
       a.interface_line_attribute11,
       a.batch_source_name,
       a.set_of_books_id,
       a.line_type,
       a.quantity,
       a.amount,
       a.cust_trx_type_id,
       a.ship_date_actual,
       a.gl_date,
       a.trx_date,
       a.warehouse_id,
       a.inventory_item_id,
       a.term_name
  FROM apps.ra_interface_lines_all a,
       --apps.ra_interface_salescredits_all b,
       --apps.ra_interface_distributions_all c,
       --apps.ra_interface_errors_all d,
       apps.hr_operating_units ou
 WHERE     1 = 1
       AND sales_order = '2011010000120'
       AND A.INTERFACE_LINE_ID = D.INTERFACE_LINE_ID
       --AND A.INTERFACE_STATUS IS NULL
       --AND A.BATCH_SOURCE_NAME = 'SCIL Incentive Upload'
       AND a.org_id = ou.organization_id
       AND a.org_id = :org_id;

  SELECT                                                  --interface_line_id,
         --         batch_source_name,
         --         line_number,
         --         line_type,
         --         cust_trx_type_name,
         --         cust_trx_type_id,
                                                          --         trx_date,
                                                           --         gl_date,
--         currency_code,
                                                           --         term_id,
--         orig_system_bill_customer_id,
--         orig_system_bill_customer_ref,
--         orig_system_bill_address_id,
--         orig_system_bill_address_ref,
--         orig_system_ship_customer_id,
--         orig_system_ship_address_id,
--         orig_system_sold_customer_id,
--         sales_order,
--         inventory_item_id,
                                                          --         uom_code,
                                                          --         quantity,
--         unit_selling_price,
                                                            --         amount,
--         description,
--         conversion_type,
--         conversion_rate,
--         interface_line_context,
--         interface_line_attribute1,
--         interface_line_attribute2,
                                                            --         org_id,
--         set_of_books_id,
--         fob_point,
--         last_update_date,
--         last_updated_by,
--         creation_date,
--         created_by
         ra.*
    FROM ra_interface_lines_all ra
   WHERE 1 = 1 AND sales_order = '2011010000120'
--AND INTERFACE_STATUS!='P'
--AND interface_line_id=1007462
ORDER BY interface_line_id, creation_date DESC;

SELECT *
  FROM ra_interface_distributions_all c;

SELECT *
  --DISTINCT ORG_ID
  FROM ra_interface_salescredits_all
 WHERE 1 = 1;

SELECT DISTINCT org_id
  FROM apps.ra_interface_errors_all;

  SELECT a.request_id,
         a.org_id,
         b.name,
         a.interface_line_id,
         a.creation_date,
         a.batch_source_name,
         a.interface_line_context,
         --apps.xxakg_ar_pkg.get_region_from_cust_id (a.orig_system_bill_customer_id) region,
         (SELECT hca.account_number || ' - ' || hp.party_name
            FROM apps.hz_cust_accounts hca, apps.hz_parties hp
           WHERE     hca.party_id = hp.party_id
                 AND hca.cust_account_id = a.orig_system_bill_customer_id)
            customer_name,
         a.sales_order,
         (SELECT segment1 || '.' || segment2 || '.' || segment3
            FROM inv.mtl_system_items_b
           WHERE     organization_id = a.warehouse_id
                 AND inventory_item_id = a.inventory_item_id)
            item_code,
         a.description,
         a.sales_order_date,
         a.sales_order_source,
         a.interface_line_attribute2,
         a.interface_line_attribute1,
         a.interface_line_attribute6,
         a.interface_line_attribute11,
         a.batch_source_name,
         a.set_of_books_id,
         a.line_type,
         a.quantity,
         a.amount,
         a.cust_trx_type_id,
         a.ship_date_actual,
         a.gl_date,
         a.trx_date,
         a.warehouse_id,
         a.inventory_item_id,
         a.term_name,
         a.*
    FROM apps.ra_interface_lines_all a, apps.hr_operating_units b
   WHERE 1 = 1 AND a.org_id = b.organization_id AND org_id = :org_id      --85
--and apps.xxakg_ar_pkg.get_customer_number_from_id (a.orig_system_bill_customer_id)= :p_customer_number
--and interface_status is null
--and batch_source_name ='ORDER_ENTRY'
ORDER BY b.name, a.creation_date;