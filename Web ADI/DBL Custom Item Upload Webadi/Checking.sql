/* Formatted on 8/12/2021 12:00:10 PM (QP5 v5.287) */
 EXECUTE APPS.xxdbl_item_conv_prc();

SELECT * FROM xxdbl.xxdbl_item_master_conv;



--------------------------------------------------------------------------------

INSERT INTO INV.MTL_SYSTEM_ITEMS_INTERFACE (PROCESS_FLAG,
                                            SET_PROCESS_ID,
                                            TRANSACTION_TYPE,
                                            ORGANIZATION_ID,
                                            INVENTORY_ITEM_ID,
                                            MIN_MINMAX_QUANTITY)
   SELECT 1,
          99,
          'UPDATE',
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          MIN_ORDER_QTY
     FROM xxdbl.XXDBL_ITEM_MASTER_CONV
    WHERE status IS NULL;

-----for update status----

UPDATE xxdbl.XXDBL_ITEM_MASTER_CONV
   SET status = 'I', STATUS_MESSAGE = 'INTERFACED'
 WHERE status IS NULL;

--------------------------------------------------------------------------------


INSERT INTO INV.MTL_SYSTEM_ITEMS_INTERFACE (PROCESS_FLAG,
                                            SET_PROCESS_ID,
                                            TRANSACTION_TYPE,
                                            ORGANIZATION_ID,
                                            INVENTORY_ITEM_ID,
                                            ATTRIBUTE1,
                                            ATTRIBUTE_CATEGORY)
   SELECT 1,
          99,
          'UPDATE',
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          LEGACY_ITEM,
          ATTRIBUTE_CATEGORY
     FROM xxdbl.XXDB_ITM_DESC_UPD_STG
    WHERE done IS NULL;

-----for update status----

UPDATE xxdbl.XXDB_ITM_DESC_UPD_STG
   SET done = 'Y'
 WHERE done IS NULL