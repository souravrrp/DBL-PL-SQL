/* Formatted on 1/20/2020 5:44:31 PM (QP5 v5.287) */
select --DISTINCT
      fu.user_id,
      papf.person_id,
      fu.user_name,
      nvl(nvl(papf.employee_number,papf.npw_number),fu.user_name) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          as employee_name,
       substr (pj.name, instr (pj.name, '.') + 1) designation,
       papf.start_date as date_of_joining,
       haou.name department,
       hla.description job_location
       ,(CASE WHEN papf.current_emp_or_apl_flag IS NULL AND papf.employee_number IS NULL AND SUBSTR(papf.npw_number,0,3)='CWK' THEN 'CWK'
              WHEN papf.current_emp_or_apl_flag IS NULL AND papf.employee_number IS NOT NULL THEN 'Inactive'
              WHEN papf.current_emp_or_apl_flag IS NOT NULL THEN 'Active'
              ELSE 'Others' 
         END) Employee_status
       ,DECODE(fu.end_date,NULL,'Active','Inactive') user_status
       ,hla.description||DECODE(hla.address_line_1,NULL,'',',')||hla.address_line_1||DECODE(hla.address_line_2,NULL,'',',')||hla.address_line_2||DECODE(hla.address_line_3,NULL,'',',')||hla.address_line_3||','||hla.town_or_city location_details
       ,papf.email_address
       --,DECODE(papf.current_emp_or_apl_flag,NULL,'Inactive','Y','Active') Employee_status
       --,apps.designation_from_user_name_id(fu.user_name,null) emp_designation
       --,papf.current_emp_or_apl_flag
       --,paaf.primary_flag
       --,apps.PER_Mobile_Utils.get_concat_phone_numbers ( p_in_person_id => papf.person_id, p_in_phone_type => 'MPL') mobile_phone
       --,PAAF.*
       --,PAPF.*
       --,PJ.*
       --,HAOU.*
       --,PPF.*
       --,HLA.*
  from apps.per_all_assignments_f paaf,
       apps.per_all_people_f papf,
       apps.per_jobs pj,
       apps.hr_all_organization_units haou,
       apps.hr_locations_all hla,
       fnd_user fu
 where    1=1 
       and paaf.business_group_id = 81
       and papf.person_id = paaf.person_id(+)
       and paaf.job_id=pj.job_id(+)
       and paaf.location_id = hla.location_id(+)
       and paaf.organization_id=haou.organization_id(+)
       and ((:p_user_id is null) or (fu.user_id = :p_user_id))
       and ((:p_user_name is null) or (fu.user_name = :p_user_name))
       and ((:p_person_id is null) or (papf.person_id = :p_person_id))
       and ((:p_emp_id is null) or (nvl(papf.employee_number,papf.npw_number) = :p_emp_id))
       and ((:p_employee_name is null) or (upper (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name) like upper ('%' || :p_employee_name || '%'))) 
       and ((:p_designation is null) or (upper (pj.name) like upper ('%' || :p_designation || '%')))
       and ((:p_department is null) or (upper (haou.name) like upper ('%' || :p_department || '%')))
       and ((:p_email is null) or (upper (papf.email_address) like upper ('%' || :p_email || '%'))) 
       --and papf.person_id = NVL ( :p_person_id, papf.person_id)
       --and nvl(papf.employee_number,papf.npw_number) in ('')
       and trunc (sysdate) between trunc (paaf.effective_start_date) and trunc (paaf.effective_end_date)
       and trunc (sysdate) between trunc (papf.effective_start_date) and trunc (papf.effective_end_date)
       --AND fu.user_name=nvl(papf.employee_number,papf.npw_number)(+)
       and papf.person_id = fu.employee_id(+)
       --AND nvl(papf.current_emp_or_apl_flag,'Y') = 'Y'
       --AND papf.current_emp_or_apl_flag is null
       --AND paaf.primary_flag = 'Y'
       ;