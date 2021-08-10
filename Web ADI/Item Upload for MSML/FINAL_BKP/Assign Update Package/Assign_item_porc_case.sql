/* Formatted on 7/16/2020 10:25:38 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_ITEM_ASSIGN_WEBADI_PKG
IS
   FUNCTION check_error_log_to_assign_data
      RETURN NUMBER
   IS
      vlp_category_id     NUMBER;
      vlp_template_name   VARCHAR2 (100);
      v_request_id        NUMBER;

      CURSOR cur_stg
      IS
         SELECT *
           FROM apps.XXDBL_ITEM_UPLOAD_WEBADI
          WHERE FLAG IS NULL;

      CURSOR cur_spining
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('SPINING-PROCESS')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;

      CURSOR cur_rmg
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('RMG-PROCESS')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;

      CURSOR cur_htl_knit
      IS
                    SELECT org.organization_id
                      FROM ORG_ORGANIZATION_DEFINITIONS org,
                           per_org_structure_elements_v pose,
                           per_organization_structures_v os
                     WHERE     1 = 1
                           AND org.organization_id = pose.organization_id_child
                           AND OS.organization_structure_id =
                                  POSE.ORG_STRUCTURE_VERSION_ID
                           AND OS.NAME IN ('HTL-KNITTING')
                START WITH pose.organization_id_parent = 138
                CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
         ORDER SIBLINGS BY pose.organization_id_child;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            fnd_file.put_line (fnd_file.LOG,
                               '--Submitting Item Import Program for Item--');


            v_request_id :=
               Fnd_Request.submit_request (application   => 'INV',
                                           Program       => 'INCOIN',
                                           description   => NULL,
                                           start_time    => SYSDATE,
                                           sub_request   => FALSE,
                                           argument1     => 138,
                                           argument2     => 1,
                                           argument3     => 1, --Group ID option (All)
                                           argument4     => 1, -- Group ID Dummy
                                           argument5     => 1, -- Delete processed Record
                                           argument6     => 251, -- Set Process id
                                           argument7     => 1   -- Update item
                                                             );
            COMMIT;

            IF (v_request_id = 0)
            THEN
               fnd_file.put_line (fnd_file.LOG,
                                  'Item Import Program Not Submitted');
            ELSE
               fnd_file.put_line (fnd_file.LOG,
                                  'Item Import Program submitted');
            END IF;
         END;

         BEGIN
            UPDATE mtl_system_items_b m
               SET mcc_control_code = 1
             WHERE segment1 = ln_cur_stg.segment1;

            COMMIT;
         END;

         CASE
            WHEN SUBSTR (ln_cur_stg.segment1, 0, 5) != 'YRNDY'      --For Yarn
            THEN
               ---spining
               BEGIN
                  FOR ln_cur_spining IN cur_spining
                  LOOP
                     BEGIN
                        IF ln_cur_spining.organization_id NOT IN (198)
                        THEN
                           vlp_template_name := 'OPM FG DUAL UOM LOT';
                           item_assign_template (
                              ln_cur_stg.segment1,
                              ln_cur_spining.organization_id,
                              vlp_template_name);
                           vlp_category_id := 2125;
                           assign_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_spining.organization_id,
                              vlp_category_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               ---rmg
               BEGIN
                  FOR ln_cur_rmg IN cur_rmg
                  LOOP
                     BEGIN
                        IF ln_cur_rmg.organization_id NOT IN (143, 144)
                        THEN
                           vlp_template_name :=
                              'DBL DIS RAW MATL DUAL UOM LOT';
                           item_assign_template (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_template_name);
                           vlp_category_id := 2126;
                           assign_item_category (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_category_id);
                        END IF;

                        IF ln_cur_rmg.organization_id IN (139,
                                                          177,
                                                          182,
                                                          187,
                                                          192)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_rmg.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;

               ---htl_knitting
               BEGIN
                  FOR ln_cur_htl_knit IN cur_htl_knit
                  LOOP
                     BEGIN
                        vlp_template_name := 'OPM RAW MATL DUAL UOM LOT';
                        item_assign_template (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_template_name);
                        vlp_category_id := 2126;
                        assign_item_category (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_category_id);

                        IF ln_cur_htl_knit.organization_id IN (169)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_htl_knit.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               vlp_category_id := 2126;
               assign_item_category (ln_cur_stg.segment1,
                                     ln_cur_stg.organization_id,
                                     vlp_category_id);
            ELSE                                               --For Dyed Yarn
               ---rmg
               BEGIN
                  FOR ln_cur_rmg IN cur_rmg
                  LOOP
                     BEGIN
                        IF ln_cur_rmg.organization_id NOT IN (143, 144)
                        THEN
                           vlp_template_name :=
                              'DBL DIS RAW MATL DUAL UOM LOT';
                           item_assign_template (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_template_name);
                           vlp_category_id := 3488;
                           assign_item_category (ln_cur_stg.segment1,
                                                 ln_cur_rmg.organization_id,
                                                 vlp_category_id);
                        END IF;

                        IF ln_cur_rmg.organization_id IN (139,
                                                          177,
                                                          182,
                                                          187,
                                                          192)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_rmg.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;

               ---htl_knitting
               BEGIN
                  FOR ln_cur_htl_knit IN cur_htl_knit
                  LOOP
                     BEGIN
                        vlp_template_name := 'OPM RAW MATL DUAL UOM LOT';
                        item_assign_template (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_template_name);
                        vlp_category_id := 3488;
                        assign_item_category (
                           ln_cur_stg.segment1,
                           ln_cur_htl_knit.organization_id,
                           vlp_category_id);

                        IF ln_cur_htl_knit.organization_id IN (169)
                        THEN
                           create_lcm_item_category (
                              ln_cur_stg.segment1,
                              ln_cur_htl_knit.organization_id);
                        END IF;
                     END;
                  END LOOP;
               END;


               vlp_category_id := 3488;
               assign_item_category (ln_cur_stg.segment1,
                                     ln_cur_stg.organization_id,
                                     vlp_category_id);
         END CASE;



         BEGIN
            item_assign_uom_conv (ln_cur_stg.segment1);
         END;


         UPDATE apps.XXDBL_ITEM_UPLOAD_WEBADI
            SET FLAG = 'Y'
          WHERE FLAG IS NULL AND segment1 = ln_cur_stg.segment1;

         COMMIT;
      END LOOP;

      RETURN 0;
   END;

   PROCEDURE assign_item_org_and_category (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_assign_data;

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
   END assign_item_org_and_category;

   PROCEDURE assign_item_into_org (l_item_code          VARCHAR2,
                                   l_organization_id    NUMBER)
   IS
      g_user_id         fnd_user.user_id%TYPE := NULL;
      l_appl_id         fnd_application.application_id%TYPE;
      l_resp_id         fnd_responsibility_tl.responsibility_id%TYPE;
      l_api_version     NUMBER := 1.0;
      x_message_list    error_handler.error_tbl_type;
      x_return_status   VARCHAR2 (2);
      x_msg_count       NUMBER := 0;
      l_error_msg       VARCHAR2 (1000);
   BEGIN
      SELECT fa.application_id
        INTO l_appl_id
        FROM fnd_application fa
       WHERE fa.application_short_name = 'INV';

      SELECT fr.responsibility_id
        INTO l_resp_id
        FROM fnd_application fa, fnd_responsibility_tl fr
       WHERE     fa.application_short_name = 'INV'
             AND fa.application_id = fr.application_id
             AND UPPER (fr.responsibility_name) = 'INVENTORY';

      fnd_global.apps_initialize (g_user_id, l_resp_id, l_appl_id);



      FOR r1 IN (SELECT inventory_item_id, l_organization_id
                   --INTO V_Inventory_Item_Id, v_Organization_id
                   FROM mtl_system_items_b
                  WHERE segment1 = l_item_code AND organization_id = 138)
      LOOP
         --Call API for IO Assignment to Inventory Item
         ego_item_pub.assign_item_to_org (
            p_api_version         => l_api_version,
            p_inventory_item_id   => r1.inventory_item_id,
            p_organization_id     => r1.l_organization_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count);
         COMMIT;

         l_error_msg :=
               'Status: '
            || x_return_status
            || ' for inventory item id : '
            || r1.inventory_item_id;
         DBMS_OUTPUT.put_line (l_error_msg);

         IF (x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            DBMS_OUTPUT.put_line ('Error Messages :');
            error_handler.get_message_list (x_message_list => x_message_list);

            FOR j IN 1 .. x_message_list.COUNT
            LOOP
               DBMS_OUTPUT.put_line (x_message_list (j).MESSAGE_TEXT);
            END LOOP;
         END IF;
      END LOOP;

      DBMS_LOCK.SLEEP (6);                     --Break process every 6 seconds
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Exception Occured :');
         DBMS_OUTPUT.put_line (SQLCODE || ':' || SQLERRM);
   END assign_item_into_org;

   PROCEDURE assign_item_category (VL_ITEM_CODE          VARCHAR2,
                                   vl_organization_id    NUMBER,
                                   vlu_category_id       NUMBER)
   IS
      v_return_status       VARCHAR2 (1) := NULL;
      v_msg_count           NUMBER := 0;
      v_msg_data            VARCHAR2 (2000);
      v_errorcode           VARCHAR2 (1000);
      v_category_id         NUMBER;
      v_old_category_id     NUMBER;
      v_category_set_id     NUMBER;
      v_inventory_item_id   NUMBER;
      vl_ITEM_ID            NUMBER;
      v_organization_id     NUMBER := vl_organization_id;
      v_context             VARCHAR2 (2);



      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         vi_category_id   NUMBER := vlu_category_id;
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         SELECT MSI.INVENTORY_ITEM_ID
           INTO vl_ITEM_ID
           FROM APPS.MTL_SYSTEM_ITEMS_B MSI
          WHERE MSI.SEGMENT1 = VL_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

         INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                    CATEGORY_SET_ID,
                                                    OLD_CATEGORY_ID,
                                                    CATEGORY_ID,
                                                    PROCESS_FLAG,
                                                    ORGANIZATION_ID,
                                                    SET_PROCESS_ID,
                                                    TRANSACTION_TYPE)
              VALUES (vl_ITEM_ID,
                      1,
                      2124,
                      vi_category_id,
                      1,
                      v_organization_id,
                      1,
                      'UPDATE');

         COMMIT;

         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);

         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      v_context := set_context ('100277', 'Inventory', 131);

      IF v_context = 'F'
      THEN
         DBMS_OUTPUT.put_line ('Error while setting the context');
      END IF;

      SELECT MSI.INVENTORY_ITEM_ID
        INTO vl_ITEM_ID
        FROM APPS.MTL_SYSTEM_ITEMS_B MSI
       WHERE MSI.SEGMENT1 = VL_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

      --- context done ------------
      v_old_category_id := 2124;
      v_category_id := vlu_category_id;
      v_category_set_id := 1;
      v_inventory_item_id := vl_ITEM_ID;
      v_organization_id := v_organization_id;

      INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY_ASSIGNMENT (
         p_api_version         => 1.0,
         p_init_msg_list       => FND_API.G_TRUE,
         p_commit              => FND_API.G_FALSE,
         x_return_status       => v_return_status,
         x_errorcode           => v_errorcode,
         x_msg_count           => v_msg_count,
         x_msg_data            => v_msg_data,
         p_old_category_id     => v_old_category_id,
         p_category_id         => v_category_id,
         p_category_set_id     => v_category_set_id,
         p_inventory_item_id   => v_inventory_item_id,
         p_organization_id     => v_organization_id);
      COMMIT;

      IF v_return_status = fnd_api.g_ret_sts_success
      THEN
         COMMIT;
         DBMS_OUTPUT.put_line (
               'Updation of category assigment is Sucessfull : '
            || v_category_id);
      ELSE
         DBMS_OUTPUT.put_line (
            'Updation of category assigment failed:' || v_msg_data);
         ROLLBACK;

         FOR i IN 1 .. v_msg_count
         LOOP
            v_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
         END LOOP;
      END IF;
   END assign_item_category;

   PROCEDURE create_lcm_item_category (LCM_ITEM_CODE          VARCHAR2,
                                       Lcm_organization_id    NUMBER)
   IS
      v_return_status       VARCHAR2 (1) := NULL;
      v_msg_count           NUMBER := 0;
      v_msg_data            VARCHAR2 (2000);
      v_errorcode           VARCHAR2 (1000);
      v_category_id         NUMBER;
      v_category_set_id     NUMBER;
      v_inventory_item_id   NUMBER;
      vl_ITEM_ID            NUMBER;
      v_organization_id     NUMBER := Lcm_organization_id;
      v_context             VARCHAR2 (2);



      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         SELECT MSI.INVENTORY_ITEM_ID
           INTO vl_ITEM_ID
           FROM APPS.MTL_SYSTEM_ITEMS_B MSI
          WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

         INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                    CATEGORY_SET_ID,
                                                    CATEGORY_ID,
                                                    PROCESS_FLAG,
                                                    ORGANIZATION_ID,
                                                    SET_PROCESS_ID,
                                                    TRANSACTION_TYPE)
              VALUES (vl_ITEM_ID,
                      1,
                      2124,
                      1,
                      v_organization_id,
                      1,
                      'INSERT');

         COMMIT;

         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);


         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      v_context := set_context ('100277', 'Inventory', 131);

      IF v_context = 'F'
      THEN
         DBMS_OUTPUT.put_line ('Error while setting the context');
      END IF;

      SELECT MSI.INVENTORY_ITEM_ID
        INTO vl_ITEM_ID
        FROM APPS.MTL_SYSTEM_ITEMS_B MSI
       WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

      --- context done ------------
      v_category_id := 2124;
      v_category_set_id := 1100000041;
      v_inventory_item_id := vl_ITEM_ID;
      v_organization_id := v_organization_id;

      INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY_ASSIGNMENT (
         p_api_version         => 1.0,
         p_init_msg_list       => FND_API.G_TRUE,
         p_commit              => FND_API.G_FALSE,
         x_return_status       => v_return_status,
         x_errorcode           => v_errorcode,
         x_msg_count           => v_msg_count,
         x_msg_data            => v_msg_data,
         p_category_id         => v_category_id,
         p_category_set_id     => v_category_set_id,
         p_inventory_item_id   => v_inventory_item_id,
         p_organization_id     => v_organization_id);
      COMMIT;

      IF v_return_status = fnd_api.g_ret_sts_success
      THEN
         COMMIT;
         DBMS_OUTPUT.put_line (
               'The Item assignment to category is Successful : '
            || v_category_id);
      ELSE
         DBMS_OUTPUT.put_line (
            'The Item assignment to category failed:' || v_msg_data);
         ROLLBACK;

         FOR i IN 1 .. v_msg_count
         LOOP
            v_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
         END LOOP;
      END IF;
   END create_lcm_item_category;

   PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2)
   IS
      p_from_uom_code        VARCHAR2 (200);
      p_to_uom_code          VARCHAR2 (200);
      p_item_id              NUMBER;
      p_uom_rate             NUMBER;
      x_return_status        VARCHAR2 (200);
      l_msg_data             VARCHAR2 (2000);
      v_context              VARCHAR2 (100);
      um_Inventory_Item_Id   NUMBER;


      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;

         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;

         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         mo_global.set_policy_context ('S', v_org_id);

         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      BEGIN
         v_context := set_context ('100277', 'Inventory', 131);

         IF v_context = 'F'
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Error while setting the context' || SQLERRM (SQLCODE));
         END IF;
      END;

      SELECT inventory_item_id
        INTO um_Inventory_Item_Id
        FROM mtl_system_items_b
       WHERE segment1 = um_item_code AND organization_id = 138;

      p_from_uom_code := 'KG';
      p_to_uom_code := 'NO';
      p_item_id := um_Inventory_Item_Id;
      p_uom_rate := '50';

      INV_CONVERT.CREATE_UOM_CONVERSION (P_FROM_UOM_CODE   => p_from_uom_code,
                                         P_TO_UOM_CODE     => p_to_uom_code,
                                         P_ITEM_ID         => p_item_id,
                                         P_UOM_RATE        => p_uom_rate,
                                         X_RETURN_STATUS   => x_return_status);

      COMMIT;

      IF x_return_status = 'S'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
      ELSIF x_return_status = 'W'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Already Exists ');
      ELSIF x_return_status = 'U'
      THEN
         DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
      ELSIF x_return_status = 'E'
      THEN
         LOOP
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
         END LOOP;
      END IF;
   END item_assign_uom_conv;

   PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                   tm_org_id          IN NUMBER,
                                   tm_template_name   IN VARCHAR2)
   IS
      l_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
      x_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
      l_msg_data             VARCHAR2 (2000);
      v_context              VARCHAR2 (100);
      tm_Inventory_Item_Id   NUMBER;
      tm_Item_description    VARCHAR2 (100);
      x_return_status        VARCHAR2 (1);
      x_msg_count            NUMBER (10);


      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_user;


         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;

         CLOSE cur_resp;


         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);


         mo_global.set_policy_context ('S', v_org_id);


         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      BEGIN
         v_context := set_context ('100277', 'Inventory', 131);

         IF v_context = 'F'
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Error while setting the context' || SQLERRM (SQLCODE));
         END IF;
      END;

      SELECT inventory_item_id, description
        INTO tm_Inventory_Item_Id, tm_Item_description
        FROM mtl_system_items_b
       WHERE segment1 = tm_item_code AND organization_id = 138;


      l_item_tbl (1).Transaction_Type := 'CREATE';
      l_item_tbl (1).Inventory_Item_Status_Code := 'Active';
      l_item_tbl (1).Organization_ID := tm_org_id;
      l_item_tbl (1).Description := tm_Item_description;
      l_item_tbl (1).Segment1 := tm_item_code;
      l_item_tbl (1).Template_Name := tm_template_name;



      DBMS_OUTPUT.PUT_LINE ('=====================================');
      DBMS_OUTPUT.PUT_LINE ('Calling EGO_ITEM_PUB.Process_Items API');
      ego_item_pub.process_items (p_api_version     => 1.0,
                                  p_init_msg_list   => fnd_api.g_true,
                                  p_commit          => fnd_api.g_true,
                                  p_item_tbl        => l_item_tbl,
                                  x_item_tbl        => x_item_tbl,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count);

      DBMS_OUTPUT.PUT_LINE ('=====================================');


      COMMIT;

      IF x_return_status = 'S'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
      ELSIF x_return_status = 'W'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Already Exists ');
      ELSIF x_return_status = 'U'
      THEN
         DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
      ELSIF x_return_status = 'E'
      THEN
         LOOP
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
         END LOOP;
      END IF;
   END item_assign_template;
END XXDBL_ITEM_ASSIGN_WEBADI_PKG;
/