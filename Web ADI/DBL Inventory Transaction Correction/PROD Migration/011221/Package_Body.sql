/* Formatted on 12/1/2021 4:31:59 PM (QP5 v5.365) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_inv_trx_acct_cor_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 15-OCT-2020
    -- LAST UPDATE DATE :06-MAY-2021
    -- PURPOSE : MOVE ORDER AND PURCHASE ORDER CORRECTION WEB ADI
    FUNCTION create_gl_code_combination (p_corrected_gl_code VARCHAR2)
        RETURN NUMBER
    IS
        l_segment1            GL_CODE_COMBINATIONS.SEGMENT1%TYPE;
        l_segment2            GL_CODE_COMBINATIONS.SEGMENT2%TYPE;
        l_segment3            GL_CODE_COMBINATIONS.SEGMENT3%TYPE;
        l_segment4            GL_CODE_COMBINATIONS.SEGMENT4%TYPE;
        l_segment5            GL_CODE_COMBINATIONS.SEGMENT5%TYPE;
        l_segment6            GL_CODE_COMBINATIONS.SEGMENT6%TYPE;
        l_segment7            GL_CODE_COMBINATIONS.SEGMENT7%TYPE;
        l_segment8            GL_CODE_COMBINATIONS.SEGMENT8%TYPE;
        l_segment9            GL_CODE_COMBINATIONS.SEGMENT9%TYPE;
        l_valid_combination   BOOLEAN;
        l_cr_combination      BOOLEAN;
        l_ccid                GL_CODE_COMBINATIONS_KFV.code_combination_id%TYPE;
        l_structure_num       FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
        l_conc_segs           GL_CODE_COMBINATIONS_KFV.CONCATENATED_SEGMENTS%TYPE;
        p_error_msg1          VARCHAR2 (240);
        p_error_msg2          VARCHAR2 (240);
    BEGIN
        SELECT RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     1),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     2),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     3),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     4),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     5),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     6),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     7),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     8),
                      '.'),
               RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                     '[^.]*.',
                                     1,
                                     9),
                      '.')
          INTO l_segment1,
               l_segment2,
               l_segment3,
               l_segment4,
               l_segment5,
               l_segment6,
               l_segment7,
               l_segment8,
               l_segment9
          FROM DUAL;

        DBMS_OUTPUT.PUT_LINE (   'Company Code ID = '
                              || RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                                       '[^.]*.',
                                                       1,
                                                       1),
                                        '.'));

        DBMS_OUTPUT.PUT_LINE (   'Location ID = '
                              || RTRIM (REGEXP_SUBSTR (p_corrected_gl_code,
                                                       '[^.]*.',
                                                       1,
                                                       2),
                                        '.'));
        l_conc_segs :=
               l_segment1
            || '.'
            || l_segment2
            || '.'
            || l_segment3
            || '.'
            || l_segment4
            || '.'
            || l_segment5
            || '.'
            || l_segment6
            || '.'
            || l_segment7
            || '.'
            || l_segment8
            || '.'
            || l_segment9;

        BEGIN
            SELECT id_flex_num
              INTO l_structure_num
              FROM apps.fnd_id_flex_structures
             WHERE     id_flex_code = 'GL#'
                   AND id_flex_structure_code = 'DBL_ACCOUNTING_FLEXFIELD';
        EXCEPTION
            WHEN OTHERS
            THEN
                l_structure_num := NULL;
        END;

        ---------------Check if CCID exits with the above Concatenated Segments---------------

        BEGIN
            SELECT code_combination_id
              INTO l_ccid
              FROM apps.gl_code_combinations_kfv
             WHERE concatenated_segments = l_conc_segs;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_ccid := NULL;
        END;

        IF l_ccid IS NOT NULL
        THEN
            ------------------------The CCID is Available----------------------
            DBMS_OUTPUT.PUT_LINE ('COMBINATION_ID= ' || l_ccid);
        ELSE
            DBMS_OUTPUT.PUT_LINE (
                'This is a New Combination. Validation Starts�.');
            ----------------------------------------------------------------
            ------------Validate the New Combination--------------------------
            ----------------------------------------------------------------
            l_valid_combination :=
                APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS (
                    operation          => 'CHECK_COMBINATION',
                    appl_short_name    => 'SQLGL',
                    key_flex_code      => 'GL#',
                    structure_number   => L_STRUCTURE_NUM,
                    concat_segments    => L_CONC_SEGS);
            p_error_msg1 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

            IF l_valid_combination
            THEN
                DBMS_OUTPUT.PUT_LINE (
                    'Validation Successful! Creating the Combination�');
                ----------------------------------------------------------------
                -------------------Create the New CCID--------------------------
                ----------------------------------------------------------------
                L_CR_COMBINATION :=
                    APPS.FND_FLEX_KEYVAL.VALIDATE_SEGS (
                        operation          => 'CREATE_COMBINATION',
                        appl_short_name    => 'SQLGL',
                        key_flex_code      => 'GL#',
                        structure_number   => L_STRUCTURE_NUM,
                        concat_segments    => L_CONC_SEGS);
                p_error_msg2 := FND_FLEX_KEYVAL.ERROR_MESSAGE;

                IF l_cr_combination
                THEN
                    ----------------------------------------------------------------
                    -------------------Fetch the New CCID--------------------------
                    ----------------------------------------------------------------
                    SELECT code_combination_id
                      INTO l_ccid
                      FROM apps.gl_code_combinations_kfv
                     WHERE concatenated_segments = l_conc_segs;

                    DBMS_OUTPUT.PUT_LINE ('NEW COMBINATION_ID = ' || l_ccid);
                ELSE
                    -------------Error in creating a combination-----------------
                    DBMS_OUTPUT.PUT_LINE (
                        'Error in creating the combination: ' || p_error_msg2);
                END IF;
            ELSE
                --------The segments in the account string are not defined in gl value set----------
                DBMS_OUTPUT.PUT_LINE (
                    'Error in validating the combination: ' || p_error_msg1);
            END IF;
        END IF;

        RETURN l_ccid;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;


    PROCEDURE mo_acct_corretion_procedure (p_trx_id NUMBER)
    IS
        CURSOR c1 IS
            SELECT *
              FROM xxdbl.xxdbl_mo_account_cor_stg
             WHERE status IS NULL AND transaction_id = p_trx_id;

        v_prd_sts   NUMBER;
    BEGIN
        FOR i IN c1
        LOOP
            SELECT CASE
                       WHEN PERIOD_CLOSE_DATE IS NULL THEN 0
                       WHEN PERIOD_CLOSE_DATE IS NOT NULL THEN 1
                   END    AS sts
              INTO v_prd_sts
              FROM inv.ORG_ACCT_PERIODS
             WHERE     period_name = TO_CHAR (i.transaction_date, 'MON-YY')
                   AND organization_id = i.organization_id;

            IF v_prd_sts <> 1
            THEN
                UPDATE (SELECT mmt.organization_id,
                               mmt.transaction_id,
                               MMT.TRANSACTION_SOURCE_ID,
                               TO_CHAR (mmt.transaction_date, ' MON-YY ')
                                   AS Period,
                               mmt.organization_id,
                               mmt.distribution_account_id,
                               MMT.TRANSACtION_quantity
                          FROM inv.mtl_material_transactions mmt
                         WHERE mmt.TRANSACTION_ID = i.transaction_id) T
                   SET t.distribution_account_id = i.cc_id;

                UPDATE inv.mtl_transaction_accounts mta
                   SET reference_account = i.cc_id
                 WHERE     transaction_id = i.transaction_id
                       AND ACCOUNTING_LINE_TYPE = 2;

                UPDATE xxdbl.xxdbl_mo_account_cor_stg
                   SET status = ' Y '
                 WHERE transaction_id = i.transaction_id;
            END IF;
        END LOOP;

        COMMIT;
    END;



    PROCEDURE import_data_from_web_adi (p_correction_type     VARCHAR2,
                                        p_transaction_id      NUMBER,
                                        p_corrected_gl_code   VARCHAR2)
    IS
        ---------------------Transaction Parameter-------------------

        L_ORGANIZATION_ID      NUMBER;
        l_transaction_id       NUMBER;
        l_mo_number            NUMBER;
        l_gl_code              VARCHAR2 (233);
        l_gl_code_id           NUMBER;
        l_transaction_date     DATE;

        ------------------------------PO--------------------------
        l_po_header_id         NUMBER;
        l_po_number            VARCHAR2 (50);
        l_po_distribution_id   NUMBER;
        l_po_line_id           NUMBER;

        --------------------------------------------
        v_prd_sts              NUMBER;
        --------------------------------------------

        l_corrected_gl_code    VARCHAR2 (50);
        l_cor_gl_code_id       NUMBER := NULL;
        --------------------------------------------

        l_error_message        VARCHAR2 (3000);
        l_error_code           VARCHAR2 (3000);
    ---------------------------------------------
    BEGIN
        IF p_correction_type = 'MO'
        THEN
            --------------------------------------------------
            ----------Validate Transaction Id-----------------
            --------------------------------------------------
            BEGIN
                SELECT mmt.transaction_id,
                       mmt.transaction_source_id,
                       mmt.organization_id,
                       mmt.transaction_date,
                       mmt.distribution_account_id
                  INTO l_transaction_id,
                       l_mo_number,
                       l_organization_id,
                       l_transaction_date,
                       l_gl_code_id
                  FROM mtl_material_transactions mmt
                 WHERE     1 = 1
                       AND mmt.transaction_type_id = 63
                       AND mmt.transaction_id = p_transaction_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM xxdbl.xxdbl_mo_account_cor_stg stg
                                 WHERE     stg.status IS NULL
                                       AND stg.transaction_id =
                                           p_transaction_id);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Transaction ID not exists or already uploaded.';
                    l_error_code := 'E';
            END;

            ------------------------------------------------
            -----------------Existing GL Code--------------
            ------------------------------------------------


            IF l_transaction_id IS NOT NULL AND l_gl_code_id IS NULL
            THEN
                SELECT mtrl.to_account_id
                  INTO l_gl_code_id
                  FROM inv.mtl_material_transactions  mmt,
                       inv.mtl_txn_request_lines      mtrl
                 WHERE     mmt.transaction_id = l_transaction_id
                       AND mtrl.line_id = mmt.move_order_line_id;

                IF l_gl_code_id IS NOT NULL
                THEN
                    BEGIN
                        UPDATE inv.mtl_material_transactions mmt
                           SET mmt.distribution_account_id = l_gl_code_id
                         WHERE mmt.transaction_id = l_transaction_id;
                    END;

                    BEGIN
                        SELECT gcc.concatenated_segments,
                               gcc.code_combination_id
                          INTO l_gl_code, l_gl_code_id
                          FROM apps.gl_code_combinations_kfv gcc
                         WHERE gcc.code_combination_id = l_gl_code_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            DBMS_OUTPUT.PUT_LINE (
                                'Please check existing Code Combination.');
                    END;
                END IF;
            ELSE
                BEGIN
                    SELECT gcc.concatenated_segments, gcc.code_combination_id
                      INTO l_gl_code, l_gl_code_id
                      FROM apps.gl_code_combinations_kfv gcc
                     WHERE gcc.code_combination_id = l_gl_code_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                            'Please check existing Code Combination.');
                END;
            END IF;


            --------------------------------------------------
            ----------Validate Transaction Period-------------
            --------------------------------------------------
            BEGIN
                SELECT CASE
                           WHEN PERIOD_CLOSE_DATE IS NULL THEN 0
                           WHEN PERIOD_CLOSE_DATE IS NOT NULL THEN 1
                       END    AS sts
                  INTO v_prd_sts
                  FROM inv.org_acct_periods
                 WHERE     period_name =
                           TO_CHAR (l_transaction_date, 'MON-YY')
                       AND organization_id = l_organization_id;

                IF v_prd_sts = 1
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please ensure the Transaction Id for Open Period.';
                    l_error_code := 'E';
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct Transaction Id for Open Period.';
                    l_error_code := 'E';
            END;


            ------------------------------------------------
            -----------------Corrected GL Code--------------
            ------------------------------------------------

            BEGIN
                SELECT concatenated_segments, code_combination_id
                  INTO l_corrected_gl_code, l_cor_gl_code_id
                  FROM apps.gl_code_combinations_kfv gccv
                 WHERE     1 = 1
                       AND gccv.concatenated_segments = p_corrected_gl_code;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Please Create New Code Combination for : '
                        || p_corrected_gl_code);

                    BEGIN
                        l_cor_gl_code_id :=
                            create_gl_code_combination (p_corrected_gl_code);
                    END;
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
                INSERT INTO xxdbl.xxdbl_mo_account_cor_stg (TRANSACTION_ID,
                                                            PRIOR_ACCOUNT,
                                                            NEW_ACCOUNT,
                                                            CC_ID,
                                                            MO_NUMBER,
                                                            ORGANIZATION_ID,
                                                            TRANSACTION_DATE)
                     VALUES (l_transaction_id,
                             l_gl_code,
                             NVL (l_corrected_gl_code, p_corrected_gl_code),
                             l_cor_gl_code_id,
                             l_mo_number,
                             l_organization_id,
                             l_transaction_date);

                COMMIT;

                BEGIN
                    mo_acct_corretion_procedure (l_transaction_id);
                END;
            END IF;
        ELSE
            --------------------------------------------------
            ----------Validate Transaction Id-----------------
            --------------------------------------------------
            BEGIN
                SELECT rt.po_header_id,
                       poh.segment1,
                       rt.organization_id,
                       rt.transaction_date,
                       rt.po_distribution_id,
                       rt.po_line_id,
                       cc.concatenated_segments
                  INTO l_po_header_id,
                       l_po_number,
                       l_organization_id,
                       l_transaction_date,
                       l_po_distribution_id,
                       l_po_line_id,
                       l_gl_code
                  FROM rcv_transactions               rt,
                       po_distributions_all           pd,
                       apps.gl_code_combinations_kfv  cc,
                       po_headers_all                 poh
                 WHERE     1 = 1
                       AND pd.po_distribution_id = rt.po_distribution_id
                       AND pd.code_combination_id = cc.code_combination_id
                       AND rt.po_header_id = poh.po_header_id
                       AND rt.transaction_id = p_transaction_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct Transaction Id';
                    l_error_code := 'E';
            END;


            --------------------------------------------------
            ----------Validate Transaction Period-------------
            --------------------------------------------------
            BEGIN
                SELECT CASE
                           WHEN PERIOD_CLOSE_DATE IS NULL THEN 0
                           WHEN PERIOD_CLOSE_DATE IS NOT NULL THEN 1
                       END    AS sts
                  INTO v_prd_sts
                  FROM inv.org_acct_periods
                 WHERE     period_name =
                           TO_CHAR (l_transaction_date, 'MON-YY')
                       AND organization_id = l_organization_id;

                IF v_prd_sts = 1
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please ensure the Transaction Id for Open Period.';
                    l_error_code := 'E';
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct Transaction Id for Open Period.';
                    l_error_code := 'E';
            END;


            ------------------------------------------------
            -----------------Corrected GL Code--------------
            ------------------------------------------------

            BEGIN
                SELECT concatenated_segments, code_combination_id
                  INTO l_corrected_gl_code, l_cor_gl_code_id
                  FROM apps.gl_code_combinations_kfv gccv
                 WHERE     1 = 1
                       AND gccv.concatenated_segments = p_corrected_gl_code;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Please Create New Code Combination for : '
                        || p_corrected_gl_code);

                    BEGIN
                        l_cor_gl_code_id :=
                            create_gl_code_combination (p_corrected_gl_code);
                    END;
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
                INSERT INTO xxdbl.xxdbl_rcv_po_account_cor_stg (
                                PO_HEADER_ID,
                                PRIOR_ACCOUNT,
                                NEW_ACCOUNT,
                                CC_ID,
                                PO_NUMBER,
                                ORGANIZATION_ID,
                                TRANSACTION_DATE,
                                PO_DISTRIBUTION_ID,
                                PO_LINE_ID)
                     VALUES (l_po_header_id,
                             l_gl_code,
                             NVL (l_corrected_gl_code, p_corrected_gl_code),
                             l_cor_gl_code_id,
                             l_po_number,
                             l_organization_id,
                             l_transaction_date,
                             l_po_distribution_id,
                             l_po_line_id);

                COMMIT;

                BEGIN
                    po_account_cor_procedure (l_organization_id,
                                              l_po_header_id,
                                              l_po_line_id,
                                              l_po_distribution_id);
                END;
            END IF;
        END IF;
    END import_data_from_web_adi;

    PROCEDURE po_account_cor_procedure (l_org_id       NUMBER,
                                        l_po_hdr_id    NUMBER,
                                        l_po_ln_id     NUMBER,
                                        l_po_dist_id   NUMBER)
    IS
        CURSOR c1 IS
            SELECT *
              FROM xxdbl.xxdbl_rcv_po_account_cor_stg
             WHERE     status IS NULL
                   AND organization_id = l_org_id
                   AND po_header_id = l_po_hdr_id
                   AND po_line_id = l_po_ln_id
                   AND po_distribution_id = l_po_dist_id;

        v_prd_sts   NUMBER;
    BEGIN
        FOR i IN c1
        LOOP
            SELECT CASE
                       WHEN PERIOD_CLOSE_DATE IS NULL THEN 0
                       WHEN PERIOD_CLOSE_DATE IS NOT NULL THEN 1
                   END    AS sts
              INTO v_prd_sts
              FROM inv.ORG_ACCT_PERIODS
             WHERE     period_name = TO_CHAR (i.transaction_date, 'MON-YY')
                   AND organization_id = i.organization_id;

            IF v_prd_sts <> 1
            THEN
                UPDATE po_distributions_all
                   SET code_combination_id = i.cc_id
                 WHERE     po_header_id = i.po_header_id
                       AND po_line_id = i.po_line_id
                       AND po_distribution_id = i.po_distribution_id;


                UPDATE rcv_receiving_sub_ledger
                   SET code_combination_id = i.cc_id
                 WHERE     rcv_transaction_id IN
                               (SELECT transaction_id
                                  FROM rcv_transactions
                                 WHERE     po_header_id = i.po_header_id
                                       AND po_line_id = i.po_line_id
                                       AND po_distribution_id =
                                           i.po_distribution_id)
                       AND ACCOUNTING_LINE_TYPE = 'Charge';

                UPDATE xxdbl.xxdbl_rcv_po_account_cor_stg
                   SET status = ' Y '
                 WHERE     po_header_id = i.po_header_id
                       AND po_line_id = i.po_line_id
                       AND po_distribution_id = i.po_distribution_id;
            END IF;
        END LOOP;

        COMMIT;
    END;
END xxdbl_inv_trx_acct_cor_pkg;
/