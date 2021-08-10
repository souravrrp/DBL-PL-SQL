/* Formatted on 6/28/2020 9:50:29 AM (QP5 v5.287) */
DECLARE
   v_return_status       VARCHAR2 (1) := NULL;
   v_msg_count           NUMBER := 0;
   v_msg_data            VARCHAR2 (2000);
   v_errorcode           VARCHAR2 (1000);
   v_category_id         NUMBER;
   v_old_category_id     NUMBER;
   v_category_set_id     NUMBER;
   v_inventory_item_id   NUMBER;
   v_organization_id     NUMBER;
   v_context             VARCHAR2 (2);

   FUNCTION set_context (i_user_name   IN VARCHAR2,
                         i_resp_name   IN VARCHAR2,
                         i_org_id      IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      --NULL;
      INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                 CATEGORY_SET_ID,
                                                 OLD_CATEGORY_ID,
                                                 CATEGORY_ID,
                                                 PROCESS_FLAG,
                                                 ORGANIZATION_ID,
                                                 SET_PROCESS_ID,
                                                 TRANSACTION_TYPE)
           VALUES (311148,
                   1,
                   2124,
                   2125,
                   1,
                   195,
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

   --- context done ------------
   v_old_category_id := 2124;
   v_category_id := 2125;
   v_category_set_id := 1;
   v_inventory_item_id := 311148;
   v_organization_id := 195;

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
         'Updation of category assigment is Sucessfull : ' || v_category_id);
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
END;