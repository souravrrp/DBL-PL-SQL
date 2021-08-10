/* Formatted on 8/9/2020 10:59:26 AM (QP5 v5.287) */
PROCEDURE item_catelog_update (ct_item_code IN VARCHAR2)
IS
   v_inv_item_id      NUMBER := 0;
   ct_item_type       VARCHAR2 (3);
   ct_item_count      VARCHAR2 (6);
   ct_product_type    VARCHAR2 (3);
   ct_item_content    VARCHAR2 (3);
   ct_item_style      VARCHAR2 (3);
   ct_item_process    VARCHAR2 (2);
   ct_item_segments   VARCHAR2 (6);
   ct_element_name    VARCHAR2 (6);

   CURSOR cur_item_type
   IS
      SELECT SUBSTR (SEGMENT1, 1, 3), 'Item Type'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;

   CURSOR cur_item_count
   IS
      SELECT SUBSTR (SEGMENT1, 4, 6), 'Count'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;

   CURSOR cur_product_type
   IS
      SELECT SUBSTR (SEGMENT1, 10, 3), 'Product Type'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;

   CURSOR cur_item_content
   IS
      SELECT SUBSTR (SEGMENT1, 13, 3), 'Content'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;

   CURSOR cur_item_style
   IS
      SELECT SUBSTR (SEGMENT1, 16, 3), 'Style'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;

   CURSOR cur_item_process
   IS
      SELECT SUBSTR (SEGMENT1, 18, 2), 'Process'
        INTO ct_item_segments, ct_element_name
        FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI
       WHERE SEGMENT1 = ct_item_code;
BEGIN
   --Getting the item id for the existing item ABCTEST
   BEGIN
      SELECT inventory_item_id
        INTO v_inv_item_id
        FROM mtl_system_items_b msi
       WHERE msi.organization_id = ct_org_id AND msi.segment1 = ct_item_code;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line (
            fnd_file.LOG,
               'Error in getting the item id for Item ABCTEST and error is '
            || SUBSTR (SQLERRM, 1, 200));
   END;


   BEGIN
      FOR r_item_type IN cur_item_type
      LOOP
         BEGIN
            item_catelog_api (r_item_type.ct_item_segments,
                              r_item_type.ct_element_name);
         END;
      END LOOP;

      FOR r_item_count IN cur_item_count
      LOOP
         BEGIN
            item_catelog_api (r_item_count.ct_item_segments,
                              r_item_count.ct_element_name);
         END;
      END LOOP;

      FOR r_product_type IN cur_product_type
      LOOP
         BEGIN
            item_catelog_api (r_product_type.ct_item_segments,
                              r_product_type.ct_element_name);
         END;
      END LOOP;

      FOR r_item_content IN cur_item_content
      LOOP
         BEGIN
            item_catelog_api (r_item_content.ct_item_segments,
                              r_item_content.ct_element_name);
         END;
      END LOOP;

      FOR r_item_style IN cur_item_style
      LOOP
         BEGIN
            item_catelog_api (r_item_style.ct_item_segments,
                              r_item_style.ct_element_name);
         END;
      END LOOP;

      FOR r_item_process IN cur_item_process
      LOOP
         BEGIN
            item_catelog_api (r_item_process.ct_item_segments,
                              r_item_process.ct_element_name);
         END;
      END LOOP;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      fnd_file.put_line (fnd_file.LOG, 'Error ' || SUBSTR (SQLERRM, 1, 200));
END item_catelog_update;

PROCEDURE item_catelog_api (ct_element IN VARCHAR2, ct_value IN VARCHAR2)
IS
   v_inv_item_id              NUMBER := 0;
   v_catalog_Group_id         NUMBER := 0;
   v_organization_id          NUMBER := 0;
   x_generated_descr          VARCHAR2 (240);
   x_return_status            VARCHAR2 (1);
   x_errorcode                NUMBER;
   x_msg_count                NUMBER;
   x_msg_data                 VARCHAR2 (1000);
   x_msg_index_out            NUMBER := 0;
   l_item_desc_elem_table     INV_ITEM_CATALOG_ELEM_PUB.ITEM_DESC_ELEMENT_TABLE;
   l_current_item_desc_elem   INV_ITEM_CATALOG_ELEM_PUB.ITEM_DESC_ELEMENT;
   l_error_message            VARCHAR2 (1000);
   j                          NUMBER := 0;
BEGIN
   l_current_item_desc_elem.DESCRIPTION_DEFAULT := 'Y';
   l_current_item_desc_elem.ELEMENT_NAME := ct_element;
   l_current_item_desc_elem.ELEMENT_VALUE := ct_value;
   l_item_desc_elem_table (j) := l_current_item_desc_elem;

   BEGIN
      FND_MSG_PUB.INITIALIZE;

      --API to assign Element Value to the Item--
      inv_item_catalog_elem_pub.process_item_descr_elements (
         p_api_version               => 1.0,
         p_inventory_item_id         => v_inv_item_id,
         p_item_desc_element_table   => l_item_desc_elem_table,
         x_generated_descr           => x_generated_descr,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data);
      COMMIT;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
         fnd_file.put_line (
            fnd_file.LOG,
            'Element value ABCValue1 is Successfully assigned to the element name CatalogElement1 for the Item ABCTEST ');
      ELSE
         --Getting the Error Reason if the element value is not assigned
         -- If there are multiple errors
         IF (FND_MSG_PUB.Count_Msg > 1)
         THEN
            FOR k IN 1 .. FND_MSG_PUB.Count_Msg
            LOOP
               FND_MSG_PUB.Get (p_msg_index       => k,
                                p_encoded         => 'F',
                                p_data            => x_msg_data,
                                p_msg_index_out   => x_msg_index_out);

               IF x_msg_data IS NOT NULL
               THEN
                  l_error_message := l_error_message || '-' || x_msg_data;
               END IF;
            END LOOP;
         ELSE
            --Only one error
            FND_MSG_PUB.Get (p_msg_index       => 1,
                             p_encoded         => 'F',
                             p_data            => x_msg_data,
                             p_msg_index_out   => x_msg_index_out);

            l_error_message := x_msg_data;
         END IF;

         Fnd_file.put_line (
            fnd_file.LOG,
               'Error in assigning Element value ABCValue1 to the element name CatalogElement1 for the Item ABCTEST and reason is '
            || l_error_message);
      END IF;
   END;
END item_catelog_api;