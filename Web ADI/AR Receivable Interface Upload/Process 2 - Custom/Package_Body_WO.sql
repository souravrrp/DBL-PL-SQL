/* Formatted on 7/21/2020 2:01:19 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_ar_interface_upload_pkg
IS
   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      CURSOR cur_stg
      IS
         SELECT *
           FROM apps.xxdbl_ra_interface_upload_stg
          WHERE FLAG IS NULL;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            INSERT
              INTO ra_interface_lines_all (interface_line_id,
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
                                           sales_order,
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
                                           created_by,
                                           SHIP_VIA,
                                           PRIMARY_SALESREP_ID,
                                           SALES_ORDER_SOURCE,
                                           SALES_ORDER_DATE,
                                           SALES_ORDER_LINE,
                                           SHIP_DATE_ACTUAL,
                                           UNIT_STANDARD_PRICE,
                                           INTERFACE_STATUS,
                                           TERRITORY_ID,
                                           TERRITORY_SEGMENT1,
                                           TERRITORY_SEGMENT2,
                                           TERRITORY_SEGMENT3,
                                           TERRITORY_SEGMENT4
                                           --invoicing_rule_id,
                                           --accounting_rule_id,
                                           --accounting_rule_duration
                                           )
            VALUES (ra_customer_trx_lines_s.NEXTVAL,    --> interface_line_id,
                    ln_cur_stg.BATCH_SOURCE_NAME,       --> batch_source_name,
                    ln_cur_stg.LINE_NUMBER,                   --> line_number,
                    'LINE',                                     --> line_type,
                    ln_cur_stg.TRX_TYPE,               --> cust_trx_type_name,
                    ln_cur_stg.CUST_TRX_TYPE_ID,         --> cust_trx_type_id,
                    ln_cur_stg.TRX_DATE,                         --> trx_date,
                    ln_cur_stg.GL_DATE,                           --> gl_date,
                    ln_cur_stg.CURRENCY_CODE,               --> currency_code,
                    ln_cur_stg.TERM_ID,                           --> term_id,
                    ln_cur_stg.CUSTOMER_ID,  --> orig_system_bill_customer_id,
                    NULL,                   --> orig_system_bill_customer_ref,
                    ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_id,
                    NULL,                    --> orig_system_bill_address_ref,
                    ln_cur_stg.CUSTOMER_ID,  --> orig_system_ship_customer_id,
                    ln_cur_stg.SHIP_TO_SITE_ID, --> orig_system_ship_address_id,
                    ln_cur_stg.CUSTOMER_ID,  --> orig_system_sold_customer_id,
                    ln_cur_stg.SALES_ORDER,                   --> sales_order,
                    ln_cur_stg.ITEM_ID,                 --> inventory_item_id,
                    ln_cur_stg.UOM_CODE,                         --> uom_code,
                    ln_cur_stg.QUANTITY,                         --> quantity,
                    ln_cur_stg.UNIT_SELLING_PRICE,     --> unit_selling_price,
                    ln_cur_stg.AMOUNT,                             --> amount,
                    'Custom Interface Upload Invoice',        --> description,
                    'User',                               --> conversion_type,
                    1,                                    --> conversion_rate,
                    'ORDER ENTRY',                 --> interface_line_context,
                    ln_cur_stg.SALES_ORDER,     --> interface_line_attribute1,
                    ln_cur_stg.FREIGHT_TERMS_CODE, --> interface_line_attribute2,
                    ln_cur_stg.OPERATING_UNIT,                     --> org_id,
                    ln_cur_stg.SET_OF_BOOKS,              --> set_of_books_id,
                    NULL,                                       --> fob_point,
                    SYSDATE,                             --> last_update_date,
                    5429,          -- fnd_global.user_id, --> last_updated_by,
                    SYSDATE,                                --> creation_date,
                    5429,                 -- fnd_global.user_id --> created_by
                    ln_cur_stg.FREIGHT_CARRIER_CODE,
                    ln_cur_stg.SALESREP_ID,
                    'ORDER ENTRY',
                    ln_cur_stg.ORDER_DATE,
                    ln_cur_stg.ORD_LINE_NUMBER,
                    ln_cur_stg.ACTUAL_SHIP_DATE,
                    ln_cur_stg.UNIT_LIST_PRICE,
                    'P',
                    ln_cur_stg.TERRITORY_ID,
                    ln_cur_stg.T_SEGMENT1,
                    ln_cur_stg.T_SEGMENT2,
                    ln_cur_stg.T_SEGMENT3,
                    ln_cur_stg.T_SEGMENT4
--                    1000,
--                    1,
--                    NULL
                    );
         EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  'Error while inserting records in lines table' || SQLERRM);
         END;



         UPDATE apps.xxdbl_ra_interface_upload_stg
            SET FLAG = 'Y'
          WHERE     FLAG IS NULL
                AND SL_NO = ln_cur_stg.SL_NO
                AND LINE_NUMBER = ln_cur_stg.LINE_NUMBER;
      END LOOP;

      RETURN 0;
   END;

   PROCEDURE import_data_to_ar_interface (ERRBUF    OUT VARCHAR2,
                                          RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_import_data;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END import_data_to_ar_interface;

   PROCEDURE upload_data_to_ar_int_stg (P_SL_NO                 NUMBER,
                                        P_ORGANIZATION_CODE     VARCHAR2,
                                        P_BATCH_SOURCE_NAME     VARCHAR2,
                                        P_TRX_TYPE              VARCHAR2,
                                        P_CUST_TRX_TYPE         VARCHAR2,
                                        P_LINE_NUMBER           NUMBER,
                                        P_TRX_DATE              DATE,
                                        P_GL_DATE               DATE,
                                        P_CURRENCY_CODE         VARCHAR2,
                                        P_CUSTOMER_NUMBER       VARCHAR2,
                                        P_ITEM_CODE             VARCHAR2,
                                        P_QUANTITY              NUMBER,
                                        P_UNIT_SELLING_PRICE    NUMBER)
   IS
      --------------------------------------------
      --ORG Parameter

      L_OPERATING_UNIT     NUMBER;
      L_ORGANIZATION_ID    NUMBER;
      L_SET_OF_BOOKS       NUMBER;
      L_LEGAL_ENTITY_ID    NUMBER;


      --------------------------------------------
      --Customer Parameter

      L_CUSTOMER_ID        NUMBER;
      L_BILL_TO_SITE_ID    NUMBER;
      L_SHIP_TO_SITE_ID    NUMBER;
      L_PAYMENT_TERM_ID    NUMBER;
      L_TERRITORY_ID       NUMBER;
      L_T_SEGMENT1         VARCHAR2 (500);
      L_T_SEGMENT2         VARCHAR2 (500);
      L_T_SEGMENT3         VARCHAR2 (500);
      L_T_SEGMENT4         VARCHAR2 (500);

      --------------------------------------------

      L_ITEM_ID            NUMBER;
      L_UOM_CODE           VARCHAR2 (10);

      --------------------------------------------

      L_AMOUNT             FLOAT;

      --------------------------------------------

      L_CUST_TRX_TYPE_ID   NUMBER;

      --------------------------------------------

      --L_CHART_OF_ACT_ID           NUMBER;

      --------------------------------------------

      L_TRX_DATE           DATE := P_TRX_DATE;
      L_GL_DATE            DATE := P_GL_DATE;

      --------------------------------------------

      l_error_message      VARCHAR2 (3000);
      l_error_code         VARCHAR2 (3000);
   BEGIN
      -----------------------------------------------------
      ----------Validate Organization Code-----------------
      -----------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE (P_ORGANIZATION_CODE);

      BEGIN
         SELECT OOD.OPERATING_UNIT,
                OOD.ORGANIZATION_ID,
                OU.SET_OF_BOOKS_ID,
                OU.DEFAULT_LEGAL_CONTEXT_ID
           INTO L_OPERATING_UNIT,
                L_ORGANIZATION_ID,
                L_SET_OF_BOOKS,
                L_LEGAL_ENTITY_ID
           FROM ORG_ORGANIZATION_DEFINITIONS OOD, HR_OPERATING_UNITS OU
          WHERE     1 = 1
                AND OOD.OPERATING_UNIT = OU.ORGANIZATION_ID
                AND OOD.ORGANIZATION_CODE = P_ORGANIZATION_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Organization Code';
            l_error_code := 'E';
      END;



      /*
      --------------------------------------------------
      ----------Validate Chart Of Accounts Id------------
      --------------------------------------------------
      BEGIN
         SELECT CHART_OF_ACCOUNTS_ID
           INTO L_CHART_OF_ACT_ID
           FROM GL_SETS_OF_BOOKS
          WHERE SET_OF_BOOKS_ID = L_SET_OF_BOOKS;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Chart Of Accounts Id';
            l_error_code := 'E';
      END;
      */



      --------------------------------------------------
      ----------Select Customer Bill TO Info------------
      --------------------------------------------------

      --IF P_CUSTOMER_NUMBER IS NOT NULL
      --THEN
      BEGIN
         SELECT HCA.CUST_ACCOUNT_ID,
                HCAS.CUST_ACCT_SITE_ID,
                HCSU.PAYMENT_TERM_ID
           INTO L_CUSTOMER_ID, L_BILL_TO_SITE_ID, L_PAYMENT_TERM_ID
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
                AND HCA.ACCOUNT_NUMBER = P_CUSTOMER_NUMBER
                AND HCAS.ORG_ID = L_OPERATING_UNIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct customer number';
            l_error_code := 'E';
      END;

      --END IF;


      --------------------------------------------------
      ----------Select Customer Ship TO Info------------
      --------------------------------------------------


      --IF P_CUSTOMER_NUMBER IS NOT NULL
      --THEN
      BEGIN
         SELECT HCAS.CUST_ACCT_SITE_ID,
                TER.TERRITORY_ID,
                TER.SEGMENT1,
                TER.SEGMENT2,
                TER.SEGMENT3,
                TER.SEGMENT4
           INTO L_SHIP_TO_SITE_ID,
                L_TERRITORY_ID,
                L_T_SEGMENT1,
                L_T_SEGMENT2,
                L_T_SEGMENT3,
                L_T_SEGMENT4
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
                AND HCA.ACCOUNT_NUMBER = P_CUSTOMER_NUMBER
                AND HCAS.ORG_ID = L_OPERATING_UNIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct customer ship to address.';
            l_error_code := 'E';
      END;

      --END IF;



      ----------------------------------------
      ----------Validate Item Info------------
      ----------------------------------------


      --IF P_ITEM_CODE IS NOT NULL OR P_SALES_ORDER IS NOT NULL
      --THEN
      BEGIN
         SELECT MSI.INVENTORY_ITEM_ID, MSI.PRIMARY_UOM_CODE
           INTO L_ITEM_ID, L_UOM_CODE
           FROM APPS.MTL_SYSTEM_ITEMS_B MSI
          WHERE     SEGMENT1 = P_ITEM_CODE
                AND ORGANIZATION_ID = L_ORGANIZATION_ID
                AND ENABLED_FLAG = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Item Info.';
            l_error_code := 'E';
      END;

      --END IF;


      ----------------------------------------
      ----------Count Total Quantity----------
      ----------------------------------------



      BEGIN
         SELECT (P_QUANTITY * P_UNIT_SELLING_PRICE)
           INTO L_AMOUNT
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Quantity and Unit Selling Price info.';
            l_error_code := 'E';
      END;


      ----------------------------------------
      ----------VALIDATE Cust_TRX_Type_ID-----
      ----------------------------------------

      BEGIN
         SELECT CUST_TRX_TYPE_ID
           INTO L_CUST_TRX_TYPE_ID
           FROM RA_CUST_TRX_TYPES_ALL CTT
          WHERE CTT.NAME = P_CUST_TRX_TYPE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Cust_Trx_Type Name info.';
            l_error_code := 'E';
      END;


      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO apps.xxdbl_ra_interface_upload_stg (SL_NO,
                                                         TRX_TYPE,
                                                         CUST_TRX_TYPE_ID,
                                                         ORGANIZATION_CODE,
                                                         BATCH_SOURCE_NAME,
                                                         LINE_NUMBER,
                                                         TRX_DATE,
                                                         GL_DATE,
                                                         CURRENCY_CODE,
                                                         CUSTOMER_NUMBER,
                                                         ITEM_CODE,
                                                         QUANTITY,
                                                         UNIT_SELLING_PRICE,
                                                         OPERATING_UNIT,
                                                         ORGANIZATION_ID,
                                                         SET_OF_BOOKS,
                                                         LEGAL_ENTITY_ID,
                                                         ITEM_ID,
                                                         UOM_CODE,
                                                         AMOUNT,
                                                         CUSTOMER_ID,
                                                         BILL_TO_SITE_ID,
                                                         SHIP_TO_SITE_ID,
                                                         TERM_ID,
                                                         TERRITORY_ID,
                                                         T_SEGMENT1,
                                                         T_SEGMENT2,
                                                         T_SEGMENT3,
                                                         T_SEGMENT4)
              VALUES (TRIM (P_SL_NO),
                      TRIM (P_TRX_TYPE),
                      TRIM (L_CUST_TRX_TYPE_ID),
                      TRIM (P_ORGANIZATION_CODE),
                      TRIM (P_BATCH_SOURCE_NAME),
                      TRIM (P_LINE_NUMBER),
                      TRIM (L_TRX_DATE),
                      TRIM (L_GL_DATE),
                      TRIM (P_CURRENCY_CODE),
                      TRIM (P_CUSTOMER_NUMBER),
                      TRIM (P_ITEM_CODE),
                      TRIM (P_QUANTITY),
                      TRIM (P_UNIT_SELLING_PRICE),
                      TRIM (L_OPERATING_UNIT),
                      TRIM (L_ORGANIZATION_ID),
                      TRIM (L_SET_OF_BOOKS),
                      TRIM (L_LEGAL_ENTITY_ID),
                      TRIM (L_ITEM_ID),
                      TRIM (L_UOM_CODE),
                      TRIM (L_AMOUNT),
                      TRIM (L_CUSTOMER_ID),
                      TRIM (L_BILL_TO_SITE_ID),
                      TRIM (L_SHIP_TO_SITE_ID),
                      TRIM (L_PAYMENT_TERM_ID),
                      TRIM (L_TERRITORY_ID),
                      TRIM (L_T_SEGMENT1),
                      TRIM (L_T_SEGMENT2),
                      TRIM (L_T_SEGMENT3),
                      TRIM (L_T_SEGMENT4));
      END IF;

      COMMIT;
   END upload_data_to_ar_int_stg;
END xxdbl_ar_interface_upload_pkg;
/