/* Formatted on 7/19/2021 1:02:17 PM (QP5 v5.287) */
  select to_char (mmt.transaction_date, 'DD-Mon-RRRR') production_date,
         fm.formula_no,
         msi.concatenated_segments as item_code,
         msi.description as item_description,
         mlt.grade_code,
         mic.segment2 as item_size,
         case
            when mtt.transaction_type_name = 'WIP Issue'
            then
               sum (mmt.transaction_quantity)
            else
               0
         end
            wip_issue_tra_quantity,
         case
            when mtt.transaction_type_name = 'WIP Completion'
            then
               sum (mmt.transaction_quantity)
            else
               0
         end
            wip_completion_tra_quantity,
         case
            when mtt.transaction_type_name = 'WIP Completion'
            then
               sum ( (  apps.inv_convert.inv_um_convert (
                           mtln.inventory_item_id,
                           '',
                           1,
                           'CTN',
                           'SQM',
                           '',
                           '')
                      * mmt.transaction_quantity))
            else
               0
         end
            production_qty_sqm
    from apps.mtl_material_transactions mmt,
         inv.mtl_transaction_types mtt,
         inv.mtl_transaction_lot_numbers mtln,
         gme.gme_batch_header h,
         fm_form_mst_b fm,
         apps.mtl_system_items_b_kfv msi,
         apps.mtl_item_categories_v mic,
         inv.mtl_lot_numbers mlt
   where     mmt.transaction_type_id = mtt.transaction_type_id
         and mmt.transaction_id = mtln.transaction_id
         and mtln.organization_id = mmt.organization_id
         and mtln.transaction_source_id = h.batch_id
         and h.organization_id = mmt.organization_id
         and fm.formula_id = h.formula_id
         and mmt.inventory_item_id = msi.inventory_item_id
         and mmt.organization_id = msi.organization_id
         and mlt.inventory_item_id = mtln.inventory_item_id
         and mlt.organization_id = mtln.organization_id
         and mlt.lot_number = mtln.lot_number
         and msi.inventory_item_id = mic.inventory_item_id
         and msi.organization_id = mic.organization_id
         and mmt.organization_id = 152
         and mmt.transaction_uom = 'CTN'
         and formula_no = 'DBLCL-RESORTING'
         and mic.category_set_id = 1100000061
         and trunc (mmt.transaction_date) between :startdate and :enddate
group by to_char (mmt.transaction_date, 'DD-Mon-RRRR'),
         fm.formula_no,
         msi.concatenated_segments,
         msi.description,
         mlt.grade_code,
         mic.segment2,
         mtt.transaction_type_name;