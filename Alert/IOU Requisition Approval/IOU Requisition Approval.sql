/* Formatted on 12/31/2020 2:28:39 PM (QP5 v5.287) */
SELECT ROW_NUMBER () OVER (ORDER BY papf.person_id DESC) sl_no,
       papf.person_id,
       NVL (papf.employee_number, papf.npw_number) AS employee_number,
       UPPER (
          TRIM (
                papf.first_name
             || ' '
             || papf.middle_names
             || ' '
             || papf.last_name))
          AS full_name,
       haou.name AS organization_name,
       SUBSTR (pj.name, 1, INSTR (pj.name, '.') - 1) AS job_category,
       SUBSTR (pj.name, INSTR (pj.name, '.') + 1) AS job_designation,
       ir.iou_number AS requisition_no,
       ir.iou_date AS requisition_date,
       ir.operating_unit,
       ir.ou_name AS unit_name,
       ir.location_name,
       ir.advance_amount,
       ir.reason_for_advance,
       ir.adjust_date,
       xx_com_pkg.amount_in_word (ir.advance_amount) advance_in_amount,
       ir.status,
       ir.payment_date,
       ir.first_approver,
       (select papf1.email_address from apps.per_people_f papf1 where ir.first_approver = NVL (papf1.employee_number, papf1.npw_number)) first_approver_mail,
       ir.second_approver,
       (select papf2.email_address from apps.per_people_f papf2 where ir.second_approver = NVL (papf2.employee_number, papf2.npw_number)) second_approver_mail,
       ir.return_days
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
       AND ir.status='CREATED'
       AND ir.employee_no = NVL (papf.employee_number, papf.npw_number)
       --AND ir.iou_number = :p_iou_number;
       --AND rsh.ROWID = :ROWID