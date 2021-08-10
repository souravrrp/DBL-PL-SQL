/* Formatted on 9/28/2020 11:52:07 AM (QP5 v5.354) */
-----------------Batch Transaction Checking------------------------------------

  SELECT b.RECIPE_DESCRIPTION,
         a.RECIPE_VALIDITY_RULE_ID,
         c.INVENTORY_ITEM_ID,
         d.description,
         DECODE (c.line_type, -1, 'Ingredient', 'Product')     TYPE,
         SUM (e.TRANSACTION_QUANTITY)                          quantity
    FROM apps.GME_BATCH_HEADER         a,
         apps.gmd_recipes              b,
         gmd_recipe_validity_rules     grr,
         apps.gme_material_details     c,
         apps.mtl_system_items         d,
         apps.mtl_material_transactions e
   WHERE     a.FORMULA_ID = b.FORMULA_ID
         AND a.ROUTING_ID = b.ROUTING_ID
         AND a.RECIPE_VALIDITY_RULE_ID = grr.RECIPE_VALIDITY_RULE_ID
         AND grr.RECIPE_ID = b.recipe_id
         AND a.BATCH_ID = c.BATCH_ID
         AND a.ORGANIZATION_ID = c.ORGANIZATION_ID
         AND c.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
         AND c.ORGANIZATION_ID = d.organization_id
         AND a.batch_id = e.TRANSACTION_SOURCE_ID
         AND a.ORGANIZATION_ID = e.ORGANIZATION_ID
         AND c.INVENTORY_ITEM_ID = e.INVENTORY_ITEM_ID
         AND a.batch_no IN
                 (SELECT batch_no
                    FROM apps.GME_BATCH_HEADER
                   WHERE TRUNC (plan_start_date) BETWEEN :from_date
                                                     AND :TO_DATE)
         AND a.ORGANIZATION_ID = :your_org_id
         AND TRUNC (e.transaction_date) BETWEEN :from_date AND :TO_DATE
GROUP BY b.RECIPE_DESCRIPTION,
         a.RECIPE_VALIDITY_RULE_ID,
         c.INVENTORY_ITEM_ID,
         d.description,
         c.line_type
ORDER BY RECIPE_DESCRIPTION;


-----------------Batch Transaction Checking------------------------------------

SELECT DISTINCT sysb.segment1                  "Ingredient Item Number",
                mtt.transaction_type_name      Ingred_transaction_type,
                mtt1.transaction_type_name     Prod_transaction_type,
                mtln.transaction_quantity,
                mmt.transaction_date,
                mmt.transaction_set_id,
                sysb1.segment1                 "Prod_Item",
                gg.object_id                   "Ingredient Object ID",
                gg.object_type                 "Ingredient Object Type",
                mtln.transaction_id,
                mtln.transaction_source_id,
                gg.parent_object_id            "Ingredient Parent Object ID",
                mtln.lot_number                "Ingredient Lot Number",
                mtln.grade_code                "Ingredient Grade",
                mtln1.lot_number               "Prod_Lot",
                mtln1.grade_code               "Prod Grade",
                batch1.batch_no                "Product Batch Number"
  FROM inv.mtl_object_genealogy         gg,
       inv.mtl_object_genealogy         gg1,
       inv.mtl_transaction_lot_numbers  mtln,
       inv.mtl_transaction_lot_numbers  mtln1,
       inv.mtl_system_items_b           sysb,
       inv.mtl_system_items_b           sysb1,
       gme.gme_batch_header             batch,
       gme.gme_batch_header             batch1,
       apps.mtl_material_transactions   mmt,
       apps.mtl_material_transactions   mmt1,
       inv.mtl_transaction_types        mtt,
       inv.mtl_transaction_types        mtt1
 WHERE     1 = 1
       AND gg.origin_txn_id(+) = mtln.transaction_id
       AND mtln.inventory_item_id = sysb.inventory_item_id
       AND mtln.transaction_source_id = batch.batch_id
       AND gg1.origin_txn_id = mtln1.transaction_id
       AND mtln1.inventory_item_id = sysb1.inventory_item_id
       AND mtln1.transaction_source_id = batch1.batch_id
       AND NVL (gg1.object_id, gg.object_id) = gg.parent_object_id
       AND mmt.transaction_type_id = mtt.transaction_type_id
       AND mmt1.transaction_type_id = mtt1.transaction_type_id
       --AND gg.object_id = gg1.parent_object_id
       AND sysb.organization_id = mmt.organization_id
       AND batch.organization_id = mmt.organization_id
       AND mtln.organization_id = mmt.organization_id
       --AND sysb.segment1 = :p_segment1
       --AND mtln.lot_number = :p_lotnumber
       AND sysb.segment1 = sysb1.segment1
       AND TRUNC (batch.plan_start_date) BETWEEN :from_date AND :TO_DATE
       --AND batch1.batch_no = :p_batch_no
       AND mtln.lot_number != mtln1.lot_number
       AND mmt.TRANSACTION_ID = mtln.transaction_id
       AND mmt1.TRANSACTION_ID = mtln1.transaction_id;