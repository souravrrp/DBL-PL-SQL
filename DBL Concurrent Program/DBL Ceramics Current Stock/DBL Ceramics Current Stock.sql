/* Formatted on 10-Mar-19 14:45:40 (QP5 v5.136.908.31019) */
  SELECT a.organization_id org_id,
         mic.segment2 AS catg,
         mic.segment3 AS TYPE,
         mmt.subinventory_code subinv,
         a.concatenated_segments || '.' || mln.grade_code item_id,
         a.description,
         micc.SEGMENT1,
         micc.SEGMENT2 Item_Size,
         -- mmt.transaction_uom,
         --mtl.lot_number,
         mln.grade_code grade,
         -- mln.origination_date production_date,
         -- a.attribute3 ITEM TYPE,
         --mms.status_code,
         --  mln.hold_date,
         SUM (mmt.primary_quantity) sft_qty,
         SUM (mtl.secondary_transaction_quantity) ctn,
         (SUM (mmt.primary_quantity) * 0.092936803) sqm
    FROM apps.mtl_material_transactions mmt,
         apps.mtl_txn_source_types mtst,
         apps.mtl_system_items_b_kfv a,
         apps.mtl_item_categories_v mic,
         apps.mtl_item_categories_v micc,
         apps.mtl_transaction_lot_numbers mtl,
         apps.mtl_material_statuses_vl mms,
         apps.mtl_lot_numbers mln
   WHERE     mmt.transaction_date <= NVL (TO_DATE (:p_dat), SYSDATE) + 1
         AND mmt.transaction_source_type_id = mtst.transaction_source_type_id
         AND mmt.inventory_item_id = a.inventory_item_id
         AND mmt.organization_id = a.organization_id
         AND mic.inventory_item_id = a.inventory_item_id
         AND mic.organization_id = a.organization_id
         AND micc.inventory_item_id = a.inventory_item_id
         AND micc.organization_id = a.organization_id
         AND mmt.transaction_id = mtl.transaction_id(+)
         AND mtl.organization_id = mln.organization_id(+)
         AND mtl.inventory_item_id = mln.inventory_item_id(+)
         AND mtl.lot_number = mln.lot_number
         AND mln.status_id = mms.status_id(+)
         AND mic.category_set_id = 1
         AND micc.category_set_id = 1100000061
         AND mic.ORGANIZATION_ID = micc.ORGANIZATION_ID
         AND mic.segment2 = 'FINISH GOODS'
         AND (mmt.logical_transaction = 2 OR mmt.logical_transaction IS NULL)
         AND a.organization_id = 152
GROUP BY a.organization_id,
         mic.segment3,
         mic.segment2,
         mmt.subinventory_code,
         a.concatenated_segments,
         a.description,
         micc.SEGMENT1,
         micc.SEGMENT2,
         --        mmt.transaction_uom,
         --mtl.lot_number,
         mln.grade_code
--mln.origination_date,
--mms.status_code,
--    mln.hold_date,
--  mln.attribute_category,
--mln.attribute2,
--mln.attribute3
ORDER BY a.description