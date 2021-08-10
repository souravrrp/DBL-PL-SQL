/* Formatted on 6/23/2020 1:19:59 PM (QP5 v5.287) */
CREATE OR REPLACE PROCEDURE XX_ARINVOICE_INTERFACE (errbuf     OUT VARCHAR2,
                                                    rectcode   OUT VARCHAR2)
AS
   l_org_id               hr_operating_units.organization_id%TYPE;

   l_sob_id               hr_operating_units.set_of_books_id%TYPE;

   l_cust_trx_type_id     ra_cust_trx_types_all.cust_trx_type_id%TYPE;

   l_gl_id_rev            ra_cust_trx_types_all.gl_id_rev%TYPE;

   l_cust_trx_type_name   ra_cust_trx_types_all.name%TYPE;

   l_currency_code        fnd_currencies.currency_code%TYPE;

   l_term_id              ra_terms_tl.term_id%TYPE;

   l_term_name            ra_terms_tl.name%TYPE;

   l_address_id           hz_cust_acct_sites_all.cust_acct_site_id%TYPE;

   l_customer_id          hz_cust_accounts.cust_account_id%TYPE;

   l_verify_flag          CHAR (1);

   l_error_message        VARCHAR2 (2500);
   
BEGIN
   BEGIN
      SELECT organization_id, SET_OF_BOOKS_ID
        INTO l_org_id, l_sob_id
        FROM hr_operating_units
       WHERE name = 'Operating Unit';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Operating Unit...';
   END;

   BEGIN
      SELECT cust_trx_type_id, name, gl_id_rev
        INTO l_cust_trx_type_id, l_cust_trx_type_name, l_gl_id_rev
        FROM ra_cust_trx_types_all
       WHERE     set_of_books_id = l_sob_id
             AND org_id = l_org_id
             AND name = 'xxx-Spares-Inv';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Invoice Type...';
   END;



   BEGIN
      SELECT currency_code
        INTO l_currency_code
        FROM fnd_currencies
       WHERE currency_code = 'USD';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Currency Code...';
   END;



   BEGIN
      SELECT term_id, name
        INTO l_term_id, l_term_name
        FROM ra_terms_tl
       WHERE UPPER (name) = UPPER ('30 Days');
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Terms Name...';
   END;



   BEGIN
      SELECT DISTINCT HCAS.cust_acct_site_id, HCA.cust_account_id
        INTO l_address_id, l_customer_id
        FROM hz_parties HP,
             hz_party_sites HPS,
             hz_cust_accounts HCA,
             hz_cust_acct_sites_all HCAS,
             hz_cust_site_uses_all HCSU
       WHERE     HCA.party_id = HP.party_id
             AND HP.party_id = HPS.party_id
             AND HCA.cust_account_id = HCAS.cust_account_id
             AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
             AND HCSU.site_use_code = 'BILL_TO'
             AND HCSU.primary_flag = 'Y'
             AND UPPER (LTRIM (RTRIM (HP.party_name))) =
                    UPPER (LTRIM (RTRIM ('Customer Name')))
             AND HCAs.org_id = l_org_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Customer Name...';
   END;



   INSERT INTO ra_interface_lines_all (INTERFACE_LINE_ID,
                                       BATCH_SOURCE_NAME,
                                       LINE_TYPE,
                                       CUST_TRX_TYPE_ID,
                                       cust_trx_type_name,
                                       TRX_DATE,
                                       GL_DATE,
                                       CURRENCY_CODE,
                                       term_id,
                                       term_name,
                                       orig_system_bill_customer_id,
                                       orig_system_bill_address_id,
                                       orig_system_sold_customer_id,
                                       QUANTITY,
                                       AMOUNT,
                                       DESCRIPTION,
                                       conversion_type,
                                       conversion_rate,
                                       INTERFACE_LINE_CONTEXT,
                                       INTERFACE_LINE_ATTRIBUTE1,
                                       org_id)
        VALUES (RA_CUSTOMER_TRX_LINES_S.NEXTVAL,
                'Invoice Migration',
                'LINE',
                l_cust_trx_type_id,
                l_cust_trx_type_name,
                SYSDATE,
                SYSDATE,
                l_currency_code,
                l_term_id,
                l_term_name,
                l_customer_id,
                l_address_id,
                l_customer_id,
                1,
                --40000

                1000,
                'AR Invoice 001',
                'User',
                1,
                'Invoice Conversions',
                '1001',
                l_org_id);



   INSERT INTO ra_interface_distributions_all (INTERFACE_LINE_ID,
                                               account_class,
                                               amount,
                                               code_combination_id,
                                               percent,
                                               interface_line_context,
                                               interface_line_attribute1,
                                               org_id)
        VALUES (RA_CUSTOMER_TRX_LINES_S.CURRVAL,
                'REV',
                1000,
                l_gl_id_rev,
                100,
                'Invoice Conversions',
                '1001',
                l_org_id);



   COMMIT;
