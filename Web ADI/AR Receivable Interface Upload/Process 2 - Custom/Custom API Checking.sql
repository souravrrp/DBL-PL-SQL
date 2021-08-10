/* Formatted on 6/23/2020 1:37:59 PM (QP5 v5.287) */
--SINGLE INSERT Script FOR Oracle AR Invoice CREATION WITH INTERFACE Approach
-->> ----------------------------------------------------------------------------------
--> Base Tables:

SELECT *
  FROM RA_CUSTOMER_TRX_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

SELECT *
  FROM RA_CUSTOMER_TRX_LINES_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

SELECT *
  FROM RA_CUST_TRX_LINE_GL_DIST_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

--> Interface Tables:

SELECT *
  FROM RA_INTERFACE_LINES_ALL
 --WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

--DELETE RA_INTERFACE_LINES_ALL where TRUNC(CREATION_DATE) = TRUNC(SYSDATE);
--COMMIT;

SELECT *
  FROM RA_INTERFACE_DISTRIBUTIONS_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);
 
 
 SELECT
 *
 FROM
 RA_INTERFACE_SALESCREDITS_ALL

--DELETE RA_INTERFACE_DISTRIBUTIONS_ALL where TRUNC(CREATION_DATE) = TRUNC(SYSDATE);
--COMMIT;
--> Error Table:

  SELECT *
    FROM RA_INTERFACE_ERRORS_ALL
ORDER BY INTERFACE_LINE_ID DESC;

SELECT cust_trx_type_id--, ctt.*
--                 INTO ln_cust_trx_type_id
                 FROM ra_cust_trx_types_all ctt
                WHERE 1=1
                AND NAME='For Dealer'


BEGIN
               SELECT cust_trx_type_id
                 INTO ln_cust_trx_type_id
                 FROM ra_cust_trx_types ctt
                WHERE ctt.name = ln_cur_line.trx_type;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  ln_line_error_flag := 'I';
                  ln_trx_error_flag := 'I';
                  FND_FILE.put_line (
                     FND_FILE.LOG,
                     'This trx type doesnot exist' || ln_cur_line.trx_type);
               WHEN OTHERS
               THEN
                  FND_FILE.put_line (FND_FILE.LOG, SQLERRM);
            END;


-->> ----------------------------------------------------------------------------------
--> Validation Queries

SELECT ORGANIZATION_ID, hou.*
  FROM hr_operating_units hou
 WHERE 1=1 
 AND name = 'MSML';
 
 SELECT hou.ORGANIZATION_ID, hou.NAME,hou.*
--  INTO l_organization_id, l_operating_unit
  FROM hr_organization_units hou
 WHERE hou.NAME = :p_organization_name;
 
 SELECT
 OOD.OPERATING_UNIT,OU.NAME, OOD.ORGANIZATION_CODE , OOD.ORGANIZATION_ID, OU.SET_OF_BOOKS_ID,OU.DEFAULT_LEGAL_CONTEXT_ID
 --INTO L_OPERATING_UNIT,L_OU_NAME, L_ORGANIZATION_CODE,L_ORGANIZATION_ID,L_SET_OF_BOOKS,L_LEGAL_ENTITY_ID
 --,ou.*
 FROM
 ORG_ORGANIZATION_DEFINITIONS OOD,
 hr_operating_units ou
 WHERE 1=1
 AND OOD.OPERATING_UNIT=OU.ORGANIZATION_ID
 --AND OPERATING_UNIT=131
 --AND OU.NAME=:OU_NAME  --'MSML'
 AND OOD.ORGANIZATION_CODE=:P_ORGANIZATION_CODE --'101'
 ;
 
 SELECT set_of_books_id, chart_of_accounts_id
--           INTO ln_set_of_books_id, ln_chart_of_act_id
           FROM gl_sets_of_books
          WHERE set_of_books_id = 2095;

