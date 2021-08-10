/ Formatted on 21/12/2019 12:35:26 PM (QP5 v5.136.908.31019) /
  SELECT                                                                 --  *
        msim.inventory_item_id,
         ghdr.batch_no,
         TRUNC (mmt.transaction_date) Received_Date,
         msim.segment1 item_no,
         msim.description,
         msim.primary_uom_code,
         msim.secondary_uom_code,
         mic.segment3 item_type,
         mmt.subinventory_code,
         SUM (mmt.primary_quantity) primary_quantity,
         SUM (mmt.secondary_transaction_quantity) secondary_quantity
    FROM mtl_material_transactions mmt,
         mtl_transaction_types mtt,
         gme_batch_header ghdr,
         mtl_system_items_b msim,
         mtl_item_categories_v mic
   WHERE 1 = 1
         AND mtt.transaction_type_name IN
                  ('WIP Completion', 'WIP Completion Return')
         AND mtt.transaction_type_id = mmt.transaction_type_id
         AND mmt.transaction_source_id = ghdr.batch_id
         AND msim.organization_id = 150
         AND mmt.inventory_item_id = msim.inventory_item_id
         AND msim.organization_id = mmt.organization_id
         AND mic.inventory_item_id = msim.inventory_item_id
         AND mic.organization_id = mmt.organization_id
         AND mic.category_set_id = 1
         AND mic.segment2 = 'FINISH GOODS'
         AND TRUNC (mmt.transaction_date) BETWEEN :p_date_from AND :p_date_to
GROUP BY msim.inventory_item_id,
         ghdr.batch_no,
         TRUNC (mmt.transaction_date),
         msim.segment1,
         mic.segment3,
         msim.description,
         msim.secondary_uom_code,
         mmt.subinventory_code,
         msim.primary_uom_code
ORDER BY TRUNC (mmt.transaction_date)