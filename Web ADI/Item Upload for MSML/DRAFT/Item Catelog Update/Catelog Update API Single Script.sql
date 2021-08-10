/* Formatted on 8/8/2020 6:00:42 PM (QP5 v5.287) */
BEGIN
   DECLARE
      v_inv_item_id              NUMBER := 0;
      v_catalog_Group_id         NUMBER := 0;
      v_organization_id          NUMBER := 193;
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
      --Getting the item id for the existing item ABCTEST
      BEGIN
         SELECT inventory_item_id
           INTO v_inv_item_id
           FROM mtl_system_items_b msi, mtl_parameters mp
          WHERE     msi.organization_id = mp.organization_id
                AND msi.segment1 = 'ABCTEST'
                AND mp.organization_code = 'V1';
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
                  'Error in getting the item id for Item ABCTEST and error is '
               || SUBSTR (SQLERRM, 1, 200));
      END;

      -- Populating the pl/Sql table. In this for Element Name CatalogElement1, Element value ABCValue1 is Mapped.

      l_current_item_desc_elem.DESCRIPTION_DEFAULT := 'Y';
      l_current_item_desc_elem.ELEMENT_NAME := 'CatalogElement1';
      l_current_item_desc_elem.ELEMENT_VALUE := 'ABCValue1';
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
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line (fnd_file.LOG,
                            'Error ' || SUBSTR (SQLERRM, 1, 200));
   END;
END;