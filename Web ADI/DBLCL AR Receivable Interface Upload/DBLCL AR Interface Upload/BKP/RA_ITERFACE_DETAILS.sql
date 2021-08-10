/* Formatted on 6/24/2020 12:16:41 PM (QP5 v5.287) */
SELECT A.REQUEST_ID,
       A.ORG_ID,
       OU.NAME,
       A.INTERFACE_LINE_ID,
       A.CREATION_DATE,
       A.INTERFACE_LINE_CONTEXT,
       (SELECT HCA.ACCOUNT_NUMBER || ' - ' || HP.PARTY_NAME
          FROM APPS.HZ_CUST_ACCOUNTS HCA, APPS.HZ_PARTIES HP
         WHERE     HCA.PARTY_ID = HP.PARTY_ID
               AND HCA.CUST_ACCOUNT_ID = A.ORIG_SYSTEM_BILL_CUSTOMER_ID)
          CUSTOMER_NAME,
       A.SALES_ORDER,
       (SELECT SEGMENT1 || '.' || SEGMENT2 || '.' || SEGMENT3
          FROM INV.MTL_SYSTEM_ITEMS_B
         WHERE     ORGANIZATION_ID = A.WAREHOUSE_ID
               AND INVENTORY_ITEM_ID = A.INVENTORY_ITEM_ID)
          ITEM_CODE,
       A.DESCRIPTION,
       A.SALES_ORDER_DATE,
       A.SALES_ORDER_SOURCE,
       A.INTERFACE_LINE_ATTRIBUTE2,
       A.INTERFACE_LINE_ATTRIBUTE1,
       A.INTERFACE_LINE_ATTRIBUTE6,
       A.INTERFACE_LINE_ATTRIBUTE11,
       A.BATCH_SOURCE_NAME,
       A.SET_OF_BOOKS_ID,
       A.LINE_TYPE,
       A.QUANTITY,
       A.AMOUNT,
       A.CUST_TRX_TYPE_ID,
       A.SHIP_DATE_ACTUAL,
       A.GL_DATE,
       A.TRX_DATE,
       A.WAREHOUSE_ID,
       A.INVENTORY_ITEM_ID,
       A.TERM_NAME
  FROM APPS.RA_INTERFACE_LINES_ALL A   
  --APPS.RA_INTERFACE_SALESCREDITS_ALL B,
  --APPS.RA_INTERFACE_DISTRIBUTIONS_ALL C,
  --,APPS.RA_INTERFACE_ERRORS_ALL D
       , APPS.HR_OPERATING_UNITS OU
 WHERE 1 = 1 
 and sales_order='2011010000120'
 --AND A.INTERFACE_LINE_ID = D.INTERFACE_LINE_ID
             --AND A.INTERFACE_STATUS IS NULL
             --AND A.BATCH_SOURCE_NAME = 'SCIL Incentive Upload'
       AND A.ORG_ID = OU.ORGANIZATION_ID AND A.ORG_ID = :ORG_ID;

  SELECT 
  --interface_line_id,
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
    FROM RA_INTERFACE_LINES_ALL ra
   WHERE 1 = 1
   and sales_order='2011010000120'
   --AND INTERFACE_STATUS!='P'
--AND interface_line_id=1007462
ORDER BY interface_line_id,CREATION_DATE DESC;

SELECT *
  FROM RA_INTERFACE_DISTRIBUTIONS_ALL C;

SELECT *
  --DISTINCT ORG_ID
  FROM RA_INTERFACE_SALESCREDITS_ALL
 WHERE 1 = 1;

SELECT DISTINCT ORG_ID
  FROM APPS.RA_INTERFACE_ERRORS_ALL;

  SELECT a.request_id,
         a.org_id,
         b.name,
         a.interface_line_id,
         a.creation_date,
         A.batch_source_name,
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
         A.*
    FROM apps.ra_interface_lines_all a, apps.hr_operating_units b
   WHERE 1 = 1 AND a.org_id = b.organization_id AND org_id = :org_id      --85
--and apps.xxakg_ar_pkg.get_customer_number_from_id (a.orig_system_bill_customer_id)= :p_customer_number
--and interface_status is null
--and batch_source_name ='ORDER_ENTRY'
ORDER BY b.name, a.creation_date;