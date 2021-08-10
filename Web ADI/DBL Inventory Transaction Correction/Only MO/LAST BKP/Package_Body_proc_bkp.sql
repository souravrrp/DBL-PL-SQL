/* Formatted on 10/18/2020 9:47:10 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_mo_acct_cor_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 15-OCT-2020
   -- LAST UPDATE DATE :17-OCT-2020
   -- PURPOSE : MOVE ORDER CORRECTION WEB ADI
   FUNCTION create_gl_code_combination (p_corrected_gl_code VARCHAR2)
      RETURN NUMBER
   IS
      l_application_short_name   VARCHAR2 (240);
      l_key_flex_code            VARCHAR2 (240);
      l_structure_num            NUMBER;
      l_validation_date          DATE;
      n_segments                 NUMBER;
      SEGMENTS                   APPS.FND_FLEX_EXT.SEGMENTARRAY;
      l_combination_id           NUMBER;
      l_data_set                 NUMBER;
      l_return                   BOOLEAN;
      l_message                  VARCHAR2 (240);
      l_segment1                 NUMBER;
      l_segment2                 NUMBER;
      l_segment3                 NUMBER;
      l_segment4                 NUMBER;
      l_segment5                 NUMBER;
      l_segment6                 NUMBER;
      l_segment7                 NUMBER;
      l_segment8                 NUMBER;
      l_segment9                 NUMBER;
   BEGIN
      l_application_short_name := 'SQLGL';
      l_key_flex_code := 'GL#';

      SELECT id_flex_num
        INTO l_structure_num
        FROM apps.fnd_id_flex_structures
       WHERE     ID_FLEX_CODE = 'GL#'
             AND ID_FLEX_STRUCTURE_CODE = 'DBL_ACCOUNTING_FLEXFIELD';


      l_validation_date := SYSDATE;
      n_segments := 9;
      segments (1) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        1);
      segments (2) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        2);
      segments (3) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        3);
      segments (4) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        4);
      segments (5) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        5);
      segments (6) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        6);
      segments (7) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        7);
      segments (8) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        8);
      segments (9) :=
         REGEXP_SUBSTR (p_corrected_gl_code,
                        '[^.]*',
                        1,
                        9);
      /*
      segments (1) := l_segment1;
      segments (2) := l_segment2;
      segments (3) := l_segment3;
      segments (4) := l_segment4;
      segments (5) := l_segment5;
      segments (6) := l_segment6;
      segments (7) := l_segment7;
      segments (8) := l_segment8;
      segments (9) := l_segment9;
      */
      l_data_set := NULL;

      l_return :=
         FND_FLEX_EXT.GET_COMBINATION_ID (
            application_short_name   => l_application_short_name,
            key_flex_code            => l_key_flex_code,
            structure_number         => l_structure_num,
            validation_date          => l_validation_date,
            n_segments               => n_segments,
            segments                 => segments,
            combination_id           => l_combination_id,
            data_set                 => l_data_set);
      l_message := FND_FLEX_EXT.GET_MESSAGE;

      IF l_return
      THEN
         DBMS_OUTPUT.PUT_LINE ('l_Return = TRUE');
         DBMS_OUTPUT.PUT_LINE ('COMBINATION_ID = ' || l_combination_id);
      ELSE
         DBMS_OUTPUT.PUT_LINE ('Error: ' || l_message);
      END IF;

      RETURN l_combination_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      L_RETURN_STATUS   VARCHAR2 (1);

      CURSOR cur_stg
      IS
         SELECT *
           FROM xxdbl.xxdbl_mo_account_correction
          WHERE FLAG IS NULL;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            L_RETURN_STATUS := NULL;


            INSERT INTO xxdbl.xxdbl_mo_account_cor_stg (transaction_id,
                                                        prior_account,
                                                        new_account,
                                                        cc_id,
                                                        mo_number,
                                                        organization_id,
                                                        transaction_date)
                 VALUES (ln_cur_stg.transaction_id,
                         ln_cur_stg.prior_account,
                         ln_cur_stg.new_account,
                         ln_cur_stg.cc_id,
                         ln_cur_stg.mo_number,
                         ln_cur_stg.organization_id,
                         ln_cur_stg.transaction_date);

            COMMIT;

            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
               DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  '--------------Unexpected errors found!--------------------');
            ELSE
               UPDATE xxdbl.xxdbl_mo_account_correction
                  SET FLAG = 'Y'
                WHERE FLAG IS NULL AND SL_NO = ln_cur_stg.SL_NO;
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

   FUNCTION mo_acct_cor_proc
      RETURN NUMBER
   IS
      CURSOR c1
      IS
         SELECT *
           FROM xxdbl.xxdbl_mo_account_cor_stg
          WHERE status IS NULL;

      v_prd_sts   NUMBER;
   BEGIN
      FOR i IN c1
      LOOP
         SELECT CASE
                   WHEN PERIOD_CLOSE_DATE IS NULL THEN 0
                   WHEN PERIOD_CLOSE_DATE IS NOT NULL THEN 1
                END
                   AS sts
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
      RETURN 0;
   END;



   PROCEDURE upload_data_stg_tbl (ERRBUF OUT VARCHAR2, RETCODE OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_import_data;

      IF L_Retcode = 0
      THEN
         l_retcode := mo_acct_cor_proc;
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
   END upload_data_stg_tbl;

   PROCEDURE import_data_from_web_adi (p_transaction_id       NUMBER,
                                       --p_organization_code    VARCHAR2,
                                       --p_transaction_date     DATE,
                                       --p_gl_code              VARCHAR2,
                                       --p_mo_number            VARCHAR2,
                                       p_corrected_gl_code    VARCHAR2)
   IS
      --------------------------------------------
      l_sl_no               NUMBER
                               := TRIM (LPAD (xxdbl.xxdbl_mo_acct_cor_s.NEXTVAL, 5, '0'));
      ---------------------Transaction Parameter-------------------

      L_ORGANIZATION_ID     NUMBER;
      l_transaction_id      NUMBER;
      l_mo_number           NUMBER;
      l_gl_code             VARCHAR2 (233);
      l_gl_code_id          NUMBER;
      l_transaction_date    DATE;

      --------------------------------------------

      l_corrected_gl_code   VARCHAR2 (50);
      l_cor_gl_code_id      NUMBER := NULL;
      --------------------------------------------

      l_error_message       VARCHAR2 (3000);
      l_error_code          VARCHAR2 (3000);
   ---------------------------------------------
   BEGIN
      /*
      -----------------------------------------------------
      ----------Validate Organization Code-----------------
      -----------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE (P_ORGANIZATION_CODE);


      BEGIN
         SELECT OOD.ORGANIZATION_ID
           INTO L_ORGANIZATION_ID
           FROM ORG_ORGANIZATION_DEFINITIONS OOD
          WHERE 1 = 1 AND OOD.ORGANIZATION_CODE = P_ORGANIZATION_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Organization Code';
            l_error_code := 'E';
      END;

      */



      --------------------------------------------------
      ----------Validate Transaction Id-----------------
      --------------------------------------------------
      BEGIN
         SELECT mmt.transaction_id,
                mmt.transaction_source_id,
                mmt.organization_id,
                mmt.transaction_date,
                gcc.concatenated_segments,
                gcc.code_combination_id
           INTO l_transaction_id,
                l_mo_number,
                l_organization_id,
                l_transaction_date,
                l_gl_code,
                l_gl_code_id
           FROM mtl_material_transactions mmt,
                apps.gl_code_combinations_kfv gcc
          WHERE     1 = 1
                AND mmt.distribution_account_id = gcc.code_combination_id(+)
                --AND gcc.concatenated_segments = p_gl_code
                --AND mmt.transaction_source_id = p_mo_number
                --and mmt.transaction_date=p_trx_date
                --AND mmt.organization_id = p_organization_id
                AND mmt.transaction_id = p_transaction_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Transaction Id'
               || p_transaction_id;
            l_error_code := 'E';
      END;



      /*
      --------------------------------------------------
      ----------Validate Transaction Id------------
      --------------------------------------------------
      BEGIN
         SELECT mmt.transaction_id.mmt.transaction_source_id,
                gcc.concatenated_segments,
                gcc.code_combination_id
           INTO l_transaction_id,
                l_mo_number,
                l_gl_code,
                l_gl_code_id
           FROM mtl_material_transactions
          WHERE transaction_id = p_transaction_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Transaction Id';
            l_error_code := 'E';
      END;
      */

      ------------------------------------------------
      -----------------Corrected GL Code--------------
      ------------------------------------------------

      BEGIN
         SELECT concatenated_segments, code_combination_id
           INTO l_corrected_gl_code, l_cor_gl_code_id
           FROM apps.gl_code_combinations_kfv gccv
          WHERE 1 = 1 AND gccv.concatenated_segments = p_corrected_gl_code;



         IF (l_cor_gl_code_id IS NULL)
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  'Please Create New Code Combination for : '
               || p_corrected_gl_code);

            BEGIN
               l_cor_gl_code_id :=
                  create_gl_code_combination (p_corrected_gl_code);
            END;
         ELSE
            DBMS_OUTPUT.PUT_LINE (
                  'Code Combination alreadey created for : '
               || p_corrected_gl_code);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  'Please check new corrected code for gl code: '
               || p_corrected_gl_code);
            L_ERROR_MESSAGE :=
                  L_ERROR_MESSAGE
               || ','
               || 'Please check new corrected code for gl code: '
               || p_corrected_gl_code;
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
         INSERT INTO xxdbl.xxdbl_mo_account_correction (SL_NO,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        TRANSACTION_ID,
                                                        PRIOR_ACCOUNT,
                                                        NEW_ACCOUNT,
                                                        CC_ID,
                                                        MO_NUMBER,
                                                        ORGANIZATION_ID,
                                                        TRANSACTION_DATE)
              VALUES (l_sl_no,
                      SYSDATE,
                      p_user_id,
                      l_transaction_id,
                      l_gl_code,
                      l_corrected_gl_code,
                      l_cor_gl_code_id,
                      l_mo_number,
                      l_organization_id,
                      l_transaction_date);


         COMMIT;
      END IF;
   END import_data_from_web_adi;
END xxdbl_mo_acct_cor_pkg;
/