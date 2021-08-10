/* Formatted on 10/13/2020 3:23:00 PM (QP5 v5.287) */
DECLARE
   vl_set_process_id    NUMBER := TO_CHAR (SYSDATE, 'ddmmyyyy');
   V_catalog_Group_id   NUMBER := 54;
   V_organization_id    NUMBER := 138;

   CURSOR cur_item
   IS
      SELECT inventory_item_id v_item_id
        FROM mtl_system_items_b msi
       WHERE     1 = 1
             --AND msi.segment1 IN ('PAPLINRK0GS125R01150')
             AND msi.segment1 LIKE 'PAP%'
             AND msi.item_catalog_group_id IS NULL
             AND msi.organization_id = V_organization_id
             AND EXISTS
                    (SELECT 1
                       FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                      WHERE     1 = 1
                            AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                            AND CAT.SEGMENT3 IN ('PAPER'));
BEGIN
   FOR ln_cur_item IN cur_item
   LOOP
      --Inserting into Item interface table
      BEGIN
         INSERT INTO mtl_system_items_interface (inventory_item_id,
                                                 organization_id,
                                                 process_flag,
                                                 set_process_id,
                                                 transaction_type,
                                                 item_catalog_group_id)
              VALUES (ln_cur_item.v_item_id,
                      v_organization_id,
                      1,
                      vl_set_process_id,
                      'UPDATE',
                      v_catalog_group_id);

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (
                  'Error in inserting record in interface table and error is  : '
               || SUBSTR (SQLERRM, 1, 200));
            fnd_file.put_line (
               fnd_file.LOG,
                  'Error in inserting record in interface table and error is '
               || SUBSTR (SQLERRM, 1, 200));
      END;
   END LOOP;
END;