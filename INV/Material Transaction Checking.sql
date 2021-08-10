/* Formatted on 1/12/2021 11:11:45 AM (QP5 v5.354) */
SELECT mmt.transaction_id,
       mmt.creation_date,
       mmt.transaction_date,
       ood.set_of_books_id              ledger_id,
       ood.organization_name            warehouse_name,
       ood.organization_code            warehouse_org_code,
       mmt.organization_id,
       msi.segment1 item_code,
       mmt.inventory_item_id,
       mmt.subinventory_code,
       mmt.transaction_type_id,
       mtt.transaction_type_name,
       mmt.transaction_source_id,
       mmt.transaction_source_type_id,
       mmt.transaction_action_id,
       mmt.transaction_quantity,
       mmt.transaction_uom,
       msi.primary_uom_code primary_uom,
       mmt.primary_quantity,
       mmt.secondary_uom_code,
       mmt.secondary_transaction_quantity,
       mmt.actual_cost,
       gcc.concatenated_segments
  --,mmt.*
  FROM mtl_material_transactions mmt, inv.mtl_transaction_types mtt, org_organization_definitions ood, inv.mtl_system_items_b msi, inv.mtl_transaction_lot_numbers mtln, apps.gl_code_combinations_kfv gcc, apps.mtl_item_categories_v cat
 WHERE     1 = 1
       AND mmt.transaction_type_id = mtt.transaction_type_id
       AND mmt.organization_id = ood.organization_id
       AND mmt.organization_id = msi.organization_id
       AND mmt.inventory_item_id = msi.inventory_item_id
       AND mmt.distribution_account_id= gcc.code_combination_id(+)
       AND mmt.transaction_id = mtln.transaction_id(+) 
       AND (   :p_operating_unit IS NULL OR (ood.operating_unit = :p_operating_unit))
       AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
       AND (   :p_org_name IS NULL OR (UPPER (ood.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
       AND (   :p_subinventory is null or (mmt.subinventory_code = :p_subinventory))
       --AND EXISTS (SELECT 1 FROM inv.mtl_transaction_lot_numbers  mtln WHERE mmt.transaction_id = mtln.transaction_id(+) AND (:p_lot_number is null or (mtln.lot_number = :p_lot_number)))
       --AND EXISTS (SELECT 1 FROM gme_batch_header gbh WHERE mmt.transaction_source_id = gbh.batch_id AND (:p_batch_no is null or (gbh.batch_no = :p_batch_no)))
       --AND mmt.source_code='OPM'
       --AND CAT.SEGMENT2 NOT IN ('FINISH GOODS')
       --AND mmt.logical_transaction IS NULL
       --AND mmt.distribution_account_id IS NULL
       --AND mmt.transaction_id IN (26065173, 26065056)
       --AND mtt.transaction_type_name in ('Subinventory Transfer')
       AND (   :p_item_code is null or (msi.segment1 = :p_item_code))
       AND (   :p_lot_number is null or (mtln.lot_number = :p_lot_number))
       AND trunc(mmt.transaction_date) between nvl(:p_transaction_date_from,trunc(mmt.transaction_date)) and nvl(:p_transaction_date_to,trunc(mmt.transaction_date))
       AND (   :p_transaction_type IS NULL OR (UPPER (mtt.transaction_type_name) LIKE UPPER ('%' || :p_transaction_type || '%')))
       AND (   :p_transaction_type_id IS NULL OR (mmt.transaction_type_id = :p_transaction_type_id))
       AND (   :p_source_type_id IS NULL OR (mmt.transaction_source_type_id = :p_source_type_id))
       AND (   :p_trx_source_id IS NULL OR (mmt.transaction_source_id = :p_trx_source_id))
       AND (   :p_organization_id IS NULL OR (ood.organization_id = :p_organization_id))
       AND (   :p_transaction_id IS NULL OR (mmt.transaction_id = :p_transaction_id))
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND (   :p_major_category IS NULL    OR (cat.segment2 = :p_major_category))
       AND (   :p_minor_category IS NULL    OR (cat.segment3 = :p_minor_category))
       AND cat.category_set_id=1 ;

--------------------------------------------------------------------------------

SELECT mmt.transaction_id,
       mmt.transaction_date,
       mmt.organization_id,
       mtv.object_id,
       mtv.transaction_quantity,
       mtv.transaction_type_id,
       --inv_project.get_locator (mmt.locator_id, mmt.organization_id) locator_name,
       mtv.*
  FROM mtl_material_transactions mmt, mtl_transaction_details_v mtv
 WHERE     mmt.transaction_id = mtv.transaction_id
       AND mmt.transaction_id = 26065173;