SELECT *
  FROM RA_BATCH_SOURCES_ALL
 WHERE 1=1
 AND NAME = 'DBL Export Sales' 
 AND ORG_ID = 131;

SELECT *
  FROM all_objects
 WHERE object_type = 'TABLE' AND object_name LIKE '%REVENUE_ASSIGNMENTS%';

SELECT *
  FROM ra_cust_trx_types_all
 WHERE 1=1
 AND NAME = 'Invoice' 
 AND ORG_ID = 131;

SELECT *
  FROM AR_LOOKUPS
 WHERE MEANING = 'Line' AND LOOKUP_TYPE = 'AR_LINE_INVOICE';

SELECT CURRENCY_CODE
  FROM fnd_currencies
 WHERE CURRENCY_CODE = 'USD';

SELECT TERM_ID
  FROM ra_terms_tl
 WHERE NAME = '30 NET';

SELECT UOM_CODE
  FROM MTL_UNITS_OF_MEASURE_TL
 WHERE UNIT_OF_MEASURE = 'Piece';

SELECT  
HCSU.site_use_code,
       HCSU.LOCATION,
       HCAS.cust_acct_site_id,
       HCA.cust_account_id,
       HP.PARTY_NUMBER,
       hp.PARTY_ID,
       ter.territory_id,
       ter.SEGMENT1,
       ter.SEGMENT2,
       ter.SEGMENT3,
       ter.SEGMENT4
  FROM hz_parties HP,
       hz_party_sites HPS,
       hz_cust_accounts HCA,
       hz_cust_acct_sites_all HCAS,
       hz_cust_site_uses_all HCSU,
       ra_territories          ter
 WHERE     HP.party_id = HPS.party_id
       AND HCA.party_id = HP.party_id
       AND HCA.cust_account_id = HCAS.cust_account_id
       AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
       AND hps.PARTY_SITE_ID = hcas.PARTY_SITE_ID
       AND HCSU.territory_id      =  ter.territory_id(+)
       AND HCSU.site_use_code = 'SHIP_TO'
       AND HCA.ACCOUNT_NUMBER='2597'
       --AND HP.PARTY_ID = 6153
       AND HCAs.org_id = 126
       --AND LOCATION = 'PROVO (OPS)'
       ;
       
       --union ALL
        
       
SELECT HCSU.site_use_code,
       HCSU.LOCATION,
       HCAS.cust_acct_site_id,
       HCA.cust_account_id,
       HP.PARTY_NUMBER,
       hp.PARTY_ID
       ,HCSU.PAYMENT_TERM_ID
--       ter.SEGMENT1,
--       ter.SEGMENT2,
--       ter.SEGMENT3,
--       ter.SEGMENT4
       --,HCSU.*
       --,HCAS.*
       --,HPS.*
       --,HCA.*
  FROM hz_parties HP,
       hz_party_sites HPS,
       hz_cust_accounts HCA,
       hz_cust_acct_sites_all HCAS,
       hz_cust_site_uses_all HCSU
       --,ra_territories          ter
 WHERE     HCA.party_id = HP.party_id
       AND HP.party_id = HPS.party_id
       AND HCA.cust_account_id = HCAS.cust_account_id
       AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
       AND HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
       --AND HCSU.territory_id      =  ter.territory_id(+)
       AND HCSU.site_use_code = 'BILL_TO'
       AND HCSU.primary_flag = 'Y'
       --AND UPPER (LTRIM (RTRIM (HP.party_name))) =UPPER (LTRIM (RTRIM ('FAKIR APPARELS LTD.')))
       AND HCA.ACCOUNT_NUMBER='2597'
       AND HCAs.org_id = 126;
       
       
SELECT
*
FROM
AR_CUSTOMERS
WHERE CUSTOMER_NUMBER='2597'

SELECT INVENTORY_ITEM_ID,segment1
  FROM mtl_system_items_b
 WHERE 1=1 
 --AND segment1 LIKE 'YRN%'
 AND segment1='YRN06S100CTN52120313'
 AND ORGANIZATION_ID = 193;

