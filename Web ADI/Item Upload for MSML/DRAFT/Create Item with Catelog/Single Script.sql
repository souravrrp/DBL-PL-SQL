/* Formatted on 8/18/2020 1:00:46 PM (QP5 v5.287) */
DECLARE
   x_item_tbl                EGO_ITEM_PUB.ITEM_TBL_TYPE;
   x_message_list            Error_Handler.Error_Tbl_Type;
   x_return_status           VARCHAR2 (2);
   x_msg_count               NUMBER := 0;
   l_user_id                 NUMBER := -1;
   l_resp_id                 NUMBER := -1;
   l_application_id          NUMBER := -1;
   l_rowcnt                  NUMBER := 1;
   l_api_version             NUMBER := 1.0;
   l_init_msg_list           VARCHAR2 (2) := FND_API.G_TRUE;
   l_commit                  VARCHAR2 (2) := FND_API.G_FALSE;
   l_item_tbl                EGO_ITEM_PUB.ITEM_TBL_TYPE;
   l_role_grant_tbl          EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE;
   l_user_name               VARCHAR2 (30) := '103908';
   l_resp_name               VARCHAR2 (30) := 'Inventory';
   l_item_catalog_group_id   NUMBER := 0;
BEGIN
   -- Get the user_id
   SELECT user_id
     INTO l_user_id
     FROM fnd_user
    WHERE user_name = l_user_name;

   -- Get the application_id and responsibility_id
   SELECT application_id, responsibility_id
     INTO l_application_id, l_resp_id
     FROM fnd_responsibility_vl
    WHERE responsibility_name = l_resp_name;

   FND_GLOBAL.APPS_INITIALIZE (l_user_id, l_resp_id, l_application_id);
   DBMS_OUTPUT.put_line (
         'Initialized applications context: '
      || l_user_id
      || ' '
      || l_resp_id
      || ' '
      || l_application_id);

   -- Load the item catalog group id
   SELECT item_catalog_group_id
     INTO l_item_catalog_group_id
     FROM mtl_item_catalog_groups_b
    WHERE segment1 = 'Yarn';                     -- Item Catalog Category Name

   -- Load l_item_tbl with the data
   l_item_tbl (l_rowcnt).Transaction_Type := 'CREATE';
   l_item_tbl (l_rowcnt).Segment1 := 'YRN30S100VC0524F0415';    -- Item Number
   l_item_tbl (l_rowcnt).Description := '30S1-VC-(15%+85%)-ECOVERO-CH ORGANIC'; -- Item Description
   l_item_tbl (l_rowcnt).Organization_Code := 'IMO';      -- Organization Code
   --l_item_tbl (l_rowcnt).Template_Name := 'DBL DIS RAW MATL DUAL UOM LOT'; -- Item template  (** should be associated to ICC, Not mandatory)
   l_item_tbl (l_rowcnt).Inventory_Item_Status_Code := 'Active'; -- Item Status
   l_item_tbl (l_rowcnt).Item_Catalog_Group_Id := l_item_catalog_group_id; -- Item Catalog Group ID
   l_item_tbl (l_rowcnt).primary_uom_code := 'KG';
   l_item_tbl (l_rowcnt).secondary_uom_code := 'BAG';
   -- call API to load Items
   DBMS_OUTPUT.PUT_LINE ('=====================================');
   DBMS_OUTPUT.PUT_LINE ('Calling EGO_ITEM_PUB.Process_Items API');
   EGO_ITEM_PUB.PROCESS_ITEMS (p_api_version      => l_api_version,
                               p_init_msg_list    => l_init_msg_list,
                               p_commit           => l_commit,
                               p_item_tbl         => l_item_tbl,
                               p_role_grant_tbl   => l_role_grant_tbl,
                               x_item_tbl         => x_item_tbl,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count);
   DBMS_OUTPUT.PUT_LINE ('=====================================');
   DBMS_OUTPUT.PUT_LINE ('Return Status: ' || x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
   THEN
      FOR i IN 1 .. x_item_tbl.COUNT
      LOOP
         DBMS_OUTPUT.PUT_LINE (
               'Inventory Item Id :'
            || TO_CHAR (x_item_tbl (i).inventory_item_id));
         DBMS_OUTPUT.PUT_LINE (
            'Organization Id   :' || TO_CHAR (x_item_tbl (i).organization_id));
      END LOOP;
   ELSE
      DBMS_OUTPUT.PUT_LINE ('Error Messages :');
      Error_Handler.GET_MESSAGE_LIST (x_message_list => x_message_list);

      FOR i IN 1 .. x_message_list.COUNT
      LOOP
         DBMS_OUTPUT.PUT_LINE (x_message_list (i).MESSAGE_TEXT);
      END LOOP;
   END IF;

   DBMS_OUTPUT.PUT_LINE ('=====================================');
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE ('Exception Occured :');
      DBMS_OUTPUT.PUT_LINE (SQLCODE || ':' || SQLERRM);
      DBMS_OUTPUT.PUT_LINE ('=====================================');
      RAISE;
END;