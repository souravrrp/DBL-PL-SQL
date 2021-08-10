SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE XX_Process_Items ( 
	p_organization_code IN varchar2, 
	p_inventory_item_id IN Number, 
	p_item_catalog_group_id IN Number
)
AS
/* History 
-------------------------
Date 		/ Who 			/ Comment
-------------------------
18-JUL-2010 / James Phipps 	/ Based on Note 728350.1 by Suhasini Rayadurgam
18-JUL-2010 / James Phipps 	/ Changed to update item and change Item Catalog Category (ICC).
18-JUL-2010 / James Phipps 	/ Modified version that takes parameters instead of querying a table.

Executing
-------------------------
To execute the routine simply call from SQL*Plus.
For example, one could issue a command like:
SQL> exec  XX_Process_Items('V1', 258957, 18015)
Or one could write a begin/end:
SQL>  begin 
XX_Process_Items('V1', 258957, 18015);
end;

Pre-requisites
-------------------------
1. This version does not require a custom table.
2. To find the item catalog category id, you can use SQL like the following:
Select ITEM_CATALOG_GROUP_ID, segment1
From Mtl_Item_Catalog_Groups;
3. To find the inventory item id, you can use SQL like the following:
Select Inventory_Item_Id, Segment1
From Mtl_System_Items_B;

*/
        l_api_version		 NUMBER := 1.0; 
        l_init_msg_list		 VARCHAR2(2) := FND_API.G_TRUE; 
        l_commit		 VARCHAR2(2) := FND_API.G_FALSE; 
        l_item_tbl		 EGO_ITEM_PUB.ITEM_TBL_TYPE; 
        l_role_grant_tbl	 EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE := EGO_ITEM_PUB.G_MISS_ROLE_GRANT_TBL; 
        x_item_tbl		 EGO_ITEM_PUB.ITEM_TBL_TYPE;     
        x_message_list           Error_Handler.Error_Tbl_Type;
        x_return_status		 VARCHAR2(2);
        x_msg_count		 NUMBER := 0;
    
	l_user_id		NUMBER := -1;
	l_resp_id		NUMBER := -1;
	l_application_id	NUMBER := -1;
        l_user_name		VARCHAR2(30) := 'MFG';
        l_resp_name		VARCHAR2(30) := 'EGO_DEVELOPMENT_MANAGER';    
      
BEGIN

	-- Get the user_id
	SELECT user_id
	INTO l_user_id
	FROM fnd_user
	WHERE user_name = l_user_name;

	-- Get the application_id and responsibility_id
	SELECT application_id, responsibility_id
	INTO l_application_id, l_resp_id
	FROM fnd_responsibility
	WHERE responsibility_key = l_resp_name;

	FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  -- MGRPLM / Development Manager / EGO
	dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );

        -- Load l_item_tbl with the data
		 l_item_tbl(1).Transaction_Type            := 'UPDATE'; 
		 l_item_tbl(1).Inventory_Item_Id           := p_inventory_item_id;
		 l_item_tbl(1).Organization_Code           := p_organization_code;
		 l_item_tbl(1).Inventory_Item_Status_Code  := 'Active';
		 l_item_tbl(1).Item_Catalog_Group_Id       :=  p_item_catalog_group_id;
       
        -- call API to load Items
       DBMS_OUTPUT.PUT_LINE('=====================================');
       DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Process_Items API');        
       EGO_ITEM_PUB.PROCESS_ITEMS( 
                                 p_api_version            => l_api_version
                                 ,p_init_msg_list         => l_init_msg_list
                                 ,p_commit                => l_commit
                                 ,p_item_tbl              => l_item_tbl
                                 ,p_role_grant_tbl        => l_role_grant_tbl
                                 ,x_item_tbl              => x_item_tbl
                                 ,x_return_status         => x_return_status
                                 ,x_msg_count             => x_msg_count);
                                  
       DBMS_OUTPUT.PUT_LINE('=====================================');
       DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          FOR i IN 1..x_item_tbl.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE('Inventory Item Id :'||to_char(x_item_tbl(i).inventory_item_id));
             DBMS_OUTPUT.PUT_LINE('Organization Id   :'||to_char(x_item_tbl(i).organization_id));
          END LOOP;
       ELSE
          DBMS_OUTPUT.PUT_LINE('Error Messages :');
          Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
          FOR i IN 1..x_message_list.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE(x_message_list(i).message_text);
          END LOOP;
       END IF;
       DBMS_OUTPUT.PUT_LINE('=====================================');       
        
EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('=====================================');
END XX_Process_Items;
/
