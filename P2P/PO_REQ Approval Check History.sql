/* Formatted on 6/21/2020 10:37:10 AM (QP5 v5.287) */
--ACTION HISTORY ON PO AND REQ

  SELECT DISTINCT prha.segment1 req,
                  pha.segment1 po,
                  gcc.segment3 acct,
                  acct_desc.description acct_desc,
                  gcc.segment4 ctr,
                  ctr_desc.description ctr_desc,
                  papf.full_name req_raised_by,
                  reqah.full_name req_last_approver,
                  poah.full_name po_last_approver,
                  pv.vendor_name supplier,
                  pvsa.vendor_site_code site
    FROM po.po_requisition_headers_all prha,
         po.po_requisition_lines_all prla,
         po.po_line_locations_all plla,
         po.po_lines_all pla,
         po.po_headers_all pha,
         po.po_distributions_all pda,
         gl.gl_code_combinations gcc,
         apps.po_vendors pv,
         apps.po_vendor_sites_all pvsa,
         apps.fnd_flex_values_vl acct_desc,
         apps.fnd_flex_values_vl ctr_desc,
         hr.per_all_people_f papf,
         (SELECT papf.full_name, pah.action_code, pah.object_id
            FROM po.po_action_history pah,
                 po.po_requisition_headers_all prha,
                 applsys.fnd_user fu,
                 hr.per_all_people_f papf
           WHERE     object_id = prha.requisition_header_id
                 AND pah.employee_id = fu.employee_id
                 AND fu.employee_id = papf.person_id
                 AND SYSDATE BETWEEN papf.effective_start_date
                                 AND papf.effective_end_date
                 AND pah.object_type_code = 'REQUISITION'
                 AND pah.action_code = 'APPROVE'
                 AND pah.sequence_num =
                        (SELECT MAX (sequence_num)
                           FROM po.po_action_history pah1
                          WHERE     pah1.object_id = pah.object_id
                                AND pah1.object_type_code = 'REQUISITION'
                                AND pah1.action_code = 'APPROVE')) reqah,
         (SELECT papf.full_name, pah.action_code, pah.object_id
            FROM po.po_action_history pah,
                 po.po_headers_all pha,
                 applsys.fnd_user fu,
                 hr.per_all_people_f papf
           WHERE     object_id = pha.po_header_id
                 AND pah.employee_id = fu.employee_id
                 AND fu.employee_id = papf.person_id
                 AND SYSDATE BETWEEN papf.effective_start_date
                                 AND papf.effective_end_date
                 AND pah.object_type_code = 'PO'
                 AND pah.action_code = 'APPROVE'
                 AND pah.sequence_num =
                        (SELECT MAX (sequence_num)
                           FROM po.po_action_history pah1
                          WHERE     pah1.object_id = pah.object_id
                                AND pah1.object_type_code = 'PO'
                                AND pah1.action_code = 'APPROVE')) poah
   WHERE     prha.requisition_header_id = prla.requisition_header_id
         AND prla.line_location_id = plla.line_location_id
         AND plla.po_header_id = pla.po_header_id
         AND pla.po_header_id = pha.po_header_id
         AND pla.po_line_id = pda.po_line_id
         AND pda.code_combination_id = gcc.code_combination_id
         AND reqah.object_id = prha.requisition_header_id
         AND poah.object_id = pha.po_header_id
         AND prha.preparer_id = papf.person_id
         AND gcc.segment3 = acct_desc.flex_value
         AND gcc.segment4 = ctr_desc.flex_value
         AND pha.vendor_id = pv.vendor_id
         AND pha.vendor_site_id = pvsa.vendor_site_id
         AND pv.vendor_id = pvsa.vendor_id
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND prha.creation_date >= '01-APR-2009'
         AND prha.creation_date <= '03-APR-2009'
ORDER BY prha.segment1, gcc.segment4;


--Checking Requisition Approval History for a specific member of staff


  SELECT pah.action_code,
         pah.object_id,
         pah.action_date,
         pah.sequence_num step,
         pah.creation_date,
         prha.segment1 req_num,
         prha.wf_item_key,
         prha.authorization_status,
         fu.description,
         papf.full_name hr_full_name,
         papf.employee_number emp_no,
         pj.NAME job
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
         AND pah.action_code = 'APPROVE'
         --AND papf.full_name = :pn
         and ((:p_emp_id is null) or (nvl(papf.employee_number,papf.npw_number) = :p_emp_id))
ORDER BY pah.creation_date DESC;

--Checking Purchase Order Approval History for a specific member of staff

  SELECT pah.action_code,
         pah.object_id,
         pah.action_date,
         pah.sequence_num step,
         pah.creation_date,
         pha.segment1 po_num,
         fu.description,
         papf.full_name hr_full_name,
         papf.employee_number emp_no,
         papf.person_id,
         fu.user_name,
         pj.NAME job
    FROM po.po_action_history pah,
         po.po_headers_all pha,
         applsys.fnd_user fu,
         hr.per_all_people_f papf,
         hr.per_all_assignments_f paaf,
         hr.per_jobs pj
   WHERE     pah.object_id = pha.po_header_id
         AND pah.employee_id = fu.employee_id
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND SYSDATE BETWEEN paaf.effective_start_date
                         AND paaf.effective_end_date
         AND pah.object_type_code = 'PO'
         AND pah.action_code = 'APPROVE'
         --AND papf.full_name = :pn
         and ((:p_emp_id is null) or (nvl(papf.employee_number,papf.npw_number) = :p_emp_id))
ORDER BY pah.sequence_num;