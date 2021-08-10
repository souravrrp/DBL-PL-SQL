SELECT hdr.batch_no, mst.formula_no, msib.segment1,
dtl.plan_qty plan_qty_ingrd, dtl.actual_qty actual_qty_ingrd,
hdr.actual_cmplt_date, dtl_prod.plan_qty plan_qty_prod,
dtl_prod.actual_qty actual_qty_prod
FROM gme_batch_header hdr,
fm_form_mst mst,
gme_material_details dtl,
mtl_system_items_b msib,
gme_material_details dtl_prod
WHERE hdr.formula_id = mst.formula_id
AND hdr.batch_id = dtl.batch_id
AND dtl.line_type = -1
AND dtl.inventory_item_id = msib.inventory_item_id
AND msib.organization_id = 150
AND msib.segment1 LIKE 'P%'
AND mst.formula_class != 'ST'
AND hdr.organization_id = 150
AND dtl.organization_id = 150
AND mst.owner_organization_id = 150
AND hdr.batch_status = 3
AND hdr.batch_id = dtl_prod.batch_id
AND dtl_prod.line_type = 1
ORDER BY 1