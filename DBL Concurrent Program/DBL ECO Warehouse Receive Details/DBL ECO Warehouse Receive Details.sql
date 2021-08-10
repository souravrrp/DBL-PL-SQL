/* Formatted on 17-Oct-19 10:02:55 (QP5 v5.136.908.31019) */
  SELECT                                                                 --  *
        msim.inventory_item_id,
         ghdr.batch_no,
         TRUNC (mmt.transaction_date) Received_Date,
         msim.segment1 item_no,
         msim.description,
         SUM (mmt.primary_quantity) primary_quantity,
         mmt.transaction_uom,
         SUM (mmt.secondary_transaction_quantity) secondary_quantity,
         mmt.secondary_uom_code,
         mmt.subinventory_code,
         msim.item_type
    FROM mtl_material_transactions mmt,
         mtl_transaction_types mtt,
         gme_batch_header ghdr,
         mtl_system_items_b msim
   WHERE     1 = 1
         AND mtt.transaction_type_name IN ('WIP Completion')
         AND mtt.transaction_type_id = mmt.transaction_type_id
         AND mmt.transaction_source_id = ghdr.batch_id
         AND msim.organization_id = 150
         AND mmt.inventory_item_id = msim.inventory_item_id
         AND msim.organization_id = mmt.organization_id
         AND TRUNC (mmt.transaction_date) BETWEEN :p_date_from AND :p_date_to
GROUP BY msim.inventory_item_id,
         msim.segment1,
         ghdr.batch_no,
         mmt.transaction_uom,
         mmt.secondary_uom_code,
         mmt.subinventory_code,
         msim.description,
         msim.item_type,
         TRUNC (mmt.transaction_date)
ORDER BY TRUNC (mmt.transaction_date)