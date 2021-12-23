/* Formatted on 11/7/2020 12:16:01 PM (QP5 v5.354) */
-------------------------------APPLICATION WISE USER RESPONSIBILITY-------------
SELECT fu.user_id,
       fu.user_name,
       ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name employee_name,
       rv.responsibility_name,
       fa.application_name,
       urgd.start_date,
       urgd.end_date
  FROM apps.fnd_user_resp_groups_direct  urgd,
       apps.fnd_user                     fu,
       apps.fnd_responsibility_vl        rv,
       apps.per_all_people_f             ppf,
       apps.fnd_application_vl           fa
 WHERE     urgd.user_id = fu.user_id(+)
       AND urgd.responsibility_id = rv.responsibility_id(+)
       --AND fa.application_short_name IN ( 'PO' )
       --and fa.application_id in (401, 201)
       --AND (UPPER (c.responsibility_name) LIKE '%PO%' OR UPPER (c.responsibility_name) LIKE '%PR%' OR UPPER (c.responsibility_name) LIKE '%INV%')
       --and c.responsibility_name in ('AKG Employee Self Service')
       AND fu.user_name = NVL (ppf.employee_number, ppf.npw_number)
       --and nvl (d.current_emp_or_apl_flag, 'Y') = 'Y'
       --AND FU.USER_NAME IN ('103908')
       AND SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date
       AND rv.application_id = fa.application_id(+)
       AND (   :p_responsibility_name IS NULL OR (UPPER (rv.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
       AND (   :p_user_name IS NULL OR (UPPER (fu.user_name) = UPPER ( :p_user_name)))
       AND (   :p_application_name IS NULL OR (UPPER (fa.application_name) LIKE UPPER ('%' || :p_application_name || '%')))
       AND (urgd.end_date IS NULL OR urgd.end_date >= TRUNC (SYSDATE))
       AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE));

-----------------------------------DEPARTMENT WISE RESPONSIBILITY---------------

  SELECT b.user_name,
         d.full_name,
         haou.name     department,
         c.responsibility_name,
         a.start_date,
         a.end_date
    FROM apps.fnd_user_resp_groups_direct a,
         apps.fnd_user                   b,
         apps.fnd_responsibility_tl      c,
         apps.per_all_people_f           d,
         apps.per_all_assignments_f      paaf,
         apps.hr_all_organization_units  haou
   WHERE     a.user_id = b.user_id
         AND a.responsibility_id = c.responsibility_id
         AND b.user_name = d.employee_number
         AND haou.organization_id = paaf.organization_id
         AND d.person_id = paaf.person_id
         AND paaf.business_group_id = 81
         AND d.current_emp_or_apl_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date) AND TRUNC (paaf.effective_end_date)
         --AND SYSDATE BETWEEN effective_start_date AND effective_end_date
         --and c.responsibility_name in ('AKG Employee Self Service')
         --AND b.user_name in ('103908')
         AND (   :p_responsibility_name IS NULL OR (UPPER (c.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
         AND (   :p_user_name IS NULL OR (UPPER (b.user_name) = UPPER ( :p_user_name)))
         AND (   ( :p_department IS NULL) OR (UPPER (haou.name) LIKE UPPER ('%' || :p_department || '%')))
ORDER BY b.user_name;


-----------------------------------DBL Responsibility Checking------------------

  SELECT fu.user_name "User Name",
         papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name employee_name,
         frt.responsibility_name "Responsibility Name",
         furgd.start_date,
         furgd.end_date
    --,frt.*
    --,furgd.*
    --,fa.*
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
         --AND frt.zd_edition_name = 'SET1'
         AND frt.zd_edition_name = 'SET2'
         AND fa.zd_edition_name = 'SET2'
         AND (   :p_responsibility_name IS NULL OR (UPPER (frt.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
         AND (   :p_user_name IS NULL OR (UPPER (fu.user_name) = UPPER ( :p_user_name)))
         --AND APPLICATION_SHORT_NAME = 'PO'
         --AND  frt.responsibility_name='ASL : PO - Manager'
         --AND fu.user_name IN ('102246', '103822', '100386', '100397')
         AND fu.user_name = NVL (papf.employee_number, papf.npw_number)
         --AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
         --AND (   UPPER (frt.responsibility_name) LIKE '%PO%' OR UPPER (frt.responsibility_name) LIKE '%PR%' OR UPPER (frt.responsibility_name) LIKE '%INV%')
         AND (furgd.end_date IS NULL OR furgd.end_date >= TRUNC (SYSDATE))
         AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
         AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE))
ORDER BY frt.responsibility_name;


--------------------------------------------------------------------------------

  SELECT fu.user_name
             "User Name",
         papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name
             employee_name,
         apps.designation_from_user_name_id (fu.user_name, NULL)
             emp_designation,
         apps.xx_com_pkg.get_dept_from_user_name_id (NULL, furgd.user_id)
             department,
         (SELECT hla.description
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
         AND fu.user_name = NVL (papf.employee_number, papf.npw_number)
         AND UPPER (frt.responsibility_name) LIKE '%PO%'
         AND (furgd.end_date IS NULL OR furgd.end_date >= TRUNC (SYSDATE))
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE))
ORDER BY fu.user_name, frt.responsibility_name;



------------------Ative User Employee List--------------------------------------
/* Formatted on 6/23/2021 3:16:43 PM (QP5 v5.287) */
SELECT fu.user_name,
       ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name
          employee_name,
       rv.responsibility_name,
       fa.application_name,
       urgd.start_date,
       urgd.end_date
  FROM apps.fnd_user fu,
       apps.fnd_user_resp_groups_direct urgd,
       apps.fnd_responsibility_vl rv,
       apps.per_all_people_f ppf,
       apps.fnd_application_vl fa
 WHERE     fu.user_id = urgd.user_id(+)
       AND urgd.responsibility_id = rv.responsibility_id(+)
       AND fu.employee_id = ppf.person_id(+)
       AND NVL (ppf.current_emp_or_apl_flag, 'Y') = 'Y'
       AND FU.USER_NAME IN ('101445','103908')
       AND SYSDATE BETWEEN ppf.effective_start_date
                       AND ppf.effective_end_date
       AND rv.application_id = fa.application_id(+)
       AND (urgd.end_date IS NULL OR urgd.end_date >= TRUNC (SYSDATE))
       AND (fu.end_date IS NULL OR fu.end_date >= TRUNC (SYSDATE));