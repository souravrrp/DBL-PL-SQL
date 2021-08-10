/* Formatted on 6/28/2020 1:11:47 PM (QP5 v5.287) */
PROCEDURE create_lcm_item_category (VL_ITEM_CODE          VARCHAR2,
                                vl_organization_id    NUMBER)
IS
   v_return_status       VARCHAR2 (1) := NULL;
   v_msg_count           NUMBER := 0;
   v_msg_data            VARCHAR2 (2000);
   v_errorcode           VARCHAR2 (1000);
   v_category_id         NUMBER;
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
    WHERE MSI.SEGMENT1 = VL_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

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
         'The Item assignment to category is Successful : ' || v_category_id);
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