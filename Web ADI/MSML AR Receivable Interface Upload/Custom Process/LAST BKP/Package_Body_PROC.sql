/* Formatted on 8/17/2020 9:47:01 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_ar_interface_upload_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 17-AUG-2020
   -- LAST UPDATE DATE :17-AUG-2020
   -- PURPOSE : CREATE AR INVOICE 
   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      L_RETURN_STATUS         VARCHAR2 (1);
      vl_interface_line_id    NUMBER;
      vl_challan_number       VARCHAR2 (500);
      vl_bill_header_id_seq   NUMBER;

      CURSOR cur_stg
      IS
         SELECT *
           FROM xxdbl.xxdbl_ra_interface_upload_stg
          WHERE FLAG IS NULL;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            L_RETURN_STATUS := NULL;
            --SELECT ra_customer_trx_lines_s.CURRVAL INTO vl_interface_line_id FROM DUAL;
            vl_interface_line_id := ra_customer_trx_lines_s.NEXTVAL;
            vl_bill_header_id_seq :=
               XX_COM_PKG.GET_SEQUENCE_VALUE ('XX_AR_BILLS_HEADERS_ALL',
                                              'BILL_HEADER_ID');

            vl_challan_number :=
                  ln_cur_stg.UNIT_NAME
               || '/'
               || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0'));


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
                                           -- sales_order,
                                           --inventory_item_id,
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
                                           interface_line_attribute3,
                                           interface_line_attribute4,
                                           interface_line_attribute5,
                                           org_id,
                                           set_of_books_id,
                                           fob_point,
                                           last_update_date,
                                           last_updated_by,
                                           creation_date,
                                           created_by,
                                           taxable_flag,
                                           amount_includes_tax_flag        --,
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
                    ln_cur_stg.CUSTOMER_ID, --> orig_system_bill_customer_ref,
                    ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_id,
                    ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_ref,
                    ln_cur_stg.CUSTOMER_ID,  --> orig_system_ship_customer_id,
                    ln_cur_stg.SHIP_TO_SITE_ID, --> orig_system_ship_address_id,
                    ln_cur_stg.CUSTOMER_ID,  --> orig_system_sold_customer_id,
                    -- 66500,                          --> sales_order,
                    --2155,                             --> inventory_item_id,
                    ln_cur_stg.UOM_CODE,                         --> uom_code,
                    ln_cur_stg.QUANTITY,                         --> quantity,
                    ln_cur_stg.UNIT_SELLING_PRICE,     --> unit_selling_price,
                    ln_cur_stg.AMOUNT,                             --> amount,
                    ln_cur_stg.ITEM_DESCRIPTION,              --> description,
                    ln_cur_stg.EXCHANGE_RATE_TYPE,        --> conversion_type,
                    ln_cur_stg.EXCHANGE_RATE,             --> conversion_rate,
                    'DBL_IC_INVOICE',              --> interface_line_context,
                    vl_challan_number,          --> interface_line_attribute1,
                    ln_cur_stg.TRX_DATE,        --> interface_line_attribute2,
                    NVL (ln_cur_stg.PI_NUMBER, 'PI-NOT AVAILABLE'), --> interface_line_attribute3,
                    NVL (ln_cur_stg.PO_NUMBER, 'PO-NOT AVAILABLE'), --> interface_line_attribute4,
                    vl_bill_header_id_seq,      --> interface_line_attribute5,
                    ln_cur_stg.OPERATING_UNIT,                     --> org_id,
                    ln_cur_stg.SET_OF_BOOKS,              --> set_of_books_id,
                    NULL,                                       --> fob_point,
                    SYSDATE,                             --> last_update_date,
                    0,             -- fnd_global.user_id, --> last_updated_by,
                    SYSDATE,                                --> creation_date,
                    0,                   -- fnd_global.user_id --> created_by,
                    'Y',                                     --> taxable_flag,
                    'N' --,                         --> amount_includes_tax_flag,
                       ---2,                                 --> invoicing_rule_id,
                       --1,                                 --> accounting_rule_id,
                       --NULL                          --> accounting_rule_duration
                    );


            INSERT
              INTO ra_interface_distributions_all (interface_line_id,
                                                   account_class,
                                                   amount,
                                                   code_combination_id,
                                                   PERCENT,
                                                   interface_line_context,
                                                   interface_line_attribute1,
                                                   interface_line_attribute2,
                                                   interface_line_attribute3,
                                                   interface_line_attribute4,
                                                   interface_line_attribute5,
                                                   org_id,
                                                   last_update_date,
                                                   last_updated_by,
                                                   creation_date,
                                                   created_by)
            VALUES (ra_customer_trx_lines_s.CURRVAL,     --> interface_line_id
                    'REV',                                    -->account_class
                    ln_cur_stg.AMOUNT,                               -->amount
                    ln_cur_stg.CODE_COMBINATION_ID,     -->code_combination_id
                    100,                                            -->PERCENT
                    'DBL_IC_INVOICE',                -->interface_line_context
                    vl_challan_number,          --> interface_line_attribute1,
                    ln_cur_stg.TRX_DATE,        --> interface_line_attribute2,
                    NVL (ln_cur_stg.PI_NUMBER, 'PI-NOT AVAILABLE'), --> interface_line_attribute3,
                    NVL (ln_cur_stg.PO_NUMBER, 'PO-NOT AVAILABLE'), --> interface_line_attribute4,
                    vl_bill_header_id_seq,      --> interface_line_attribute5,
                    ln_cur_stg.OPERATING_UNIT,                       -->org_id
                    SYSDATE,                               -->last_update_date
                    0,                                      -->last_updated_by
                    SYSDATE,                                  -->creation_date
                    0                                            -->created_by
                     );


            COMMIT;

            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
               DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  '--------------Unexpected errors found!--------------------');
            ELSE
               UPDATE xxdbl.xxdbl_ra_interface_upload_stg
                  SET FLAG = 'Y'
                WHERE     FLAG IS NULL
                      AND SL_NO = ln_cur_stg.SL_NO
                      AND LINE_NUMBER = ln_cur_stg.LINE_NUMBER;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.put_line (
                  FND_FILE.LOG,
                     'Error while inserting records into Interface lines table.'
                  || SQLERRM);
         END;
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
                                        P_EXCHANGE_RATE         NUMBER,
                                        P_CUSTOMER_NUMBER       VARCHAR2,
                                        P_ITEM_CODE             VARCHAR2,
                                        P_QUANTITY              NUMBER,
                                        P_UNIT_SELLING_PRICE    NUMBER,
                                        P_PO_NUMBER             VARCHAR2,
                                        P_PI_NUMBER             VARCHAR2)
   IS
      --------------------------------------------
      --ORG Parameter

      L_OPERATING_UNIT        NUMBER;
      L_ORGANIZATION_ID       NUMBER;
      L_SET_OF_BOOKS          NUMBER;
      L_LEGAL_ENTITY_ID       NUMBER;
      L_UNIT_NAME             VARCHAR2 (240 BYTE);


      --------------------------------------------
      --Customer Parameter

      L_CUSTOMER_ID           NUMBER;
      L_CUSTOMER_NAME         VARCHAR2 (240);
      L_BILL_TO_SITE_ID       NUMBER;
      L_SHIP_TO_SITE_ID       NUMBER;
      L_PAYMENT_TERM_ID       NUMBER;
      L_TERRITORY_ID          NUMBER;
      L_T_SEGMENT1            VARCHAR2 (500);
      L_T_SEGMENT2            VARCHAR2 (500);
      L_T_SEGMENT3            VARCHAR2 (500);
      L_T_SEGMENT4            VARCHAR2 (500);

      --------------------------------------------

      L_ITEM_ID               NUMBER;
      L_UOM_CODE              VARCHAR2 (20);
      L_ITEM_DESCRIPTION      VARCHAR2 (240);

      --------------------------------------------

      L_AMOUNT                FLOAT;

      --------------------------------------------

      L_CUST_TRX_TYPE_ID      NUMBER;
      L_CODE_COMBINATION_ID   NUMBER;

      --------------------------------------------

      --L_CHART_OF_ACT_ID           NUMBER;

      --------------------------------------------

      L_BATCH_SOURCE_ID       NUMBER;
      L_GROUPING_RULE_ID      NUMBER;

      --------------------------------------------

      L_TRX_DATE              DATE := P_TRX_DATE;
      L_GL_DATE               DATE := P_GL_DATE;

      --------------------------------------------

      l_error_message         VARCHAR2 (3000);
      l_error_code            VARCHAR2 (3000);

      --------------------------------------------

      l_exchange_rate_type    VARCHAR2 (50);
      l_exchange_date         DATE;
      l_exchange_rate         NUMBER;

      --------------------------------------------

      L_PO_NUMBER             VARCHAR2 (50);
      L_UNIT_SELLING_PRICE    NUMBER;
      L_CURRENCY_CODE         VARCHAR2 (3);
      L_RATE                  NUMBER;

      ---------------------------------------------
      L_CTT_LOOKUP            VARCHAR2 (100) := 'DBL_BILL_CATEGORY';
   --------------------------------------------
   BEGIN
      -----------------------------------------------------
      ----------Validate Organization Code-----------------
      -----------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE (P_ORGANIZATION_CODE);

      BEGIN
         SELECT OOD.OPERATING_UNIT,
                OOD.ORGANIZATION_ID,
                OU.SET_OF_BOOKS_ID,
                OU.DEFAULT_LEGAL_CONTEXT_ID,
                OU.NAME
           INTO L_OPERATING_UNIT,
                L_ORGANIZATION_ID,
                L_SET_OF_BOOKS,
                L_LEGAL_ENTITY_ID,
                L_UNIT_NAME
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
                HCA.ACCOUNT_NAME,
                HCAS.CUST_ACCT_SITE_ID,
                HCSU.PAYMENT_TERM_ID
           INTO L_CUSTOMER_ID,
                L_CUSTOMER_NAME,
                L_BILL_TO_SITE_ID,
                L_PAYMENT_TERM_ID
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
         SELECT MSI.INVENTORY_ITEM_ID, MSI.PRIMARY_UOM_CODE, MSI.DESCRIPTION
           INTO L_ITEM_ID, L_UOM_CODE, L_ITEM_DESCRIPTION
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
         SELECT CTT.CUST_TRX_TYPE_ID, CTT.GL_ID_REV
           INTO L_CUST_TRX_TYPE_ID, L_CODE_COMBINATION_ID
           FROM FND_LOOKUP_VALUES_VL LV,
                RA_CUST_TRX_TYPES_ALL CTT,
                HR_OPERATING_UNITS OU
          WHERE     LV.LOOKUP_TYPE = L_CTT_LOOKUP
                AND LV.MEANING = P_CUST_TRX_TYPE
                AND LV.DESCRIPTION = CTT.NAME
                AND LV.TAG = OU.NAME
                AND CTT.ORG_ID = OU.ORGANIZATION_ID;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Cust_Trx_Type Name info.';
            l_error_code := 'E';
      END;


      ----------------------------------------
      ----------validate batch source-----
      ----------------------------------------

      BEGIN
         SELECT BATCH_SOURCE_ID, GROUPING_RULE_ID
           INTO L_BATCH_SOURCE_ID, L_GROUPING_RULE_ID
           FROM RA_BATCH_SOURCES_ALL
          WHERE     UPPER (NAME) = UPPER (P_BATCH_SOURCE_NAME)
                AND ORG_ID = L_OPERATING_UNIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct batch source name info.';
            L_ERROR_CODE := 'E';
      END;


      ----------------------------------------
      -----------------po number--------------
      ----------------------------------------

      BEGIN
         SELECT NVL (PHA.SEGMENT1, NULL),
                NVL (PLA.UNIT_PRICE, 1),
                PHA.RATE,
                NVL (PHA.CURRENCY_CODE, NULL)
           INTO L_PO_NUMBER,
                L_UNIT_SELLING_PRICE,
                L_RATE,
                L_CURRENCY_CODE
           FROM PO_HEADERS_ALL PHA,
                APPS.PO_LINES_ALL PLA,
                PO_VENDORS PV,
                XXDBL_COMPANY_LE_MAPPING_V CL
          WHERE     pha.type_lookup_code IN ('BLANKET', 'STANDARD')
                AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
                AND pha.approved_flag = 'Y'
                AND NVL (pha.cancel_flag, 'N') = 'N'
                AND PHA.VENDOR_ID = pv.vendor_id(+)
                AND CL.ORG_ID = PHA.ORG_ID
                AND PLA.PO_HEADER_ID = PHA.PO_HEADER_ID
                AND PHA.SEGMENT1 = P_PO_NUMBER
                AND EXISTS
                       (SELECT 1
                          FROM APPS.MTL_SYSTEM_ITEMS_VL MSI
                         WHERE     MSI.INVENTORY_ITEM_ID = PLA.ITEM_ID
                               AND MSI.SEGMENT1 = P_ITEM_CODE)
                AND UPPER (CL.LEGAL_ENTITY_NAME) LIKE
                       RTRIM (UPPER (L_CUSTOMER_NAME), '.') || '%'
                AND EXISTS
                       (SELECT 1
                          FROM XX_DBL_PO_RECV_ADJUST X
                         WHERE X.PO_NO = PHA.SEGMENT1);
      EXCEPTION
         WHEN OTHERS
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct po number and item code in according customer.';
            L_ERROR_CODE := 'E';
      END;

      ----------------------------------------
      ----------validate Exchange Rate-----
      ----------------------------------------

      BEGIN
         SELECT CASE
                   WHEN NVL (p_currency_code, L_CURRENCY_CODE) = 'BDT'
                   THEN
                      NULL
                   ELSE
                      'User'
                END
           INTO l_exchange_rate_type
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct currency Code and Trx Date.';
            L_ERROR_CODE := 'E';
      END;

      ----------------------------------------
      ----------validate Exchange Date-----
      ----------------------------------------

      BEGIN
         SELECT CASE
                   WHEN NVL (p_currency_code, L_CURRENCY_CODE) = 'BDT'
                   THEN
                      NULL
                   ELSE
                      p_trx_date
                END
           INTO l_exchange_date
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct currency Code.';
            L_ERROR_CODE := 'E';
      END;

      ----------------------------------------
      ----------validate Exchange Rate-----
      ----------------------------------------

      BEGIN
         SELECT CASE
                   WHEN NVL (p_currency_code, L_CURRENCY_CODE) = 'BDT'
                   THEN
                      NULL
                   ELSE
                      NVL (p_exchange_rate, L_RATE)
                END
           INTO l_exchange_rate
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct currency Code.';
            L_ERROR_CODE := 'E';
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
         INSERT
           INTO xxdbl.xxdbl_ra_interface_upload_stg (SL_NO,
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
                                                     UNIT_NAME,
                                                     OPERATING_UNIT,
                                                     ORGANIZATION_ID,
                                                     SET_OF_BOOKS,
                                                     LEGAL_ENTITY_ID,
                                                     ITEM_ID,
                                                     UOM_CODE,
                                                     ITEM_DESCRIPTION,
                                                     AMOUNT,
                                                     CUSTOMER_ID,
                                                     BILL_TO_SITE_ID,
                                                     SHIP_TO_SITE_ID,
                                                     TERM_ID,
                                                     TERRITORY_ID,
                                                     T_SEGMENT1,
                                                     T_SEGMENT2,
                                                     T_SEGMENT3,
                                                     T_SEGMENT4,
                                                     GROUPING_RULE_ID,
                                                     BATCH_SOURCE_ID,
                                                     EXCHANGE_RATE_TYPE,
                                                     EXCHANGE_DATE,
                                                     EXCHANGE_RATE,
                                                     CODE_COMBINATION_ID,
                                                     PO_NUMBER,
                                                     PI_NUMBER,
                                                     CREATION_DATE,
                                                     CREATED_BY)
         VALUES (TRIM (P_SL_NO),
                 TRIM (P_TRX_TYPE),
                 TRIM (L_CUST_TRX_TYPE_ID),
                 TRIM (P_ORGANIZATION_CODE),
                 TRIM (P_BATCH_SOURCE_NAME),
                 TRIM (P_LINE_NUMBER),
                 TRIM (L_TRX_DATE),
                 TRIM (L_GL_DATE),
                 TRIM (NVL (P_CURRENCY_CODE, L_CURRENCY_CODE)),
                 TRIM (P_CUSTOMER_NUMBER),
                 TRIM (P_ITEM_CODE),
                 TRIM (P_QUANTITY),
                 TRIM (NVL (P_UNIT_SELLING_PRICE, L_UNIT_SELLING_PRICE)),
                 TRIM (L_UNIT_NAME),
                 TRIM (L_OPERATING_UNIT),
                 TRIM (L_ORGANIZATION_ID),
                 TRIM (L_SET_OF_BOOKS),
                 TRIM (L_LEGAL_ENTITY_ID),
                 TRIM (L_ITEM_ID),
                 TRIM (L_UOM_CODE),
                 TRIM (L_ITEM_DESCRIPTION),
                 TRIM (L_AMOUNT),
                 TRIM (L_CUSTOMER_ID),
                 TRIM (L_BILL_TO_SITE_ID),
                 TRIM (L_SHIP_TO_SITE_ID),
                 TRIM (L_PAYMENT_TERM_ID),
                 TRIM (L_TERRITORY_ID),
                 TRIM (L_T_SEGMENT1),
                 TRIM (L_T_SEGMENT2),
                 TRIM (L_T_SEGMENT3),
                 TRIM (L_T_SEGMENT4),
                 TRIM (L_BATCH_SOURCE_ID),
                 TRIM (L_GROUPING_RULE_ID),
                 TRIM (l_exchange_rate_type),
                 TRIM (l_exchange_date),
                 TRIM (NVL (l_exchange_rate, L_RATE)),
                 TRIM (L_CODE_COMBINATION_ID),
                 TRIM (L_PO_NUMBER),
                 TRIM (P_PI_NUMBER),
                 SYSDATE,
                 TRIM (p_user_id));

         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.put_line (
            FND_FILE.LOG,
            'Error while inserting records into stagein table' || SQLERRM);
   END upload_data_to_ar_int_stg;
END xxdbl_ar_interface_upload_pkg;
/