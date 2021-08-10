/* Formatted on 6/20/2021 4:01:19 PM (QP5 v5.287) */
  SELECT ood.organization_code,
         ood.organization_name,
         mmt.subinventory_code,
         mmt.transaction_uom,
         mmt.transaction_date,
         mmt.source_code,
         mtt.transaction_type_name,
         ycat.yrn_type,
         msib.segment1 itemcode,
         msib.description,
         mln.attribute1 brand,
         mln.lot_number,
         c.customer_name AS buyer,
         SUM (mmt.primary_quantity) qty_kg,
         ROUND (
              (SUM (mmt.primary_quantity) * SUM (mmt.new_cost))
            / SUM (mmt.primary_quantity),
            2)
            rate
    FROM mtl_material_transactions mmt,
         mtl_transaction_types mtt,
         mtl_system_items_b msib,
         apps.mtl_transaction_lot_numbers mlt,
         apps.mtl_lot_numbers mln,
         apps.org_organization_definitions ood,
         apps.mtl_item_categories_v mic,
         xxdbl.xxdbl_yrn_catg ycat,
         (SELECT tr.transaction_id, c.customer_name
            FROM mtl_material_transactions tr, ar_customers c
           WHERE     TO_NUMBER (NVL (tr.attribute2, '0')) = c.customer_id
                 AND tr.attribute_category = 'Grey Yarn Issue for Knitting') c
   WHERE     1 = 1
         AND mtt.transaction_type_id = mmt.transaction_type_id
         AND mmt.inventory_item_id = msib.inventory_item_id
         AND msib.inventory_item_id = ycat.inventory_item_id(+)
         AND mmt.organization_id = msib.organization_id
         AND msib.organization_id = mic.organization_id
         AND msib.inventory_item_id = mic.inventory_item_id
         AND mlt.organization_id = mln.organization_id(+)
         AND mlt.inventory_item_id = mln.inventory_item_id(+)
         AND mlt.lot_number = mln.lot_number(+)
         AND mmt.organization_id = ood.organization_id
         AND mmt.transaction_id = mlt.transaction_id(+)
         AND mic.segment2 = 'RAW MATERIAL'
         AND mic.segment3 = 'YARN'
         AND mic.category_set_id = 1
         AND mtt.transaction_type_id IN (31, 41)
         AND mmt.transaction_id = c.transaction_id(+)
         AND mmt.subinventory_code NOT LIKE 'DYR ST%'
GROUP BY ood.organization_code,
         ood.organization_name,
         mmt.subinventory_code,
         mmt.transaction_uom,
         mmt.transaction_date,
         mmt.source_code,
         mtt.transaction_type_name,
         msib.segment1,
         msib.description,
         mln.attribute1,
         mln.lot_number,
         c.customer_name,
         ycat.yrn_type