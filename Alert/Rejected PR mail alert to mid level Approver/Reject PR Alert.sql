/* Formatted on 6/18/2020 9:40:52 AM (QP5 v5.287) */
SELECT prha.segment1 req_num, fu.EMAIL_ADDRESS
  FROM po.po_action_history pah,
       po.po_requisition_headers_all prha,
       applsys.fnd_user fu,
       hr.per_all_people_f papf,
       hr.per_all_assignments_f paaf,
       hr.per_jobs pj
 WHERE     object_id = prha.requisition_header_id
       AND pah.employee_id = fu.employee_id
       AND fu.employee_id = papf.person_id
       AND papf.person_id = paaf.person_id
       AND paaf.job_id = pj.job_id
       AND paaf.primary_flag = 'Y'
       AND SYSDATE BETWEEN papf.effective_start_date
                       AND papf.effective_end_date
       AND SYSDATE BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
       AND pah.object_type_code = 'REQUISITION'
       AND prha.authorization_status = 'REJECTED'
       AND prha.CREATION_DATE > '15-JUN-2020'
       AND pah.action_code = 'APPROVE';