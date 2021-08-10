/* Formatted on 6/25/2020 5:22:40 PM (QP5 v5.287) */
SELECT OOD.OPERATING_UNIT,
       OOD.ORGANIZATION_ID,
       OU.SET_OF_BOOKS_ID,
       OU.DEFAULT_LEGAL_CONTEXT_ID
  --           INTO L_OPERATING_UNIT,
  --                L_ORGANIZATION_ID,
  --                L_SET_OF_BOOKS,
  --                L_LEGAL_ENTITY_ID
  FROM ORG_ORGANIZATION_DEFINITIONS OOD, HR_OPERATING_UNITS OU
 WHERE     1 = 1
       AND OOD.OPERATING_UNIT = OU.ORGANIZATION_ID
       AND OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE;

SELECT HCA.CUST_ACCOUNT_ID, HCAS.CUST_ACCT_SITE_ID
  FROM HZ_PARTIES HP,
       HZ_PARTY_SITES HPS,
       HZ_CUST_ACCOUNTS HCA,
       HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_SITE_USES_ALL HCSU
 WHERE     HCA.PARTY_ID = HP.PARTY_ID
       AND HP.PARTY_ID = HPS.PARTY_ID
       AND HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
       AND HCAS.CUST_ACCT_SITE_ID = HCSU.CUST_ACCT_SITE_ID
       AND HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
       AND HCSU.SITE_USE_CODE = 'BILL_TO'
       AND HCSU.PRIMARY_FLAG = 'Y'
       AND HCA.ACCOUNT_NUMBER = :P_CUSTOMER_NUMBER
       AND HCAS.ORG_ID = :L_OPERATING_UNIT;


SELECT HCAS.CUST_ACCT_SITE_ID,
       TER.TERRITORY_ID,
       TER.SEGMENT1,
       TER.SEGMENT2,
       TER.SEGMENT3,
       TER.SEGMENT4
  --              INTO L_SHIP_TO_SITE_ID,
  --                   L_TERRITORY_ID,
  --                   L_T_SEGMENT1,
  --                   L_T_SEGMENT2,
  --                   L_T_SEGMENT3,
  --                   L_T_SEGMENT4
  FROM HZ_PARTIES HP,
       HZ_PARTY_SITES HPS,
       HZ_CUST_ACCOUNTS HCA,
       HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_SITE_USES_ALL HCSU,
       ra_territories ter
 WHERE     HP.PARTY_ID = HPS.PARTY_ID
       AND HCA.PARTY_ID = HP.PARTY_ID
       AND HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
       AND HCAS.CUST_ACCT_SITE_ID = HCSU.CUST_ACCT_SITE_ID
       AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
       AND HCSU.TERRITORY_ID = TER.TERRITORY_ID(+)
       AND HCSU.SITE_USE_CODE = 'SHIP_TO'
       AND HCSU.PRIMARY_FLAG = 'Y'
       AND HCA.ACCOUNT_NUMBER = :P_CUSTOMER_NUMBER
       AND HCAS.ORG_ID = :L_OPERATING_UNIT;

SELECT OOH.HEADER_ID,
       OOH.TRANSACTIONAL_CURR_CODE,
       INITCAP (OOH.FREIGHT_TERMS_CODE),
       OOH.FREIGHT_CARRIER_CODE,
       OOH.SALESREP_ID,
       OOL.LINE_ID,
       OOL.INVENTORY_ITEM_ID,
       OOL.UNIT_SELLING_PRICE,
       OOL.ORDERED_QUANTITY,
       OOH.ORDERED_DATE,
       OOL.LINE_NUMBER,
       OOL.UNIT_LIST_PRICE,
       OOL.ACTUAL_SHIPMENT_DATE
  --              INTO L_HEADER_ID,
  --                   L_TRANSACTIONAL_CURR_CODE,
  --                   L_FREIGHT_TERMS_CODE,
  --                   L_FREIGHT_CARRIER_CODE,
  --                   L_SALESREP_ID,
  --                   L_LINE_ID,
  --                   L_INVENTORY_ITEM_ID,
  --                   L_UNIT_SELLING_PRICE,
  --                   L_ORDERED_QUANTITY,
  --                   L_ORDERED_DATE,
  --                   L_LINE_NUMBER,
  --                   L_UNIT_LIST_PRICE,
  --                   L_ACTUAL_SHIP_DATE
  FROM OE_ORDER_HEADERS_ALL OOH, OE_ORDER_LINES_ALL OOL
 WHERE     1 = 1
       AND OOH.HEADER_ID = OOL.HEADER_ID
       AND ORDER_NUMBER = :P_SALES_ORDER
       AND LINE_NUMBER = :LINE_NUMBER;


