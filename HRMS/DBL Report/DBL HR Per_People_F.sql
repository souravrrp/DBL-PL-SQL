/* Formatted on 1/20/2020 5:44:31 PM (QP5 v5.287) */
select 
      papf.person_id,
      nvl(papf.employee_number,papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          as employee_name,
       papf.start_date as date_of_joining
       ,papf.current_emp_or_apl_flag
       ,papf.email_address
       ,papf.DATE_OF_BIRTH
       ,papf.*
  from 
       apps.per_all_people_f papf
 where    1=1 
       and ((:p_person_id is null) or (papf.person_id = :p_person_id))
       and ((:p_emp_id is null) or (nvl(papf.employee_number,papf.npw_number) = :p_emp_id))
       and ((:p_employee_name is null) or (upper (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) like upper ('%' || :p_employee_name || '%'))) 
       and ((:p_email is null) or (upper (papf.email_address) like upper ('%' || :p_email || '%'))) 
       and trunc (sysdate) between trunc (papf.effective_start_date) and trunc (papf.effective_end_date)
       --AND nvl(papf.current_emp_or_apl_flag,'Y') = 'Y'
       --AND papf.current_emp_or_apl_flag is null
       ;