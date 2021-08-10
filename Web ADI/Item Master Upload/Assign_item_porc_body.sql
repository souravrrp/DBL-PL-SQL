/* Formatted on 6/28/2020 2:04:18 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY apps.cust_webadi_item_assign_pkg
IS
   FUNCTION check_error_log_to_assign_data (EP_ORGANIZATION_ID    NUMBER,
                                            P_LCM_FLAG            VARCHAR2)
      RETURN NUMBER
   IS
      CURSOR cur_stg
      IS
         SELECT *
           FROM apps.cust_webadi_item_upload
          WHERE FLAG IS NULL;
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            assign_item_into_org (ln_cur_stg.segment1, EP_ORGANIZATION_ID);
            assign_item_category (ln_cur_stg.segment1, EP_ORGANIZATION_ID);

            IF P_LCM_FLAG = 'Y'
            THEN
               create_lcm_item_category (ln_cur_stg.segment1,
                                         EP_ORGANIZATION_ID);
            END IF;
         END;
      /*

      UPDATE apps.cust_webadi_item_upload
         SET FLAG = 'Y'
       WHERE     FLAG IS NULL
             AND SL_NO = ln_cur_stg.SL_NO
             AND LINE_NUMBER = ln_cur_stg.LINE_NUMBER;
       */



      END LOOP;

      RETURN 0;
   END;

   PROCEDURE assign_item_org_and_category (
      ERRBUF                  OUT VARCHAR2,
      RETCODE                 OUT VARCHAR2,
      CP_ORGANIZATION_ID   IN     NUMBER,
      LCM_FLAG             IN     VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode :=
         check_error_log_to_assign_data (CP_ORGANIZATION_ID, LCM_FLAG);

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
      l_init_msg_list   VARCHAR2 (2) := fnd_api.g_false;
      l_commit          VARCHAR2 (2) := fnd_api.g_false;
      x_message_list    error_handler.error_tbl_type;
      x_return_status   VARCHAR2 (2);
      x_msg_count       NUMBER := 0;
      l_error_msg       VARCHAR2 (1000);
   --v_inventory_item_id   NUMBER;
   --v_Organization_id     NUMBER;
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
                                   vl_organization_id    NUMBER)
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
      BEGIN
         --NULL;

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
                      2125,
                      1,
                      v_organization_id,
                      1,
                      'UPDATE');

         COMMIT;
         RETURN 0;
      -- In order to reduce the content of the post I moved the implementation part of this function to another post and it is   available here
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
      v_category_id := 2125;
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
      BEGIN
         --NULL;

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
         RETURN 0;
      -- In order to reduce the content of the post I moved the implementation part of this function to another post and it is   available here
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
END cust_webadi_item_assign_pkg;
/