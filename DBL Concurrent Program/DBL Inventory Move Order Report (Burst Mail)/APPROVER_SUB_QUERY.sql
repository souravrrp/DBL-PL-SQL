/* Formatted on 3/16/2021 1:39:29 PM (QP5 v5.354) */
SELECT MAX (papf2.full_name)     AS APPROVED_BY
  FROM apps.per_all_people_f       papf,
       apps.per_all_assignments_f  paaf,
       apps.per_all_assignments_f  paaf1,
       apps.per_all_people_f       papf1,
       apps.per_all_people_f       papf2,
       apps.per_all_assignments_f  paaf3,
       apps.per_person_types       ppt,
       fnd_user                    fu,
       apps.per_grades             pg
 WHERE     papf.person_id = paaf.person_id
       AND papf1.person_id = paaf.supervisor_id
       AND papf1.person_id = paaf1.person_id
       AND papf.business_group_id = 81
       AND fu.user_name = papf.employee_number
       AND paaf1.supervisor_id = papf2.person_id
       AND papf.business_group_id = paaf.business_group_id
       --AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
       --AND TRUNC (SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
       --AND TRUNC (SYSDATE) BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
       --AND TRUNC (SYSDATE) BETWEEN paaf3.effective_start_date AND paaf3.effective_end_date
       AND ppt.person_type_id = papf.person_type_id
       AND pg.grade_id(+) = paaf3.grade_id
       AND ppt.user_person_type <> 'Ex-employee'
       AND papf2.person_id = paaf3.person_id
       AND LPAD (pg.NAME, 2) <> 'TM'
       AND user_id = 2793