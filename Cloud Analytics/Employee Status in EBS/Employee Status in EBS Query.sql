/* Formatted on 7/7/2021 11:59:33 AM (QP5 v5.354) */
  SELECT employee_type, SUM (no_of_employee) no_of_employee
    FROM (SELECT 'Active' employee_type, COUNT (papf.person_id) no_of_employee
            FROM apps.per_all_assignments_f    paaf,
                 apps.per_all_people_f         papf,
                 apps.per_jobs                 pj,
                 apps.hr_all_organization_units haou,
                 apps.hr_locations_all         hla,
                 fnd_user                      fu
           WHERE     1 = 1
                 AND paaf.business_group_id = 81
                 AND papf.person_id = paaf.person_id(+)
                 AND paaf.job_id = pj.job_id(+)
                 AND paaf.location_id = hla.location_id(+)
                 AND paaf.organization_id = haou.organization_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND papf.person_id = fu.employee_id(+)
                 AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
                 AND paaf.primary_flag = 'Y'
          UNION ALL
          SELECT 'Inactive'                 employee_type,
                 COUNT (papf.person_id)     no_of_employee
            FROM apps.per_all_assignments_f    paaf,
                 apps.per_all_people_f         papf,
                 apps.per_jobs                 pj,
                 apps.hr_all_organization_units haou,
                 apps.hr_locations_all         hla,
                 fnd_user                      fu
           WHERE     1 = 1
                 AND paaf.business_group_id = 81
                 AND papf.person_id = paaf.person_id(+)
                 AND paaf.job_id = pj.job_id(+)
                 AND paaf.location_id = hla.location_id(+)
                 AND paaf.organization_id = haou.organization_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND papf.person_id = fu.employee_id(+)
                 AND papf.current_emp_or_apl_flag IS NULL
          UNION ALL
          SELECT 'CWK' employee_type, COUNT (papf.person_id) no_of_employee
            FROM apps.per_all_assignments_f    paaf,
                 apps.per_all_people_f         papf,
                 apps.per_jobs                 pj,
                 apps.hr_all_organization_units haou,
                 apps.hr_locations_all         hla,
                 fnd_user                      fu
           WHERE     1 = 1
                 AND paaf.business_group_id = 81
                 AND papf.person_id = paaf.person_id(+)
                 AND paaf.job_id = pj.job_id(+)
                 AND paaf.location_id = hla.location_id(+)
                 AND paaf.organization_id = haou.organization_id(+)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND papf.person_id = fu.employee_id(+)
                 AND papf.current_emp_or_apl_flag IS NULL
                 AND fu.user_name LIKE 'CWK%')
GROUP BY employee_type