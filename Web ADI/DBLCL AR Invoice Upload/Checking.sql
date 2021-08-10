/* Formatted on 6/25/2020 5:22:40 PM (QP5 v5.287) */
SELECT
    STG.*
    FROM xxdbl.xxdbl_cer_ar_inv_upld_stg STG
   WHERE 1 = 1
   AND operating_unit=126
   --AND FLAG IS NULL
   order by creation_date desc
   ;


SELECT *
--MAX(CUSTOMER_TRX_ID)
FROM
APPS.RA_CUSTOMER_TRX_ALL
order by 
creation_date 
--,
--LAST_UPDATE_DATE
desc
;

SELECT
*
FROM
RA_CUSTOMER_TRX_LINES_ALL
order by 
creation_date 
--,
--LAST_UPDATE_DATE
desc;


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


SELECT CTT.NAME,CUST_TRX_TYPE_ID
  --INTO L_CUST_TRX_TYPE_ID
  FROM RA_CUST_TRX_TYPES_ALL CTT
 WHERE      (:P_CUST_TRX_TYPE IS NULL OR (UPPER(NAME) LIKE UPPER('%'||:P_CUST_TRX_TYPE||'%') ))
 --AND CUST_TRX_TYPE_ID=1009
 --and CTT.NAME = :P_CUST_TRX_TYPE
 ;

SELECT MSI.INVENTORY_ITEM_ID, MSI.PRIMARY_UOM_CODE
  --INTO L_INVENTORY_ITEM_ID, L_UOM_CODE
  FROM APPS.MTL_SYSTEM_ITEMS_B MSI
 WHERE     SEGMENT1 = :P_ITEM_CODE
       AND ORGANIZATION_ID = :L_ORGANIZATION_ID
       AND ENABLED_FLAG = 'Y';
       
       
       SELECT batch_source_id,org_id
           --INTO v_batch_source_id
           FROM ra_batch_sources_all
          WHERE     UPPER (NAME) = UPPER ('DBLCL - Manual')
                AND org_id = :p_org_id;

SELECT DISTINCT SL_NO,
                BATCH_SOURCE_ID,
                CUST_TRX_TYPE_ID,
                CUSTOMER_ID,
                CURRENCY_CODE,
                TRX_DATE,
                GL_DATE
  FROM apps.xxdbl_cer_ar_inv_upld_stg
 WHERE FLAG IS NULL AND OPERATING_UNIT = 126;

    
   
   update
   xxdbl_cer_ar_inv_upld_stg STG
   SET FLAG='Y',SL_NO=2
   WHERE 1=1
   AND operating_unit=126
   AND SL_NO=1
   AND BATCH_SOURCE_ID=4037
   --AND FLAG IS NULL
   ;
   
   
   DELETE FROM xxdbl_cer_ar_inv_upld_stg WHERE FLAG IS NULL;
   

EXECUTE apps.ar_cust_trx_upld_adi_pkg.import_data_to_ar_cust_trx;--('','');

EXECUTE APPS.xxdbl_cer_ar_inv_upld_pkg.ar_cust_trx_stg_upload (1,'251','DBLCL - Sales','Invoice','Tiles Local INV',1,'25-SEP-19','25-SEP-19','BDT','2597','NP6060-012GN',10,9,'Testing Phase');

EXECUTE APPS.ar_cust_trx_upld_adi_pkg.ar_cust_trx_stg_upload (1,'101','MSML - Manual','Invoice','Yarn Sales INV',1,'31-MAY-2020','31-MAY-2020','BDT','2013','YRN30S100CTN521G0415',3,2,'Testing Phase');

show errors procedure apps.ar_cust_trx_upld_adi_pkg.import_data_to_ar_cust_trx ;

execute apps.xxdbl_cer_ar_inv_upld_pkg.import_data_to_ar_invoice;

select apps.ar_cust_trx_upld_adi_pkg.check_error_log_to_import_data from dual;