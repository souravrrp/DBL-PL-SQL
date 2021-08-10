/* Formatted on 10/5/2020 12:00:21 PM (QP5 v5.354) */
  SELECT ood.organization_id
             unit_id,
         h.request_number
             move_order,
         h.date_required
             move_ord_date,
         mmt.transaction_date,
         trx.header_status_name
             move_order_status,
         msi.segment1
             item_code,
         msi.description
             item_name,
         l.quantity
             request_qty,
         l.quantity_delivered
             confirm_qty,
         l.uom_code,
         --XXDBL.xxdbl_fnc_get_item_cost (h.organization_id, l.inventory_item_id, TO_CHAR (h.date_required, 'MON-YY'))
         mmt.actual_cost
             item_rate,
         (mmt.actual_cost * l.quantity_delivered)
             confirm_value,
         l.attribute7
             use_area,
         ffv.description
             natural_account,
         concatenated_segments
             account_code,
         (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
             created_by,
         (   papfs.first_name
          || ' '
          || papfs.middle_names
          || ' '
          || papfs.last_name)
             approved_by,
         apps.xx_com_pkg.get_emp_name_from_user_id (mmt.created_by)
             delivered_by
    FROM apps.mtl_txn_request_headers  h,
         apps.mtl_txn_request_lines    l,
         apps.mtl_txn_request_headers_v trx,
         hr_operating_units            hou,
         org_organization_definitions  ood,
         xxdbl_company_le_mapping_v    ou,
         apps.mtl_system_items_b       msi,
         apps.mtl_item_categories_v    mic,
         apps.gl_code_combinations_kfv gccv,
         apps.fnd_flex_values_vl       ffv,
         apps.mtl_material_transactions mmt,
         applsys.fnd_user              fu,
         hr.per_all_people_f           papf,
         hr.per_all_assignments_f      paaf,
         hr.per_all_assignments_f      paafs,
         hr.per_all_people_f           papfs
   WHERE     1 = 1
         AND msi.inventory_item_id = l.inventory_item_id
         AND msi.organization_id = l.organization_id
         AND mic.category_set_id = 1
         AND msi.inventory_item_id = mic.inventory_item_id
         AND msi.organization_id = mic.organization_id
         AND h.header_id = mmt.transaction_source_id(+)
         AND l.line_id = mmt.move_order_line_id(+)
         AND h.request_number = trx.request_number
         AND h.header_id = l.header_id
         AND h.organization_id = l.organization_id
         AND trx.header_status_name IN ('Approved', 'Closed')
         AND ( :p_move_ord_no IS NULL OR (h.request_number = :p_move_ord_no))
         AND (   :p_organization_id IS NULL
              OR (ood.organization_id = :p_organization_id))
         AND msi.organization_id = ood.organization_id
         AND hou.organization_id = ood.operating_unit
         AND ood.operating_unit = ou.org_id
         AND l.to_account_id = gccv.code_combination_id(+)
         AND gccv.segment5 = ffv.flex_value(+)
         AND h.created_by = fu.user_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND paaf.supervisor_id = papfs.person_id(+)
         AND papfs.person_id = paafs.person_id
         AND SYSDATE BETWEEN papfs.effective_start_date
                         AND papfs.effective_end_date
         AND SYSDATE BETWEEN paafs.effective_start_date
                         AND paafs.effective_end_date
ORDER BY h.request_number DESC;


  SELECT *
    FROM apps.mtl_txn_request_headers h
--where H.REQUEST_NUMBER = '783222'
ORDER BY creation_date DESC