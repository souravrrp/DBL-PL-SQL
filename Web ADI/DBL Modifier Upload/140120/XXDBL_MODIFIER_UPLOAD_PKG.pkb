/* Formatted on 1/14/2021 12:37:26 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_MODIFIER_upload_pkg
AS
   g_user_id   NUMBER := 1130;
   --Fnd_Profile.VALUE('USER_ID');--profile value
   g_resp_id   NUMBER := 21623;                          --fnd_global.resp_id;
   g_appl_id   NUMBER := 660;                       --fnd_global.resp_appl_id;
   g_org_id    NUMBER := 126;                             --fnd_global.org_id;
   --  x_login_id                      NUMBER    :=Fnd_Profile.VALUE('LOGIN_ID');
   g_process   VARCHAR2 (1) := 'P';
   g_error     VARCHAR2 (1) := 'E';

   PROCEDURE load_modifier_adi_prc (
      p_MODIFIER_NAME             IN VARCHAR2 DEFAULT NULL,
      p_LINE_LEVEL                IN VARCHAR2 DEFAULT NULL,
      p_MODIFIER_TYPE             IN VARCHAR2 DEFAULT NULL,
      p_effective_date_from       IN DATE DEFAULT NULL,
      p_effective_date_to         IN DATE DEFAULT NULL,
      P_PRICING_PHASE             IN VARCHAR2 DEFAULT NULL,
      P_PRICING_PHASE_ID          IN NUMBER DEFAULT NULL,
      p_ln_product_context        IN VARCHAR2 DEFAULT NULL,
      p_trns_product_context      IN VARCHAR2 DEFAULT NULL,
      p_PRODUCT_ATTRIBUTE         IN VARCHAR2 DEFAULT NULL,
      P_LN_PRODUCT_VALUE          IN VARCHAR2 DEFAULT NULL,
      p_VOLUME_TYPE               IN VARCHAR2 DEFAULT NULL,
      p_uom                       IN VARCHAR2 DEFAULT NULL,
      p_ln_uom_code               IN VARCHAR2 DEFAULT NULL,
      p_BREAK_TYPE                IN VARCHAR2 DEFAULT NULL,
      p_LN_PRODUCT_ATTRIBUTE      IN VARCHAR2 DEFAULT NULL,
      p_OPERATOR                  IN VARCHAR2 DEFAULT NULL,
      P_VALUE_FROM                IN NUMBER DEFAULT NULL,
      P_VALUE_TO                  IN NUMBER DEFAULT NULL,
      P_APPLICATION_METHOD        IN VARCHAR2 DEFAULT NULL,
      P_VALUE                     IN NUMBER DEFAULT NULL,
      P_PRICING_ATTRIBUTE         IN VARCHAR2 DEFAULT NULL,
      P_ITEM_ID                   IN NUMBER DEFAULT NULL,
      p_application_operator      IN VARCHAR2 DEFAULT NULL,
      p_ln_value                  IN NUMBER DEFAULT NULL,
      p_grade_pricing_attribute   IN VARCHAR2 DEFAULT NULL,
      p_grade_operator            IN VARCHAR2 DEFAULT NULL,
      p_grade_lookup_code         IN VARCHAR2 DEFAULT NULL,
      p_grade_name                IN VARCHAR2 DEFAULT NULL)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_err_stat         NUMBER := NULL;
      l_err_msg          VARCHAR2 (3999) := NULL;
      validation_ex      EXCEPTION;
      insertion_ex       EXCEPTION;
      l_error_manas      VARCHAR2 (4000) := NULL;
      l_description      VARCHAR2 (500);
      l_attribute2       VARCHAR2 (500);
      l_list_type_code   VARCHAR2 (100);
      l_meaning          VARCHAR2 (500);
   BEGIN
      l_err_stat := 0;
      l_err_msg := NULL;

      BEGIN
         SELECT description, attribute2, list_type_code
           INTO l_description, l_attribute2, l_list_type_code
           FROM qp_list_headers
          WHERE NAME = p_modifier_name;

         SELECT meaning
           INTO l_meaning
           FROM fnd_lookup_values_vl flv
          WHERE     1 = 1
                AND lookup_type = 'LIST_LINE_TYPE_CODE'
                AND lookup_code =
                       DECODE (l_list_type_code,
                               'DLT', 'DIS',
                               'SLT', 'SUR');

         INSERT INTO xxdbl_MODIFIER_stg (RECORD_ID,
                                         MODIFIER_NAME,
                                         LINE_LEVEL,
                                         MODIFIER_TYPE,
                                         EFFECTIVE_DATE_FROM,
                                         EFFECTIVE_DATE_TO,
                                         PRICING_PHASE,
                                         -- PRICING_PHASE_ID         ,
                                         PRODUCT_ATTRIBUTE,
                                         LN_PRODUCT_VALUE,
                                         VOLUME_TYPE,
                                         BREAK_TYPE,
                                         LN_PRODUCT_ATTRIBUTE,
                                         OPERATOR,
                                         VALUE_FROM,
                                         VALUE_TO,
                                         APPLICATION_METHOD,
                                         VALUE,
                                         PRICING_ATTRIBUTE,
                                         ITEM_ID,
                                         UOM,
                                         -- LN_UOM_CODE              ,
                                         -- LN_TYPE_CODE             ,
                                         LN_APPLICATION_OPERATOR,
                                         LN_VALUE,
                                         GRADE_OPERATOR,
                                         GRADE_LOOKUP_CODE,
                                         GRADE_NAME,
                                         STATUS)
              VALUES (xxdbl_modifier_seq.NEXTVAL,
                      p_modifier_name,
                      'Line'                                    --p_LINE_LEVEL
                            ,
                      l_meaning --'Discount'                             --p_MODIFIER_TYPE  --Update Line type by Sourav on 14-Jan-2021
                               ,
                      p_effective_date_from,
                      p_effective_date_to,
                      P_PRICING_PHASE,
                      'Item Number'                     -- p_PRODUCT_ATTRIBUTE
                                   ,
                      P_LN_PRODUCT_VALUE,
                      'Item Quantity'                        --- p_VOLUME_TYPE
                                     ,
                      'Point'                                   --p_BREAK_TYPE
                             ,
                      p_LN_PRODUCT_ATTRIBUTE,
                      'BETWEEN'                                   --p_OPERATOR
                               ,
                      1                                  ------ , P_VALUE_FROM
                       ,
                      9999999999                                  --P_VALUE_TO
                                ,
                      'Amount'                          --P_APPLICATION_METHOD
                              ,
                      P_VALUE,
                      'Grade'                            --P_PRICING_ATTRIBUTE
                             ,
                      P_ITEM_ID,
                      p_uom,
                      p_application_operator,
                      p_ln_value,
                      p_grade_operator,
                      p_grade_lookup_code,
                      p_grade_name,
                      'U');

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_manas := SQLCODE || '-' || SUBSTR (SQLERRM, 1, 100);
      END;

      main (l_err_msg,
            l_err_stat,
            'VALIDATION',
            p_modifier_name,
            xxdbl_modifier_seq.CURRVAL);


      IF l_err_stat <> 0
      THEN
         RAISE validation_ex;
      ELSE
         main (l_err_msg,
               l_err_stat,
               'INSERTION',
               p_modifier_name,
               xxdbl_modifier_seq.CURRVAL);

         IF l_err_stat <> 0
         THEN
            RAISE insertion_ex;
         END IF;
      END IF;
   EXCEPTION
      WHEN validation_ex
      THEN
         fnd_message.set_name ('XXDBL', 'XXDBL_CERAMIC_COMM_MSG');
         fnd_message.set_token ('ERROR_MESSAGE',
                                'Error in Validation - ' || l_err_msg);
         fnd_message.raise_error;
         raise_application_error (-20117,
                                  'Error in Validation - ' || l_err_msg);
      WHEN insertion_ex
      THEN
         fnd_message.set_name ('XXDBL', 'XXDBL_CERAMIC_COMM_MSG');
         fnd_message.set_token ('ERROR_MESSAGE',
                                'Error in Insertion  API- ' || l_err_msg);
         fnd_message.raise_error;
         raise_application_error (-20117,
                                  'Error in Insertion - ' || l_err_msg);
      WHEN OTHERS
      THEN
         fnd_message.set_name ('XXDBL', 'XXDBL_CERAMIC_COMM_MSG');
         fnd_message.set_token ('ERROR_MESSAGE',
                                'Error in Insertion  - ' || l_err_msg);
         fnd_message.raise_error;
         raise_application_error (-20116, 'Error in Webadi-' || SQLERRM);
   END load_modifier_adi_prc;

   PROCEDURE initializa_pl (p_org_id IN VARCHAR2)
   IS
   BEGIN
      mo_global.set_policy_context ('S', p_org_id);
      COMMIT;
   END initializa_pl;

   PROCEDURE validate_pl (x_retcode        OUT NUMBER,
                          x_errbuff        OUT VARCHAR2,
                          p_listname    IN     VARCHAR2,
                          p_record_id   IN     NUMBER)
   IS
      CURSOR act_pl_cur
      IS
         SELECT *
           FROM xxdbl_MODIFIER_stg
          WHERE     NVL (status, 'X') NOT IN ('S', 'P', 'E')
                AND MODIFIER_name = p_listname
                AND record_id = NVL (p_record_id, record_id);

      --ORDER BY RECORD_ID;
      v_success               VARCHAR2 (1) := 'S';
      v_error                 VARCHAR2 (1) := 'E';
      v_status                VARCHAR2 (1) := v_success;
      v_msg                   VARCHAR2 (3999) := NULL;
      l_list_hdr_id           NUMBER := NULL;
      l_curr_hdr_id           NUMBER := NULL;
      l_category_id           NUMBER := NULL;
      l_formula_id            NUMBER := NULL;
      l_uom_code              VARCHAR2 (3) := NULL;
      l_buyer_lkp_code        VARCHAR2 (30) := NULL;
      l_cust_inv_org_id       NUMBER := NULL;
      l_cust_account_number   NUMBER := NULL;
      l_cust_account_id       NUMBER := NULL;
      l_item_id               NUMBER := NULL;
      l_pricing_phase_id      NUMBER;
      L_LIST_LINE_ID          NUMBER := NULL;
   BEGIN
      FOR pl_rec IN act_pl_cur
      LOOP
         v_msg := NULL;
         l_list_hdr_id := NULL;
         l_curr_hdr_id := NULL;
         l_category_id := NULL;
         l_formula_id := NULL;
         l_uom_code := NULL;
         l_buyer_lkp_code := NULL;
         l_cust_inv_org_id := NULL;
         v_status := v_success;
         l_cust_account_id := NULL;
         l_pricing_phase_id := NULL;



         BEGIN
            SELECT list_header_id
              INTO l_list_hdr_id
              FROM qp_list_headers
             WHERE NAME = pl_rec.MODIFIER_NAME AND active_flag = 'Y';
         EXCEPTION
            WHEN OTHERS
            THEN
               l_list_hdr_id := NULL;
         END;

         IF pl_rec.ln_product_value IS NOT NULL                  --item_number
         THEN
            BEGIN
               SELECT msit.inventory_item_id
                 INTO l_item_id
                 FROM mtl_system_items_b msit
                WHERE     msit.segment1 = pl_rec.ln_product_value
                      AND organization_id = 152;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_status := v_error;
                  v_msg :=
                        'item - '
                     || pl_rec.ln_product_value
                     || ' is not defined~';
            END;
         END IF;

         IF pl_rec.uom IS NOT NULL
         THEN
            BEGIN
               SELECT uom_code
                 INTO l_uom_code
                 FROM mtl_units_of_measure_vl
                WHERE UPPER (uom_code) = UPPER (pl_rec.uom);
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_status := v_error;
                  v_msg := 'Uom Code - ' || pl_rec.uom || ' is not defined~';
            END;
         END IF;

         IF pl_rec.PRICING_PHASE IS NOT NULL
         THEN
            BEGIN
               SELECT pricing_phase_id
                 INTO l_pricing_phase_id
                 FROM qp_pricing_phases
                WHERE name = pl_rec.PRICING_PHASE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_status := v_error;
                  v_msg :=
                     'pRICING pHASE - ' || pl_rec.uom || ' is not defined~';
            END;
         END IF;

         IF v_status = v_error
         THEN
            x_retcode := 2;
            x_errbuff := v_msg;

            UPDATE xxdbl_modifier_stg
               SET status = v_error, error_message = v_msg
             WHERE record_id = pl_rec.record_id;
         ELSE
            x_retcode := 0;
            x_errbuff := v_msg;

            UPDATE xxdbl_modifier_stg
               SET status = v_status,
                   error_message = v_msg,
                   list_header_id = l_list_hdr_id,
                   item_id = l_item_id,
                   ln_uom_code = l_uom_code,
                   PRICING_PHASE_ID = l_pricing_phase_id
             WHERE record_id = pl_rec.record_id;
         END IF;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_retcode := 2;
         x_errbuff := SQLCODE || ' - ' || SQLERRM;
   END validate_pl;

   PROCEDURE insert_end_date (x_retcode        OUT NUMBER,
                              x_errbuff        OUT VARCHAR2,
                              p_listname    IN     VARCHAR2,
                              p_record_id   IN     NUMBER)
   IS
      CURSOR pl_succ_cur
      IS
         SELECT *
           FROM xxdbl_modifier_stg
          WHERE     NVL (status, 'X') = 'S'
                AND modifier_name = p_listname
                AND record_id = NVL (p_record_id, record_id);

      l_control_rec               QP_GLOBALS.Control_Rec_Type;
      l_return_status             VARCHAR2 (1);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2 (2000);
      x_msg_index                 NUMBER;
      i                           NUMBER := 1;
      j                           NUMBER := 1;
      k                           NUMBER := 1;
      l_qualifier_id              NUMBER;
      l_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
      l_MODIFIER_LIST_val_rec     QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
      l_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
      l_MODIFIERS_val_tbl         QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
      l_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
      l_QUALIFIERS_val_tbl        QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
      l_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
      l_PRICING_ATTR_val_tbl      QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
      l_x_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type;
      l_x_MODIFIER_LIST_val_rec   QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
      l_x_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
      l_x_MODIFIERS_val_tbl       QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
      l_x_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
      l_x_QUALIFIERS_val_tbl      QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
      l_x_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
      l_x_PRICING_ATTR_val_tbl    QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
      l_list_hdr_id               NUMBER := NULL;
      l_list_line_id              NUMBER := NULL;
      L_LIST_LINE_ID1             NUMBER := NULL;
      IN_TIME                     INT;                           --num seconds
      v_now                       DATE;
      L_id                        NUMBER;
   BEGIN
      fnd_global.apps_initialize (g_user_id, g_resp_id, g_appl_id);
      fnd_msg_pub.initialize;

      FOR pl_succ_rec IN pl_succ_cur
      LOOP
         l_list_hdr_id := NULL;
         l_list_line_id := NULL;
         x_msg_data := NULL;

         --x_updt_msg_data := NULL;

         SELECT list_header_id
           INTO l_list_hdr_id
           FROM qp_list_headers
          WHERE NAME = pl_succ_rec.modifier_name AND active_flag = 'Y';

         -- begin
         FOR rec
            IN (SELECT a.LIST_LINE_ID
                  ------ INTO L_LIST_LINE_ID1
                  FROM qp_modifier_summary_v a, qp_pricing_attributes b
                 WHERE     1 = 1                      ---a.LIST_LINE_ID=171334
                       AND a.list_line_id = b.list_line_id
                       AND b.pricing_attribute = 'PRICING_ATTRIBUTE19'
                       AND b.pricing_attr_value_from = pl_succ_rec.GRADE_NAME --'A'
                       --  AND (a.START_DATE_ACTIVE  <=pl_succ_rec.EFFECTIVE_DATE_FROM
                       AND a.END_DATE_ACTIVE >=
                              TO_DATE (pl_succ_rec.EFFECTIVE_DATE_from,
                                       'dd-mm-yyyy')
                       AND a.Product_attr_val = TO_CHAR (pl_succ_rec.item_id)
                       AND a.list_header_id = pl_succ_rec.list_header_id)
         LOOP
            /* EXCEPTION
                   WHEN OTHERS
                   THEN
                     L_LIST_LINE_ID1 :=null;

             END;%*/



            -----------------------------------  if L_LIST_LINE_ID1 is  not null then --end date old line
            l_MODIFIERS_tbl (i).operation := 'UPDATE'; --QP_GLOBALS.G_OPR_CREATE;
            l_MODIFIERS_tbl (1).list_header_id := l_list_hdr_id;
            l_MODIFIERS_tbl (i).list_line_id := rec.LIST_LINE_ID; --------------L_LIST_LINE_ID1;
            l_MODIFIERS_tbl (i).end_date_active :=
               NVL (pl_succ_rec.EFFECTIVE_DATE_from - 1, TRUNC (SYSDATE));

            /* Call the Modifiers Public API to update the modifier header, lines and Header Level Qualifiers */
            QP_Modifiers_PUB.Process_Modifiers (
               p_api_version_number      => 1.0,
               p_init_msg_list           => 'T',
               p_return_values           => 'T',
               p_commit                  => 'T',
               x_return_status           => l_return_status,
               x_msg_count               => x_msg_count,
               x_msg_data                => x_msg_data,
               p_MODIFIER_LIST_rec       => l_MODIFIER_LIST_rec,
               p_MODIFIERS_tbl           => l_MODIFIERS_tbl,
               p_QUALIFIERS_tbl          => l_QUALIFIERS_tbl,
               p_PRICING_ATTR_tbl        => l_PRICING_ATTR_tbl,
               x_MODIFIER_LIST_rec       => l_x_MODIFIER_LIST_rec,
               x_MODIFIER_LIST_val_rec   => l_MODIFIER_LIST_val_rec,
               x_MODIFIERS_tbl           => l_x_MODIFIERS_tbl,
               x_MODIFIERS_val_tbl       => l_MODIFIERS_val_tbl,
               x_QUALIFIERS_tbl          => l_x_QUALIFIERS_tbl,
               x_QUALIFIERS_val_tbl      => l_QUALIFIERS_val_tbl,
               x_PRICING_ATTR_tbl        => l_x_PRICING_ATTR_tbl,
               x_PRICING_ATTR_val_tbl    => l_PRICING_ATTR_val_tbl);

            --insert into xx_test values(l_return_status ||'   l_return_status update');
            --commit;
            IF l_return_status = 'S'
            THEN
               x_retcode := 0;
               x_errbuff := 'API Executed Successfully';
               COMMIT;
            END IF;

            IF l_return_status != 'S'
            THEN
               ROLLBACK;

               IF (x_msg_count > 0)
               THEN
                  FOR l_lcv IN 1 .. x_msg_count
                  LOOP
                     x_msg_data :=
                        oe_msg_pub.get (p_msg_index => k, p_encoded => 'F');
                  END LOOP;
               END IF;
            END IF;
         --   else
         --  x_retcode := 0;
         -- x_errbuff := 'No Data END DATED';


         --------------------  end if;
         END LOOP;
      ---------------
      /*IN_TIME :=5;
      SELECT SYSDATE
            INTO v_now
            FROM DUAL;

           -- 2) Loop until the original timestamp plus the amount of seconds <= current date
           LOOP
             EXIT WHEN v_now + (IN_TIME * (1/86400)) <= SYSDATE;
           END LOOP;*/



      ------------------



      --else
      -- x_retcode := 2;
      -- x_errbuff := 'Item already exists'|| SQLCODE || ' - ' || SQLERRM;

      --end if;
      END LOOP;

      COMMIT;
   --ERROR_REPORT('INSERTION');
   EXCEPTION
      WHEN OTHERS
      THEN
         x_retcode := 2;
         x_errbuff := SQLCODE || ' - ' || SQLERRM;
   END insert_end_date;

   PROCEDURE insert_pl (x_retcode        OUT NUMBER,
                        x_errbuff        OUT VARCHAR2,
                        p_listname    IN     VARCHAR2,
                        p_record_id   IN     NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      CURSOR pl_succ_cur
      IS
         SELECT *
           FROM xxdbl_modifier_stg
          WHERE     NVL (status, 'X') = 'S'
                AND modifier_name = p_listname
                AND record_id = NVL (p_record_id, record_id);

      l_control_rec               QP_GLOBALS.Control_Rec_Type;
      l_return_status             VARCHAR2 (1);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2 (2000);
      x_msg_index                 NUMBER;
      i                           NUMBER := 1;
      j                           NUMBER := 1;
      k                           NUMBER := 1;
      l_qualifier_id              NUMBER;
      l_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
      l_MODIFIER_LIST_val_rec     QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
      l_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
      l_MODIFIERS_val_tbl         QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
      l_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
      l_QUALIFIERS_val_tbl        QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
      l_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
      l_PRICING_ATTR_val_tbl      QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
      l_x_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type;
      l_x_MODIFIER_LIST_val_rec   QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
      l_x_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
      l_x_MODIFIERS_val_tbl       QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
      l_x_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
      l_x_QUALIFIERS_val_tbl      QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
      l_x_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
      l_x_PRICING_ATTR_val_tbl    QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
      l_list_hdr_type_code        VARCHAR2 (100);
      l_list_hdr_id               NUMBER := NULL;
      l_list_line_id              NUMBER := NULL;
      L_LIST_LINE_ID1             NUMBER := NULL;
      IN_TIME                     INT;                           --num seconds
      v_now                       DATE;
      L_id                        NUMBER;
   BEGIN
      fnd_global.apps_initialize (g_user_id, g_resp_id, g_appl_id);
      fnd_msg_pub.initialize;

      FOR pl_succ_rec IN pl_succ_cur
      LOOP
         l_list_hdr_id := NULL;
         l_list_line_id := NULL;
         x_msg_data := NULL;

         --x_updt_msg_data := NULL;

         SELECT list_header_id,
                DECODE (list_type_code,  'DLT', 'DIS',  'SLT', 'SUR')
           INTO l_list_hdr_id, l_list_hdr_type_code
           FROM qp_list_headers
          WHERE NAME = pl_succ_rec.modifier_name AND active_flag = 'Y';

         BEGIN
            SELECT a.LIST_LINE_ID
              INTO L_LIST_LINE_ID1
              FROM qp_modifier_summary_v a, qp_pricing_attributes b
             WHERE     1 = 1                          ---a.LIST_LINE_ID=171334
                   AND a.list_line_id = b.list_line_id
                   AND b.pricing_attribute = 'PRICING_ATTRIBUTE19'
                   AND b.pricing_attr_value_from = pl_succ_rec.GRADE_NAME --'A'
                   --  AND (a.START_DATE_ACTIVE  <=pl_succ_rec.EFFECTIVE_DATE_FROM
                   AND a.END_DATE_ACTIVE >=
                          TO_DATE (pl_succ_rec.EFFECTIVE_DATE_from,
                                   'dd-mm-yyyy')
                   AND a.Product_attr_val = TO_CHAR (pl_succ_rec.item_id)
                   AND a.list_header_id = pl_succ_rec.list_header_id   --54182
                                                                    -- and rownum=1
            ;                                                       --'187872'
         EXCEPTION
            WHEN OTHERS
            THEN
               L_LIST_LINE_ID1 := NULL;
         END;



         ---------------
         /*IN_TIME :=5;
         SELECT SYSDATE
               INTO v_now
               FROM DUAL;

              -- 2) Loop until the original timestamp plus the amount of seconds <= current date
              LOOP
                EXIT WHEN v_now + (IN_TIME * (1/86400)) <= SYSDATE;
              END LOOP;*/



         ------------------
         /*  select a.Product_attr_val
               INTO L_id
               from qp_modifier_summary_v a
               ,qp_pricing_attributes b
               WHERE 1=1---a.LIST_LINE_ID=171334
               and a.list_line_id = b.list_line_id
               and b.pricing_attribute ='PRICING_ATTRIBUTE19'
               and b.pricing_attr_value_from =pl_succ_rec.GRADE_NAME--'A'
             --  AND (a.START_DATE_ACTIVE  <=pl_succ_rec.EFFECTIVE_DATE_FROM
               aND a.END_DATE_ACTIVE =pl_succ_rec.EFFECTIVE_DATE_from -1
               and a.Product_attr_val=to_char(pl_succ_rec.item_id)
               and a.list_header_id          = pl_succ_rec.list_header_id;--54182 */

         -- insert into xx_test values(to_char(pl_succ_rec.EFFECTIVE_DATE_FROM) ||'   pl_succ_rec.EFFECTIVE_DATE_FROM');
         -- insert into xx_test values(to_char(pl_succ_rec.EFFECTIVE_DATE_TO) ||'   pl_succ_rec.EFFECTIVE_DATE_TO');
         --     commit;
         -- if L_LIST_LINE_ID1 is   null then
         l_return_status := NULL;
         l_MODIFIERS_tbl (1).list_header_id := l_list_hdr_id; ---54182;   --Comment Header Code

         /* Create a Modifier Line to define a New Price for the inventory item id 2834301 */
         l_MODIFIERS_tbl (i).modifier_level_code := 'LINE'; -- lookup_code in fnd_lookup_values where lookup_type = 'MODIFIER_LEVEL_CODE'
         l_MODIFIERS_tbl (i).start_date_active := --to_date(pl_succ_rec.EFFECTIVE_DATE_from,'dd-mon-yyyy');--
            NVL (pl_succ_rec.EFFECTIVE_DATE_FROM, TRUNC (SYSDATE));
         l_MODIFIERS_tbl (i).end_date_active := --to_date(pl_succ_rec.EFFECTIVE_DATE_to,'dd-mon-yyyy');--
            NVL (pl_succ_rec.EFFECTIVE_DATE_TO, TRUNC (SYSDATE));
         l_MODIFIERS_tbl (i).list_line_type_code := l_list_hdr_type_code; --'DIS'; -- lookup_code in fnd_lookup_values where lookup_type = 'LIST_LINE_TYPE_CODE'
         l_MODIFIERS_tbl (i).accrual_flag := 'N';
         l_MODIFIERS_tbl (i).arithmetic_operator := 'AMT'; -- lookup_code in fnd_lookup_values where lookup_type = 'AMS_QP_ARITHMETIC_OPERATOR'
         l_MODIFIERS_tbl (i).operand := pl_succ_rec.VALUE; -- New price amount
         l_MODIFIERS_tbl (i).product_precedence := 220;
         l_MODIFIERS_tbl (i).price_break_type_code := 'POINT'; -- lookup_code in fnd_lookup_values where lookup_type = 'PRICE_BREAK_TYPE_CODE'
         l_MODIFIERS_tbl (i).automatic_flag := 'Y';
         l_MODIFIERS_tbl (i).override_flag := 'N';
         l_MODIFIERS_tbl (i).pricing_phase_id := pl_succ_rec.pricing_phase_id; -- pricing_phase_id in qp_pricing_phases
         -- l_MODIFIERS_tbl(i).pricing_phase :='List Line Adjustment';
         l_MODIFIERS_tbl (i).pricing_group_sequence := 1;            -- Bucket
         l_MODIFIERS_tbl (i).operation := 'CREATE'; --QP_GLOBALS.G_OPR_CREATE;

         l_PRICING_ATTR_tbl (i).product_attribute_context := 'ITEM'; -- prc_context_code in qp_prc_contexts_b where prc_context_type = 'PRODUCT'
         l_PRICING_ATTR_tbl (i).product_attribute := 'PRICING_ATTRIBUTE1'; -- segment_mapping_column in qp_segments_b
         l_PRICING_ATTR_tbl (i).product_attr_value := pl_succ_rec.item_id; --'187872'; -- inventory_item_id in mtl_system_items_b as product_attribute_context is ITEM
         l_PRICING_ATTR_tbl (i).product_uom_code := pl_succ_rec.LN_UOM_CODE; -- uom_code in mtl_units_of_measure
         l_PRICING_ATTR_tbl (i).comparison_operator_code := 'BETWEEN';
         l_PRICING_ATTR_tbl (i).pricing_attribute_context := 'VOLUME'; -- prc_context_code in qp_prc_contexts_b
         l_PRICING_ATTR_tbl (i).pricing_attribute := 'PRICING_ATTRIBUTE10'; -- segment_mapping_column in qp_segments_b
         l_PRICING_ATTR_tbl (i).excluder_flag := 'N';
         l_PRICING_ATTR_tbl (i).accumulate_flag := 'N';
         l_PRICING_ATTR_tbl (i).MODIFIERS_index := 1;
         l_PRICING_ATTR_tbl (i).PRICING_ATTR_VALUE_FROM :=
            pl_succ_rec.VALUE_FROM;
         l_PRICING_ATTR_tbl (i).PRICING_ATTR_VALUE_TO := pl_succ_rec.VALUE_TO;
         l_PRICING_ATTR_tbl (i).operation := 'CREATE'; --QP_GLOBALS.G_OPR_CREATE;

         l_PRICING_ATTR_tbl (2).product_attribute_context := 'ITEM'; -- prc_context_code in qp_prc_contexts_b where prc_context_type = 'PRODUCT'
         l_PRICING_ATTR_tbl (2).product_attribute := 'PRICING_ATTRIBUTE1'; -- segment_mapping_column in qp_segments_b
         l_PRICING_ATTR_tbl (2).product_attr_value := pl_succ_rec.item_id; -- inventory_item_id in mtl_system_items_b as product_attribute_context is ITEM
         l_PRICING_ATTR_tbl (2).product_uom_code := pl_succ_rec.LN_UOM_CODE; -- uom_code in mtl_units_of_measure
         l_PRICING_ATTR_tbl (2).comparison_operator_code := '=';
         l_PRICING_ATTR_tbl (2).pricing_attribute_context :=
            'PRICING ATTRIBUTE';      -- prc_context_code in qp_prc_contexts_b
         l_PRICING_ATTR_tbl (2).pricing_attribute := 'PRICING_ATTRIBUTE19'; -- segment_mapping_column in qp_segments_b
         l_PRICING_ATTR_tbl (2).excluder_flag := 'N';
         l_PRICING_ATTR_tbl (2).accumulate_flag := 'N';
         l_PRICING_ATTR_tbl (2).MODIFIERS_index := 1;
         l_PRICING_ATTR_tbl (2).PRICING_ATTR_VALUE_FROM :=
            pl_succ_rec.grade_name;                                     --'B';
         l_PRICING_ATTR_val_tbl (2).pricing_attr_value_from_desc := 'B';
         l_PRICING_ATTR_tbl (2).operation := 'CREATE'; --QP_GLOBALS.G_OPR_CREATE;


         /* Call the Modifiers Public API to create the modifier header, lines and Header Level Qualifiers */
         QP_Modifiers_PUB.Process_Modifiers (
            p_api_version_number      => 1.0,
            p_init_msg_list           => 'T',              -- FND_API.G_FALSE,
            p_return_values           => 'T',               --FND_API.G_FALSE,
            p_commit                  => 'T',              ---FND_API.G_FALSE,
            x_return_status           => l_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            p_MODIFIER_LIST_rec       => l_MODIFIER_LIST_rec,
            p_MODIFIERS_tbl           => l_MODIFIERS_tbl,
            p_QUALIFIERS_tbl          => l_QUALIFIERS_tbl,
            p_PRICING_ATTR_tbl        => l_PRICING_ATTR_tbl,
            x_MODIFIER_LIST_rec       => l_x_MODIFIER_LIST_rec,
            x_MODIFIER_LIST_val_rec   => l_MODIFIER_LIST_val_rec,
            x_MODIFIERS_tbl           => l_x_MODIFIERS_tbl,
            x_MODIFIERS_val_tbl       => l_MODIFIERS_val_tbl,
            x_QUALIFIERS_tbl          => l_x_QUALIFIERS_tbl,
            x_QUALIFIERS_val_tbl      => l_QUALIFIERS_val_tbl,
            x_PRICING_ATTR_tbl        => l_x_PRICING_ATTR_tbl,
            x_PRICING_ATTR_val_tbl    => l_PRICING_ATTR_val_tbl);

         --insert into xx_test values(l_return_status ||'   l_return_status create');
         --commit;

         IF l_return_status = 'S'
         THEN
            x_retcode := 0;
            x_errbuff := 'API Executed Successfully';

            UPDATE xxdbl_modifier_stg
               SET status = g_process
             WHERE record_id = pl_succ_rec.record_id;

            COMMIT;
         END IF;

         IF l_return_status != 'S'
         THEN
            ROLLBACK;

            IF (x_msg_count > 0)
            THEN
               FOR l_lcv IN 1 .. x_msg_count
               LOOP
                  x_msg_data :=
                     oe_msg_pub.get (p_msg_index => k, p_encoded => 'F');
               END LOOP;
            END IF;

            x_retcode := 2;
            x_errbuff := x_msg_data;

            UPDATE xxdbl_modifier_stg
               SET status = g_error, error_message = x_msg_data
             WHERE record_id = pl_succ_rec.record_id;

            COMMIT;
         END IF;
      --else
      -- x_retcode := 2;
      -- x_errbuff := 'Item already exists'|| SQLCODE || ' - ' || SQLERRM;

      --end if;
      END LOOP;

      COMMIT;
   --ERROR_REPORT('INSERTION');
   EXCEPTION
      WHEN OTHERS
      THEN
         x_retcode := 2;
         x_errbuff := SQLCODE || ' - ' || SQLERRM;
   END insert_pl;

   PROCEDURE main (errbuf           OUT VARCHAR2,
                   retcode          OUT VARCHAR2,
                   p_mode        IN     VARCHAR2,
                   p_list_name   IN     VARCHAR2,
                   p_record_id   IN     NUMBER)
   IS
      x_retcode   NUMBER := NULL;
      x_errbuff   VARCHAR2 (3999) := NULL;
   BEGIN
      x_retcode := NULL;
      x_errbuff := NULL;

      IF p_mode = 'VALIDATION'
      THEN
         initializa_pl (g_org_id);
         validate_pl (x_retcode,
                      x_errbuff,
                      p_list_name,
                      p_record_id);
         errbuf := x_errbuff;
         retcode := x_retcode;
      ELSIF p_mode = 'INSERTION'
      THEN
         insert_end_date (x_retcode,
                          x_errbuff,
                          p_list_name,
                          p_record_id);
         insert_pl (x_retcode,
                    x_errbuff,
                    p_list_name,
                    p_record_id);
         errbuf := x_errbuff;
         retcode := x_retcode;
      END IF;
   END main;
END;
/