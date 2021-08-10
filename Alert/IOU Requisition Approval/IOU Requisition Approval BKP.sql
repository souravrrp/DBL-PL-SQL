SELECT ir.iou_number,
       ir.advance_amount,
       ir.reason_for_advance,
       ir.return_days,
          NVL (papf.employee_number, papf.npw_number)
       || '-'
       || UPPER (
             TRIM (
                   papf.first_name
                || ' '
                || papf.middle_names
                || ' '
                || papf.last_name)),
       ir.first_approver || '-' || ir.fst_approver_name,
       ir.second_approver || '-' || ir.snd_approver_name
  INTO &iou_req_no,
       &advance_amount,
       &reason,
       &adjustment_period,
       &requestor,
       &fst_approver,
       &snd_approver
  FROM fnd_user ppf,
       apps.per_people_f papf,
       per_all_assignments_f paaf,
       apps.hr_all_organization_units haou,
       apps.per_jobs pj,
       xxdbl.xxdbl_iou_req_dtl ir
 WHERE     1 = 1
       AND papf.person_id = paaf.person_id
       AND paaf.organization_id = haou.organization_id(+)
       AND pj.job_id(+) = paaf.job_id
       AND SYSDATE BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
       AND SYSDATE BETWEEN papf.effective_start_date
                       AND papf.effective_end_date
       AND NVL (papf.employee_number, papf.npw_number) = ppf.user_name
       AND ir.status = 'CREATED'
       AND ir.employee_no = NVL (papf.employee_number, papf.npw_number)
       AND ir.ROWID = :ROWID