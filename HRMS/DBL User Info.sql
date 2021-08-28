/* Formatted on 8/26/2021 4:14:15 PM (QP5 v5.354) */
SELECT user_id,
       user_name,
       employee_id person_id,
       (SELECT (   papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) FROM apps.per_all_people_f papf
        WHERE TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date) AND TRUNC (papf.effective_end_date) AND papf.person_id(+) = fu.employee_id) employee_name,
       email_address,
       start_date,
       end_date,
       last_logon_date,
       password_date,
       apps.xx_com_pkg.get_emp_name_from_user_id (fu.created_by) created_by_name,
       apps.xx_com_pkg.get_emp_name_from_user_id (fu.last_updated_by) updated_by_name
  --,FU.*
  FROM fnd_user fu
 WHERE     1 = 1
       AND (( :p_emp_id IS NULL) OR (user_name = :p_emp_id))
       AND (( :p_user_id IS NULL) OR (user_id = :p_user_id));