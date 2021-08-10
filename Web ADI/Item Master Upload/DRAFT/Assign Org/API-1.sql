/* Formatted on 6/27/2020 2:57:21 PM (QP5 v5.287) */
DECLARE
   l_mesg              VARCHAR2 (1000);
   l_count             NUMBER;
   v_master_org        NUMBER;
   v_organization_id   NUMBER;
   v_item_id           NUMBER;
BEGIN
   --Getting the Organization id
   BEGIN
      SELECT Organization_id, master_organization_id
        INTO v_organization_id, v_master_org
        FROM mtl_parameters mp
       WHERE mp.organization_code = '103'; --101 is the Child Organization Code
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (
               'Error in getting the Organization id for Organization code V1 and error is '
            || SUBSTR (SQLERRM, 1, 200));
   END;

   --Getting the Inventory Item id of the Item which is available in Master Organization
   BEGIN
      SELECT inventory_item_id
        INTO v_item_id
        FROM mtl_system_items_b
       WHERE     segment1 = 'SPRECONS000000067004'      --'Existing Item Name'
             AND organization_id = v_master_org;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (
               'Error in getting the inventory item id for Item and error is '
            || SUBSTR (SQLERRM, 1, 200));
   END;

   EGO_ITEM_PUB.Assign_Item_To_Org (p_api_version       => 1.0,
                                    p_Item_Number       => v_item_id,
                                    p_Organization_Id   => v_organization_id,
                                    x_return_status     => l_mesg,
                                    x_msg_count         => l_count);

   COMMIT;

   IF l_count = 1
   THEN
      DBMS_OUTPUT.put_line ('Error in API is ' || l_mesg);
   ELSIF l_count > 1
   THEN
      LOOP
         l_count := l_count + 1;
         l_mesg := FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

         IF l_mesg IS NULL
         THEN
            EXIT;
         END IF;

         DBMS_OUTPUT.put_line ('Message' || l_count || ' ---' || l_mesg);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error in the API and error is');
      DBMS_OUTPUT.put_line (SQLCODE || ':' || SQLERRM);
--DBMS_OUTPUT.put_line('Error in the API and error is '||SUBSTR(SQLERRM,1,200));
END;