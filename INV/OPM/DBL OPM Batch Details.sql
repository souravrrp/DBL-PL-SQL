/* Formatted on 2/13/2021 9:42:55 AM (QP5 v5.354) */
  SELECT 
         gbh.actual_start_date,
         --gbh.actual_cmplt_date,
         --gbh.batch_close_date,
         --gbh.attribute3 as Shift,
         --gbh.attribute11 as heat_no,
         --mmt.transaction_id,
         --gmd.created_by,
         --fu.user_name,
         --mmt.trx_source_line_id as material_detail_id,
         --mmt.transaction_source_id as trans_source_id,
         mmt.locator_id,
         --mtln.lot_number as lot_number,
         --mmt.primary_quantity,
         --mtln.transaction_quantity as lot_qty,
         to_char(mmt.transaction_date, 'DD-MON-YYYY HH24:MI:SS') as transaction_date,
         DECODE (gbh.batch_status,
                 -1, 'Cancelled',
                 1, 'Pending',
                 2, 'WIP',
                 3, 'Completed',
                 4, 'Closed')                  AS batch_status,
         gbh.batch_no                          AS batch_no,
         DECODE (gmd.line_type,
                 -1, 'Ingredients',
                 1, 'Product',
                 2, 'by product')              AS line_type, 
         mmt.organization_id,
         msi.concatenated_segments,
         msi.description,
         mtt.transaction_type_name,
         mmt.subinventory_code,
         CASE
             WHEN mtln.lot_number IS NOT NULL THEN mtln.transaction_quantity
             ELSE mmt.transaction_quantity
         END                                   AS trans_qty,
         mmt.transaction_uom                   AS trans_uom,
         mmt.secondary_transaction_quantity    AS sec_qty,
         mmt.secondary_uom_code,
         (CASE
              WHEN gmd.line_type = '-1' AND mtln.lot_number IS NOT NULL
              THEN
                  mtln.transaction_quantity
              ELSE
                  (CASE
                       WHEN gmd.line_type = '-1' AND mtln.lot_number IS NULL
                       THEN
                           gmd.actual_qty
                   END)
          END)                                 ingredients_quantity,
         (CASE
              WHEN gmd.line_type = '1' AND mtln.lot_number IS NOT NULL
              THEN
                  mtln.transaction_quantity
              ELSE
                  (CASE
                       WHEN gmd.line_type = '1' AND mtln.lot_number IS NULL
                       THEN
                           gmd.actual_qty
                   END)
          END)                                 product_quantity,
         (CASE
              WHEN gmd.line_type = '2' AND mtln.lot_number IS NOT NULL
              THEN
                  mtln.transaction_quantity
              ELSE
                  (CASE
                       WHEN gmd.line_type = '2' AND mtln.lot_number IS NULL
                       THEN
                           gmd.actual_qty
                   END)
          END)                                 byproduct_quantity
         --,gbh.*
         --,mmt.*
         --,gmd.*
         --,mtln.*
         --,mln.*
         --,grb.*
    FROM inv.mtl_material_transactions  mmt,
         apps.gme_material_details       gmd,
         apps.gme_batch_header           gbh,
         apps.mtl_transaction_lot_numbers mtln,
         apps.mtl_lot_numbers            mln,
         apps.mtl_system_items_kfv       msi,
         apps.mtl_transaction_types      mtt,
         inv.mtl_item_categories         mic,
         inv.mtl_categories_b            mc,
         org_organization_definitions    ood
   --apps.fnd_user fu
   WHERE     1 = 1
         AND mmt.transaction_source_type_id = 5
         AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
         AND (   :p_batch_no IS NULL OR (gbh.batch_no = :p_batch_no))
         AND (   :p_item_code is null or (msi.segment1 = :p_item_code))
         AND (   :p_transaction_type IS NULL OR (UPPER (mtt.transaction_type_name) LIKE UPPER ('%' || :p_transaction_type || '%')))
         AND trunc(mmt.transaction_date) between nvl(:p_transaction_date_from,trunc(mmt.transaction_date)) and nvl(:p_transaction_date_to,trunc(mmt.transaction_date))
         AND mmt.transaction_source_id = gbh.batch_id
         AND mmt.organization_id = gbh.organization_id
         AND gmd.batch_id = gbh.batch_id
         AND gmd.material_detail_id = mmt.trx_source_line_id
         AND mmt.transaction_id = mtln.transaction_id(+)
         AND mtln.lot_number  = mln.lot_number(+)
         AND mtln.organization_id = mln.organization_id(+)
         AND mtln.inventory_item_id = mln.inventory_item_id(+)
         AND gmd.inventory_item_id = msi.inventory_item_id
         AND gmd.organization_id = msi.organization_id
         AND mmt.transaction_type_id = mtt.transaction_type_id
         AND msi.inventory_item_id = mic.inventory_item_id
         AND msi.organization_id = mic.organization_id
         AND mic.category_id = mc.category_id
         --and mmt.created_by=fu.user_id
         --and mmt.organization_id in (YY)
         --and gbh.batch_id in (xxxxxx)
         --and mtln.lot_number IN ('ZZZ')
         --and gbh.batch_status=2
         --and mtt.transaction_type_name in ('wip issue','wip return')     --('wip completion','wip completion return')
         AND mic.category_set_id = 1
ORDER BY gbh.actual_start_date;