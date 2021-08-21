/* Formatted on 8/21/2021 3:30:38 PM (QP5 v5.354) */
  SELECT TO_CHAR (mmt.transaction_date, 'DD-Mon-RRRR')    production_date,
         fm.formula_no,
         msi.concatenated_segments                        AS item_code,
         msi.description                                  AS item_description,
         mlt.grade_code,
         mic.segment2                                     AS item_size,
         CASE
             WHEN mtt.transaction_type_name = 'WIP Completion'
             THEN
                 SUM (mmt.transaction_quantity)
             ELSE
                 0
         END                                              resort_ctn,
         CASE
             WHEN mtt.transaction_type_name = 'WIP Completion'
             THEN
                 SUM ((  apps.inv_convert.inv_um_convert (
                             mtln.inventory_item_id,
                             '',
                             1,
                             'CTN',
                             'SQM',
                             '',
                             '')
                       * mmt.transaction_quantity))
             ELSE
                 0
         END                                              resort_sqm
    FROM apps.mtl_material_transactions mmt,
         inv.mtl_transaction_types      mtt,
         inv.mtl_transaction_lot_numbers mtln,
         gme.gme_batch_header           h,
         fm_form_mst_b                  fm,
         apps.mtl_system_items_b_kfv    msi,
         apps.mtl_item_categories_v     mic,
         inv.mtl_lot_numbers            mlt
   WHERE     mmt.transaction_type_id = mtt.transaction_type_id
         AND mmt.transaction_id = mtln.transaction_id
         AND mtln.organization_id = mmt.organization_id
         AND mtln.transaction_source_id = h.batch_id
         AND h.organization_id = mmt.organization_id
         AND fm.formula_id = h.formula_id
         AND mmt.inventory_item_id = msi.inventory_item_id
         AND mmt.organization_id = msi.organization_id
         AND mlt.inventory_item_id = mtln.inventory_item_id
         AND mlt.organization_id = mtln.organization_id
         AND mlt.lot_number = mtln.lot_number
         AND msi.inventory_item_id = mic.inventory_item_id
         AND msi.organization_id = mic.organization_id
         AND mmt.organization_id = 152
         AND mmt.transaction_uom = 'CTN'
         AND formula_no = 'DBLCL-RESORTING'
         AND mic.category_set_id = 1100000061
         AND mmt.transaction_date BETWEEN :p_date_from AND :p_date_to + .99999
         AND mmt.subinventory_code =
             NVL ( :p_subinventory_code, mmt.subinventory_code)
         AND msi.concatenated_segments =
             NVL ( :p_item, msi.concatenated_segments)
GROUP BY TO_CHAR (mmt.transaction_date, 'DD-Mon-RRRR'),
         fm.formula_no,
         msi.concatenated_segments,
         msi.description,
         mlt.grade_code,
         mic.segment2,
         mtt.transaction_type_name;