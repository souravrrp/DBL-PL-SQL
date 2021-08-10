SELECT --a.organization_id org_id,
    --     od.ORGANIZATION_CODE org,
      --   ou.organization_id ou_id,
    --     od.ORGANIZATION_NAME,
     --    a.inventory_item_id,
    --     mic.segment1 AS catg,
       --  mic.segment2 AS TYPE,
         mmt.subinventory_code subinv,
         --a.CONCATENATED_SEGMENTS item_id,
     --    a.description,
    --     a.PRIMARY_UOM_CODE,
       --  SUM (primary_quantity) target_qty,
     --    c.ITEM_COST AS itm_cost,
         SUM (primary_quantity) * c.ITEM_COST AS on_val
    FROM apps.mtl_material_transactions mmt,
         apps.mtl_txn_source_types mtst,
         APPS.mtl_system_items_b_kfv a,
         apps.mtl_item_categories_v mic,
         apps.org_organization_definitions od,
         APPS.CST_ITEM_COST_TYPE_V c,
         apps.hr_operating_units ou
   WHERE     transaction_date <= NVL (TO_DATE (:P_DATE), SYSDATE) + 1
         AND mmt.transaction_source_type_id = mtst.transaction_source_type_id
         AND mmt.inventory_item_id = a.inventory_item_id
         AND mmt.organization_id = a.organization_id
         AND mic.inventory_item_id = a.inventory_item_id
         AND mic.organization_id = a.organization_id
         AND od.organization_id = a.organization_id
         AND od.OPERATING_UNIT = ou.organization_id
         AND mmt.inventory_item_id = c.inventory_item_id
         AND mmt.organization_id = c.organization_id
         AND mic.category_set_id = 1
     --    AND ou.organization_id = 136
 AND od.organization_code = '188'
 --AND a.CONCATENATED_SEGMENTS ='SPRECONS000000019690'
GROUP BY --a.organization_id,
        -- od.ORGANIZATION_CODE,
        -- ou.organization_id,
      --   a.inventory_item_id,
      --   mic.segment1,
    --     mic.segment2,
         mmt.subinventory_code,
    --     a.CONCATENATED_SEGMENTS,
    --     a.description,
     --    a.PRIMARY_UOM_CODE,
    --     od.ORGANIZATION_NAME,
     c.ITEM_COST
     HAVING SUM (primary_quantity) <> 0