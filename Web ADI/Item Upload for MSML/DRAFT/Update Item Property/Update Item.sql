/* Formatted on 6/30/2020 11:10:12 AM (QP5 v5.287) */
DECLARE
   l_item_tbl_typ        ego_item_pub.item_tbl_type;
   x_item_table          ego_item_pub.item_tbl_type;
   x_inventory_item_id   mtl_system_items_b.inventory_item_id%TYPE;
   x_organization_id     mtl_system_items_b.organization_id%TYPE;
   x_return_status       VARCHAR2 (1);
   x_msg_count           NUMBER (10);
   x_msg_data            VARCHAR2 (1000);
   x_message_list        error_handler.error_tbl_type;

   CURSOR lcu_validated_data
   IS
      SELECT ORGANIZATION_ID, --TAX_CODE,     --Here TAX Code is not Updated Because ----there is no Tax code defined in the System  in AR
                             TAXABLE_FLAG, inventory_item_id
        FROM xxsff_mtl_items_b_stg             --xx_mtl_system_items_stg xxmtb
       WHERE organization_id = 101;                         ---ORGANIZATION_ID
BEGIN
   FOR i IN lcu_validated_data
   LOOP
      --Setting FND global variables.
      --Replace MFG user name with appropriate user name.
      /*   fnd_global.apps_initialize (11224
                                   , 20634
                                   , 401
                                    );*/
      --FIRST Item definition
      l_item_tbl_typ (1).transaction_type := 'UPDATE'; -- Replace this with 'UPDATE' for update transaction.
      l_item_tbl_typ (1).inventory_item_id := i.inventory_item_id;
      l_item_tbl_typ (1).organization_id := i.organization_id;
      --      l_item_tbl_typ (1).TAX_CODE := i.tax_code;
      l_item_tbl_typ (1).TAXABLE_FLAG := i.TAXABLE_FLAG;
      --      l_item_tbl_typ (1).price_tolerance_percent := '';
      DBMS_OUTPUT.put_line ('=====================================');
      DBMS_OUTPUT.put_line ('Calling EGO_ITEM_PUB.Process_Items API');
      ego_item_pub.process_items (p_api_version     => 1.0,
                                  p_init_msg_list   => fnd_api.g_true,
                                  p_commit          => fnd_api.g_true,
                                  p_item_tbl        => l_item_tbl_typ,
                                  x_item_tbl        => x_item_table,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count);

      DBMS_OUTPUT.put_line ('==================================');
      DBMS_OUTPUT.put_line ('Return Status ==>' || x_return_status);

      IF (x_return_status = fnd_api.g_ret_sts_success)
      THEN
         FOR i IN 1 .. x_item_table.COUNT
         LOOP
            DBMS_OUTPUT.put_line (
                  'Inventory Item Id :'
               || TO_CHAR (x_item_table (i).inventory_item_id));
         --DBMS_OUTPUT.put_line ('Organization Id   :' || TO_CHAR (x_item_table (i).organization_id));
         END LOOP;
      ELSE
         DBMS_OUTPUT.put_line ('Error Messages :');
         error_handler.get_message_list (x_message_list => x_message_list);

         FOR i IN 1 .. x_message_list.COUNT
         LOOP
            DBMS_OUTPUT.put_line (x_message_list (i).MESSAGE_TEXT);
         END LOOP;
      END IF;

      DBMS_OUTPUT.put_line ('==================================');
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Exception Occured :');
      DBMS_OUTPUT.put_line (SQLCODE || ':' || SQLERRM);
      DBMS_OUTPUT.put_line ('=====================================');
END;