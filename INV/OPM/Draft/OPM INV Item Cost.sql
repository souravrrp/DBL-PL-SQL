SELECT msi.segment1 "ITEM_NAME",
  msi.inventory_item_id,
  cic.item_cost ,
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
FROM cst_cost_types cct,
  cst_item_costs cic,
  mtl_system_items_b msi,
  mtl_parameters mp
WHERE cct.cost_type_id    = cic.cost_type_id
AND cic.inventory_item_id = msi.inventory_item_id
AND cic.organization_id   = msi.organization_id
AND msi.organization_id   = mp.organization_id
--AND msi.inventory_item_id = 45
--AND mp.organization_id    = 204
--AND cct.cost_type         = 'Frozen' --'Average' --'Pending'