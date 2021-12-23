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

--------------------Trading Item--------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'TRD%' AND ORGANIZATION_ID = 138;

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

