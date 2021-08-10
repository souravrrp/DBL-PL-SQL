/* Formatted on 3/25/2021 10:14:25 AM (QP5 v5.354) */
  SELECT fu.user_name
             "User Name",
         papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name
             employee_name,
         apps.designation_from_user_name_id (fu.user_name, NULL)
             emp_designation,
         apps.xx_com_pkg.get_dept_from_user_name_id (NULL, furgd.user_id)
             department,
         papf.current_emp_or_apl_flag,
         (SELECT DISTINCT hla.description
            FROM apps.per_all_assignments_f paaf, apps.hr_locations_all hla
           WHERE     papf.person_id = paaf.person_id
                 AND paaf.business_group_id = 81
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND paaf.location_id = hla.location_id)
             job_location,
         frt.responsibility_name
             "Responsibility Name",
         furgd.start_date,
         furgd.end_date
    FROM fnd_user_resp_groups_direct furgd,
         fnd_user                   fu,
         apps.per_all_people_f      papf,
         fnd_responsibility_tl      frt,
         fnd_application            fa
   WHERE     1 = 1
         AND furgd.user_id = fu.user_id
         AND furgd.responsibility_id = frt.responsibility_id
         AND furgd.responsibility_application_id = fa.application_id
         AND frt.application_id = fa.application_id
         AND frt.language = USERENV ('LANG')
         AND frt.zd_edition_name = 'SET2'
         AND fa.zd_edition_name = 'SET2'
         --AND fu.user_name='101919'
         AND fu.user_name = NVL (papf.employee_number, papf.npw_number)
         --AND UPPER (frt.responsibility_name) LIKE '%PO%'
         AND (furgd.end_date IS NULL OR furgd.end_date >= TRUNC (SYSDATE))
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE))
ORDER BY fu.user_name, frt.responsibility_name;