/* Formatted on 10/13/2020 3:32:14 PM (QP5 v5.287) */
DECLARE
   v_catelog_update   VARCHAR2 (100);
   ct_item_code       VARCHAR2 (20);

   CURSOR cur_item_type
   IS
      SELECT inventory_item_id item_id,
             'PAPER' ct_item_type,
             'Item Type' ct_element_name
        FROM mtl_system_items_b msi
       WHERE     1 = 1
             AND msi.item_catalog_group_id = 54
             AND msi.segment1 LIKE 'PAP%'
             --AND msi.segment1 IN ('PAPLINRK0GS125R01150')
             AND msi.organization_id = 138
             AND EXISTS
                    (SELECT 1
                       FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                      WHERE     1 = 1
                            AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                            AND CAT.SEGMENT3 IN ('PAPER'));

   CURSOR cur_paper_cat
   IS
      SELECT inventory_item_id item_id,
             REGEXP_SUBSTR (msi.description,
                            '[^,]+',
                            1,
                            1)
                ct_paper_cat,
             'Paper Category' ct_element_name
        FROM mtl_system_items_b msi
       WHERE     1 = 1
             AND msi.item_catalog_group_id = 54
             AND msi.segment1 LIKE 'PAP%'
             --AND msi.segment1 IN ('PAPLINRK0GS125R01150')
             AND msi.organization_id = 138
             AND EXISTS
                    (SELECT 1
                       FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                      WHERE     1 = 1
                            AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                            AND CAT.SEGMENT3 IN ('PAPER'));

   CURSOR cur_gsm
   IS
      SELECT inventory_item_id item_id,
             REGEXP_SUBSTR (msi.description,
                            '[^,]+',
                            1,
                            2)
                ct_gsm,
             'Paper GSM' ct_element_name
        FROM mtl_system_items_b msi
       WHERE     1 = 1
             AND msi.item_catalog_group_id = 54
             AND msi.segment1 LIKE 'PAP%'
             --AND msi.segment1 IN ('PAPLINRK0GS125R01150')
             AND msi.organization_id = 138
             AND EXISTS
                    (SELECT 1
                       FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                      WHERE     1 = 1
                            AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                            AND CAT.SEGMENT3 IN ('PAPER'));

   CURSOR cur_real_size
   IS
      SELECT inventory_item_id item_id,
             REGEXP_SUBSTR (msi.description,
                            '[^,]+',
                            1,
                            3)
                ct_real_size,
             'Paper Reel Size' ct_element_name
        FROM mtl_system_items_b msi
       WHERE     1 = 1
             AND msi.item_catalog_group_id = 54
             AND msi.segment1 LIKE 'PAP%'
             --AND msi.segment1 IN ('PAPLINRK0GS125R01150')
             AND msi.organization_id = 138
             AND EXISTS
                    (SELECT 1
                       FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                      WHERE     1 = 1
                            AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                            AND CAT.SEGMENT3 IN ('PAPER'));

   FUNCTION item_catelog_api (ct_item_id      NUMBER,
                              ct_element   IN VARCHAR2,
                              ct_value     IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_inv_item_id              NUMBER := ct_item_id;
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
      v_return                   VARCHAR2 (10) := 'Y';
   BEGIN
      /*
      BEGIN
         SELECT inventory_item_id
           INTO v_inv_item_id
           FROM mtl_system_items_b msi
          WHERE msi.organization_id = 138 AND msi.segment1 = ct_item_code;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
                  'Error in getting the item id for Item '
               || ct_item_code
               || ' and error is '
               || SUBSTR (SQLERRM, 1, 200));
      END;
      */



      IF ct_element = 'Item Type'
      THEN
         l_current_item_desc_elem.DESCRIPTION_DEFAULT := 'N';
      ELSE
         l_current_item_desc_elem.DESCRIPTION_DEFAULT := 'Y';
      END IF;

      --l_current_item_desc_elem.DESCRIPTION_DEFAULT := 'Y';
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
                  'Element value '
               || ct_value
               || ' is Successfully assigned to the element name '
               || ct_element
               || ' for the Item '
               || ct_item_code
               || '.');
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
                  'Error in assigning Element value '
               || ct_value
               || ' to the element name '
               || ct_element
               || ' for the Item '
               || ct_item_code
               || ' and reason is '
               || l_error_message);
         END IF;
      END;

      RETURN v_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END item_catelog_api;
BEGIN
   --Getting the item id for the existing item ABCTEST

   BEGIN
      DBMS_OUTPUT.put_line ('The Item Code : ' || ct_item_code);

      FOR r_item_type IN cur_item_type
      LOOP
         BEGIN
            DBMS_OUTPUT.put_line (
               'The Item Type : ' || r_item_type.ct_item_type);
            v_catelog_update :=
               item_catelog_api (r_item_type.item_id,
                                 r_item_type.ct_element_name,
                                 r_item_type.ct_item_type);
         END;
      END LOOP;

      FOR r_paper_cat IN cur_paper_cat
      LOOP
         BEGIN
            DBMS_OUTPUT.put_line (
               'The Item Count : ' || r_paper_cat.ct_paper_cat);
            v_catelog_update :=
               item_catelog_api (r_paper_cat.item_id,
                                 r_paper_cat.ct_element_name,
                                 r_paper_cat.ct_paper_cat);
         END;
      END LOOP;

      FOR r_gsm IN cur_gsm
      LOOP
         BEGIN
            DBMS_OUTPUT.put_line ('The Product Type : ' || r_gsm.ct_gsm);
            v_catelog_update :=
               item_catelog_api (r_gsm.item_id,
                                 r_gsm.ct_element_name,
                                 r_gsm.ct_gsm);
         END;
      END LOOP;

      FOR r_real_size IN cur_real_size
      LOOP
         BEGIN
            DBMS_OUTPUT.put_line (
               'The Item Content : ' || r_real_size.ct_real_size);
            v_catelog_update :=
               item_catelog_api (r_real_size.item_id,
                                 r_real_size.ct_element_name,
                                 r_real_size.ct_real_size);
         END;
      END LOOP;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      fnd_file.put_line (fnd_file.LOG, 'Error ' || SUBSTR (SQLERRM, 1, 200));
END;