SELECT (  NVL ( :P_QUANTITY, :L_ORDERED_QUANTITY)
        * NVL ( :P_UNIT_SELLING_PRICE, :L_UNIT_SELLING_PRICE))
  --INTO L_AMOUNT
  FROM DUAL;
  
SELECT (  :P_QUANTITY
        * :P_UNIT_SELLING_PRICE)
  --INTO L_AMOUNT
  FROM DUAL;


SELECT CUST_TRX_TYPE_ID
  --INTO L_CUST_TRX_TYPE_ID
  FROM RA_CUST_TRX_TYPES_ALL CTT
 WHERE CTT.NAME = :P_CUST_TRX_TYPE;

SELECT MSI.INVENTORY_ITEM_ID, MSI.PRIMARY_UOM_CODE
  --INTO L_INVENTORY_ITEM_ID, L_UOM_CODE
  FROM APPS.MTL_SYSTEM_ITEMS_B MSI
 WHERE     SEGMENT1 = :P_ITEM_CODE
       AND ORGANIZATION_ID = :L_ORGANIZATION_ID
       AND ENABLED_FLAG = 'Y';
       
       
       SELECT batch_source_id,org_id,arb.*
           --INTO v_batch_source_id
           FROM ra_batch_sources_all arb
          WHERE     UPPER (NAME) = UPPER ('DBL Export Sales')
                AND org_id = :p_org_id;

SELECT   pha.segment1, pla.unit_price
    FROM po_headers_all pha, apps.po_lines_all pla, po_vendors pv, xxdbl_company_le_mapping_v cl
   WHERE pha.type_lookup_code IN ('BLANKET', 'STANDARD')
     AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
     AND pha.approved_flag = 'Y'
     AND NVL (pha.cancel_flag, 'N') = 'N'
     AND pha.vendor_id = pv.vendor_id(+)
     AND cl.org_id = pha.org_id
     and pla.po_header_id=pha.po_header_id
     AND pha.segment1 = :P_PO_NUMBER
     and exists(select 1 from apps.mtl_system_items_vl msi where msi.inventory_item_id=pla.item_id and msi.segment1 =:P_ITEM_CODE )
     --and =:P_ITEM_CODE     --YRN20S100CVC54699919
     AND UPPER (cl.legal_entity_name) LIKE RTRIM (UPPER (:xx_ar_bills_headers_all), '.') || '%'
     AND EXISTS (SELECT 1
                   FROM xx_dbl_po_recv_adjust x
                  WHERE x.po_no = pha.segment1);

    SELECT DISTINCT SL_NO,
                         BATCH_SOURCE_ID,
                         CUST_TRX_TYPE_ID,
                         OPERATING_UNIT,
                         --bh.bill_header_id invoice_id,
                         --bh.bill_number,
                         TRX_DATE,
                         GL_DATE,
                         CURRENCY_CODE,
                         EXCHANCE_RATE,
                         'Bill Invoice' ATTRIBUTE_CATEGORY,
                         --bh.bill_header_id attribute6,
                         --bh.bill_header_id attribute10,
                         'Sales of Yarn' COMMENTS,
                         CUSTOMER_ID,
                         TERM_ID,
                         BILL_CATEGORY
           FROM APPS.XXDBL_AR_INVOICE_STG
          WHERE FLAG IS NULL;
    
    SELECT
    STG.*
    FROM apps.xxdbl_ar_invoice_stg STG
   WHERE 1 = 1
   AND operating_unit=131
   AND FLAG IS NULL
   --order by creation_date desc
   ;
   
   /*
   update
   apps.xxdbl_ar_invoice_stg STG
   SET FLAG=NULL
   WHERE 1=1
   AND operating_unit=131
   --AND FLAG IS NULL
   ;
   */
   
   
   DELETE FROM apps.xxdbl_ar_invoice_stg WHERE FLAG IS NULL;
   

EXECUTE apps.xxdbl_ar_invoice_upld_adi_pkg.import_data_to_ar_cust_trx;--('','');


EXECUTE apps.xxdbl_ar_invoice_upld_adi_pkg.ar_cust_trx_stg_upload (2,1,'13-JUL-2020','BDT','2024','','YRN26S100CVC53820218',3,2,'Yarn Export','13-JUL-2020','10233000298','',85);

show errors procedure apps.xxdbl_ar_invoice_upld_adi_pkg.ar_cust_trx_stg_upload ;
