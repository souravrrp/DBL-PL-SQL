SELECT msi.segment1 "ITEM_NAME",
       msi.inventory_item_id,
       cic.item_cost,
       mp.organization_code,
       mp.organization_id,
       cct.cost_type,
       cct.description,
       cic.tl_material,
       cic.tl_material_overhead,
       cic.material_cost,
       cic.material_overhead_cost,
       cic.tl_item_cost,
       cic.unburdened_cost,
       cic.burden_cost
  FROM apps.cst_cost_types cct,
       apps.cst_item_costs cic,
       inv.mtl_system_items_b msi,
       inv.mtl_parameters mp
 WHERE     cct.cost_type_id = cic.cost_type_id
       AND cic.inventory_item_id = msi.inventory_item_id
       AND cic.organization_id = msi.organization_id
       AND msi.organization_id = mp.organization_id
--       AND msi.inventory_item_id = 5014
--       AND mp.organization_id = 93
--       AND cct.cost_type IN  ('Frozen','Pending','C16')
       
--------------------------------------------------------------------------------

SELECT msib.segment1 "Item Name",
       mp.organization_code,
       cict.cost_type,
       cic.material_cost
FROM apps.mtl_system_items_b msib,
     apps.mtl_parameters mp,
     apps.cst_item_costs cic,
     apps.cst_cost_types cict
WHERE     1 - 1 = 0
      AND msib.organization_id = mp.organization_id
      AND msib.organization_id = cic.organization_id
      AND msib.inventory_item_id = cic.inventory_item_id
      AND cic.cost_type_id = cict.cost_type_id
--      AND msib.segment1 LIKE 'NokiaMobile'
--      AND cic.organization_id = 101;       