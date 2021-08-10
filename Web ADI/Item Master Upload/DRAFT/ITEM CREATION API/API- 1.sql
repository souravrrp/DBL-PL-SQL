/* Formatted on 6/22/2020 12:20:06 PM (QP5 v5.287) */
DECLARE
   l_item_table       EGO_Item_PUB.Item_Tbl_Type;

   v_item_tabl_type   EGO_Item_PUB.Item_Tbl_Type;

   x_return_status    VARCHAR2 (1);

   x_msg_count        NUMBER (10);

   x_msg_data         VARCHAR2 (1000);

   x_message_list     Error_Handler.Error_Tbl_Type;
BEGIN
   FND_GLOBAL.APPS_INITIALIZE (USER_ID        => 2793,
                               RESP_ID        => 20634,
                               RESP_APPL_ID   => 401);
   l_item_table (1).Transaction_Type := 'CREATE'; -- Replace this with 'UPDATE' for update transaction.

   l_item_table (1).Segment1 := 'SPRECONS000000067001';                -- item code---

   l_item_table (1).Description := 'PINION FOR DRYER';        -- item description----

   l_item_table (1).Organization_Code := 'IMO';  --inventory master org code--

   l_item_table (1).Template_Name := 'DBL Spares and Civil Item'; -- inventory template name from which item will inherit the item attributes values--



   EGO_ITEM_PUB.Process_Items (p_api_version     => 1.0,
                               p_init_msg_list   => FND_API.g_TRUE,
                               p_commit          => FND_API.g_TRUE,
                               p_Item_Tbl        => l_item_table,
                               x_Item_Tbl        => v_item_tabl_type,
                               x_return_status   => x_return_status,
                               x_msg_count       => x_msg_count);
   DBMS_OUTPUT.PUT_LINE ('API Return Status ==>' || x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
   THEN
      DBMS_OUTPUT.PUT_LINE ('SUCCESS');

      FOR i IN 1 .. v_item_tabl_type.COUNT
      LOOP
         DBMS_OUTPUT.PUT_LINE (
               'Inventory Item Id Created:'
            || TO_CHAR (v_item_tabl_type (i).Inventory_Item_Id));

         DBMS_OUTPUT.PUT_LINE (
               'Organization Id :'
            || TO_CHAR (v_item_tabl_type (i).Organization_Id));
      END LOOP;
   ELSE
      DBMS_OUTPUT.PUT_LINE ('Error Messages :');

      Error_Handler.GET_MESSAGE_LIST (x_message_list => x_message_list);

      FOR i IN 1 .. x_message_list.COUNT
      LOOP
         DBMS_OUTPUT.PUT_LINE (x_message_list (i).MESSAGE_TEXT);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'Error has Occured and error is ' || SUBSTR (SQLERRM, 1, 200));
END;