SELECT conversion_type
  FROM gl_daily_conversion_types
 WHERE conversion_type = 'User';

SELECT LOOKUP_CODE,MEANING
  FROM fnd_lookup_values
 WHERE     lookup_type = 'FOB'
       AND MEANING = 'Shipping Point'
       AND VIEW_APPLICATION_ID = 222;

SELECT CODE_COMBINATION_ID
  FROM GL_CODE_COMBINATIONS_KFV
 WHERE CONCATENATED_SEGMENTS = '251.999.999.99999.122109.101.999.999.999';
 
-- SELECT CONCATENATED_SEGMENTS,CODE_COMBINATION_ID
--  FROM GL_CODE_COMBINATIONS_KFV
-- WHERE CONCATENATED_SEGMENTS LIKE '251%'

-->> ----------------------------------------------------------------------------------
--> Interface Tables:

SELECT *
  FROM RA_INTERFACE_LINES_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

--DELETE RA_INTERFACE_LINES_ALL where TRUNC(CREATION_DATE) = TRUNC(SYSDATE);
--COMMIT;

SELECT *
  FROM RA_INTERFACE_DISTRIBUTIONS_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

--DELETE RA_INTERFACE_DISTRIBUTIONS_ALL where TRUNC(CREATION_DATE) = TRUNC(SYSDATE);
--COMMIT;
--> Error Table:

  SELECT *
    FROM RA_INTERFACE_ERRORS_ALL
ORDER BY INTERFACE_LINE_ID DESC;

INSERT INTO ra_interface_lines_all (interface_line_id,
                                    batch_source_name,
                                    line_number,
                                    line_type,
                                    cust_trx_type_name,
                                    cust_trx_type_id,
                                    trx_date,
                                    gl_date,
                                    currency_code,
                                    term_id,
                                    orig_system_bill_customer_id,
                                    orig_system_bill_customer_ref,
                                    orig_system_bill_address_id,
                                    orig_system_bill_address_ref,
                                    orig_system_ship_customer_id,
                                    orig_system_ship_address_id,
                                    orig_system_sold_customer_id,
                                    -- sales_order,
                                    inventory_item_id,
                                    uom_code,
                                    quantity,
                                    unit_selling_price,
                                    amount,
                                    description,
                                    conversion_type,
                                    conversion_rate,
                                    interface_line_context,
                                    interface_line_attribute1,
                                    interface_line_attribute2,
                                    org_id,
                                    set_of_books_id,
                                    fob_point,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by)
     VALUES (ra_customer_trx_lines_s.NEXTVAL,           --> interface_line_id,
             'VISION BUILD',                            --> batch_source_name,
             1,                                               --> line_number,
             'LINE',                                            --> line_type,
             'Invoice',                                --> cust_trx_type_name,
             1,                                          --> cust_trx_type_id,
             SYSDATE,                                            --> trx_date,
             TO_DATE ('20-JAN-2014'),                             --> gl_date,
             'USD',                                         --> currency_code,
             4,                                                   --> term_id,
             1290,                           --> orig_system_bill_customer_id,
             1290,                          --> orig_system_bill_customer_ref,
             1340,                            --> orig_system_bill_address_id,
             1340,                           --> orig_system_bill_address_ref,
             1290,                           --> orig_system_ship_customer_id,
             1340,                            --> orig_system_ship_address_id,
             1290,                           --> orig_system_sold_customer_id,
             -- 66500,                          --> sales_order,
             2155,                                      --> inventory_item_id,
             'Ea',                                               --> uom_code,
             20,                                                 --> quantity,
             400,                                      --> unit_selling_price,
             8000,                                                 --> amount,
             'XXAA Invoice',                                  --> description,
             'User',                                      --> conversion_type,
             1,                                           --> conversion_rate,
             'VISION BUILD',                       --> interface_line_context,
             '5805',                            --> interface_line_attribute1,
             '2541',                            --> interface_line_attribute2,
             204,                                                  --> org_id,
             1,                                           --> set_of_books_id,
             'Destination',                                     --> fob_point,
             SYSDATE,                                    --> last_update_date,
             1318,                 -- fnd_global.user_id, --> last_updated_by,
             SYSDATE,                                       --> creation_date,
             1318                         -- fnd_global.user_id --> created_by
                 );

