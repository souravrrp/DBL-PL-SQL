/* Formatted on 6/27/2020 3:18:48 PM (QP5 v5.287) */
PROCEDURE initialize_segment_len (p_item_code          VARCHAR2,
                                  p_organization_id    VARCHAR2)
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

   FOR r1 IN (SELECT inventory_item_id, p_Organization_id
                INTO v_inventory_item_id, v_Organization_id
                FROM mtl_system_items_b
               WHERE segment1 = p_item_code AND organization_id = 138)
   LOOP
      --Call API for IO Assignment to Inventory Item
      ego_item_pub.assign_item_to_org (
         p_api_version         => l_api_version,
         p_inventory_item_id   => r1.inventory_item_id,
         p_organization_id     => r1.organization_id,
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

   DBMS_LOCK.SLEEP (6);                        --Break process every 6 seconds
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Exception Occured :');
      DBMS_OUTPUT.put_line (SQLCODE || ':' || SQLERRM);
END initialize_segment_len;