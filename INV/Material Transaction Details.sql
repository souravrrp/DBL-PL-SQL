/* Formatted on 2/4/2021 11:17:05 AM (QP5 v5.354) */
  SELECT mmt.transaction_id,
         mmt.transaction_date,
         mmt.rcv_transaction_id,
         mmt.trx_source_line_id,
         mtt.transaction_type_name,
         mmt.transaction_source_id,
         mmt.transaction_source_name,
         mc.segment1 item_category,
         mc.segment2 item_type,
         mmt.inventory_item_id,
         msi.segment1 Item_code,
         msi.description,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         mtln.lot_number,
         mmt.organization_id,
         ood1.organization_code,
         ood2.organization_code transfer_organization,
         mmt.subinventory_code,
         mmt.transfer_subinventory,
         mil.segment1 item_Locator,
         mmt.distribution_account_id,
         gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7||'.'||gcc.segment8||'.'||gcc.segment9 dist_acc_code,
         mmt.transaction_reference,
         TO_CHAR (TRUNC (mmt.transaction_date), 'MON-YYYY') Txn_period,
         mmt.transaction_quantity,
         mmt.prior_costed_quantity,
         mmt.prior_cost,
         NVL (mtln.primary_quantity, mmt.primary_quantity) primary_qty,
         mtln.transaction_quantity lot_transaction_qty,
         mmt.transaction_uom,
         NVL (mtln.secondary_transaction_quantity, mmt.secondary_transaction_quantity) secondary_transaction_qty,
         --apps.fnc_get_item_cost(mmt.transfer_organization_id,mmt.inventory_item_id,to_char(trunc(mmt.transaction_date),'MON-YY')) dest_item_cost,
         --apps.fnc_get_item_cost(mmt.organization_id,mmt.inventory_item_id,to_char(trunc(mmt.transaction_date),'MON-YY')) source_item_cost,
         NVL (mmt.transaction_cost, mmt.actual_cost) per_qty_txn_cost,
         ABS ( mmt.transaction_quantity * NVL (mmt.transaction_cost, mmt.actual_cost)) transaction_value
    --,mmt.*
    --,mtt.*
    FROM inv.mtl_material_transactions    mmt,
         inv.mtl_transaction_lot_numbers  mtln,
         inv.mtl_system_items_b           msi,
         inv.mtl_item_categories          mic,
         inv.mtl_categories_b             mc,
         inv.mtl_transaction_types        mtt,
         apps.org_organization_definitions ood1,
         apps.org_organization_definitions ood2,
         inv.mtl_item_locations           mil,
         gl.gl_code_combinations          gcc
   WHERE     1 = 1
         AND msi.inventory_item_id = mmt.inventory_item_id
         AND msi.organization_id = mmt.organization_id
         AND ood1.organization_id = mmt.organization_id
         AND mmt.transaction_type_id = mtt.transaction_type_id
         AND mmt.transfer_organization_id = ood2.organization_id(+)
         AND msi.inventory_item_id = mic.inventory_item_id
         AND msi.organization_id = mic.organization_id
         AND mic.category_id = mc.category_id
         AND mmt.transaction_id = mtln.transaction_id(+)
         AND mmt.locator_id = mil.inventory_location_id(+)
         AND mmt.distribution_account_id = gcc.code_combination_id(+)
         AND (logical_transaction = 2 OR logical_transaction IS NULL)
         AND mic.category_set_id = 1
         --AND TRUNC (mmt.transaction_date) > '30-APR-2018' -- between '01-JAN-2016' and '31-OCT-2017'
         --AND TO_CHAR (TRUNC (mmt.transaction_date), 'MON-YY') IN ('JAN-21')
         --AND TO_CHAR (TRUNC (mmt.transaction_date), 'RRRR') IN ('2018')
         --AND ood1.legal_entity = 23279
         --AND ood1.operating_unit=85
         --AND ood2.organization_code = '251'
         --and mmt.organization_id in (152)
         --and ood1.organization_code in ('277')
         --AND mmt.subinventory_code IN ('CER-MOLD')
         --AND mmt.transfer_subinventory IN ('G27-STAGIN')
         --AND mmt.reason_id is null
         --AND mtln.lot_number IN ( '3-A-06-01-2021')
         --AND mc.segment1 IN ('FINISH GOODS')
         --AND mc.segment2 LIKE '%GRINDING MEDIA%'
         --AND gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7||'.'||gcc.segment8||'.'||gcc.segment9='2110.NUL.4020107.9999.00'
         --AND mtt.transaction_type_name IN ('Sales Order Pick')
         --AND mmt.transaction_source_name IN ('SCRAP_STOCK_RECEIVE_FOR_DELIVERY_JUNE_2018')
         --AND mmt.attribute_category = 'Distribution Sales'
         --AND mmt.transaction_source_id = '10521203'
         --AND mmt.trx_source_line_id = 9103548
         --AND mmt.rcv_transaction_id IN ()
         --AND mmt.transaction_set_id IN ()
         --AND mtt.transaction_source_type_id = 5
         AND mmt.transaction_type_id IN (44, 43, 1002)
         --AND msi.segment1 IN ('TH4040-001')
         --AND UPPER (msi.description) LIKE '%TYRE%MICRO%195%R%'
         --AND msi.inventory_item_id = '7297'
         --AND mmt.transaction_id IN (17472892)
         AND (   :p_operating_unit IS NULL OR (ood1.operating_unit = :p_operating_unit))
         AND (   :p_organization_code IS NULL OR (ood1.organization_code = :p_organization_code))
         AND (   :p_org_name IS NULL OR (UPPER (ood1.organization_name) LIKE UPPER ('%' || :p_org_name || '%')))
         AND (   :p_subinventory is null or (mmt.subinventory_code = :p_subinventory))
         AND (   :p_lot_number is null        or (mtln.lot_number = :p_lot_number))
         AND (   :p_item_code is null or (msi.segment1 = :p_item_code))
         AND trunc(mmt.transaction_date) between nvl(:p_transaction_date_from,trunc(mmt.transaction_date)) and nvl(:p_transaction_date_to,trunc(mmt.transaction_date))
         AND (   :p_transaction_type IS NULL OR (UPPER (mtt.transaction_type_name) LIKE UPPER ('%' || :p_transaction_type || '%')))
         AND (   :p_line_of_business is null or (upper (mc.segment1) like upper ('%' || :p_line_of_business || '%')))
         AND (   :p_major_category is null or (upper (mc.segment2) like upper ('%' || :p_major_category || '%')))
         AND (   :p_minor_category is null or (upper (mc.segment3) like upper ('%' || :p_minor_category || '%')))
ORDER BY mmt.transaction_id, mmt.transaction_date;