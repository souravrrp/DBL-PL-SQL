SELECT msi.segment1 itm_code,
         msi.ATTRIBUTE1 AS "Legacy Code",
         msi.ATTRIBUTE3 AS "Locator",
         mic.segment2 item_catg,
         mic.segment3 itm_type,
         msi.description,
         org.organization_code,
         org.organization_name,
         moq.subinventory_code,
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
         mtl_item_categories_v mic
   WHERE     moq.organization_id = org.organization_id
         AND moq.organization_id = msi.organization_id
         AND moq.inventory_item_id = msi.inventory_item_id
         AND moq.organization_id = mic.organization_id
         AND moq.inventory_item_id = mic.inventory_item_id
         AND mic.category_set_id = 1
         AND org.organization_id = NVL (:p_organization, org.organization_id)
         AND msi.inventory_item_id = NVL (:p_item_id, msi.inventory_item_id)
         AND moq.subinventory_code =
               NVL (:p_subinventory, moq.subinventory_code)
         AND mic.segment2 = NVL (:P_catg, mic.segment2)
         AND mic.segment3 = NVL (:P_TYPE, mic.segment3)
       --  AND moq.transaction_date <= NVL (:P_date_to, SYSDATE) + .99999 --'MSML-SPCNS'
           AND moq.transaction_date <= NVL (:P_date_to, SYSDATE) --'MSML-SPCNS'
--and msi.ATTRIBUTE_CATEGORY='Maintain Items'
GROUP BY moq.inventory_item_id,
         moq.organization_id,
         org.organization_code,
         org.organization_name,
         moq.subinventory_code,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         msi.segment1,
         msi.description,
         --         lot_number,
         mic.segment2,
         mic.segment3,
         msi.ATTRIBUTE1,
         msi.ATTRIBUTE3
  HAVING SUM (primary_quantity) <> 0