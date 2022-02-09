/* Formatted on 2/8/2022 4:30:36 PM (QP5 v5.374) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_cer_ar_intrf_pkg
IS
    FUNCTION check_error_log_to_import_data
        RETURN NUMBER
    IS
        L_RETURN_STATUS   VARCHAR2 (1);

        CURSOR cur_stg IS
            SELECT *
              FROM xxdbl.xxdbl_cer_ar_intrf_stg
             WHERE FLAG IS NULL;
    BEGIN
        FOR ln_cur_stg IN cur_stg
        LOOP
            BEGIN
                INSERT INTO ra_interface_lines_all (
                                interface_line_id,
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
                                conversion_date,
                                --interface_line_context,
                                --interface_line_attribute1,
                                --interface_line_attribute2,
                                --interface_line_attribute3,
                                --interface_line_attribute4,
                                --interface_line_attribute5,
                                org_id,
                                set_of_books_id,
                                warehouse_id,
                                fob_point,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login,
                                taxable_flag,
                                amount_includes_tax_flag,
                                territory_id,
                                territory_segment1,
                                territory_segment2,
                                territory_segment3,
                                territory_segment4,
                                --invoicing_rule_id,
                                --accounting_rule_id,
                                --accounting_rule_duration
                                primary_salesrep_id)
                     VALUES (ra_customer_trx_lines_s.NEXTVAL, --> interface_line_id,
                             ln_cur_stg.BATCH_SOURCE_NAME, --> batch_source_name,
                             ln_cur_stg.LINE_NUMBER,          --> line_number,
                             'LINE',                            --> line_type,
                             ln_cur_stg.TRX_TYPE,      --> cust_trx_type_name,
                             ln_cur_stg.CUST_TRX_TYPE_ID, --> cust_trx_type_id,
                             ln_cur_stg.TRX_DATE,                --> trx_date,
                             ln_cur_stg.GL_DATE,                  --> gl_date,
                             ln_cur_stg.CURRENCY_CODE,      --> currency_code,
                             ln_cur_stg.TERM_ID,                  --> term_id,
                             ln_cur_stg.CUSTOMER_ID, --> orig_system_bill_customer_id,
                             ln_cur_stg.CUSTOMER_ID, --> orig_system_bill_customer_ref,
                             ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_id,
                             ln_cur_stg.BILL_TO_SITE_ID, --> orig_system_bill_address_ref,
                             ln_cur_stg.CUSTOMER_ID, --> orig_system_ship_customer_id,
                             ln_cur_stg.SHIP_TO_SITE_ID, --> orig_system_ship_address_id,
                             ln_cur_stg.CUSTOMER_ID, --> orig_system_sold_customer_id,
                             -- 66500,                          --> sales_order,
                             ln_cur_stg.ITEM_ID,        --> inventory_item_id,
                             ln_cur_stg.UOM_CODE,                --> uom_code,
                             ln_cur_stg.QUANTITY,                --> quantity,
                             ln_cur_stg.UNIT_SELLING_PRICE, --> unit_selling_price,
                             ln_cur_stg.AMOUNT,                    --> amount,
                             ln_cur_stg.DESCRIPTION, --'Custom Interface Upload Invoice', --> description,
                             ln_cur_stg.EXCHANGE_RATE_TYPE, --> conversion_type,
                             ln_cur_stg.EXCHANGE_RATE,    --> conversion_rate,
                             ln_cur_stg.EXCHANGE_DATE,    --> conversion_date,
                             --'DBL_IC_INVOICE',     --> interface_line_context,
                             --'XXDBLCL2',        --> interface_line_attribute1,
                             --ln_cur_stg.TRX_DATE, --> interface_line_attribute2,
                             --'XXDBLCL3',        --> interface_line_attribute3,
                             --'XXDBLCL4',        --> interface_line_attribute4,
                             --'XXDBLCL5',        --> interface_line_attribute5,
                             ln_cur_stg.OPERATING_UNIT,            --> org_id,
                             ln_cur_stg.SET_OF_BOOKS,     --> set_of_books_id,
                             ln_cur_stg.ORGANIZATION_ID,  --> organization_id,
                             NULL,                              --> fob_point,
                             SYSDATE,                    --> last_update_date,
                             p_user_id, --fnd_global.user_id, --> last_updated_by,
                             SYSDATE,                       --> creation_date,
                             p_user_id,                        --> created_by,
                             p_login_id,                  -->last_update_login
                             'Y',                            --> taxable_flag,
                             'N',                --> amount_includes_tax_flag,
                             ln_cur_stg.territory_id,          -->territory_id
                             ln_cur_stg.t_segment1,      -->territory_segment1
                             ln_cur_stg.t_segment2,      -->territory_segment2
                             ln_cur_stg.t_segment3,      -->territory_segment3
                             ln_cur_stg.t_segment4,      -->territory_segment3
                             --2,                                  --> invoicing_rule_id,
                             --1,                                 --> accounting_rule_id,
                             --NULL                          --> accounting_rule_duration
                             ln_cur_stg.salesrep_id     -->primary_salesrep_id
                                                   );

                COMMIT;

                INSERT INTO ra_interface_distributions_all (
                                interface_distribution_id,
                                interface_line_id,
                                account_class,
                                amount,
                                code_combination_id,
                                PERCENT,
                                --interface_line_context,
                                --interface_line_attribute1,
                                --interface_line_attribute2,
                                --interface_line_attribute3,
                                --interface_line_attribute4,
                                --interface_line_attribute5,
                                org_id,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login)
                     VALUES (ra_cust_trx_line_gl_dist_s.NEXTVAL, --interface_distribution_id
                             ra_customer_trx_lines_s.CURRVAL, --> interface_line_id
                             'REV',                           -->account_class
                             ln_cur_stg.AMOUNT,                      -->amount
                             ln_cur_stg.CODE_COMBINATION_ID, -->code_combination_id
                             100,                                   -->PERCENT
                             --'DBL_IC_INVOICE',       -->interface_line_context
                             --'XXDBLCL2',        --> interface_line_attribute1,
                             --ln_cur_stg.TRX_DATE, --> interface_line_attribute2,
                             --'XXDBLCL3',        --> interface_line_attribute3,
                             --'XXDBLCL4',        --> interface_line_attribute4,
                             --'XXDBLCL5',        --> interface_line_attribute5,
                             ln_cur_stg.OPERATING_UNIT,              -->org_id
                             SYSDATE,                      -->last_update_date
                             p_user_id,                     -->last_updated_by
                             SYSDATE,                         -->creation_date
                             p_user_id,                          -->created_by
                             p_login_id                   -->last_update_login
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
                    UPDATE apps.xxdbl_cer_ar_intrf_stg
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
                           'Error while inserting records in lines table'
                        || SQLERRM);
            END;
        END LOOP;

        RETURN 0;
    END;

    PROCEDURE import_data_to_ar_interface (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2)
    IS
        L_Retcode              NUMBER;
        CONC_STATUS            BOOLEAN;
        l_error                VARCHAR2 (100);

        v_batch_source_id      NUMBER;
        v_batch_source_name    VARCHAR2 (500 BYTE);

        ln_req_id              NUMBER;
        lv_req_phase           VARCHAR2 (240);
        lv_req_status          VARCHAR2 (240);
        lv_req_dev_phase       VARCHAR2 (240);
        lv_req_dev_status      VARCHAR2 (240);
        lv_req_message         VARCHAR2 (240);
        lv_req_return_status   BOOLEAN;
    BEGIN
        fnd_file.put_line (fnd_file.LOG, 'Parameter received');

        SELECT rbsa.batch_source_id, rbsa.name
          INTO v_batch_source_id, v_batch_source_name
          FROM apps.ra_batch_sources_all rbsa
         WHERE rbsa.name = 'DBLCL - Manual';


        BEGIN
            fnd_file.put_line (
                fnd_file.output,
                '*** Call The Auto Invoice Master Program  ***');
            FND_GLOBAL.APPS_INITIALIZE (2734, 51456, 222);
            MO_GLOBAL.SET_POLICY_CONTEXT ('S', '126');
            FND_GLOBAL.SET_NLS_CONTEXT ('AMERICAN');
            MO_GLOBAL.INIT ('AR');
            ln_req_id :=
                fnd_request.submit_request (
                    'AR',
                    'RAXMTR',
                    NULL,
                    TO_CHAR (TRUNC (SYSDATE), 'YYYY/MM/DD HH24:MI:SS'),
                    FALSE,
                    '1',
                    -99,
                    v_batch_source_id,
                    v_batch_source_name,
                    TO_CHAR (TRUNC (SYSDATE), 'YYYY/MM/DD HH24:MI:SS'),
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    'Y',
                    NULL);
            COMMIT;

            IF ln_req_id = 0
            THEN
                fnd_file.put_line (
                    fnd_file.LOG,
                       'Request Not Submitted due to "'
                    || fnd_message.get
                    || '".');
            ELSE
                fnd_file.put_line (
                    fnd_file.LOG,
                       'The Item Import Program submitted - Request id :'
                    || ln_req_id);
            END IF;

            IF ln_req_id > 0
            THEN
                LOOP
                    lv_req_return_status :=
                        fnd_concurrent.wait_for_request (ln_req_id,
                                                         60,
                                                         0,
                                                         lv_req_phase,
                                                         lv_req_status,
                                                         lv_req_dev_phase,
                                                         lv_req_dev_status,
                                                         lv_req_message);
                    EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                              OR UPPER (lv_req_status) IN
                                     ('CANCELLED', 'ERROR', 'TERMINATED');
                END LOOP;

                DBMS_OUTPUT.PUT_LINE (
                    'Request Phase  : ' || lv_req_dev_phase);
                DBMS_OUTPUT.PUT_LINE (
                    'Request Status : ' || lv_req_dev_status);
                DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
                Fnd_File.PUT_LINE (
                    Fnd_File.LOG,
                       'The Item Import Program Completion Phase: '
                    || lv_req_dev_phase);
                Fnd_File.PUT_LINE (
                    Fnd_File.LOG,
                       'The Item Import Program Completion Status: '
                    || lv_req_dev_status);

                CASE
                    WHEN     UPPER (lv_req_phase) = 'COMPLETED'
                         AND UPPER (lv_req_status) = 'ERROR'
                    THEN
                        fnd_file.put_line (
                            fnd_file.LOG,
                            'The Item Import prog completed in error. See log for request id');
                        fnd_file.put_line (fnd_file.LOG, SQLERRM);
                    WHEN    (    UPPER (lv_req_phase) = 'COMPLETED'
                             AND UPPER (lv_req_status) = 'NORMAL')
                         OR (    UPPER (lv_req_phase) = 'COMPLETED'
                             AND UPPER (lv_req_status) = 'WARNING')
                    THEN
                        BEGIN
                            --L_Retcode := check_error_log_to_assign_data;
                            Fnd_File.PUT_LINE (
                                Fnd_File.LOG,
                                   'The Item successfully Assigned to the respected Organization for request id: '
                                || ln_req_id);
                        END;

                        Fnd_File.PUT_LINE (
                            Fnd_File.LOG,
                               'The Item Import successfully completed for request id: '
                            || ln_req_id);
                    ELSE
                        Fnd_File.PUT_LINE (
                            Fnd_File.LOG,
                            'The Item Import request failed.Review log for Oracle request id ');
                        Fnd_File.PUT_LINE (Fnd_File.LOG, SQLERRM);
                END CASE;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                fnd_file.put_line (
                    fnd_file.LOG,
                       'OTHERS exception while submitting The Item  Import Program: '
                    || SQLERRM);
        END;

        --L_Retcode := check_error_log_to_assign_data;



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

    PROCEDURE upload_data_to_ar_int_stg (P_SL_NO                NUMBER,
                                         P_BATCH_SOURCE_NAME    VARCHAR2,
                                         P_TRX_TYPE             VARCHAR2,
                                         P_CUST_TRX_TYPE        VARCHAR2,
                                         P_LINE_NUMBER          NUMBER,
                                         P_TRX_DATE             DATE,
                                         P_GL_DATE              DATE,
                                         P_CURRENCY_CODE        VARCHAR2,
                                         P_CUSTOMER_NUMBER      VARCHAR2,
                                         P_QUANTITY             NUMBER,
                                         P_UNIT_SELLING_PRICE   NUMBER,
                                         P_DESCRIPTION          VARCHAR2,
                                         P_GL_CODE              VARCHAR2)
    IS
        --------------------------------------------

        P_ORGANIZATION_CODE     VARCHAR2 (3) := TO_CHAR ('251');
        P_ITEM_CODE             VARCHAR2 (20) := NULL;
        P_EXCHANGE_RATE_TYPE    VARCHAR2 (30) := NULL;
        P_EXCHANGE_RATE         NUMBER := NULL;


        --ORG Parameter

        L_OPERATING_UNIT        NUMBER;
        L_ORGANIZATION_ID       NUMBER;
        L_ORGANIZATION_CODE     VARCHAR2 (3);
        L_SET_OF_BOOKS          NUMBER;
        L_LEGAL_ENTITY_ID       NUMBER;


        --------------------------------------------
        --Customer Parameter

        L_CUSTOMER_ID           NUMBER;
        L_BILL_TO_SITE_ID       NUMBER;
        L_SHIP_TO_SITE_ID       NUMBER;
        L_PAYMENT_TERM_ID       NUMBER;
        L_TERRITORY_ID          NUMBER;
        L_T_SEGMENT1            VARCHAR2 (500);
        L_T_SEGMENT2            VARCHAR2 (500);
        L_T_SEGMENT3            VARCHAR2 (500);
        L_T_SEGMENT4            VARCHAR2 (500);
        L_SALESREP_ID           NUMBER;

        --------------------------------------------

        L_ITEM_ID               NUMBER;
        L_UOM_CODE              VARCHAR2 (10);

        --------------------------------------------

        L_AMOUNT                FLOAT;

        --------------------------------------------

        L_BATCH_SOURCE_NAME     VARCHAR2 (500); --:= 'DBL CL Imported Invoice';
        L_CUST_TRX_TYPE_ID      NUMBER;
        L_CODE_COMBINATION_ID   NUMBER;
        L_GL_CODE               NUMBER;

        --------------------------------------------

        --L_CHART_OF_ACT_ID           NUMBER;

        --------------------------------------------

        L_CURRENCY_CODE         VARCHAR2 (3);
        L_EXCHANGE_RATE_TYPE    VARCHAR2 (30 BYTE);
        L_EXCHANGE_RATE         NUMBER;
        L_EXCHANGE_DATE         DATE;

        --------------------------------------------

        L_TRX_DATE              DATE := NVL (P_TRX_DATE, SYSDATE);
        L_GL_DATE               DATE := NVL (P_GL_DATE, SYSDATE);

        --------------------------------------------

        l_error_message         VARCHAR2 (3000);
        l_error_code            VARCHAR2 (3000);
        l_return_status         VARCHAR2 (1);
    BEGIN
        -----------------------------------------------------
        ----------Validate Organization Code-----------------
        -----------------------------------------------------
        --DBMS_OUTPUT.PUT_LINE (P_ORGANIZATION_CODE);

        BEGIN
            SELECT OOD.OPERATING_UNIT,
                   OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_ID,
                   OU.SET_OF_BOOKS_ID,
                   OU.DEFAULT_LEGAL_CONTEXT_ID
              INTO L_OPERATING_UNIT,
                   L_ORGANIZATION_CODE,
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
        ----------Validate Chart Of Accounts Id------------
        --------------------------------------------------
        BEGIN
            SELECT currency_code
              INTO l_currency_code
              FROM gl_currencies
             WHERE     enabled_flag = 'Y'
                   AND currency_code = NVL (p_currency_code, 'BDT');
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_error_message :=
                       l_error_message
                    || ','
                    || 'Please enter correct Currency Code.';
                l_error_code := 'E';
        END;



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
              FROM HZ_PARTIES              HP,
                   HZ_PARTY_SITES          HPS,
                   HZ_CUST_ACCOUNTS        HCA,
                   HZ_CUST_ACCT_SITES_ALL  HCAS,
                   HZ_CUST_SITE_USES_ALL   HCSU
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
                   TER.SEGMENT4,
                   HCSU.PRIMARY_SALESREP_ID
              INTO L_SHIP_TO_SITE_ID,
                   L_TERRITORY_ID,
                   L_T_SEGMENT1,
                   L_T_SEGMENT2,
                   L_T_SEGMENT3,
                   L_T_SEGMENT4,
                   L_SALESREP_ID
              FROM HZ_PARTIES              HP,
                   HZ_PARTY_SITES          HPS,
                   HZ_CUST_ACCOUNTS        HCA,
                   HZ_CUST_ACCT_SITES_ALL  HCAS,
                   HZ_CUST_SITE_USES_ALL   HCSU,
                   ra_territories          ter
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


        IF P_ITEM_CODE IS NOT NULL              --OR P_SALES_ORDER IS NOT NULL
        THEN
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
                           l_error_message
                        || ','
                        || 'Please enter correct Item Info.';
                    l_error_code := 'E';
            END;
        ELSE
            SELECT NULL, NULL
              INTO L_ITEM_ID, L_UOM_CODE
              FROM DUAL;
        END IF;


        ----------------------------------------
        ----------Count Total Quantity----------
        ----------------------------------------



        BEGIN
            SELECT -(NVL (P_QUANTITY, 1) * NVL (P_UNIT_SELLING_PRICE, 1))
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
        ----------VALIDATE Btach Source-----
        ----------------------------------------

        BEGIN
            SELECT NAME
              INTO L_BATCH_SOURCE_NAME
              FROM RA_BATCH_SOURCES_ALL
             WHERE     NAME = P_BATCH_SOURCE_NAME
                   AND ORG_ID = L_OPERATING_UNIT
                   AND STATUS = 'A';
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
        ----------VALIDATE Cust_TRX_Type_ID-----
        ----------------------------------------

        BEGIN
            SELECT CUST_TRX_TYPE_ID, CTT.GL_ID_REV
              INTO L_CUST_TRX_TYPE_ID, L_CODE_COMBINATION_ID
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



        ------------------------------------------
        ----------VALIDATE Exchange Rate Type-----
        ------------------------------------------

        IF l_currency_code = 'BDT' AND P_EXCHANGE_RATE_TYPE = 'User'
        THEN
            SELECT P_EXCHANGE_RATE_TYPE, L_TRX_DATE, 1
              INTO L_EXCHANGE_RATE_TYPE, L_EXCHANGE_DATE, L_EXCHANGE_RATE
              FROM DUAL;
        ELSIF l_currency_code != 'BDT' AND P_EXCHANGE_RATE_TYPE = 'User'
        THEN
            SELECT P_EXCHANGE_RATE_TYPE, L_TRX_DATE, P_EXCHANGE_RATE
              INTO L_EXCHANGE_RATE_TYPE, L_EXCHANGE_DATE, L_EXCHANGE_RATE
              FROM DUAL;
        ELSIF l_currency_code != 'BDT' AND P_EXCHANGE_RATE_TYPE != 'User'
        THEN
            SELECT CONVERSION_TYPE, CONVERSION_DATE, CONVERSION_RATE
              INTO L_EXCHANGE_RATE_TYPE, L_EXCHANGE_DATE, L_EXCHANGE_RATE
              FROM gl_daily_rates
             WHERE     1 = 1
                   AND FROM_CURRENCY = P_CURRENCY_CODE
                   AND TRUNC (CONVERSION_DATE) = TRUNC (L_TRX_DATE)
                   AND CONVERSION_TYPE = P_EXCHANGE_RATE_TYPE
                   AND TO_CURRENCY = 'BDT';
        ELSIF P_EXCHANGE_RATE_TYPE IS NULL
        THEN
            SELECT NULL, NULL, NULL
              INTO L_EXCHANGE_RATE_TYPE, L_EXCHANGE_DATE, L_EXCHANGE_RATE
              FROM DUAL;
        END IF;

        --------------------------------------------------
        ----------Validate Chart Of Accounts Id------------
        --------------------------------------------------
        BEGIN
            SELECT gcc.code_combination_id
              INTO l_gl_code
              FROM apps.gl_code_combinations_kfv gcc
             WHERE 1 = 1 AND gcc.concatenated_segments = p_gl_code;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_error_message :=
                    l_error_message || ',' || 'Please enter correct GL Code';
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
            INSERT INTO apps.xxdbl_cer_ar_intrf_stg (SL_NO,
                                                     CREATION_DATE,
                                                     CREATED_BY,
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
                                                     DESCRIPTION,
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
                                                     EXCHANGE_RATE_TYPE,
                                                     EXCHANGE_DATE,
                                                     EXCHANGE_RATE,
                                                     CODE_COMBINATION_ID,
                                                     SALESREP_ID)
                 VALUES (TRIM (P_SL_NO),
                         SYSDATE,
                         P_USER_ID,
                         TRIM (P_TRX_TYPE),
                         TRIM (L_CUST_TRX_TYPE_ID),
                         TRIM (L_ORGANIZATION_CODE),
                         TRIM (L_BATCH_SOURCE_NAME),
                         TRIM (P_LINE_NUMBER),
                         TRIM (L_TRX_DATE),
                         TRIM (L_GL_DATE),
                         TRIM (L_CURRENCY_CODE),
                         TRIM (P_CUSTOMER_NUMBER),
                         TRIM (P_ITEM_CODE),
                         TRIM (NVL (P_QUANTITY, 1)),
                         TRIM (NVL (P_UNIT_SELLING_PRICE, 1)),
                         TRIM (P_DESCRIPTION),
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
                         TRIM (L_EXCHANGE_RATE_TYPE),
                         TRIM (L_EXCHANGE_DATE),
                         TRIM (L_EXCHANGE_RATE),
                         TRIM (L_GL_CODE),
                         --TRIM (NVL (L_GL_CODE, L_CODE_COMBINATION_ID)),
                         TRIM (L_SALESREP_ID));


            COMMIT;

            BEGIN
                l_return_status := check_error_log_to_import_data;
                COMMIT;
            END;
        END IF;
    END upload_data_to_ar_int_stg;
END xxdbl_cer_ar_intrf_pkg;
/
