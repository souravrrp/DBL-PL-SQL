DECLARE
 V_item_id                   NUMBER: = 0;
 V_catalog_Group_id          NUMBER: = 0;
 V_organization_id           NUMBER: = 0;
 V_request_id                NUMBER: = 0; 
BEGIN 
  --Getting the Organization id   
  BEGIN
      SELECT Organization_id
      INTO   v_organization_id
      FROM   mtl_parameters mp
      WHERE  mp.organization_code = 'V1';
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG,'Error in getting the Organization id for Organization code V1 and error is '||SUBSTR (SQLERRM, 1,200));
   END;

   --Getting the item id for the existing item ABCTEST
   BEGIN
      SELECT inventory_item_id
      INTO   v_item_id
      FROM   mtl_system_items_b msi
      WHERE  msi.segment1 = 'ABCTEST'
      AND    msi.organization_id = v_organization_id;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG,'Error in getting the item id for Item ABCTEST and error is '||SUBSTR (SQLERRM, 1,200));
   END;


   --Getting the catalog group id for the existing Catalog Group Name 'NewCatalog'
   BEGIN
      SELECT item_catalog_group_id
      INTO   v_catalog_group_id
      FROM   mtl_item_catalog_groups
      WHERE segment1='NewCatalog';
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG,'Error in getting the catalog group id for catalog group Newcatalog and error is '||SUBSTR (SQLERRM, 1,200));
   END;

   --Inserting into Item interface table
   BEGIN
      INSERT INTO mtl_system_items_interface
                 (inventory_item_id,
                  organization_id,
                  process_flag,
                  set_process_id,
                  transaction_type,
                  item_catalog_group_id
                  )
            VALUES
                 (v_item_id,
                  v_organization_id,
                  1,
                  1,
                  'UPDATE',
                  v_catalog_group_id
                  );
        COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG,'Error in inserting record in interface table and error is '||SUBSTR (SQLERRM, 1,200));
   END;
  
   --Submit the item import program in Update Mode to update the item catalog group information
   BEGIN
     
        fnd_file.put_line (fnd_file.LOG,'--Submitting Item Import Program for Item--');
     
     
        v_request_id:= Fnd_Request.submit_request (
                       application   => 'INV',
                       Program       => 'INCOIN',
                       description   => NULL,
                       start_time    => SYSDATE,
                       sub_request   => FALSE,
                       argument1     => v_organization_id,
                       argument2     => 1,            
                       argument3     => 1,  --Group ID option (All)
                       argument4     => 1,  -- Group ID Dummy
                       argument5     => 1,  -- Delete processed Record  
                       argument6     => 1,  -- Set Process id                    
                       argument7     => 2   -- Update item
                       ); 
         COMMIT;                      
         IF (v_request_id = 0) THEN        
             fnd_file.put_line (fnd_file.LOG,'Item Import Program Not Submitted');
         ELSE
             fnd_file.put_line (fnd_file.LOG,'Item Import Program submitted');            
         END IF;
  END;

END;
