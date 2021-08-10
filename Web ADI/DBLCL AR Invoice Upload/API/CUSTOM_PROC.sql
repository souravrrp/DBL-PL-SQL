/* Formatted on 4/25/2021 12:44:43 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_cer_ar_inv_upld_pkg
IS
   PROCEDURE import_data_to_ar_invoice
   IS
      v_trx_header_id          NUMBER;
      v_trx_line_id            NUMBER;

      CURSOR mcur
      IS
         SELECT *
           FROM apps.xxdbl_cer_ar_inv_upld_stg
          WHERE FLAG IS NULL;

      l_return_status          VARCHAR2 (1000);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
      l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
      l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
      l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
      l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
      l_cust_trx_id            NUMBER;
   BEGIN
      FOR mrec IN mcur
      LOOP
         BEGIN
            SELECT ctt.cust_trx_type_id
              INTO l_cust_trx_id
              FROM ra_cust_trx_types_all ctt
             WHERE ctt.NAME = mrec.TRX_TYPE;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.PUT_LINE ('');
         END;

         v_trx_header_id := RA_CUSTOMER_TRX_S.NEXTVAL;

         -- Populate header information.
         l_trx_header_tbl (1).trx_header_id := v_trx_header_id;

         l_trx_header_tbl (1).trx_date := mrec.trx_date;
         l_trx_header_tbl (1).gl_date := mrec.gl_date;
         l_trx_header_tbl (1).sold_to_customer_id := mrec.CUSTOMER_ID;
         l_trx_header_tbl (1).bill_to_customer_id := mrec.CUSTOMER_ID;
         l_trx_header_tbl (1).BILL_TO_SITE_USE_ID := mrec.BILL_TO_SITE_ID;
         l_trx_header_tbl (1).cust_trx_type_id := mrec.CUST_TRX_TYPE_ID;
         l_trx_header_tbl (1).primary_salesrep_id := mrec.SALESREP_ID;
         l_trx_header_tbl (1).printing_option := 'PRI';

         DBMS_OUTPUT.PUT_LINE (mrec.CUSTOMER_ID);

         -- Populate batch source information.
         l_batch_source_rec.batch_source_id := mrec.BATCH_SOURCE_ID;

         -- Populate line 1 information.
         v_trx_line_id := RA_CUSTOMER_TRX_LINES_S.NEXTVAL;

         l_trx_lines_tbl (1).trx_header_id := v_trx_header_id;
         l_trx_lines_tbl (1).trx_line_id := v_trx_line_id;
         l_trx_lines_tbl (1).line_number := mrec.LINE_NUMBER;
         l_trx_lines_tbl (1).INVENTORY_ITEM_ID := mrec.ITEM_ID;
         l_trx_lines_tbl (1).DESCRIPTION := mrec.ITEM_DESCRIPTION;
         l_trx_lines_tbl (1).QUANTITY_INVOICED := mrec.QUANTITY;
         l_trx_lines_tbl (1).UNIT_SELLING_PRICE := mrec.UNIT_SELLING_PRICE;
         l_trx_lines_tbl (1).SALES_ORDER := mrec.SALES_ORDER;
         l_trx_lines_tbl (1).UOM_CODE := mrec.UOM_CODE;
         l_trx_lines_tbl (1).WAREHOUSE_ID := mrec.ORGANIZATION_ID;
         l_trx_lines_tbl (1).line_type := 'LINE';

         -- Populate Distribution Information
         --l_trx_dist_tbl (1).trx_dist_id :=XX_COM_PKG.GET_SEQUENCE_VALUE ('RA_CUST_TRX_LINE_GL_DIST_ALL','CUST_TRX_LINE_GL_DIST_ID');
         l_trx_dist_tbl (1).trx_header_id := v_trx_header_id;
         l_trx_dist_tbl (1).trx_LINE_ID := v_trx_line_id;
         l_trx_dist_tbl (1).ACCOUNT_CLASS := 'REV';
         l_trx_dist_tbl (1).AMOUNT := mrec.AMOUNT;

         ar_invoice_api_pub.create_single_invoice (
            p_api_version            => 1.0,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_customer_trx_id        => l_cust_trx_id,
            p_commit                 => fnd_api.g_true,
            p_batch_source_rec       => l_batch_source_rec,
            p_trx_header_tbl         => l_trx_header_tbl,
            p_trx_lines_tbl          => l_trx_lines_tbl,
            p_trx_dist_tbl           => l_trx_dist_tbl,
            p_trx_salescredits_tbl   => l_trx_salescredits_tbl);

         UPDATE apps.xxdbl_cer_ar_inv_upld_stg
            SET FLAG = 'Y'
          WHERE     FLAG IS NULL
                AND SL_NO = mrec.SL_NO
                AND LINE_NUMBER = mrec.LINE_NUMBER;
      END LOOP;
   END import_data_to_ar_invoice;

   PROCEDURE import_data_to_ar_cust_trx (ERRBUF    OUT VARCHAR2,
                                         RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      --L_Retcode := check_error_log_to_import_data;

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
   END import_data_to_ar_cust_trx;



   PROCEDURE ar_cust_trx_stg_upload (P_SL_NO                 NUMBER,
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
                                     P_UNIT_SELLING_PRICE    NUMBER,
                                     P_LINE_DESCRIPTION      VARCHAR2)
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
      L_ITEM_DESCRIPTION   VARCHAR2 (500);

      --------------------------------------------

      L_AMOUNT             FLOAT;

      --------------------------------------------

      L_CUST_TRX_TYPE_ID   NUMBER;

      --------------------------------------------

      --L_CHART_OF_ACT_ID           NUMBER;

      --------------------------------------------

      l_batch_source_id    NUMBER;

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


      ----------------------------------------
      ----------VALIDATE Batch Source-----
      ----------------------------------------

      BEGIN
         SELECT batch_source_id
           INTO l_batch_source_id
           FROM ra_batch_sources_all
          WHERE     UPPER (NAME) = UPPER (P_BATCH_SOURCE_NAME)
                AND ORG_ID = L_OPERATING_UNIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Batch Source Name info.';
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
         INSERT INTO apps.xxdbl_cer_ar_inv_upld_stg (SL_NO,
                                                     TRX_TYPE,
                                                     CUST_TRX_TYPE_ID,
                                                     ORGANIZATION_CODE,
                                                     BATCH_SOURCE_NAME,
                                                     BATCH_SOURCE_ID,
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
                                                     T_SEGMENT4,
                                                     LINE_DESCRIPTION,
                                                     ITEM_DESCRIPTION)
              VALUES (TRIM (P_SL_NO),
                      TRIM (P_TRX_TYPE),
                      TRIM (L_CUST_TRX_TYPE_ID),
                      TRIM (P_ORGANIZATION_CODE),
                      TRIM (P_BATCH_SOURCE_NAME),
                      TRIM (l_batch_source_id),
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
                      TRIM (L_T_SEGMENT4),
                      TRIM (P_LINE_DESCRIPTION),
                      TRIM (l_item_description));
      END IF;

      COMMIT;
   END ar_cust_trx_stg_upload;
END xxdbl_cer_ar_inv_upld_pkg;
/