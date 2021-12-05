/* Formatted on 9/4/2021 9:44:32 AM (QP5 v5.354) */
--------------------Count no of Item--------------------------------------------

SELECT COUNT (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE '%SPRECONS%' AND organization_id = 138;

--------------------Spare Consumable Item---------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE '%SPRECONS0000000890%' AND organization_id = 138;

--------------------Fixed Asset Item--------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'FASSET%003%';


--------------------Ribon Item--------------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'RIBON%'
  AND organization_id = 138;


--------------------Yarn Item---------------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'YRN00%' AND ORGANIZATION_ID = 138;


--------------------Dyes Item--------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'DYES00%' AND ORGANIZATION_ID = 138;

--------------------Item Details--------------------------------------------

  SELECT ood.organization_code,
         ood.organization_id,
         ORGANIZATION_NAME,
         a.inventory_item_id,
         a.segment1     AS Item_Code,
         description,
         --LOT_CONTROL_CODE,
         PRIMARY_UOM_CODE,
         SECONDARY_UOM_CODE,
         b.segment2     "Item_Category",
         b.segment3     "Item_Type",
         a.PROCESS_COSTING_ENABLED_FLAG,
         a.PROCESS_YIELD_SUBINVENTORY,
         a.PROCESS_SUPPLY_SUBINVENTORY
    FROM apps.mtl_system_items_b_kfv      a,
         apps.mtl_item_categories_v       b,
         apps.org_organization_definitions ood
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = ood.organization_id
         AND CATEGORY_SET_ID = 1 -- 1100000041    -- 1100000061  sales category set ID
         --   AND TO_dATE(A.CREATION_DATE) ='27-SEP-2017'                              --1100000041
         --   AND description like '%?%'
         --  and INVENTORY_ITEM_FLAG ='N'
         --  and   description  like '%%'
         --and  b.segment1 LIKE 'PACK%'
         AND b.segment2 LIKE 'FINISH%'
         AND ood.organization_code IN ('193')
--AND ood.organization_code IN ('113','133','143','152','163','183')
--  and b.segment3='YARN'
--and  a.segment1!='SPRECONS00000006576'
--and  a.segment1 between 'SPRECONS000000063955' and 'SPRECONS00000006576'
ORDER BY 5, 1;

--------------------------------------------------------------------------------

SELECT XIB.BATCH_NAME,
       XIB.BATCH_STATUS,
       XIM.ITEM_STATUS,
       XIM.CATALOG_TYPE,
       XIM.ITEM_MASTER_ID     ITEM_ID,
       XIM.ITEM_CODE,
       XIM.ITEM_DESCRIPTION,
       XIM.LONG_DESCRIPTION,
       XIM.PRIMARY_UOM_CODE,
       XIM.SECONDARY_UOM_CODE,
       XIM.DUAL_UOM_FLAG,
       XIOH.ORG_HIERARCHY,
       XIOH.TEMPLATE_NAME,
       XIOH.CATEGORY_SET_ID,
       XIOH.CATEGORY_ID,
       XIOH.CATEGORY_NAME,
       XIOH.LCM_FLAG,
       XIOH.EXPENSE_ACCOUNT,
       XIOH.PRODUCT_LINE,
       XIOH.EXPENSE_SUB_ACCOUNT
  --,XIB.*
  --,XIM.*
  --,XIOH.*
  FROM XXDBL_ITEM_BATCHES        XIB,
       XXDBL_ITEM_MASTER         XIM,
       XXDBL_ITEM_ORG_HIERARCHY  XIOH
 WHERE     1 = 1
       AND XIB.BATCH_ID = XIM.BATCH_ID
       AND XIM.ITEM_MASTER_ID = XIOH.ITEM_MASTER_ID
       AND XIM.BATCH_ID = XIOH.BATCH_ID
       --AND XIM.ITEM_CODE LIKE '%DYES%'
       AND XIB.BATCH_NAME = '13222';

--------------------------------------------------------------------------------

SELECT XIM.*
  FROM XXDBL_ITEM_MASTER XIM;

SELECT *
  FROM XXDBL_ITEM_ORG_HIERARCHY
 WHERE 1 = 1 AND BATCH_ID = 10207;

SELECT * FROM XXDBL_ITEM_BATCHES;