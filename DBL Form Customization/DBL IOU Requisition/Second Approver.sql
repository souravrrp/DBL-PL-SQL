SELECT NVL (papf.employee_number, papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          AS employee_name
  FROM apps.per_all_assignments_f paaf,
       apps.per_all_people_f papf,
       apps.per_jobs pj,
       apps.hr_all_organization_units haou,
       apps.per_pay_bases ppb,
       apps.pay_people_groups ppg,
       apps.pay_payrolls_f ppf,
       apps.hr_locations_all hla,
       fnd_user fu
 WHERE     1 = 1
       AND paaf.business_group_id = 81
       AND papf.person_id = paaf.person_id(+)
       AND paaf.job_id = pj.job_id(+)
       AND paaf.payroll_id = ppf.payroll_id(+)
       AND paaf.location_id = hla.location_id(+)
       AND paaf.people_group_id = ppg.people_group_id(+)
       AND paaf.organization_id = haou.organization_id(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                               AND TRUNC (paaf.effective_end_date)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND NVL (papf.employee_number, papf.npw_number) = fu.user_name(+)
       AND fu.end_date IS NULL
       AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
       
       
--------------------------------------------------------------------------------

SELECT NVL (papf.employee_number, papf.npw_number) employee_number,
       (papf.first_name || ' ' || papf.middle_names || ' ' || papf.last_name)
          AS employee_name
  FROM apps.per_all_assignments_f paaf,
       apps.per_all_people_f papf,
       apps.per_jobs pj,
       apps.hr_all_organization_units haou,
       apps.per_pay_bases ppb,
       apps.pay_people_groups ppg,
       apps.pay_payrolls_f ppf,
       apps.hr_locations_all hla,
       fnd_user fu
 WHERE     1 = 1
       AND paaf.business_group_id = 81
       AND papf.person_id = paaf.person_id(+)
       AND paaf.job_id = pj.job_id(+)
       AND paaf.payroll_id = ppf.payroll_id(+)
       AND paaf.location_id = hla.location_id(+)
       AND paaf.people_group_id = ppg.people_group_id(+)
       AND paaf.organization_id = haou.organization_id(+)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                               AND TRUNC (paaf.effective_end_date)
       AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                               AND TRUNC (papf.effective_end_date)
       AND NVL (papf.employee_number, papf.npw_number) = fu.user_name(+)