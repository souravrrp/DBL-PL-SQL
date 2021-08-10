SELECT (SELECT inventory_item_id
                      FROM mtl_system_items_b msib
                     WHERE msib.segment1 = msii.segment1 AND ROWNUM = 1)
                      inventory_item_id,               --get inventory item id
                   msii.organization_id
              FROM xrspi_inv_api_assign_io_tmp msii --table custom for temporary upload
             WHERE NOT EXISTS
                      (SELECT 1
                         FROM mtl_system_items_b msib              --condition
                        WHERE     msib.segment1 = msii.segment1 --for item didn't exists
                              AND msib.organization_id = msii.organization_id) --in MTL_SYSTEM_ITEMS_B
          ORDER BY msii.segment1

SELECT inventory_item_id, '195' Organization_id
--        INTO v_item_id
        FROM mtl_system_items_b
       WHERE     segment1 = 'SPRECONS000000067004'      --'Existing Item Name'
             AND organization_id = 138;
             
             
             SELECT Organization_id, master_organization_id
--        INTO v_organization_id, v_master_org
        FROM mtl_parameters mp
       WHERE mp.organization_code = '101';