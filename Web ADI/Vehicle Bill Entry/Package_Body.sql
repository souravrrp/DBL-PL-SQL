CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_VEHICLE_BILL_ENTRY
AS
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
            'This is a New Combination. Validation Starts….');
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
               'Validation Successful! Creating the Combination…');
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

   PROCEDURE SP_TMP_VEHICLE_BILL_ENTRY (p_M_BILL_DATE          IN DATE,
                                        p_M_DESC_WORK          IN VARCHAR2,
                                        p_M_CURRENT_KM         IN NUMBER,
                                        p_M_NEXT_KM            IN NUMBER,
                                        p_M_REMARKS            IN VARCHAR2,
                                        p_M_VANDOR_NAME        IN VARCHAR2,
                                        p_M_PURCH_OU           IN VARCHAR2,
                                        p_M_MAINTAINCE_TYPE    IN VARCHAR2,
                                        p_M_VOUCHER_NO         IN VARCHAR2,
                                        p_M_ALTERNATE_VENDOR   IN VARCHAR2,
                                        -- Detail Table
                                        p_D_BILL_ITEM_TYPE     IN VARCHAR2,
                                        p_D_ITEM_DTL           IN VARCHAR2,
                                        p_D_REMARKS            IN VARCHAR2,
                                        p_D_ITEM_QTY           IN NUMBER,
                                        p_D_UNIT_PRICE         IN NUMBER,
                                        p_D_DISCOUNT_AMOUNT    IN NUMBER,
                                        p_D_DR_CODE_COMB       IN VARCHAR2,
                                        p_D_VEHICLE_NUMBER     IN VARCHAR2,
                                        p_D_PR_NUMBER          IN VARCHAR2,
                                        p_D_VAT_AMNT           IN NUMBER)
   IS
      -- Table field related value
      v_VENDOR_ID               VARCHAR2 (500);
      v_Organization_ID         NUMBER;
      v_VENDOR_SITE_ID          NUMBER;
      v_LEGAL_ENTITY_ID         NUMBER;
      v_LEGAL_ENTITY_NAME       VARCHAR2 (200);
      v_LEDGER_ID               NUMBER;
      v_LEDGER_NAME             VARCHAR2 (200);
      v_CHART_OF_ACCOUNTS_ID    NUMBER;
      v_VendorCount             NUMBER := 0;
      v_MaintainceType          NUMBER := 0;
      v_VOUCHER_NO              NUMBER;

      -- Details Table related condition variable
      v_Bill_Item_Type          VARCHAR2 (200);
      v_Item_DTL                VARCHAR2 (200);
      v_VEHICLE_NUMBER          VARCHAR2 (200);
      v_GL_Code                 NUMBER;
      v_DR_CCID                 NUMBER;
      v_BILL_AMOUNT             NUMBER;
      v_VAT_PRCT                NUMBER;
      v_TOT_AMNT                NUMBER;
      v_DISCOUNT_AMT_PERTENGE   NUMBER;

      -- Error related table coloumn
      v_error_message           VARCHAR2 (3000);
      v_error_code              VARCHAR2 (2);
      L_Retcode                 NUMBER;
   BEGIN
      IF p_M_VOUCHER_NO IS NOT NULL
      THEN
         v_error_message := '';
         v_error_code := 'V';

         -- GET ORG ID
         BEGIN
            v_Organization_ID := NULL;

            SELECT ORGANIZATION_ID
              INTO v_Organization_ID
              FROM HR_OPERATING_UNITS
             WHERE NAME = p_M_PURCH_OU;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct operating unit ('
                  || p_M_PURCH_OU
                  || ').';
               v_error_code := 'E';
         END;

         -- Get VENDOR ID
         BEGIN
            SELECT COUNT (*)
              INTO v_VendorCount
              FROM AP_SUPPLIERS
             WHERE VENDOR_NAME = p_M_VANDOR_NAME;

            IF v_VendorCount = 0
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Please enter correct vandor name ('
                     || p_M_VANDOR_NAME
                     || ').';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct vandor name ('
                  || p_M_VANDOR_NAME
                  || ').';
               v_error_code := 'E';
         END;


         -- Fill VENDOR_ID, VENDOR_SITE_ID
         BEGIN
            SELECT VENDOR_ID, VENDOR_SITE_ID
              INTO v_VENDOR_ID, v_VENDOR_SITE_ID
              FROM (SELECT sup.segment1,
                           sup.vendor_id,
                           sup.vendor_name,
                           sups.vendor_site_id
                      FROM ap_suppliers sup,
                           ap_supplier_sites_all sups,
                           hr_operating_units hr
                     WHERE     sup.vendor_id = sups.vendor_id
                           AND sups.org_id = hr.organization_id
                           AND sups.inactive_date IS NULL
                           AND sup.vendor_type_lookup_code LIKE 'VEHICLE%'
                           AND hr.name = p_M_PURCH_OU
                           AND sup.vendor_name = p_M_VANDOR_NAME
                    UNION ALL
                    SELECT sup.segment1,
                           sup.vendor_id,
                           sup.vendor_name,
                           sups.vendor_site_id
                      FROM ap_suppliers sup,
                           ap_supplier_sites_all sups,
                           hr_operating_units hr
                     WHERE     sup.vendor_id = sups.vendor_id
                           AND sups.org_id = hr.organization_id
                           AND sups.inactive_date IS NULL
                           AND sup.customer_num IS NOT NULL
                           AND hr.name = p_M_PURCH_OU
                           AND sup.vendor_name = p_M_VANDOR_NAME);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct vandor name ('
                  || p_M_VANDOR_NAME
                  || ').';
               v_error_code := 'E';
         END;

         -- GET MAINTAINCE_TYPE
         BEGIN
            SELECT COUNT (*)
              INTO v_MaintainceType
              FROM FND_LOOKUP_VALUES_VL
             WHERE     LOOKUP_TYPE = 'XXVM_MAINTAINCE_TYPE'
                   AND END_DATE_ACTIVE IS NULL
                   AND MEANING = p_M_MAINTAINCE_TYPE;

            IF v_MaintainceType = 0
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Please enter correct maintaince type ('
                     || p_M_MAINTAINCE_TYPE
                     || ').';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct maintaince type ('
                  || p_M_MAINTAINCE_TYPE
                  || ').';
               v_error_code := 'E';
         END;

         -- Fill LEGAL ENTITY RELATED INFORMATION
         BEGIN
              SELECT DISTINCT lol.LEGAL_ENTITY_ID,
                              lol.LEGAL_ENTITY_NAME,
                              lol.LEDGER_ID,
                              lol.LEDGER_NAME,
                              gl.CHART_OF_ACCOUNTS_ID
                INTO v_LEGAL_ENTITY_ID,
                     v_LEGAL_ENTITY_NAME,
                     v_LEDGER_ID,
                     v_LEDGER_NAME,
                     v_CHART_OF_ACCOUNTS_ID
                FROM xle_le_ou_ledger_v lol,
                     gl_legal_entities_bsvs gll,
                     gl_ledgers gl,
                     hr_operating_units org
               WHERE     lol.legal_entity_id = gll.legal_entity_id
                     AND lol.ledger_id = gl.ledger_id
                     AND lol.operating_unit_id = org.organization_id
                     AND org.NAME = p_M_PURCH_OU
            ORDER BY lol.legal_entity_name;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct operating unit ('
                  || p_M_PURCH_OU
                  || ').';
               v_error_code := 'E';
         END;


         BEGIN
            SELECT COUNT (*)
              INTO v_VOUCHER_NO
              FROM XX_VMS_BILL_MST
             WHERE VOUCHER_NO = p_M_VOUCHER_NO;

            IF v_VOUCHER_NO <> 0
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Invoice Number already exist('
                  || p_M_VOUCHER_NO
                  || ')';
               v_error_code := 'E';
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Invoice Number already exist('
                  || p_M_VOUCHER_NO
                  || ')';
               v_error_code := 'E';
         END;

         --********* Details Table

         -- GET Bill Type Item
         BEGIN
            SELECT COUNT (*)
              INTO v_Bill_Item_Type
              FROM FND_LOOKUP_VALUES_VL
             WHERE     LOOKUP_TYPE = 'XXVM_BILL_ITEM_TYPE'
                   AND MEANING = p_D_BILL_ITEM_TYPE;

            IF v_Bill_Item_Type = 0
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Please enter correct Bill Item Type ('
                     || p_D_BILL_ITEM_TYPE
                     || ').';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct Bill Item Type ('
                  || p_D_BILL_ITEM_TYPE
                  || ').';
               v_error_code := 'E';
         END;

         -- Get Item DTL
         BEGIN
            SELECT COUNT (*)
              INTO v_Item_DTL
              FROM XX_VEHICLE_BILL_TYPE_V
             WHERE MEANING = p_D_ITEM_DTL;

            IF v_Item_DTL = 0
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Please enter correct Item ('
                     || p_D_ITEM_DTL
                     || ').';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct Item ('
                  || p_D_ITEM_DTL
                  || ').';
               v_error_code := 'E';
         END;

         -- Get Vehicle
         BEGIN
            SELECT COUNT (*)
              INTO v_VEHICLE_NUMBER
              FROM XX_VECHICLE_MST a,
                   (SELECT *
                      FROM XX_VECHICLE_ORG
                     WHERE ASSIGN_TO IS NULL) b
             WHERE     a.VMST_ID = b.VMST_ID
                   AND b.OPERATING_UNIT = p_M_PURCH_OU
                   AND a.V_REG_NO = p_D_VEHICLE_NUMBER;

            IF v_VEHICLE_NUMBER = 0
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Please enter correct Vehicle No ('
                     || p_D_VEHICLE_NUMBER
                     || ').';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct Vehicle No ('
                  || p_D_VEHICLE_NUMBER
                  || ').';
               v_error_code := 'E';
         END;

         -- GET Item Qty
         BEGIN
            IF (p_D_ITEM_QTY <= 0)
            THEN
               BEGIN
                  v_error_message :=
                        v_error_message
                     || ','
                     || 'Qty must be greater than zero(0)';
                  v_error_code := 'E';
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Please enter correct Iem Qty ('
                  || p_D_ITEM_QTY
                  || ').';
               v_error_code := 'E';
         END;

         -- GL Code Combination
         BEGIN
            SELECT COUNT (*)
              INTO v_GL_Code
              FROM GL_CODE_COMBINATIONS_KFV
             WHERE PADDED_CONCATENATED_SEGMENTS = p_D_DR_CODE_COMB;

            IF v_GL_Code = 0
            THEN
               BEGIN
                  -- Call Function
                  L_Retcode := create_gl_code_combination (p_D_DR_CODE_COMB);
                  COMMIT; 

                  IF L_Retcode > 1
                  THEN
                     fnd_message.CLEAR;
                  END IF;
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'GL Code not match ('
                  || p_D_DR_CODE_COMB
                  || ')';
               v_error_code := 'E';
         END;

         -- Fill GL Code
         BEGIN
            SELECT CODE_COMBINATION_ID
              INTO v_DR_CCID
              FROM GL_CODE_COMBINATIONS_KFV
             WHERE PADDED_CONCATENATED_SEGMENTS = p_D_DR_CODE_COMB;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_error_message :=
                  v_error_message || ',' || 'Please enter correct GL Code';
               v_error_code := 'E';
         END;

         -- Get Total Amount
         SELECT   (NVL (p_D_UNIT_PRICE, 0) * NVL (p_D_ITEM_QTY, 0))
                - NVL (p_D_DISCOUNT_AMOUNT, 0)
           INTO v_TOT_AMNT
           FROM DUAL;

         -- Get Discount Percent
         SELECT (  (NVL (p_D_DISCOUNT_AMOUNT, 0) * 100)
                 / (NVL (p_D_ITEM_QTY, 0) * NVL (p_D_UNIT_PRICE, 0)))
           INTO v_DISCOUNT_AMT_PERTENGE
           FROM DUAL;

         -- Get VAT Percent
         SELECT (NVL (p_D_VAT_AMNT, 0) * 100) / NVL (v_TOT_AMNT, 0)
           INTO v_VAT_PRCT
           FROM DUAL;

         --Get Bill Amount
         SELECT (  (  NVL (p_D_UNIT_PRICE, 0) * NVL (p_D_ITEM_QTY, 0)
                    + NVL (p_D_VAT_AMNT, 0))
                 - NVL (p_D_DISCOUNT_AMOUNT, 0))
           INTO v_BILL_AMOUNT
           FROM DUAL;

         IF v_error_code = 'E'
         THEN
            raise_application_error (-20101, v_error_message);
         ELSIF NVL (v_error_code, 'V') <> 'E'
         THEN
            INSERT INTO XXDBL.XXDBL_VEHICLE_WEBADI_UPD_TMP (M_VMS_BILL_ID,
                                              M_BILL_DATE,
                                              M_BLL_NO,
                                              M_DESC_WORK,
                                              M_CURRENT_KM,
                                              M_NEXT_KM,
                                              M_REMARKS,
                                              M_CREATED_BY,
                                              M_CREATION_DATE,
                                              M_ORG_ID,
                                              M_VANDOR_NAME,
                                              M_PURCH_OU,
                                              M_MAINTAINCE_TYPE,
                                              M_VOUCHER_NO,
                                              M_LEGAL_ENTITY_ID,
                                              M_LEGAL_ENTITY_NAME,
                                              M_LEDGER_ID,
                                              M_CHART_OF_ACCOUNTS_ID,
                                              M_LEDGER_NAME,
                                              M_VENDOR_ID,
                                              M_VENDOR_SITE_ID,
                                              M_INVOICE_AMOUNT,
                                              M_VOUCHER_NUMBER,
                                              M_ALTERNATE_VENDOR,
                                              M_BILL_STATUS,
                                              D_BILL_ITEM_TYPE,
                                              D_ITEM_DTL,
                                              D_BILL_AMOUNT,
                                              D_REMARKS,
                                              D_ITEM_QTY,
                                              D_UNIT_PRICE,
                                              D_DISCOUNT_AMOUNT,
                                              D_DISCOUNT_AMT_PERTENGE,
                                              D_DR_CODE_COMB,
                                              D_DR_CCID,
                                              D_VEHICLE_NUMBER,
                                              D_PR_NUMBER,
                                              D_VAT_PRCT,
                                              D_VAT_AMNT,
                                              M_ERROR_CODE,
                                              M_ERROR_MESSAGE)
                 VALUES (0,
                         p_M_BILL_DATE,
                         'N/A',
                         p_M_DESC_WORK,
                         p_M_CURRENT_KM,
                         p_M_NEXT_KM,
                         p_M_REMARKS,
                         apps.fnd_global.user_id,
                         SYSDATE,
                         v_Organization_ID,
                         p_M_VANDOR_NAME,
                         p_M_PURCH_OU,
                         p_M_MAINTAINCE_TYPE,
                         p_M_VOUCHER_NO,
                         v_LEGAL_ENTITY_ID,
                         --p_M_LEGAL_ENTITY_NAME,

                         v_LEGAL_ENTITY_NAME,
                         v_LEDGER_ID,
                         v_CHART_OF_ACCOUNTS_ID,
                         v_LEDGER_NAME,
                         v_VENDOR_ID,
                         v_VENDOR_SITE_ID,
                         0,          --M_INVOICE_AMOUNT(Sum of details amount)
                         '0',
                         p_M_ALTERNATE_VENDOR,
                         'Open',
                         p_D_BILL_ITEM_TYPE,
                         p_D_ITEM_DTL,
                         v_BILL_AMOUNT,                                   --0,
                         p_D_REMARKS,
                         p_D_ITEM_QTY,
                         p_D_UNIT_PRICE,
                         p_D_DISCOUNT_AMOUNT,
                         v_DISCOUNT_AMT_PERTENGE,                         --0,
                         p_D_DR_CODE_COMB,
                         v_DR_CCID,                             --p_D_DR_CCID,
                         p_D_VEHICLE_NUMBER,
                         p_D_PR_NUMBER,
                         v_VAT_PRCT,                                      --0,
                         p_D_VAT_AMNT,                                    --0,
                         v_error_code,
                         v_error_message);
         END IF;

         COMMIT;
      ELSE
         v_error_message :=
            v_error_message || ',' || 'Please enter correct GL Code';
         v_error_code := 'E';
      END IF;
   -- Call another Procedure
   --      BEGIN
   --         --SP_VEHICLE_BILL_ENTRY (p_M_PURCH_OU, p_D_DR_CODE_COMB);
   --         SP_VEHICLE_BILL_ENTRY ();
   --      END;
   END SP_TMP_VEHICLE_BILL_ENTRY;


   FUNCTION Fx_VEHICLE_BILL_ENTRY
      RETURN NUMBER
   IS
      v_VOUCHER_NO      NUMBER;
      l_inv_seq         NUMBER;
      v_VMS_BILL_ID     NUMBER;
      v_BLL_NO          VARCHAR2 (50);
      v_short_code      VARCHAR2 (50);
      v_do_seq          NUMBER;
      v_error_message   VARCHAR2 (3000) := '';
      v_error_code      VARCHAR2 (2) := 'V';

      CURSOR c_inv
      IS
           SELECT DISTINCT api.M_VMS_BILL_ID,
                           api.M_BILL_DATE,
                           api.M_BLL_NO,
                           api.M_DESC_WORK,
                           api.M_CURRENT_KM,
                           api.M_NEXT_KM,
                           api.M_REMARKS,
                           api.M_ORG_ID,
                           api.M_VANDOR_NAME,
                           api.M_PURCH_OU,
                           api.M_MAINTAINCE_TYPE,
                           api.M_VOUCHER_NO,
                           api.M_LEGAL_ENTITY_ID,
                           api.M_LEGAL_ENTITY_NAME,
                           api.M_LEDGER_ID,
                           api.M_CHART_OF_ACCOUNTS_ID,
                           api.M_LEDGER_NAME,
                           api.M_VENDOR_ID,
                           api.M_VENDOR_SITE_ID,
                           NVL (api.M_INVOICE_AMOUNT, 0) M_INVOICE_AMOUNT,
                           api.M_VOUCHER_NUMBER,
                           api.M_ALTERNATE_VENDOR,
                           api.M_BILL_STATUS,
                           api.M_ERROR_CODE,
                           api.M_ERROR_MESSAGE
             FROM XXDBL.XXDBL_VEHICLE_WEBADI_UPD_TMP api
            WHERE     api.M_ERROR_CODE = 'V'
                  AND api.M_CREATED_BY = apps.fnd_global.user_id
                  AND NOT EXISTS
                         (SELECT 1
                            FROM XXDBL.XX_VMS_BILL_MST MST
                           WHERE api.M_VOUCHER_NO = MST.VOUCHER_NO)
         GROUP BY api.M_VMS_BILL_ID,
                  api.M_BILL_DATE,
                  api.M_BLL_NO,
                  api.M_DESC_WORK,
                  api.M_CURRENT_KM,
                  api.M_NEXT_KM,
                  api.M_REMARKS,
                  api.M_ORG_ID,
                  api.M_VANDOR_NAME,
                  api.M_PURCH_OU,
                  api.M_MAINTAINCE_TYPE,
                  api.M_VOUCHER_NO,
                  api.M_LEGAL_ENTITY_ID,
                  api.M_LEGAL_ENTITY_NAME,
                  api.M_LEDGER_ID,
                  api.M_CHART_OF_ACCOUNTS_ID,
                  api.M_LEDGER_NAME,
                  api.M_VENDOR_ID,
                  api.M_VENDOR_SITE_ID,
                  api.M_INVOICE_AMOUNT,
                  api.M_VOUCHER_NUMBER,
                  api.M_ALTERNATE_VENDOR,
                  api.M_BILL_STATUS,
                  api.M_ERROR_CODE,
                  api.M_ERROR_MESSAGE
         ORDER BY api.M_BILL_DATE,
                  api.M_DESC_WORK,
                  api.M_CURRENT_KM,
                  api.M_VOUCHER_NUMBER;



      CURSOR c_lin (
         x_Invoice_Number    VARCHAR2,
         x_Operating_Unit    VARCHAR2)
      IS
           SELECT apl.D_BILL_ITEM_TYPE,
                  apl.D_ITEM_DTL,
                  NVL (apl.D_BILL_AMOUNT, 0) D_BILL_AMOUNT,
                  apl.D_REMARKS,
                  NVL (apl.D_ITEM_QTY, 0) D_ITEM_QTY,
                  NVL (apl.D_UNIT_PRICE, 0) D_UNIT_PRICE,
                  NVL (apl.D_DISCOUNT_AMOUNT, 0) D_DISCOUNT_AMOUNT,
                  NVL (apl.D_DISCOUNT_AMT_PERTENGE, 0) D_DISCOUNT_AMT_PERTENGE,
                  apl.D_DR_CODE_COMB,
                  apl.D_DR_CCID,
                  apl.D_VEHICLE_NUMBER,
                  apl.D_PR_NUMBER,
                  NVL (apl.D_VAT_PRCT, 0) D_VAT_PRCT,
                  NVL (apl.D_VAT_AMNT, 0) D_VAT_AMNT,
                  ROWNUM AS SL_NO
             FROM XXDBL.XXDBL_VEHICLE_WEBADI_UPD_TMP apl
            WHERE     apl.M_ERROR_CODE = 'V'
                  AND apl.M_CREATED_BY = apps.fnd_global.user_id
                  AND apl.M_VOUCHER_NO = x_invoice_number
                  AND apl.M_PURCH_OU = x_Operating_Unit
         ORDER BY apl.D_ITEM_DTL;

   BEGIN
      FOR h_inv IN c_inv
      LOOP
         -- Get VMS BILL ID
         BEGIN
            v_VMS_BILL_ID := NULL;

            SELECT XX_COM_PKG.GET_SEQUENCE_VALUE ('XX_VMS_BILL_MST',
                                                  'VMS_BILL_ID')
              INTO v_VMS_BILL_ID
              FROM DUAL;
         END;

         -- Get BILL NO
         BEGIN
            SELECT   MAX (
                        XX_COM_PKG.GET_SEQUENCE_VALUE ('XX_VMS_BILL_MST',
                                                       'VMS_BILL_ID'))
                   + 1
              INTO v_do_seq
              FROM DUAL;

            SELECT    h_inv.M_PURCH_OU
                   || '/'
                   || v_short_code
                   || 'BILL'
                   || DECODE (v_short_code, NULL, NULL, '/')
                   || v_do_seq
              INTO v_BLL_NO
              FROM DUAL;
         END;


         BEGIN
            SELECT COUNT (*)
              INTO v_VOUCHER_NO
              FROM XX_VMS_BILL_MST
             WHERE VOUCHER_NO = h_inv.M_VOUCHER_NO;

            IF v_VOUCHER_NO <> 0
            THEN
               v_error_message :=
                     v_error_message
                  || ','
                  || 'Invoice Number already exist('
                  || h_inv.M_VOUCHER_NO
                  || ')';
               v_error_code := 'E';
            END IF;
         END;


         IF v_error_code = 'E'
         THEN
            raise_application_error (-20101, v_error_message);
         ELSIF (    (NVL (v_error_code, 'V') <> 'E')
                AND (NVL (v_VOUCHER_NO, 0) = 0))
         --ELSIF (NVL (v_error_code, 'V') <> 'E')
         THEN
            BEGIN
               INSERT INTO XXDBL.XX_VMS_BILL_MST (VMS_BILL_ID,
                                                  BILL_DATE,
                                                  BLL_NO,
                                                  DESC_WORK,
                                                  CURRENT_KM,
                                                  NEXT_KM,
                                                  REMARKS,
                                                  CREATED_BY,
                                                  CREATION_DATE,
                                                  ORG_ID,
                                                  VANDOR_NAME,
                                                  PURCH_OU,
                                                  MAINTAINCE_TYPE,
                                                  VOUCHER_NO,
                                                  LEGAL_ENTITY_ID,
                                                  LEGAL_ENTITY_NAME,
                                                  LEDGER_ID,
                                                  CHART_OF_ACCOUNTS_ID,
                                                  LEDGER_NAME,
                                                  VENDOR_ID,
                                                  VENDOR_SITE_ID,
                                                  INVOICE_AMOUNT,
                                                  --VOUCHER_NUMBER,
                                                  ALTERNATE_VENDOR,
                                                  BILL_STATUS)
                    VALUES (v_VMS_BILL_ID,
                            h_inv.M_BILL_DATE,
                            v_BLL_NO,
                            h_inv.M_DESC_WORK,
                            h_inv.M_CURRENT_KM,
                            h_inv.M_NEXT_KM,
                            h_inv.M_REMARKS,
                            apps.fnd_global.user_id,
                            SYSDATE,
                            h_inv.M_ORG_ID,
                            h_inv.M_VANDOR_NAME,
                            h_inv.M_PURCH_OU,
                            h_inv.M_MAINTAINCE_TYPE,
                            h_inv.M_VOUCHER_NO,
                            h_inv.M_LEGAL_ENTITY_ID,
                            h_inv.M_LEGAL_ENTITY_NAME,
                            h_inv.M_LEDGER_ID,
                            h_inv.M_CHART_OF_ACCOUNTS_ID,
                            h_inv.M_LEDGER_NAME,
                            h_inv.M_VENDOR_ID,
                            h_inv.M_VENDOR_SITE_ID,
                            h_inv.M_INVOICE_AMOUNT,
                            --h_inv.M_VOUCHER_NUMBER,
                            h_inv.M_ALTERNATE_VENDOR,
                            'Open');
            END;
         END IF;

         COMMIT;

         -- Insert Details Data
         FOR l_lin IN c_lin (h_inv.M_VOUCHER_NO, h_inv.M_PURCH_OU)
         LOOP
            -- Get Detail Table Serial No
            SELECT ap_invoices_interface_s.NEXTVAL INTO l_inv_seq FROM DUAL;

            INSERT INTO XXDBL.XX_VMS_BILL_DTL (VMS_BILL_ID,
                                               BILL_ITEM_TYPE,
                                               ITEM_DTL,
                                               BILL_AMOUNT,
                                               REMARKS,
                                               ITEM_QTY,
                                               UNIT_PRICE,
                                               DISCOUNT_AMOUNT,
                                               DISCOUNT_AMT_PERTENGE,
                                               DR_CODE_COMB,
                                               DR_CCID,
                                               SL,
                                               VEHICLE_NUMBER,
                                               PR_NUMBER,
                                               VAT_PRCT,
                                               VAT_AMNT,
                                               CREATED_BY,
                                               CREATION_DATE)
                 VALUES (v_VMS_BILL_ID,
                         l_lin.D_BILL_ITEM_TYPE,
                         l_lin.D_ITEM_DTL,
                         l_lin.D_BILL_AMOUNT,
                         l_lin.D_REMARKS,
                         l_lin.D_ITEM_QTY,
                         l_lin.D_UNIT_PRICE,
                         l_lin.D_DISCOUNT_AMOUNT,
                         l_lin.D_DISCOUNT_AMT_PERTENGE,
                         l_lin.D_DR_CODE_COMB,
                         l_lin.D_DR_CCID,
                         l_lin.SL_NO,                             --l_inv_seq,
                         l_lin.D_VEHICLE_NUMBER,
                         l_lin.D_PR_NUMBER,
                         l_lin.D_VAT_PRCT,
                         l_lin.D_VAT_AMNT,
                         apps.fnd_global.user_id,
                         SYSDATE);
         END LOOP;

         COMMIT;

         UPDATE XXDBL.XXDBL_VEHICLE_WEBADI_UPD_TMP
            SET M_ERROR_CODE = 'P'
          WHERE     M_VOUCHER_NO = h_inv.M_VOUCHER_NO
                AND M_CREATED_BY = apps.fnd_global.user_id;

         UPDATE XXDBL.XX_VMS_BILL_MST
            SET INVOICE_AMOUNT =
                   (SELECT SUM (NVL (BILL_AMOUNT, 0))
                      FROM XX_VMS_BILL_DTL
                     WHERE VMS_BILL_ID = v_VMS_BILL_ID)
          WHERE     VMS_BILL_ID = v_VMS_BILL_ID
                AND CREATED_BY = apps.fnd_global.user_id;

         DELETE FROM XXDBL.XXDBL_VEHICLE_WEBADI_UPD_TMP
               WHERE     M_VOUCHER_NO = h_inv.M_VOUCHER_NO
                     AND M_CREATED_BY = apps.fnd_global.user_id;

         COMMIT;
      END LOOP;


      --   EXCEPTION
      --      WHEN OTHERS
      --      THEN
      --         raise_application_error (-20103,
      --                                  'Error-' || SQLCODE || '-' || SQLERRM);



      RETURN 0;
   END;

   PROCEDURE SP_IMPORT_DATA_TO_VEHICLE_TBL (ERRBUF    OUT VARCHAR2,
                                            RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := Fx_VEHICLE_BILL_ENTRY;

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
   END SP_IMPORT_DATA_TO_VEHICLE_TBL;
END XXDBL_VEHICLE_BILL_ENTRY;
/
