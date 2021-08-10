/* Formatted on 1/24/2021 4:52:05 PM (QP5 v5.354) */
SELECT mmt.transaction_id,
       mmt.transaction_date,
       mmt.organization_id,
       mmt.inventory_item_id,
       mmt.subinventory_code,
       mmt.transaction_type_id,
       mtt.transaction_type_name,
       mmt.transaction_source_id,
       mmt.transaction_source_type_id,
       mmt.transaction_action_id,
       mmt.transaction_quantity,
       mmt.transaction_uom,
       mmt.primary_quantity,
       mmt.secondary_uom_code,
       mmt.secondary_transaction_quantity
  --,mmt.*
  --,mtt.*
  --,msi.*
  --,cat.*
  --,ood.*
  --,gbh.*
  FROM mtl_material_transactions          mmt,
       inv.mtl_transaction_types          mtt,
       apps.mtl_system_items_b            msi,
       apps.org_organization_definitions  ood,
       apps.mtl_item_categories_v         cat,
       gme.gme_batch_header               gbh
 WHERE     1 = 1
       AND mmt.transaction_type_id = mtt.transaction_type_id
       AND mmt.organization_id = ood.organization_id
       AND mmt.inventory_item_id = msi.inventory_item_id
       AND msi.organization_id = ood.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND cat.category_set_id = 1
       AND mmt.transaction_source_id = gbh.batch_id
       --AND mmt.organization_id = 150
       --AND mmt.logical_transaction IS NULL
       --AND mmt.transaction_id IN (26065173, 26065056)
       --AND mtt.transaction_type_name in ('WIP Issue','WIP Return','WIP Completion')
       AND mtt.transaction_type_name = 'WIP Issue'
       AND ( :p_batch_no IS NULL OR (gbh.batch_no = :p_batch_no))
       AND ( :p_org_code IS NULL OR (ood.organization_code = :p_org_code))
       AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
       AND (   :p_line_of_business IS NULL
            OR (cat.segment1 = :p_line_of_business))
       AND ( :p_major_category IS NULL OR (cat.segment2 = :p_major_category))
       --AND TRUNC (mmt.transaction_date) BETWEEN NVL ( :p_date_from, TRUNC ( mmt.transaction_date)) AND NVL ( :p_date_to, TRUNC (mmt.transaction_date))
       AND mmt.transaction_source_type_id = 5;