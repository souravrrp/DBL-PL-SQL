/* Formatted on 1/28/2020 4:21:06 PM (QP5 v5.287) */
  SELECT OOD.OPERATING_UNIT,
         OOD.ORGANIZATION_NAME,
         OOD.ORGANIZATION_CODE,
         OOD.ORGANIZATION_ID,
         OHQD.SUBINVENTORY_CODE,
         --MSI.DESCRIPTION SUBINVENTORY_NAME,
         OHQD.LOT_NUMBER,
         MSIB.SEGMENT1 ITEM_CODE,
         MSIB.DESCRIPTION,
         OHQD.INVENTORY_ITEM_ID,
         SUM (OHQD.PRIMARY_TRANSACTION_QUANTITY) AS ONHAND_QTY,
         MSIB.PRIMARY_UOM_CODE UOM_CODE
    FROM APPS.MTL_ONHAND_QUANTITIES_DETAIL OHQD,
         APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
         --APPS.MTL_SECONDARY_INVENTORIES MSI,
         APPS.MTL_SYSTEM_ITEMS_B MSIB,
         APPS.MTL_ITEM_CATEGORIES_V CAT
   WHERE     1 = 1
         AND MSIB.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND OHQD.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND OHQD.INVENTORY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
         AND (   :P_OPERATING_UNIT IS NULL OR (OOD.OPERATING_UNIT = :P_OPERATING_UNIT))
         AND (   :P_ORGANIZATION_CODE IS NULL OR (OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
         AND (   :P_ORGANIZATION_ID IS NULL OR (OOD.ORGANIZATION_ID = :P_ORGANIZATION_CODE))
         AND (   :P_SUBINVENTORY IS NULL OR (OHQD.SUBINVENTORY_CODE = :P_SUBINVENTORY))
         AND (   :P_LOT_NUMBER IS NULL OR (OHQD.LOT_NUMBER = :P_LOT_NUMBER))
         AND MSIB.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
         AND MSIB.ORGANIZATION_ID = CAT.ORGANIZATION_ID
         AND CAT.CATEGORY_SET_ID=1
         AND (   :P_LINE_OF_BUSINESS IS NULL  OR (CAT.SEGMENT1 = :P_LINE_OF_BUSINESS))
         AND (   :P_MAJOR_CATEGORY IS NULL    OR (CAT.SEGMENT2 = :P_MAJOR_CATEGORY))
         AND (   :P_MINOR_CATEGORY IS NULL    OR (CAT.SEGMENT3 = :P_MINOR_CATEGORY))
         --AND MSI.ORGANIZATION_ID=OOD.ORGANIZATION_ID
         --AND OHQD.SUBINVENTORY_CODE!='DUMMY FG'
         --AND OOD.OPERATING_UNIT IN (125,131)
         --AND OHQD.ORGANIZATION_ID IN ('101','113','1345','1346')
         --AND OOD.ORGANIZATION_CODE IN ('SCI')
         --AND MSIB.INVENTORY_ITEM_ID=55605
         --AND MSIB.SEGMENT1='BRND'
         --AND MSIB.SEGMENT1='GIFT'
         --AND MSIB.SEGMENT1 IN ('CMNT.SBAG.0001')
         --AND CAT.SEGMENT2 NOT IN ('RAW MATERIAL')
         AND ( :P_ITEM_CODE IS NULL OR (MSIB.SEGMENT1 = :P_ITEM_CODE))
GROUP BY OOD.OPERATING_UNIT,
         MSIB.SEGMENT1,
         MSIB.DESCRIPTION,
         OHQD.INVENTORY_ITEM_ID,
         OHQD.LOT_NUMBER,
         OHQD.SUBINVENTORY_CODE,
         --MSI.DESCRIPTION,
         MSIB.PRIMARY_UOM_CODE,
         OOD.ORGANIZATION_ID,
         OOD.ORGANIZATION_CODE,
         OOD.ORGANIZATION_NAME
ORDER BY ORGANIZATION_CODE;


--------------------------------------------------------------------------------

select ood.operating_unit,
       ood.organization_name,
       ood.organization_code,
       ood.organization_id,
       msi.secondary_inventory_name     subinventory_code,
       msi.description                  subinventory_name
       --ood.business_group_id,
       --ood.set_of_books_id,
       --ood.chart_of_accounts_id
  --,OOD.*
  --,MSI.*
  from apps.org_organization_definitions  ood,
       apps.mtl_secondary_inventories     msi
 where     1 = 1
       and msi.organization_id = ood.organization_id
       AND (   :p_operating_unit IS NULL OR (ood.operating_unit = :p_operating_unit))
       and (   :p_organization_code is null or (ood.organization_code = :p_organization_code))
       AND (   :p_org_name IS NULL OR (UPPER (ood.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
       and (   :p_sub_inv_code is null or (msi.secondary_inventory_name = :p_sub_inv_code))
       AND (   :p_sub_inv_name IS NULL OR (UPPER (msi.description) LIKE UPPER ('%' || :p_sub_inv_name || '%')))
       and msi.disable_date is null;

--------------------------------------------------------------------------------
 /* Formatted on 2/5/2022 1:38:23 PM (QP5 v5.374) */
  SELECT ood.organization_name,
         ood.organization_code,
         msib.segment1                               item_code,
         msib.description,
         ohqd.inventory_item_id,
         SUM (ohqd.primary_transaction_quantity)     AS onhand_qty,
         msib.primary_uom_code                   uom_code
    FROM apps.mtl_onhand_quantities_detail ohqd,
         apps.org_organization_definitions ood,
         apps.mtl_system_items_b          msib
   WHERE     1 = 1
         AND msib.organization_id = ood.organization_id
         AND ohqd.organization_id = ood.organization_id
         AND ohqd.inventory_item_id = msib.inventory_item_id
         AND msib.segment1 IN ('RT2030-013BR')
GROUP BY msib.segment1,
         msib.description,
         ohqd.inventory_item_id,
         msib.primary_uom_code,
         ood.organization_code,
         ood.organization_name;