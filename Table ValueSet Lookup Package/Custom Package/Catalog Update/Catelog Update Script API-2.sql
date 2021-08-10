/* Formatted on 8/18/2020 3:33:23 PM (QP5 v5.287) */
DECLARE
   l_cat_rec              inv_item_category_pub.category_rec_type;
   l_cat_item             inv_item_catalog_elem_pub.item_desc_element;
   l_cat_tab              inv_item_catalog_elem_pub.item_desc_element_table;
   l_cat_tab_ind          NUMBER := 0;
   l_return_status        VARCHAR2 (4000);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2 (4000);
   l_message              VARCHAR2 (4000);
   v_message              VARCHAR2 (4000);
   v_generated_descr      VARCHAR2 (4000);
   v_msg_index_out        NUMBER;
   ct_inventory_item_id   NUMBER;
BEGIN
   l_cat_item := NULL;

   l_cat_tab_ind := l_cat_tab_ind + 1;

   SELECT inventory_item_id
     INTO ct_inventory_item_id
     FROM mtl_system_items_b
    WHERE segment1 = 'YRN10S100CTN52197849' AND organization_id = 138;

   l_cat_item.element_name := 'Item Type';
   l_cat_item.element_value := 'YRN';                 --SUBSTR ('SP2', 1, 30);
   l_cat_item.description_default := 'N';

   l_cat_tab (l_cat_tab_ind) := l_cat_item;

   -- catalog has been created, so add
   ego_item_pub.Process_item_descr_elements (
      p_api_version               => 1.0,
      p_init_msg_list             => fnd_api.g_true,
      p_commit_flag               => fnd_api.g_false,
      p_inventory_item_id         => ct_inventory_item_id,
      p_item_desc_element_table   => l_cat_tab,
      x_generated_descr           => v_generated_descr,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data);
   DBMS_OUTPUT.put_line (l_msg_count || ' errors ');

   IF l_msg_count > 0
   THEN
      FOR v_index IN 1 .. l_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index       => v_index,
                          p_encoded         => 'F',
                          p_data            => l_msg_data,
                          p_msg_index_out   => v_msg_index_out);
         v_message := SUBSTR (l_msg_data, 1, 3000);
         DBMS_OUTPUT.put_line (v_message || v_generated_descr);
      END LOOP;
   END IF;
END;