END XX_ARINVOICE_INTERFACE;
/



----------------------------------------------------------------------------------------------------------------------------


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

-->> ----------------------------------------------------------------------------------
--> Validation Queries

SELECT ORGANIZATION_ID
  FROM hr_operating_units
 WHERE name = 'Vision Operations';

SELECT *
  FROM RA_BATCH_SOURCES_ALL
 WHERE NAME = 'VISION BUILD' AND ORG_ID = 204;

SELECT *
  FROM all_objects
 WHERE object_type = 'TABLE' AND object_name LIKE '%REVENUE_ASSIGNMENTS%';

SELECT *
  FROM ra_cust_trx_types_all
 WHERE NAME = 'Invoice' AND ORG_ID = 204;

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
 WHERE UNIT_OF_MEASURE = 'Each';

SELECT HCSU.site_use_code,
       HCSU.LOCATION,
       HCAS.cust_acct_site_id,
       HCA.cust_account_id,
       HP.PARTY_NUMBER,
       hp.PARTY_ID
  FROM hz_parties HP,
       hz_party_sites HPS,
       hz_cust_accounts HCA,
       hz_cust_acct_sites_all HCAS,
       hz_cust_site_uses_all HCSU
 WHERE     HP.party_id = HPS.party_id
       AND HCA.party_id = HP.party_id
       AND HCA.cust_account_id = HCAS.cust_account_id
       AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
       AND hps.PARTY_SITE_ID = hcas.PARTY_SITE_ID
       AND HCSU.site_use_code = 'SHIP_TO'
       AND HP.PARTY_ID = 1290
       AND HCAs.org_id = 204
       AND LOCATION = 'PROVO (OPS)';

SELECT HCSU.site_use_code,
       HCSU.LOCATION,
       HCAS.cust_acct_site_id,
       HCA.cust_account_id,
       HP.PARTY_NUMBER,
       hp.PARTY_ID
  FROM hz_parties HP,
       hz_party_sites HPS,
       hz_cust_accounts HCA,
       hz_cust_acct_sites_all HCAS,
       hz_cust_site_uses_all HCSU
 WHERE     HCA.party_id = HP.party_id
       AND HP.party_id = HPS.party_id
       AND HCA.cust_account_id = HCAS.cust_account_id
       AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
       AND HCSU.site_use_code = 'BILL_TO'
       AND HCSU.primary_flag = 'Y'
       AND UPPER (LTRIM (RTRIM (HP.party_name))) =
              UPPER (LTRIM (RTRIM ('A. C. Networks')))
       AND HCAs.org_id = 204;

SELECT INVENTORY_ITEM_ID
  FROM mtl_system_items_b
 WHERE segment1 = 'AS54999' AND ORGANIZATION_ID = 204;

SELECT conversion_type
  FROM gl_daily_conversion_types
 WHERE conversion_type = 'User';

SELECT LOOKUP_CODE
  FROM fnd_lookup_values
 WHERE     lookup_type = 'FOB'
       AND MEANING = 'Destination'
       AND VIEW_APPLICATION_ID = 222;

SELECT CODE_COMBINATION_ID
  FROM GL_CODE_COMBINATIONS_KFV
 WHERE CONCATENATED_SEGMENTS = '01-520-5250-0000-000';

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
             -- 66500, --> sales_order,
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
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

SELECT *
  FROM RA_CUSTOMER_TRX_LINES_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

SELECT *
  FROM RA_CUST_TRX_LINE_GL_DIST_ALL
 WHERE TRUNC (CREATION_DATE) = TRUNC (SYSDATE);

-->> ----------------------------------------------------------------------------------

