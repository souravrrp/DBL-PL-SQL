/* Formatted on 8/26/2020 4:39:12 PM (QP5 v5.287) */
DECLARE
   vl_set_process_id      NUMBER := TO_CHAR (SYSDATE, 'ddmmyyyy');
   cg_item_code           VARCHAR2 (20) := 'PAPLINRK0GS127R01400';
   cg_catelog_group       VARCHAR2 (100) := 'Paper';
   v_item_id              NUMBER := 0;
   V_catalog_Group_id     NUMBER := 0;
   V_organization_id      NUMBER := 138;
   V_request_id           NUMBER := 0;
   lv_req_return_status   BOOLEAN;
   lv_req_phase           VARCHAR2 (240);
   lv_req_status          VARCHAR2 (240);
   lv_req_dev_phase       VARCHAR2 (240);
   lv_req_dev_status      VARCHAR2 (240);
   lv_req_message         VARCHAR2 (240);
BEGIN
   --Getting the item id for the existing item ABCTEST
   BEGIN
      SELECT inventory_item_id
        INTO v_item_id
        FROM mtl_system_items_b msi
       WHERE     msi.segment1 = cg_item_code
             AND msi.organization_id = v_organization_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (
               'Error in getting the item id for Item '
            || cg_item_code
            || ' and error is '
            || SUBSTR (SQLERRM, 1, 200));
         fnd_file.put_line (
            fnd_file.LOG,
               'Error in getting the item id for Item '
            || cg_item_code
            || ' and error is '
            || SUBSTR (SQLERRM, 1, 200));
   END;


   --Getting the catalog group id for the existing Catalog Group Name 'NewCatalog'
   BEGIN
      SELECT item_catalog_group_id
        INTO v_catalog_group_id
        FROM mtl_item_catalog_groups
       WHERE segment1 = cg_catelog_group;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (
               'Error in getting the catalog group id for catalog group '
            || cg_catelog_group
            || ' and error is : '
            || SUBSTR (SQLERRM, 1, 200));
         fnd_file.put_line (
            fnd_file.LOG,
               'Error in getting the catalog group id for catalog group '
            || cg_catelog_group
            || ' and error is '
            || SUBSTR (SQLERRM, 1, 200));
   END;


   --Inserting into Item interface table
   BEGIN
      INSERT INTO mtl_system_items_interface (inventory_item_id,
                                              organization_id,
                                              process_flag,
                                              set_process_id,
                                              transaction_type,
                                              item_catalog_group_id)
           VALUES (v_item_id,
                   v_organization_id,
                   1,
                   vl_set_process_id,                               --1383120,
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

   /*
   -----------------------------------------------------------------------------------------------

   --Submit the item import program in Update Mode to update the item catalog group information
   BEGIN
      DBMS_OUTPUT.put_line ('--Submitting Item Import Program for Item--');
      fnd_file.put_line (fnd_file.LOG,
                         '--Submitting Item Import Program for Item--');


      v_request_id :=
         Fnd_Request.submit_request (application   => 'INV',
                                     Program       => 'INCOIN',
                                     description   => NULL,
                                     start_time    => SYSDATE,
                                     sub_request   => FALSE,
                                     argument1     => v_organization_id,
                                     argument2     => 1,
                                     argument3     => 1, --Group ID option (All)
                                     argument4     => 1,     -- Group ID Dummy
                                     argument5     => 1, -- Delete processed Record
                                     argument6     => vl_set_process_id, --1383120, -- Set Process id
                                     argument7     => 2         -- Update item
                                                       );

      LOOP
         lv_req_return_status :=
            fnd_concurrent.wait_for_request (v_request_id,
                                             60,
                                             0,
                                             lv_req_phase,
                                             lv_req_status,
                                             lv_req_dev_phase,
                                             lv_req_dev_status,
                                             lv_req_message);
         EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                   OR UPPER (lv_req_status) IN
                         ('CANCELLED', 'ERROR', 'TERMINATED');
      END LOOP;

      COMMIT;

      IF (v_request_id = 0)
      THEN
         DBMS_OUTPUT.put_line ('Item Import Program Not Submitted');
         fnd_file.put_line (fnd_file.LOG,
                            'Item Import Program Not Submitted');
      ELSE
         DBMS_OUTPUT.put_line (
            'Item Import Program submitted' || SUBSTR (SQLERRM, 1, 200));
         fnd_file.put_line (fnd_file.LOG, 'Item Import Program submitted');
      END IF;
   END;
   */
END;