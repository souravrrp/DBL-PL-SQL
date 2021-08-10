SELECT DISTINCT
       hou.name,
       prha.segment1
           req_num,
       prha.description,
       prha.creation_date
           fecha_creacion,
       prha.approved_date
           fecha_aprob,
       TO_CHAR (fuser.user_name)
           User_id,
       (ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name)
           za_Requester,
       papf.email_address
           buyer_email
  INTO &unit_name,
       &req_num,
       &descr,
       &Creation_date,
       &Approval_date,
       &User_ID,
       &za_Requester,
       &mail_za_Buyer
  FROM po_requisition_headers_all  prha,
       apps.hr_operating_units     hou,
           po_requisition_lines_all    prla,
       fnd_user                    fu,
       fnd_user                    fuser,
       apps.per_all_people_f       ppf,
       apps.per_all_people_f       papf
 WHERE     prha.requisition_header_id = prla.requisition_header_id
       AND fu.employee_id = prla.suggested_buyer_id
       AND prha.preparer_id = ppf.person_id(+)
       AND fu.employee_id = papf.person_id(+)
       AND ppf.person_id = fuser.employee_id(+)
       AND hou.organization_id = prha.org_id
       AND NVL (prha.cancel_flag, 'N') = 'N'
       AND prha.authorization_status = 'APPROVED'
       --AND prha.org_id IN (127,131,125,126)
       AND prha.ROWID = :ROWID;