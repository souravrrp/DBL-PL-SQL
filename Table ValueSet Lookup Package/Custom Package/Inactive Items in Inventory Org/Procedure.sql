/* Formatted on 10/14/2020 5:54:56 PM (QP5 v5.287) */
/**** STEP 2) Call below API code to do the actual change ****/

DECLARE
   x_return_status   VARCHAR2 (100);
   x_msg_count       NUMBER;
   x_msg_data        VARCHAR2 (1000);
   l_user_name       VARCHAR2 (100) := '103908';

   CURSOR cur_items
   IS
      SELECT msi.organization_id l_organization_id,
             msi.inventory_item_id l_item_id
        FROM apps.mtl_system_items_b msi,
             apps.org_organization_definitions ood,
             apps.mtl_item_categories_v cat
       WHERE     1 = 1
             AND msi.organization_id = ood.organization_id
             AND msi.inventory_item_id = cat.inventory_item_id
             AND msi.organization_id = cat.organization_id
             AND msi.inventory_item_status_code = 'Active'
             --AND ORGANIZATION_CODE NOT IN ('IMO')
             --AND ORGANIZATION_CODE IN ('251')
             --AND OPERATING_UNIT IN (85)
             --AND MSI.INVENTORY_ITEM_ID IN ('7297')
             --AND MSI.SEGMENT1 IN ('FT-GP6060-038BK')
             --AND MSI.DESCRIPTION IN ('40S1-COTTON-100%-CH ORGANIC')
             --AND MSI.PRIMARY_UOM_CODE='PCS'
             --AND MSI.ORGANIZATION_ID IN (101)
             AND cat.category_set_id = 1
             --AND CAT.CATEGORY_ID='74551'
             --AND CAT.SEGMENT2 NOT IN ('FINISH GOODS')
             --AND CAT.SEGMENT2='BRND'
             --AND CAT.SEGMENT3='GIFT'
             AND msi.enabled_flag = 'Y';
BEGIN
   SELECT user_id l_user_id
     FROM fnd_user
    WHERE user_name = l_user_name;

   FOR rec_cur_items IN cur_items
   LOOP
      BEGIN
         INSERT INTO mtl_pending_item_status (inventory_item_id,
                                              organization_id,
                                              status_code,
                                              effective_date,
                                              implemented_date,
                                              pending_flag,
                                              last_update_date,
                                              last_updated_by,
                                              creation_date,
                                              created_by)
              VALUES (inventory_item_id,                       -- Item Segment
                      114,                                  -- Organization Id
                      'Inactive',                                    -- status
                      SYSDATE,
                      SYSDATE,
                      'Y',
                      SYSDATE,
                      l_user_id,
                      SYSDATE,
                      l_user_id);

         inv_item_status_pub.update_pending_status (
            p_api_version     => 1.0,
            p_org_id          => l_organization_id          -- Organization Id
                                                  ,
            p_item_id         => l_item_id                     -- Item Segment
                                          ,
            p_init_msg_list   => fnd_api.g_false,
            p_commit          => fnd_api.g_false,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data);
      END;
   END LOOP;

   COMMIT;
END;