/* Formatted on 5/5/2021 3:58:03 PM (QP5 v5.354) */
  SELECT DISTINCT
         papf1.person_id,
         cfu.user_name,
         NVL (papf1.employee_number, papf1.NPW_NUMBER)     level1_empno,
         papf1.full_name                                   leve1_full_name,
         NVL (papf2.employee_number, papf2.NPW_NUMBER)     level2_empno,
         papf2.full_name                                   leve2_full_name
    FROM per_all_people_f        papf1,
         hr.per_all_assignments_f paaf1,
         hr.per_all_assignments_f paaf2,
         hr.per_all_people_f     papf2,
         fnd_user                cfu
   WHERE     papf1.person_id = paaf1.person_id
         AND paaf1.supervisor_id = papf2.person_id(+)
         AND papf2.person_id = paaf2.person_id
         AND SYSDATE BETWEEN papf1.effective_start_date
                         AND papf1.effective_end_date
         AND SYSDATE BETWEEN paaf1.effective_start_date
                         AND paaf1.effective_end_date
         AND SYSDATE BETWEEN paaf2.effective_start_date
                         AND paaf2.effective_end_date
         AND SYSDATE BETWEEN papf2.effective_start_date
                         AND papf2.effective_end_date
         AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = '103362'
         AND NVL (papf1.employee_number, papf1.NPW_NUMBER) = cfu.user_name
         AND NVL (papf2.current_emp_or_apl_flag, 'Y') = 'Y'
ORDER BY leve1_full_name;

SELECT DISTINCT NVL (papf.employee_number, papf.NPW_NUMBER), papf.full_name
  --into
  --sup_emp_no, sup_emp_name
  FROM hr.per_all_assignments_f paaf, hr.per_all_people_f papf, fnd_user fu
 WHERE     paaf.person_id = 3570
       AND papf.person_id = fu.employee_id(+)
       AND fu.end_date IS NULL
       --AND SYSDATE BETWEEN fu.start_date AND NVL(fu.end_date,SYSDATE)
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
       AND paaf.supervisor_id = papf.person_id(+)
       AND SYSDATE BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
       AND SYSDATE BETWEEN papf.effective_start_date
                       AND papf.effective_end_date;


SELECT DISTINCT NVL (papf.employee_number, papf.NPW_NUMBER) sup_emp_no, papf.full_name, (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) sup_name
  --into
  --sup_emp_no, sup_emp_name
  FROM hr.per_all_assignments_f paaf, hr.per_all_people_f papf
 WHERE     paaf.person_id = 3570
       AND paaf.supervisor_id = papf.person_id(+)
       AND SYSDATE BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
       AND SYSDATE BETWEEN papf.effective_start_date
                       AND papf.effective_end_date;
                       
                       
SELECT DISTINCT
       NVL (papf2.employee_number, papf2.NPW_NUMBER), papf2.full_name, (papf2.first_name || ' ' || papf2.middle_names || ' ' || papf2.last_name) sup_name
  --into
  --sup_emp_no, sup_emp_name
  FROM hr.per_all_assignments_f paaf,
       hr.per_all_people_f papf1,
       hr.per_all_assignments_f paaf1,
       hr.per_all_people_f papf2,
       fnd_user fu
 WHERE     paaf.person_id = 3570
       AND papf1.person_id = fu.employee_id(+)
       AND paaf.supervisor_id = papf1.person_id
       AND papf1.person_id = papf2.person_id
       AND paaf1.supervisor_id = papf1.person_id;