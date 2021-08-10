/* Formatted on 7/21/2020 11:53:09 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_AR_INVOICE_UPLD_ADI_PKG
IS
   FUNCTION CHECK_ERROR_LOG_TO_IMPORT_DATA
      RETURN NUMBER
   IS
      L_RETURN_STATUS          VARCHAR2 (1);
      L_MSG_COUNT              NUMBER;
      L_MSG_DATA               VARCHAR2 (2000);
      L_BATCH_ID               NUMBER;
      L_CNT                    NUMBER := 0;
      L_BATCH_SOURCE_REC       AR_INVOICE_API_PUB.BATCH_SOURCE_REC_TYPE;
      L_TRX_HEADER_TBL         AR_INVOICE_API_PUB.TRX_HEADER_TBL_TYPE;
      L_TRX_LINES_TBL          AR_INVOICE_API_PUB.TRX_LINE_TBL_TYPE;
      L_TRX_DIST_TBL           AR_INVOICE_API_PUB.TRX_DIST_TBL_TYPE;
      L_TRX_SALESCREDITS_TBL   AR_INVOICE_API_PUB.TRX_SALESCREDITS_TBL_TYPE;
      L_CUSTOMER_TRX_ID        NUMBER;
      L_LINE_NO                NUMBER := 0;
      V_TRX_HEADER_ID          NUMBER := 100;
      V_TRX_LINE_ID            NUMBER := 400;
      VL_RESPONSIBILITY_ID     NUMBER
         := CASE
               WHEN P_RESPONSIBILITY_ID IS NOT NULL THEN P_RESPONSIBILITY_ID
               ELSE '51915'
            END;
      VL_RESPAPPL_ID           NUMBER
         := CASE
               WHEN P_RESPAPPL_ID IS NOT NULL THEN P_RESPAPPL_ID
               ELSE '222'
            END;
      VL_USER_ID               NUMBER
         := CASE WHEN P_USER_ID IS NOT NULL THEN P_USER_ID ELSE '5958' END;
      VL_ORG_ID                NUMBER
         := CASE
               WHEN P_ORG_ID IS NULL OR P_ORG_ID = '-1' THEN '131'
               ELSE P_ORG_ID
            END;

      CURSOR CUR_STG
      IS
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
          WHERE FLAG IS NULL AND OPERATING_UNIT = VL_ORG_ID;

      CURSOR CUR_LINES (
         P_SL_NO    NUMBER)
      IS
         SELECT OPERATING_UNIT,
                --bh.bill_header_id invoice_id,
                --bl.bill_line_id line_id,
                --bld.bill_line_detail_id,
                TRX_DATE,
                GL_DATE,
                CURRENCY_CODE,
                EXCHANCE_RATE,
                'Bill Invoice' ATTRIBUTE_CATEGORY,
                --bh.bill_header_id attribute6,
                --bh.bill_header_id attribute10,
                'Sales of Yarn' COMMENTS,
                CUSTOMER_ID,
                ITEM_DESCRIPTION,
                UOM_CODE,
                QUANTITY,
                UNIT_SELLING_PRICE,
                AMOUNT,
                --bl.challan_number,
                CHALLAN_DATE,
                PI_NUMBER,
                PO_NUMBER,
                BILL_CATEGORY
           FROM APPS.XXDBL_AR_INVOICE_STG
          WHERE     FLAG IS NULL
                AND SL_NO = P_SL_NO
                AND OPERATING_UNIT = VL_ORG_ID;

      CURSOR LIST_ERRORS
      IS
         SELECT TRX_HEADER_ID,
                TRX_LINE_ID,
                TRX_SALESCREDIT_ID,
                TRX_DIST_ID,
                TRX_CONTINGENCY_ID,
                ERROR_MESSAGE,
                INVALID_VALUE
           FROM AR_TRX_ERRORS_GT;
   BEGIN
      FOR LN_CUR_STG IN CUR_STG
      LOOP
         BEGIN
            V_TRX_HEADER_ID := V_TRX_HEADER_ID + 1;

            L_RETURN_STATUS := NULL;
            L_CUSTOMER_TRX_ID := NULL;
            -- c. Set the applications context
            MO_GLOBAL.INIT ('AR');
            MO_GLOBAL.SET_POLICY_CONTEXT ('S', VL_ORG_ID);
            FND_GLOBAL.APPS_INITIALIZE (VL_USER_ID,
                                        VL_RESPONSIBILITY_ID,
                                        VL_RESPAPPL_ID,
                                        0);

            -- d. Populate batch source information.
            L_BATCH_SOURCE_REC.BATCH_SOURCE_ID := LN_CUR_STG.BATCH_SOURCE_ID;

            -- e. Populate header information.
            L_TRX_HEADER_TBL (1).TRX_HEADER_ID := V_TRX_HEADER_ID;
            L_TRX_HEADER_TBL (1).BILL_TO_CUSTOMER_ID := LN_CUR_STG.CUSTOMER_ID;
            L_TRX_HEADER_TBL (1).CUST_TRX_TYPE_ID :=
               LN_CUR_STG.CUST_TRX_TYPE_ID;

            ---
            L_TRX_HEADER_TBL (1).TERM_ID := LN_CUR_STG.TERM_ID;
            L_TRX_HEADER_TBL (1).FINANCE_CHARGES := 'N';
            L_TRX_HEADER_TBL (1).STATUS_TRX := 'OP';
            L_TRX_HEADER_TBL (1).PRINTING_OPTION := 'PRI';
            L_TRX_HEADER_TBL (1).COMMENTS := LN_CUR_STG.COMMENTS;
            L_TRX_HEADER_TBL (1).ATTRIBUTE_CATEGORY :=
               LN_CUR_STG.ATTRIBUTE_CATEGORY;
            --l_trx_header_tbl (1).attribute6 := ln_cur_stg.attribute6;
            --l_trx_header_tbl (1).attribute10 := ln_cur_stg.attribute10;
            L_TRX_HEADER_TBL (1).ORG_ID := LN_CUR_STG.OPERATING_UNIT;
            --
            --L_TRX_HEADER_TBL (1).INVOICING_RULE_ID := 1000;
            l_trx_header_tbl (1).trx_currency := LN_CUR_STG.CURRENCY_CODE;
            --l_trx_header_tbl (1).trx_currency :=NVL (LN_CUR_STG.CURRENCY_CODE, arp_global.functional_currency);
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'Currency of provided transaction: '
               || LN_CUR_STG.CURRENCY_CODE);

            L_TRX_HEADER_TBL (1).EXCHANGE_RATE_TYPE :=
               CASE
                  WHEN LN_CUR_STG.CURRENCY_CODE = 'BDT' THEN NULL
                  ELSE 'User'
               END;
            L_TRX_HEADER_TBL (1).EXCHANGE_DATE :=
               CASE
                  WHEN LN_CUR_STG.CURRENCY_CODE = 'BDT' THEN NULL
                  ELSE LN_CUR_STG.TRX_DATE
               END;
            L_TRX_HEADER_TBL (1).EXCHANGE_RATE :=
               CASE
                  WHEN LN_CUR_STG.CURRENCY_CODE = 'BDT' THEN NULL
                  ELSE LN_CUR_STG.EXCHANCE_RATE
               END;


            L_LINE_NO := 0;

            FOR LN_CUR_LINES IN CUR_LINES (LN_CUR_STG.SL_NO)
            LOOP
               L_LINE_NO := L_LINE_NO + 1;
               V_TRX_LINE_ID := V_TRX_LINE_ID + 1;

               -- f. Populate lines information for first invoice
               L_TRX_LINES_TBL (L_LINE_NO).TRX_HEADER_ID := V_TRX_HEADER_ID;
               L_TRX_LINES_TBL (L_LINE_NO).TRX_LINE_ID := V_TRX_LINE_ID;
               L_TRX_LINES_TBL (L_LINE_NO).LINE_NUMBER := L_LINE_NO;
               L_TRX_LINES_TBL (L_LINE_NO).DESCRIPTION :=
                  LN_CUR_LINES.ITEM_DESCRIPTION;
               L_TRX_LINES_TBL (L_LINE_NO).QUANTITY_INVOICED :=
                  LN_CUR_LINES.QUANTITY;
               L_TRX_LINES_TBL (L_LINE_NO).UNIT_SELLING_PRICE :=
                  LN_CUR_LINES.UNIT_SELLING_PRICE;
               L_TRX_LINES_TBL (L_LINE_NO).LINE_TYPE := 'LINE';

               --
               --l_trx_lines_tbl (i).trx_header_id := rec.invoice_id;
               --l_trx_lines_tbl (i).trx_line_id := rec.bill_line_detail_id;
               L_TRX_LINES_TBL (L_LINE_NO).INTERFACE_LINE_CONTEXT :=
                  'DBL_IC_INVOICE';
               --l_trx_lines_tbl (i).interface_line_attribute1 :=rec.challan_number;
               L_TRX_LINES_TBL (L_LINE_NO).INTERFACE_LINE_ATTRIBUTE2 :=
                  LN_CUR_LINES.CHALLAN_DATE;
               L_TRX_LINES_TBL (L_LINE_NO).INTERFACE_LINE_ATTRIBUTE3 :=
                  LN_CUR_LINES.PI_NUMBER;
               L_TRX_LINES_TBL (L_LINE_NO).INTERFACE_LINE_ATTRIBUTE4 :=
                  LN_CUR_LINES.PO_NUMBER;
            --l_trx_lines_tbl (i).interface_line_attribute5 :=rec.bill_line_detail_id;
            --
            --L_TRX_LINES_TBL (L_LINE_NO).INVOICING_RULE_ID := '1000';
            END LOOP;



            -- j. Call the invoice api to create the invoice
            AR_INVOICE_API_PUB.CREATE_SINGLE_INVOICE (
               P_API_VERSION            => 1.0,
               P_BATCH_SOURCE_REC       => L_BATCH_SOURCE_REC,
               P_TRX_HEADER_TBL         => L_TRX_HEADER_TBL,
               P_TRX_LINES_TBL          => L_TRX_LINES_TBL,
               P_TRX_DIST_TBL           => L_TRX_DIST_TBL,
               P_TRX_SALESCREDITS_TBL   => L_TRX_SALESCREDITS_TBL,
               X_CUSTOMER_TRX_ID        => L_CUSTOMER_TRX_ID,
               P_COMMIT                 => FND_API.G_TRUE,
               X_RETURN_STATUS          => L_RETURN_STATUS,
               X_MSG_COUNT              => L_MSG_COUNT,
               X_MSG_DATA               => L_MSG_DATA);

            -- j. Check for errors
            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
               DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
            ELSE
               SELECT COUNT (*) INTO L_CNT FROM AR_TRX_ERRORS_GT;

               IF L_CNT = 0
               THEN
                  UPDATE APPS.XXDBL_AR_INVOICE_STG
                     SET FLAG = 'Y'
                   WHERE FLAG IS NULL AND SL_NO = LN_CUR_STG.SL_NO;

                  DBMS_OUTPUT.PUT_LINE (
                        'SUCCESS: Created customer_trx_id = '
                     || L_CUSTOMER_TRX_ID);
               ELSE
                  -- k. List errors
                  DBMS_OUTPUT.PUT_LINE (
                     'FAILURE: Errors encountered, see list below:');

                  FOR I IN LIST_ERRORS
                  LOOP
                     DBMS_OUTPUT.PUT_LINE (
                        '----------------------------------------------------');
                     DBMS_OUTPUT.PUT_LINE (
                        'Header ID       = ' || TO_CHAR (I.TRX_HEADER_ID));
                     DBMS_OUTPUT.PUT_LINE (
                        'Line ID         = ' || TO_CHAR (I.TRX_LINE_ID));
                     DBMS_OUTPUT.PUT_LINE (
                           'Sales Credit ID = '
                        || TO_CHAR (I.TRX_SALESCREDIT_ID));
                     DBMS_OUTPUT.PUT_LINE (
                        'Dist Id         = ' || TO_CHAR (I.TRX_DIST_ID));
                     DBMS_OUTPUT.PUT_LINE (
                           'Contingency ID  = '
                        || TO_CHAR (I.TRX_CONTINGENCY_ID));
                     DBMS_OUTPUT.PUT_LINE (
                           'Message         = '
                        || SUBSTR (I.ERROR_MESSAGE, 1, 80));
                     DBMS_OUTPUT.PUT_LINE (
                           'Invalid Value   = '
                        || SUBSTR (I.INVALID_VALUE, 1, 80));
                     DBMS_OUTPUT.PUT_LINE (
                        '----------------------------------------------------');
                  END LOOP;
               END IF;
            END IF;
         END;
      END LOOP;

      XX_COM_PKG.WRITELOG (
            CHR (10)
         || '+----------------------------Information Log---------------------------------+'
         || CHR (10));
      XX_COM_PKG.WRITELOG (
         'Responsibility ID: ' || VL_RESPONSIBILITY_ID || CHR (10));
      XX_COM_PKG.WRITELOG (
         'Responsibility Application ID: ' || VL_RESPAPPL_ID || CHR (10));
      XX_COM_PKG.WRITELOG ('User ID: ' || VL_USER_ID || CHR (10));
      XX_COM_PKG.WRITELOG ('Operating Unit: ' || VL_ORG_ID || CHR (10));

      RETURN 0;
   END;

   PROCEDURE IMPORT_DATA_TO_AR_CUST_TRX (ERRBUF    OUT VARCHAR2,
                                         RETCODE   OUT VARCHAR2)
   IS
      L_RETCODE     NUMBER;
      CONC_STATUS   BOOLEAN;
      L_ERROR       VARCHAR2 (100);
   BEGIN
      FND_FILE.PUT_LINE (FND_FILE.LOG, 'Parameter received');


      L_RETCODE := CHECK_ERROR_LOG_TO_IMPORT_DATA;

      IF L_RETCODE = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Status :' || L_RETCODE);
      ELSIF L_RETCODE = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_RETCODE = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         L_ERROR := 'error while executing the procedure ' || SQLERRM;
         ERRBUF := L_ERROR;
         RETCODE := 1;
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Status :' || L_RETCODE);
   END IMPORT_DATA_TO_AR_CUST_TRX;



   PROCEDURE AR_CUST_TRX_STG_UPLOAD (P_SL_NO                 NUMBER,
                                     P_LINE_NUMBER           NUMBER,
                                     P_BILL_DATE             DATE,
                                     P_CURRENCY_CODE         VARCHAR2,
                                     P_CUSTOMER_NUMBER       VARCHAR2,
                                     P_CUSTOMER_NAME         VARCHAR2,
                                     P_ITEM_CODE             VARCHAR2,
                                     P_QUANTITY              NUMBER,
                                     P_UNIT_SELLING_PRICE    NUMBER,
                                     P_BILL_CATEGORY         VARCHAR2,
                                     P_CHALLAN_DATE          DATE,
                                     P_PO_NUMBER             VARCHAR2,
                                     P_PI_NUMBER             VARCHAR2,
                                     P_EXCHANCE_RATE         NUMBER)
   IS
      --------------------------------------------
      --Custom Parameter

      P_ORGANIZATION_CODE    VARCHAR2 (10 BYTE) := '101';
      P_BATCH_SOURCE_NAME    VARCHAR2 (500 BYTE) := 'DBL Export Sales';
      P_TRX_TYPE             VARCHAR2 (500 BYTE) := 'Invoice';
      L_CTT_LOOKUP           VARCHAR2 (100) := 'DBL_BILL_CATEGORY';

      --------------------------------------------
      --ORG Parameter

      L_OPERATING_UNIT       NUMBER;
      L_ORGANIZATION_ID      NUMBER;
      L_SET_OF_BOOKS         NUMBER;
      L_LEGAL_ENTITY_ID      NUMBER;


      --------------------------------------------
      --Customer Parameter

      L_CUSTOMER_ID          NUMBER;
      L_CUSTOMER_NAME        VARCHAR2 (240);
      L_BILL_TO_SITE_ID      NUMBER;
      L_SHIP_TO_SITE_ID      NUMBER;
      L_PAYMENT_TERM_ID      NUMBER;
      L_TERRITORY_ID         NUMBER;
      L_T_SEGMENT1           VARCHAR2 (500);
      L_T_SEGMENT2           VARCHAR2 (500);
      L_T_SEGMENT3           VARCHAR2 (500);
      L_T_SEGMENT4           VARCHAR2 (500);

      --------------------------------------------

      L_ITEM_ID              NUMBER;
      L_UOM_CODE             VARCHAR2 (10);
      L_ITEM_DESCRIPTION     VARCHAR2 (500);

      --------------------------------------------

      L_AMOUNT               FLOAT;

      --------------------------------------------

      L_CUST_TRX_TYPE_ID     NUMBER;
      L_CUST_TRX_TYPE_NAME   VARCHAR2 (500);

      --------------------------------------------

      --L_CHART_OF_ACT_ID           NUMBER;

      --------------------------------------------

      L_BATCH_SOURCE_ID      NUMBER;

      --------------------------------------------

      L_TRX_DATE             DATE := NVL (P_BILL_DATE, SYSDATE);
      L_GL_DATE              DATE := NVL (P_BILL_DATE, SYSDATE);

      --------------------------------------------

      L_ERROR_MESSAGE        VARCHAR2 (3000);
      L_ERROR_CODE           VARCHAR2 (3000);

      --------------------------------------------

      L_PO_NUMBER            VARCHAR2 (50);
      L_UNIT_SELLING_PRICE   NUMBER;
      L_CURRENCY_CODE        VARCHAR2 (3);
   --------------------------------------------
   BEGIN
      -----------------------------------------------------
      ----------validate organization code-----------------
      -----------------------------------------------------
      --dbms_output.put_line (p_organization_code);

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
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct organization code';
            L_ERROR_CODE := 'E';
      END;



      --------------------------------------------------
      ----------select customer bill to info------------
      --------------------------------------------------

      BEGIN
         SELECT HCA.ACCOUNT_NAME,
                HCA.CUST_ACCOUNT_ID,
                HCAS.CUST_ACCT_SITE_ID,
                HCSU.PAYMENT_TERM_ID
           INTO L_CUSTOMER_NAME,
                L_CUSTOMER_ID,
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
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct customer number';
            L_ERROR_CODE := 'E';
      END;



      --------------------------------------------------
      ----------select customer ship to info------------
      --------------------------------------------------


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
                RA_TERRITORIES TER
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
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct customer ship to address.';
            L_ERROR_CODE := 'E';
      END;



      ----------------------------------------
      ----------validate item info------------
      ----------------------------------------


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
            L_ERROR_MESSAGE :=
               L_ERROR_MESSAGE || ',' || 'please enter correct item info.';
            L_ERROR_CODE := 'E';
      END;



      ----------------------------------------
      ----------validate cust_trx_type_id-----
      ----------------------------------------

      BEGIN
         SELECT CTT.CUST_TRX_TYPE_ID, CTT.NAME
           INTO L_CUST_TRX_TYPE_ID, L_CUST_TRX_TYPE_NAME
           FROM FND_LOOKUP_VALUES_VL LV,
                RA_CUST_TRX_TYPES_ALL CTT,
                HR_OPERATING_UNITS OU
          WHERE     LV.LOOKUP_TYPE = L_CTT_LOOKUP
                AND LV.MEANING = P_BILL_CATEGORY
                AND LV.DESCRIPTION = CTT.NAME
                AND LV.TAG = OU.NAME
                AND CTT.ORG_ID = OU.ORGANIZATION_ID;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct cust_trx_type name info.';
            L_ERROR_CODE := 'E';
      END;


      ----------------------------------------
      ----------validate batch source-----
      ----------------------------------------

      BEGIN
         SELECT BATCH_SOURCE_ID
           INTO L_BATCH_SOURCE_ID
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
                PHA.CURRENCY_CODE
           INTO L_PO_NUMBER, L_UNIT_SELLING_PRICE, L_CURRENCY_CODE
           FROM PO_HEADERS_ALL PHA,
                APPS.PO_LINES_ALL PLA,
                PO_VENDORS PV,
                XXDBL_COMPANY_LE_MAPPING_V CL
          WHERE     pha.type_lookup_code IN ('BLANKET', 'STANDARD')
                AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
                AND pha.approved_flag = 'Y'
                AND NVL (pha.cancel_flag, 'N') = 'N'
                AND PHA.VENDOR_ID = PV.VENDOR_ID(+)
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
      ----------count total quantity----------
      ----------------------------------------



      BEGIN
         SELECT (  P_QUANTITY
                 * NVL (L_UNIT_SELLING_PRICE, P_UNIT_SELLING_PRICE))
           INTO L_AMOUNT
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'please enter correct quantity and unit selling price info.';
            L_ERROR_CODE := 'E';
      END;


      --------------------------------------------------------------------------------------------------------------
      --------condition to show error if any of the above validation picks up a data entry error--------------------
      --------condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF L_ERROR_CODE = 'E'
      THEN
         RAISE_APPLICATION_ERROR (-20101, L_ERROR_MESSAGE);
      ELSIF NVL (L_ERROR_CODE, 'A') <> 'E'
      THEN
         INSERT INTO APPS.XXDBL_AR_INVOICE_STG (SL_NO,
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
                                                ITEM_DESCRIPTION,
                                                BILL_CATEGORY,
                                                CHALLAN_DATE,
                                                PO_NUMBER,
                                                PI_NUMBER,
                                                EXCHANCE_RATE)
                 VALUES (
                           TRIM (P_SL_NO),
                           TRIM (P_TRX_TYPE),
                           TRIM (L_CUST_TRX_TYPE_ID),
                           TRIM (P_ORGANIZATION_CODE),
                           TRIM (P_BATCH_SOURCE_NAME),
                           TRIM (L_BATCH_SOURCE_ID),
                           TRIM (P_LINE_NUMBER),
                           TRIM (L_TRX_DATE),
                           TRIM (L_GL_DATE),
                           TRIM (NVL (L_CURRENCY_CODE, P_CURRENCY_CODE)),
                           TRIM (P_CUSTOMER_NUMBER),
                           TRIM (P_ITEM_CODE),
                           TRIM (P_QUANTITY),
                           TRIM (
                              NVL (L_UNIT_SELLING_PRICE,
                                   P_UNIT_SELLING_PRICE)),
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
                           TRIM (L_ITEM_DESCRIPTION),
                           TRIM (P_BILL_CATEGORY),
                           TRIM (P_CHALLAN_DATE),
                           TRIM (L_PO_NUMBER),
                           TRIM (P_PI_NUMBER),
                           TRIM (NVL (P_EXCHANCE_RATE, 1)));
      END IF;

      COMMIT;
   END AR_CUST_TRX_STG_UPLOAD;
END XXDBL_AR_INVOICE_UPLD_ADI_PKG;
/