INSERT INTO ra_interface_distributions_all (interface_line_id,
                                            account_class,
                                            amount,
                                            code_combination_id,
                                            PERCENT,
                                            interface_line_context,
                                            interface_line_attribute1,
                                            INTERFACE_LINE_ATTRIBUTE2,
                                            org_id,
                                            last_update_date,
                                            last_updated_by,
                                            creation_date,
                                            created_by)
     VALUES (ra_customer_trx_lines_s.CURRVAL,
             'REV',
             8000,
             17021,
             100,
             'VISION BUILD',
             '5805',
             '2541',
             204,
             SYSDATE,
             1318,                                      -- fnd_global.user_id,
             SYSDATE,
             1318                                        -- fnd_global.user_id
                 );

COMMIT;
-->> ----------------------------------------------------------------------------------
-->Run 'Autoinvoice Master Program' from Receivable, Vision Operation (USA) responsibility
-->> ----------------------------------------------------------------------------------
--> Error Table:

  SELECT *
    FROM RA_INTERFACE_ERRORS_ALL
ORDER BY INTERFACE_LINE_ID DESC;

--> Base Tables:

SELECT *
  FROM RA_CUSTOMER_TRX_ALL
 WHERE 1=1
 --AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE)
 ;

SELECT *
  FROM RA_CUSTOMER_TRX_LINES_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

SELECT *
  FROM RA_CUST_TRX_LINE_GL_DIST_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

-->> ----------------------------------------------------------------------------------


SELECT
OOH.ORG_ID,
OOH.HEADER_ID,
OOH.ORDER_NUMBER,
OOH.TRANSACTIONAL_CURR_CODE,
INITCAP(OOH.FREIGHT_TERMS_CODE),
OOH.FREIGHT_CARRIER_CODE,
OOH.SALESREP_ID
,OOH.ORDERED_DATE
--,OOH.*
,OOL.INVENTORY_ITEM_ID
,OOL.UNIT_SELLING_PRICE
,OOL.ORDERED_QUANTITY
,OOL.LINE_NUMBER
,OOL.UNIT_LIST_PRICE
,OOL.ACTUAL_SHIPMENT_DATE
,OOL.*
FROM
OE_ORDER_HEADERS_ALL OOH, OE_ORDER_LINES_ALL OOL
WHERE 1=1
AND OOH.HEADER_ID=OOL.HEADER_ID
AND ORDER_NUMBER='2011010000120';


SELECT
OOH.*
FROM
OE_ORDER_HEADERS_ALL
WHERE 1=1
AND ORDER_NUMBER='2011010000120';
SELECT
*
FROM
OE_ORDER_LINES_ALL;

SELECT
(3*2)
FROM
DUAL

SELECT
*
FROM APPS.RA_CUST_TRX_TYPES_ALL
WHERE 1=1
AND CUST_TRX_TYPE_ID='17162'


SELECT
MSI.INVENTORY_ITEM_ID,
MSI.SEGMENT1,
MSI.DESCRIPTION,
PRIMARY_UOM_CODE
FROM
APPS.MTL_SYSTEM_ITEMS_B MSI
WHERE SEGMENT1=:P_ITEM_CODE
AND ORGANIZATION_ID=:L_ORGANIZATION_ID
AND ENABLED_FLAG='Y'


select
*
from
ra_territories

execute APPS.ar_interface_upld_adi_pkg.upload_data_to_ar_int_stg (1,'251','DBLCL - Sales','Invoice','Tiles Local INV',1,'25-Sep-19','25-Sep-19','BDT','2597','NP6060-012GN',10,9);