/* Formatted on 7/9/2020 11:33:57 AM (QP5 v5.287) */
  SELECT  distinct
         pha.ORG_ID,
         HOU.NAME,
         OU.LEDGER_NAME,
         OU.LEGAL_ENTITY_NAME,
         pha.segment1 "PO Number",
         pv.segment1 "Supplier ID",
         pv.vendor_name "Supplier Name",
         pvsa.vendor_site_code "Supplier Site",
         pla.line_num,
         pla.purchase_basis "Line Type",
         --pla.item_id,
         mc.segment1 item_category,
         mc.segment2 item_type,
         msi.segment1 "Item Code",
         pla.item_description,
         pla.unit_meas_lookup_code "UOM",
         TO_CHAR (TRUNC (pha.creation_date), 'DD-MON-RR') CREATION_DATE,
         TO_CHAR (TRUNC (pha.last_update_date), 'DD-MON-RR') LAST_UPDATE_DATE,
         TO_CHAR (TRUNC (pha.approved_date), 'DD-MON-RR') APPROVED_DATE,
         (SELECT MAX( PAH.ACTION_DATE)
            FROM apps.PO_ACTION_HISTORY PAH
           WHERE     pha.PO_HEADER_ID = PAH.object_id(+)
                 AND PAH.action_code = 'SUBMIT'
                 AND PAH.OBJECT_TYPE_CODE = 'PO')
            SUBMIT_DATE
    --pda.*
    FROM apps.po_headers_all pha,
         apps.po_lines_all pla,
         apps.po_line_locations_all pll,
         apps.gl_code_combinations gcc,
         apps.gl_code_combinations gcc1,
         apps.po_distributions_all pda,
         apps.ap_suppliers pv,
         apps.ap_supplier_sites_all pvsa,
         apps.mtl_system_items_vl msi,
         apps.org_organization_definitions ood,
         --apps.fnd_flex_values_vl flex,
         apps.fnd_user fu,
         apps.per_people_f ppf,
         --apps.pa_projects_all ppa,
         apps.pa_tasks pt,
         apps.mtl_item_categories mic,
         apps.mtl_categories mc,
         apps.mtl_category_sets mcs,
         apps.po_req_distributions_all prda,
         apps.po_requisition_lines_all prla,
         apps.po_requisition_headers_all prha,
         po.po_action_history pah,
         HR_OPERATING_UNITS HOU,
         XXDBL_COMPANY_LE_MAPPING_V OU
   WHERE     1 = 1
         AND ( :P_ORG_ID IS NULL OR (PHA.ORG_ID = :P_ORG_ID))
         AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no))
         AND ( :p_req_no IS NULL OR (prha.segment1 = :p_req_no))
         AND msi.inventory_item_id = mic.inventory_item_id(+)
         AND msi.organization_id = mic.organization_id(+)
         AND pla.category_id = mic.category_id(+)
         AND pla.category_id = mc.category_id(+)
         --and mic.category_id=mc.category_id(+)
         AND mc.structure_id = mcs.structure_id(+)
         AND mic.category_set_id = mcs.category_set_id(+)
         --and msi.segment1||'.'||msi.segment2||'.'||msi.segment3 in ('BRND.GIFT.0001')
         --and pha.creation_date between '01-JAN-2017' and '16-MAY-2018'
         --and pda.destination_organization_id=1345
         --and pda.destination_type_code = 'EXPENSE'
         AND (pha.cancel_flag IS NULL OR pha.cancel_flag = 'N')
         AND (pla.cancel_flag IS NULL OR pla.cancel_flag = 'N')
         AND pda.gl_cancelled_date IS NULL
         AND ( :p_item_category IS NULL OR (mc.segment1 = :p_item_category))
         AND ( :p_item_type IS NULL OR (mc.segment2 = :p_item_type))
         --and gcc.segment2 in ('BRAND','MKT')
         --and gcc1.segment1||'.'||gcc1.segment2||'.'||gcc1.segment3||'.'||gcc1.segment4||'.'||gcc1.segment5 != '2110.NUL.1050102.9999.00'
         --AND mc.segment1='INGREDIENT'
         --and ppf.employee_number in (1601)
         AND pla.po_header_id = pha.po_header_id
         AND pla.po_header_id = pda.po_header_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pda.po_line_id
         AND pla.po_line_id = pll.po_line_id
         AND gcc.code_combination_id = pda.code_combination_id
         AND gcc1.code_combination_id = pda.accrual_account_id
         --and gcc.segment3=flex.flex_value_meaning
         AND pha.vendor_id = pv.vendor_id
         AND msi.inventory_item_id(+) = pla.item_id
         AND ood.organization_id = pda.destination_organization_id
         AND ood.organization_id = msi.organization_id(+)
         AND ood.operating_unit = pha.org_id
         AND pvsa.vendor_id = pv.vendor_id
         AND pha.vendor_site_id = pvsa.vendor_site_id
         AND pha.created_by = fu.user_id
         AND fu.user_name = TO_CHAR (ppf.employee_number)
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
         --and pda.project_id=ppa.project_id(+)
         AND pda.task_id = pt.task_id(+)
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND pah.object_id = pha.po_header_id
         --and rownum=10
         --AND pha.authorization_status = 'REQUIRES REAPPROVAL'
         --AND pha.authorization_status = 'INCOMPLETE'
         AND pha.authorization_status = 'IN PROCESS'
         --AND pha.authorization_status = 'APPROVED'
         ---AND pha.authorization_status = 'REJECTED'
         --AND pha.CREATION_DATE > '15-JUN-2020'
         AND pah.action_code = 'APPROVE'
         --AND pah.action_code = 'SUBMIT'
         --AND pah.action_code = 'DELEGATE'
         --AND pah.action_code = 'CLOSE'
         --AND pah.action_code = 'IMPORT'
         --AND pah.action_code = 'REJECT'
         --AND pah.action_code = 'CANCEL'
         --AND pah.action_code = 'OPEN'
         --AND pah.action_code = 'FINALLY CLOSE'
         --AND pah.action_code = 'HOLD'
         --AND pah.action_code = 'ANSWER'
         --AND pah.action_code = 'RELEASE HOLD'
         --AND pah.action_code = 'QUESTION'
         --AND pah.action_code = 'FORWARD'
         --AND pah.action_code = 'APPROVE AND FORWARD'
         --AND pah.action_code = 'FREEZE'
         --AND pah.action_code = 'UNFREEZE'
         --AND prha.segment1 = '50313000001'
         AND OOD.OPERATING_UNIT = OU.ORG_ID
         AND HOU.ORGANIZATION_ID = OOD.OPERATING_UNIT
ORDER BY pha.segment1, pla.line_num;