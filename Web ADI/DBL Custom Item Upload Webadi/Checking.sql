/* Formatted on 8/16/2021 10:58:32 AM (QP5 v5.287) */
--EXECUTE APPS.xxdbl_item_conv_prc();

SELECT *
  FROM xxdbl.xxdbl_item_master_conv
 WHERE 1 = 1
 AND ITEM_CODE='SPRECONS000000084732'
--Order by desc
;

SELECT msii.SET_PROCESS_ID,msii.*
  FROM inv.mtl_system_items_interface msii
 WHERE     1 = 1
       --AND set_process_id = 1000
       AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE)
--AND EXISTS (SELECT 1 FROM XXDBL.xxdbl_item_master_conv xxdbl WHERE xxdbl.item_code = msii.segment1)

SELECT
*
FROM
MTL_SYSTEM_ITEMS_B
WHERE 1=1
AND  SEGMENT1='SPRECONS000000084732';

SELECT *
  FROM XXDBL.xxdbl_item_master_conv xxdbl
 WHERE     1 = 1
       AND xxdbl.status = 'I'
       AND xxdbl.organization_code = 'IMO'
       AND EXISTS
              (SELECT 1
                 FROM mtl_system_items_b msi
                WHERE     xxdbl.item_code = msi.segment1
                      AND msi.organization_id = 138
                      AND TRUNC (msi.creation_date) = TRUNC (SYSDATE))
--       AND EXISTS
--              (SELECT 1
--                 FROM inv.mtl_system_items_interface msii
--                WHERE     xxdbl.item_code = msii.segment1
--                      AND TRUNC (msii.creation_date) = TRUNC (SYSDATE))
;

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
    WHERE STATUS IS NULL;

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
 WHERE done IS NULL;


SELECT * FROM xxdbl.XXDB_ITM_DESC_UPD_STG;

--------------------------------------------------------------------------------

--ALTER TABLE xxdbl.xxdbl_item_master_conv ADD (set_process_id NUMBER, creaed_by NUMBER, creation_date DATE);


SELECT *
  FROM INV.MTL_CATEGORIES_B MC
 WHERE 1 = 1;


SELECT category_id                                                      --INTO
                  l_category_id
  FROM mtl_categories_b mc
 WHERE     UPPER (mc.segment1) = UPPER ( :P_ITEM_CATEGORY_SEGMENT1)
       AND UPPER (mc.segment2) = UPPER ( :P_ITEM_CATEGORY_SEGMENT2)
       AND UPPER (mc.segment3) = UPPER ( :P_ITEM_CATEGORY_SEGMENT3)
       AND UPPER (mc.segment4) = UPPER ( :P_ITEM_CATEGORY_SEGMENT4);
       
--------------------------------------------------------------------------------

ALTER TABLE xxdbl.xxdbl_item_master_conv
   ADD (CATEGORY_ID NUMBER);
   
ALTER TABLE xxdbl.xxdbl_item_master_conv DROP COLUMN CATEGORY_ID;