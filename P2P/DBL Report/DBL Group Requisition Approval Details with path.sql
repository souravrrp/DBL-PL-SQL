/* Formatted on 7/1/2020 3:32:29 PM (QP5 v5.287) */
SELECT 
       --prha.ORG_ID,
       HOU.NAME,
       --OU.LEDGER_NAME,
       OU.LEGAL_ENTITY_NAME,
       prha.segment1 req_num,
       pah.sequence_num,
       pah.action_code,
       --prha.authorization_status,
       prl.item_description,
       CAT.SEGMENT2 ITEM_CATEGORY,
       papf.full_name full_name,
       papf.employee_number emp_no,
       pj.NAME job
  FROM po.po_action_history pah,
       po.po_requisition_headers_all prha,
       po.po_requisition_lines_all prl,
       applsys.fnd_user fu,
       hr.per_all_people_f papf,
       hr.per_all_assignments_f paaf,
       hr.per_jobs pj,
       HR_OPERATING_UNITS HOU,
       XXDBL_COMPANY_LE_MAPPING_V OU,
       APPS.MTL_ITEM_CATEGORIES_V CAT
   WHERE     object_id = prha.requisition_header_id
         AND pah.employee_id = fu.employee_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND prha.requisition_header_id = prl.requisition_header_id
         AND paaf.job_id = pj.job_id(+)
         AND paaf.primary_flag = 'Y'
         AND PRL.CATEGORY_ID=CAT.CATEGORY_ID
         AND PRL.ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND PRL.DESTINATION_ORGANIZATION_ID = CAT.ORGANIZATION_ID
         --AND PRL.LINE_TYPE_ID=1
         AND HOU.ORGANIZATION_ID = prha.ORG_ID
         AND HOU.ORGANIZATION_ID = OU.ORG_ID
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND pah.object_type_code = 'REQUISITION'
         AND prha.authorization_status = 'APPROVED'
AND prha.segment1 = '10321005881'
--AND prha.CREATION_DATE > '15-JAN-2020'
--AND prha.CREATION_DATE > '15-JAN-2020'
ORDER BY prha.segment1,pah.sequence_num;