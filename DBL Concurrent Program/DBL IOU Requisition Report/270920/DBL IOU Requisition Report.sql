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
       ir.fst_approver_name,
       REGEXP_SUBSTR (designation_from_user_name_id(ir.first_approver,NULL),'[^.]+', 1, 1) fst_department,
       REGEXP_SUBSTR (designation_from_user_name_id(ir.first_approver,NULL),'[^.]+', 1, 2) fst_designation,
       ir.second_approver,
       ir.snd_approver_name,
       REGEXP_SUBSTR (designation_from_user_name_id(ir.second_approver,NULL),'[^.]+', 1, 1) snd_department,
       REGEXP_SUBSTR (designation_from_user_name_id(ir.second_approver,NULL),'[^.]+', 1, 2) snd_designation,
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
       AND ir.employee_no = NVL (papf.employee_number, papf.npw_number)
       AND ir.iou_number = :p_iou_number;