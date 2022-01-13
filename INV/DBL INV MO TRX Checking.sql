/* Formatted on 1/11/2022 12:19:23 PM (QP5 v5.374) */
---------------------------------DBL MOVE Order----------------------------------------------

  SELECT ood.operating_unit              org_id,
         --hou.name                         operating_unit_name,
         ood.organization_code           org_code,
         mtrh.organization_id,
         --mtrh.from_subinventory_code     from_subinv,
         --mtrh.to_subinventory_code       to_subinv,
         --hou.default_legal_context_id     legal_entity,
         --ou.legal_entity_name,
         --mtrh.header_id mov_ord_hdr_id,
         --mtrh.creation_date,
         mtrh.request_number             move_order,
         trh.header_status_name mo_status,
         trh.status_date,
         mtrl.inventory_item_id,
         msib.segment1                   item_code,
         msib.description                item_name,
         cat.segment2                    item_category,
         cat.segment3                    item_type,
         mtrl.uom_code,
         mtrl.quantity,
         mtrl.quantity_delivered,
         --mtrl.reason_id,
         trh.transaction_type_name       trx_type,
         trh.move_order_type_name        mo_type,
         gcc.concatenated_segments
    --,mtrh.*
    --,mtrl.*
    --,trh.*
    --,mmt.*
    --,mtt.*
    --,msib.*
    --,cat.*
    FROM apps.mtl_txn_request_headers  mtrh,
         apps.mtl_txn_request_lines    mtrl,
         apps.mtl_txn_request_headers_v trh,
         apps.mtl_material_transactions mmt,
         --,inv.mtl_transaction_types mtt
         --hr_operating_units            hou,
         --xxdbl_company_le_mapping_v    ou,
         org_organization_definitions  ood,
         apps.gl_code_combinations_kfv gcc,
         apps.mtl_system_items_b       msib,
         apps.mtl_item_categories_v    cat
   WHERE     1 = 1
         AND mtrh.header_id = mtrl.header_id(+)
         AND mtrh.organization_id = mtrl.organization_id(+)
         AND mtrh.request_number = trh.request_number(+)
         AND mtrh.organization_id = ood.organization_id(+)
         AND mtrl.inventory_item_id = msib.inventory_item_id(+)
         AND mtrl.organization_id = msib.organization_id(+)
         AND cat.category_set_id = 1
         AND msib.inventory_item_id = cat.inventory_item_id(+)
         AND msib.organization_id = cat.organization_id(+)
         AND mtrl.to_account_id = gcc.code_combination_id(+)
         AND mtrh.header_id = mmt.transaction_source_id(+)
         AND mtrl.line_id = mmt.move_order_line_id(+)
         -----------------------------------------------------------------------
         --and mtt.transaction_type_id=mmt.transaction_type_id
         --and mtt.transaction_source_type_id = mmt.transaction_source_type_id
         --AND (   :p_operating_unit IS NULL OR (ood.operating_unit = :p_operating_unit))
         --AND ( :p_ou_name IS NULL OR (hou.name = :p_ou_name))
         --AND (   :p_legal_entity IS NULL OR (hou.default_legal_context_id = :p_legal_entity))
         --AND ood.operating_unit = hou.organization_id
         --AND ood.operating_unit = ou.org_id
         -----------------------------------------------------------------------
         --and trh.header_status_name = 'Approved'
         --and mtrh.from_subinventory_code='AKC-GEN ST'
         --and mtrh.organization_id IN (193)
         --and trh.move_order_type_name='Requisition'
         --and trh.transaction_type_name='Move Order Issue'
         --and mtrh.request_number IN ('1144849')
         --and mtrl.line_id IN ('31251259')
         -----------------------------------------------------------------------
         AND ( :p_move_ord_no IS NULL OR (mtrh.request_number = :p_move_ord_no))
         AND TRUNC (mmt.transaction_date) BETWEEN NVL ( :p_trx_date_from, TRUNC ( mmt.transaction_date)) AND NVL ( :p_trx_date_to, TRUNC ( mmt.transaction_date))
         AND ( :p_item_code IS NULL OR (msib.segment1 = :p_item_code))
         AND (   :p_organization_code IS NULL OR (ood.organization_code = :p_organization_code))
ORDER BY mtrh.request_number DESC;