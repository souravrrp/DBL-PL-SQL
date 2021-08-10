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


SELECT CUST_TRX_TYPE_ID, CTT.*
  --INTO L_CUST_TRX_TYPE_ID
  FROM RA_CUST_TRX_TYPES_ALL CTT
 WHERE CTT.NAME = :P_CUST_TRX_TYPE;

SELECT MSI.INVENTORY_ITEM_ID, MSI.PRIMARY_UOM_CODE
  --INTO L_INVENTORY_ITEM_ID, L_UOM_CODE
  FROM APPS.MTL_SYSTEM_ITEMS_B MSI
 WHERE     SEGMENT1 = :P_ITEM_CODE
       AND ORGANIZATION_ID = :L_ORGANIZATION_ID
       AND ENABLED_FLAG = 'Y';
       
       SELECT *
--MAX(CUSTOMER_TRX_ID)
FROM
APPS.RA_CUSTOMER_TRX_ALL
WHERE 1=1
AND ORG_ID=131-- IN (131,126)
--AND TRUNC(TRX_DATE)='25-SEP-19'
order by 
--creation_date 
--,
LAST_UPDATE_DATE
--,TRX_NUMBER
DESC
;

select
*
from
ra_interface_distributions_all
order by last_update_date desc;

SELECT
ra.*
    FROM RA_INTERFACE_LINES_ALL ra
   WHERE 1 = 1
   AND nvl(INTERFACE_STATUS, '~') != 'P'
   AND ORG_ID  
   --IN (131,126)
   =131
   --AND INTERFACE_LINE_ID=1320699
   --AND SALES_ORDER_SOURCE='ORDER ENTRY'
   order by creation_date desc;
   
  UPDATE RA_INTERFACE_LINES_ALL
Set 
--TERM_ID = 5,
--TERM_NAME='IMMEDIATE'
AMOUNT='6997.73'
Where nvl(INTERFACE_STATUS, '~') != 'P'
AND INTERFACE_LINE_ID=1324655
AND ORG_ID=131;

--  DELETE RA_INTERFACE_LINES_ALL
--Where nvl(INTERFACE_STATUS, '~') != 'P'
--AND ORG_ID=131;

select 
*
--TERM_ID
from
RA_INTERFACE_LINES_ALL
Where 1=1
AND nvl(INTERFACE_STATUS, '~') != 'P'
AND ORG_ID=131;
   
--   DELETE FROM xxdbl_ra_interface_upload_stg;


--TRUNCATE TABLE xxdbl.xxdbl_ra_interface_upload_stg;
--
--DELETE xxdbl.xxdbl_ra_interface_upload_stg where TRUNC(CREATION_DATE) = TRUNC(SYSDATE);
--COMMIT;
   
   SELECT
   *
   FROM
   xxdbl.xxdbl_ra_interface_upload_stg
   WHERE 1=1
   --AND ORGANIZATION_CODE='101'
   --AND FLAG IS NULL
   AND TO_CHAR(TRX_DATE,'DD-MON-RR') = '30-AUG-20'
   --AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
   ;
   
--   update xxdbl_ra_interface_upload_stg set flag=null
--   WHERE 1=1
--   AND FLAG='Y';
   

EXECUTE apps.xxdbl_ar_interface_upload_pkg.import_data_to_ar_interface(' ',' ');


EXECUTE APPS.xxdbl_ar_interface_upload_pkg.upload_data_to_ar_int_stg (1,'251','DBLCL - Sales','Invoice','Tiles Local INV',1,'22-JUL-20','22-JUL-20','USD','82','2597','NP6060-012GN',10,9);

EXECUTE APPS.xxdbl_ar_interface_upload_pkg.upload_data_to_ar_int_stg (1,'251','DBL CL Imported Invoice','Invoice','Tiles Local INV',1,'22-JUL-20','22-JUL-20','USD','82','2597','FINI.FIPD.00001',10,9,'','');

EXECUTE APPS.xxdbl_ar_interface_upload_pkg.upload_data_to_ar_int_stg (1,'101','DBL Export Sales','Invoice','Yarn Export',2,'15-AUG-20','15-AUG-20','USD','82','2024','YRN26S100CVC53820218',10,9,'10233000298',''); --Yarn Sales INV

EXECUTE APPS.xxdbl_ar_interface_upload_pkg.upload_data_to_ar_int_stg ('Yarn Export',15,'17-AUG-20','17-AUG-20','USD','82','2026','YRN24S100CTN52199915',3000,3,'10323010469','');