/* Formatted on 7/14/2020 12:22:02 PM (QP5 v5.287) */
  SELECT prha.ORG_ID,
         HOU.NAME,
         OU.LEDGER_NAME,
         OU.LEGAL_ENTITY_NAME,
         NVL (papf.EMPLOYEE_NUMBER, papf.NPW_NUMBER) APPROVER_ID,
         (papf.FIRST_NAME || ' ' || papf.MIDDLE_NAMES || ' ' || papf.LAST_NAME)
            REQUESTOR_NAME,
         MAX (prha.SEGMENT1) "Last Requisition Number",
         MAX (prha.APPROVED_DATE) LAST_APPROVED_DATE
    FROM po.po_action_history pah,
         po.po_requisition_headers_all prha,
         hr.per_all_people_f papf,
         HR_OPERATING_UNITS HOU,
         XXDBL_COMPANY_LE_MAPPING_V OU
   WHERE     object_id = prha.requisition_header_id
         AND pah.employee_id = papf.person_id
         AND HOU.ORGANIZATION_ID = prha.ORG_ID
         AND HOU.ORGANIZATION_ID = OU.ORG_ID
         AND pah.object_type_code = 'REQUISITION'
         AND prha.authorization_status = 'APPROVED'
         --AND ( ( :P_ORG_ID IS NULL) OR (prha.ORG_ID = :P_ORG_ID))
         --AND ( :P_REQ_NO IS NULL OR (prha.SEGMENT1 = :P_REQ_NO))
         --AND ( ( :P_EMP_ID IS NULL) OR (papf.EMPLOYEE_NUMBER = :P_EMP_ID))
         --AND prha.segment1 = '40511000057'
         AND PAH.action_code = 'APPROVE'
GROUP BY prha.ORG_ID,
         HOU.NAME,
         OU.LEDGER_NAME,
         OU.LEGAL_ENTITY_NAME,
         (   papf.FIRST_NAME
          || ' '
          || papf.MIDDLE_NAMES
          || ' '
          || papf.LAST_NAME),
         NVL (papf.EMPLOYEE_NUMBER, papf.NPW_NUMBER);