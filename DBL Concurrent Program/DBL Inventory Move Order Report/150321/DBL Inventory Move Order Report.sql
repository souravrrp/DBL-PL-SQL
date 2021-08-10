/* Formatted on 3/15/2021 11:30:11 AM (QP5 v5.354) */
  SELECT mtrl.line_number,
         mtrh.created_by,
         mtrh.request_number,
         mtrh.organization_id,
         mfg.meaning,
         mtrh.description
             "MO Description",
         TO_CHAR (mtrh.date_required, 'DD-MON-RRRR HH12:MI:SS PM')
             date_required,
         mtrh.from_subinventory_code,
         mtt.transaction_type_name,
         msi.segment1,
         msi.description,
         mtrl.uom_code,
         mtrl.quantity,
         mtrl.REFERENCE,
         mtrl.quantity_delivered,
            -- to_char(mmt.creation_date,'DD-MON-RRRR HH12:MI:SS PM')  "Delivered Date",
            gcc.segment1
         || '.'
         || gcc.segment2
         || '.'
         || gcc.segment3
         || '.'
         || gcc.segment4
         || '.'
         || gcc.segment5
         || '.'
         || gcc.segment6
             Account_old,
         ffv.description || ' ' || '(' || gcc.segment5 || ')'
             Account,
         ffv2.description || ' ' || '(' || gcc.segment4 || ')'
             "Cost Center",
         moq.on_hand,
         ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name
             global_name,
         mtrl.attribute7
             "Use Of Area",
         mtrl.attribute8
             "Specification",
         CASE
             WHEN mtrh.HEADER_STATUS = 3
             THEN
                 (SELECT MAX (papf2.full_name)     AS APPROVED_BY
                    FROM apps.per_all_people_f     papf,
                         apps.per_all_assignments_f paaf,
                         apps.per_all_assignments_f paaf1,
                         apps.per_all_people_f     papf1,
                         apps.per_all_people_f     papf2,
                         apps.per_all_assignments_f paaf3,
                         apps.per_person_types     ppt,
                         fnd_user                  fu,
                         apps.per_grades           pg
                   WHERE     papf.person_id = paaf.person_id
                         AND papf1.person_id = paaf.supervisor_id
                         AND papf1.person_id = paaf1.person_id
                         AND papf.business_group_id = 81
                         AND fu.user_name = papf.employee_number
                         AND paaf1.supervisor_id = papf2.person_id
                         AND papf.business_group_id = paaf.business_group_id
                         AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                                                 AND papf.effective_end_date
                         AND TRUNC (SYSDATE) BETWEEN paaf.effective_start_date
                                                 AND paaf.effective_end_date
                         AND TRUNC (SYSDATE) BETWEEN paaf1.effective_start_date
                                                 AND paaf1.effective_end_date
                         AND TRUNC (SYSDATE) BETWEEN paaf3.effective_start_date
                                                 AND paaf3.effective_end_date
                         AND ppt.person_type_id = papf.person_type_id
                         AND pg.grade_id(+) = paaf3.grade_id
                         AND ppt.user_person_type <> 'Ex-employee'
                         AND papf2.person_id = paaf3.person_id
                         AND LPAD (pg.NAME, 2) <> 'TM'
                         AND user_id = mtrh.created_by)
             ELSE
                 ''
         END
             AS APPROVED_BY
    FROM mtl_txn_request_headers mtrh,
         mtl_txn_request_lines  mtrl,
         mtl_transaction_types  mtt,
         mtl_system_items_b     msi,
         mfg_lookups            mfg,
         -- mtl_material_transactions mmt,
         fnd_user               fu,
         per_people_f           ppf,
         gl_code_combinations   gcc,
         fnd_flex_values_vl     ffv,
         fnd_flex_values_vl     ffv2,
         mtl_lot_numbers        mln,
         (  SELECT inventory_item_id,
                   organization_id,
                   SUM (NVL (transaction_quantity, 0))     on_hand
              FROM mtl_onhand_quantities
          GROUP BY inventory_item_id, organization_id) moq
   WHERE     mtrh.header_id = mtrl.header_id
         AND mtrh.transaction_type_id = mtt.transaction_type_id
         AND mtrl.inventory_item_id = msi.inventory_item_id
         AND mtrl.organization_id = msi.organization_id
         AND mtrh.header_status = mfg.lookup_code
         AND lookup_type = 'MTL_TXN_REQUEST_STATUS'
         --and mtrl.line_id=mmt.move_order_line_id(+)
         --and mtrl.organization_id=mmt.organization_id(+)
         --and mtrl.inventory_item_id=mmt.inventory_item_id(+)
         AND mtrh.created_by = fu.user_id(+)
         AND fu.employee_id = ppf.person_id(+)
         --and sysdate between ppf.effective_start_date and ppf.effective_end_date
         AND mtrl.to_account_id = gcc.code_combination_id(+)
         AND gcc.segment5 = ffv.flex_value_meaning(+)
         AND gcc.segment4 = ffv2.flex_value_meaning(+)
         AND mtrl.inventory_item_id = moq.inventory_item_id(+)
         AND mtrl.organization_id = moq.organization_id(+)
         AND mtrl.lot_number = mln.lot_number(+)
         AND mtrl.inventory_item_id = mln.inventory_item_id(+)
         AND mtrl.organization_id = mln.organization_id(+)
         AND ffv2.flex_value_set_id = 1017032
         AND ffv.flex_value_set_id = 1017040
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
         --and mtrh.request_number=:p_move_order
         AND mtrh.organization_id = :p_organization_id
         AND mfg.meaning = NVL ( :p_status, mfg.meaning)
         AND (   :p_move_order IS NULL
              OR mtrh.request_number BETWEEN :p_move_order AND :p_move_order_to)
         AND (   :p_from_creation_date IS NULL
              OR TRUNC (mtrh.creation_date) BETWEEN :p_from_creation_date
                                                AND :p_to_creation_date)
ORDER BY mtrl.line_number