/* Formatted on 1/4/2021 2:38:44 PM (QP5 v5.287) */
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
       (SELECT papf1.email_address
          FROM apps.per_people_f papf1
         WHERE ir.first_approver =
                  NVL (papf1.employee_number, papf1.npw_number))
          first_approver_mail,
       ir.second_approver || '-' || ir.snd_approver_name,
       (SELECT papf2.email_address
          FROM apps.per_people_f papf2
         WHERE ir.second_approver =
                  NVL (papf2.employee_number, papf2.npw_number))
          second_approver_mail
  INTO &iou_req_no,
       &advance_amount,
       &reason,
       &adjustment_period,
       &requestor,
       &fst_approver,
       &fst_approver_mail,
       &snd_approver,
       &snd_approver_mail
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