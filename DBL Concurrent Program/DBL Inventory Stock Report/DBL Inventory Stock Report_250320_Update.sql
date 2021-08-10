/* Formatted on 3/25/2020 1:30:09 PM (QP5 v5.287) */
  SELECT msi.segment1 itm_code,
         msi.ATTRIBUTE1 AS "Legacy Code",
         mil.segment1 AS "Locator",
         mic.segment2 item_catg,
         mic.segment3 itm_type,
         msi.description,
         org.organization_code,
         org.organization_name,
         si.SECONDARY_INVENTORY_NAME,
         -- moq.inventory_item_id,
         moq.organization_id,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         --         lot_number,
         SUM (primary_quantity) on_hand,
         SUM (SECONDARY_TRANSACTION_QUANTITY) "Secondary"
    FROM mtl_material_transactions moq,           --mtl_onhand_quantities moq,
         org_organization_definitions org,
         mtl_system_items_b msi,
         mtl_item_categories_v mic,
         mtl_secondary_inventories si,
         inv.mtl_item_locations mil
   WHERE     moq.organization_id = org.organization_id
         AND moq.organization_id = msi.organization_id
         AND moq.inventory_item_id = msi.inventory_item_id
         AND moq.organization_id = mic.organization_id
         AND moq.inventory_item_id = mic.inventory_item_id
         AND moq.organization_id = si.organization_id
         AND msi.organization_id = si.organization_id
         AND mic.organization_id = si.organization_id
         AND moq.SUBINVENTORY_CODE = si.SECONDARY_INVENTORY_NAME
         AND mic.category_set_id = 1
         AND org.organization_id = NVL ( :p_organization, org.organization_id)
         AND msi.inventory_item_id = NVL ( :p_item_id, msi.inventory_item_id)
         AND moq.subinventory_code =
                NVL ( :p_subinventory, moq.subinventory_code)
         AND mic.segment2 = NVL ( :P_catg, mic.segment2)
         AND mic.segment3 = NVL ( :P_TYPE, mic.segment3)
         --  AND moq.transaction_date <= NVL (:P_date_to, SYSDATE) + .99999 --'MSML-SPCNS'
         AND moq.transaction_date <= NVL ( :P_date_to, SYSDATE) + .99999
         --  AND moq.TRANSACTION_TYPE_ID <> 98
         AND si.DISABLE_DATE IS NULL
         AND moq.locator_id = mil.inventory_location_id(+)
--   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
--   AND moq.TRANSACTION_TYPE_ID NOT IN (80, 98, 99, 120, 52, 26, 64) --'MSML-SPCNS'
--and msi.ATTRIBUTE_CATEGORY='Maintain Items'
GROUP BY moq.inventory_item_id,
         moq.organization_id,
         org.organization_code,
         org.organization_name,
         si.SECONDARY_INVENTORY_NAME,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         msi.segment1,
         msi.description,
         --         lot_number,
         mic.segment2,
         mic.segment3,
         msi.ATTRIBUTE1,
         mil.segment1
  HAVING SUM (primary_quantity) <> 0