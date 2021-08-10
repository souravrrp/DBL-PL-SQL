/* Formatted on 1/26/2020 3:47:53 PM (QP5 v5.287) */
  SELECT employee_number,
         employee_name,
         to_char(:p_date_from) from_date,
         to_char(:p_date_to) date_to,
         to_CHAR(start_date,'MON-YY') payroll_month,
         loan_taken debit_amount,
         NVL (loan_adjusted, 0) credit_amount,
         SUM (loan_taken - loan_adjusted) closing_balance
    FROM (SELECT papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 peevf.effective_start_date start_date,
                 TO_NUMBER (peevf.screen_entry_value) loan_taken,
                 0 loan_adjusted
            FROM apps.pay_element_types_f petf,
                 apps.pay_element_links_f pelf,
                 apps.pay_element_entries_f peef,
                 apps.per_all_assignments_f paaf,
                 apps.per_all_people_f papf,
                 --   pay_costs pc,
                 apps.per_jobs pj,
                 apps.hr_all_organization_units haou,
                 apps.pay_payrolls_f ppf,
                 apps.pay_element_entry_values_f peevf,
                 apps.pay_input_values_f pivf
           --  (PEEVF.SCREEN_ENTRY_VALUE)-(pc.COSTED_VALUE) as blance
           WHERE     1 = 1
                 AND pj.job_id(+) = paaf.job_id
                 AND ppf.payroll_id = paaf.payroll_id
                 AND haou.organization_id = paaf.organization_id
                 AND paaf.business_group_id = 81
                 AND petf.element_name = 'Total Advance Adjustment'
                 AND peevf.effective_start_date >= '31-May-2018'
                 AND papf.person_id = NVL ( :p_person_id, papf.person_id)
                 AND trunc(peevf.effective_start_date) between nvl(:p_date_from,trunc(peevf.effective_start_date)) and nvl(:p_date_to,trunc(peevf.effective_start_date))
                 --and peevf.effective_start_date between :p_date_from and :p_date_to
                 AND papf.person_id = paaf.person_id
                 AND pelf.element_type_id = petf.element_type_id
                 AND peef.element_type_id = petf.element_type_id
                 AND paaf.assignment_id = peef.assignment_id
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND papf.person_id = paaf.person_id
                 AND papf.current_emp_or_apl_flag = 'Y'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND peevf.element_entry_id = peef.element_entry_id
                 AND pivf.input_value_id = peevf.input_value_id
          UNION ALL
          SELECT DISTINCT
                 papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 ppa.effective_date AS start_date,
                 0,
                 pc.costed_value debit
            --   DECODE (pc.debit_or_credit, 'C', pc.costed_value) credit
            FROM apps.per_people_f papf,
                 apps.per_assignments_f paaf,
                 apps.pay_assignment_actions pav,
                 apps.pay_payroll_actions ppa,
                 apps.pay_costs pc,
                 apps.pay_cost_allocation_keyflex pca,
                 apps.pay_element_types_f pet,
                 apps.pay_run_results prr,
                 --PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
                 apps.pay_run_result_values prrv
           WHERE                                   -- pca.segment5 = '1060103'
                papf .person_id = paaf.person_id
                 AND paaf.assignment_id = pav.assignment_id
                 AND paaf.primary_flag = 'Y'
                 --   and ppa.action_type = 'C'
                 -- AND papf.employee_number = :p_employee_number
                 AND pet.element_name = 'Monthly Advance Adjustment'
                 AND papf.person_id = :p_person_id
                 AND pav.payroll_action_id = ppa.payroll_action_id
                 AND pav.assignment_action_id = pc.assignment_action_id
                 AND pc.cost_allocation_keyflex_id =
                        pca.cost_allocation_keyflex_id
                 AND pet.element_type_id = prr.element_type_id
                 AND prr.run_result_id = prrv.run_result_id
                 AND pc.run_result_id = prrv.run_result_id
                 AND pc.input_value_id = prrv.input_value_id
                 AND trunc(ppa.effective_date) between nvl(:p_date_from,trunc(ppa.effective_date)) and nvl(:p_date_to,trunc(ppa.effective_date))
                 AND papf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_people_f
                          WHERE person_id = papf.person_id)
                 AND paaf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_assignments_f
                          WHERE assignment_id = paaf.assignment_id))
GROUP BY employee_number,
         employee_name,
         start_date,
         loan_taken,
         loan_adjusted
ORDER BY start_date;

--------------------------------------------------------------------------------

/* Formatted on 1/26/2020 3:47:53 PM (QP5 v5.287) */
  SELECT employee_number,
         employee_name,
         to_char(:p_date_from) from_date,
         to_char(:p_date_to) date_to,
         --to_CHAR(start_date,'MON-YY') payroll_month,
         --(sum(loan_taken))-(NVL (sum(loan_adjusted), 0)) opening_balance,
         sum(loan_taken) debit_amount,
         NVL (sum(loan_adjusted), 0) credit_amount,
         SUM (loan_taken) - sum(loan_adjusted) closing_balance
    FROM (SELECT papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 peevf.effective_start_date start_date,
                 TO_NUMBER (peevf.screen_entry_value) loan_taken,
                 0 loan_adjusted
            FROM apps.pay_element_types_f petf,
                 apps.pay_element_links_f pelf,
                 apps.pay_element_entries_f peef,
                 apps.per_all_assignments_f paaf,
                 apps.per_all_people_f papf,
                 --   pay_costs pc,
                 apps.per_jobs pj,
                 apps.hr_all_organization_units haou,
                 apps.pay_payrolls_f ppf,
                 apps.pay_element_entry_values_f peevf,
                 apps.pay_input_values_f pivf
           --  (PEEVF.SCREEN_ENTRY_VALUE)-(pc.COSTED_VALUE) as blance
           WHERE     1 = 1
                 AND pj.job_id(+) = paaf.job_id
                 AND ppf.payroll_id = paaf.payroll_id
                 AND haou.organization_id = paaf.organization_id
                 AND paaf.business_group_id = 81
                 AND petf.element_name = 'Total Advance Adjustment'
                 AND peevf.effective_start_date >= '31-May-2018'
                 AND papf.person_id = NVL ( :p_person_id, papf.person_id)
                 AND trunc(peevf.effective_start_date) between nvl(:p_date_from,trunc(peevf.effective_start_date)) and nvl(:p_date_to,trunc(peevf.effective_start_date))
                 --and peevf.effective_start_date between :p_date_from and :p_date_to
                 AND papf.person_id = paaf.person_id
                 AND pelf.element_type_id = petf.element_type_id
                 AND peef.element_type_id = petf.element_type_id
                 AND paaf.assignment_id = peef.assignment_id
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND papf.person_id = paaf.person_id
                 AND papf.current_emp_or_apl_flag = 'Y'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND peevf.element_entry_id = peef.element_entry_id
                 AND pivf.input_value_id = peevf.input_value_id
          UNION ALL
          SELECT DISTINCT
                 papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 ppa.effective_date AS start_date,
                 0,
                 pc.costed_value debit
            --   DECODE (pc.debit_or_credit, 'C', pc.costed_value) credit
            FROM apps.per_people_f papf,
                 apps.per_assignments_f paaf,
                 apps.pay_assignment_actions pav,
                 apps.pay_payroll_actions ppa,
                 apps.pay_costs pc,
                 apps.pay_cost_allocation_keyflex pca,
                 apps.pay_element_types_f pet,
                 apps.pay_run_results prr,
                 --PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
                 apps.pay_run_result_values prrv
           WHERE                                   -- pca.segment5 = '1060103'
                papf .person_id = paaf.person_id
                 AND paaf.assignment_id = pav.assignment_id
                 AND paaf.primary_flag = 'Y'
                 --   and ppa.action_type = 'C'
                 -- AND papf.employee_number = :p_employee_number
                 AND pet.element_name = 'Monthly Advance Adjustment'
                 AND papf.person_id = :p_person_id
                 AND pav.payroll_action_id = ppa.payroll_action_id
                 AND pav.assignment_action_id = pc.assignment_action_id
                 AND pc.cost_allocation_keyflex_id =
                        pca.cost_allocation_keyflex_id
                 AND pet.element_type_id = prr.element_type_id
                 AND prr.run_result_id = prrv.run_result_id
                 AND pc.run_result_id = prrv.run_result_id
                 AND pc.input_value_id = prrv.input_value_id
                 AND trunc(ppa.effective_date) between nvl(:p_date_from,trunc(ppa.effective_date)) and nvl(:p_date_to,trunc(ppa.effective_date))
                 AND papf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_people_f
                          WHERE person_id = papf.person_id)
                 AND paaf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_assignments_f
                          WHERE assignment_id = paaf.assignment_id))
GROUP BY employee_number,
         employee_name
--         start_date,
--         loan_taken,
--         loan_adjusted
--ORDER BY start_date
;


------------------Opening Balance-----------------------------------------------
/* Formatted on 1/26/2020 3:47:53 PM (QP5 v5.287) */
  SELECT 
         --employee_number,
         --employee_name,
         --to_char(:p_date_from) from_date,
         --to_char(:p_date_to) date_to,
         --to_CHAR(start_date,'MON-YY') payroll_month,
         (sum(loan_taken))-(NVL (sum(loan_adjusted), 0)) opening_balance
         --sum(loan_taken) debit_amount,
         --NVL (sum(loan_adjusted), 0) credit_amount,
         --SUM (loan_taken) - sum(loan_adjusted) closing_balance
    FROM (SELECT papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 peevf.effective_start_date start_date,
                 TO_NUMBER (peevf.screen_entry_value) loan_taken,
                 0 loan_adjusted
            FROM apps.pay_element_types_f petf,
                 apps.pay_element_links_f pelf,
                 apps.pay_element_entries_f peef,
                 apps.per_all_assignments_f paaf,
                 apps.per_all_people_f papf,
                 --   pay_costs pc,
                 apps.per_jobs pj,
                 apps.hr_all_organization_units haou,
                 apps.pay_payrolls_f ppf,
                 apps.pay_element_entry_values_f peevf,
                 apps.pay_input_values_f pivf
           --  (PEEVF.SCREEN_ENTRY_VALUE)-(pc.COSTED_VALUE) as blance
           WHERE     1 = 1
                 AND pj.job_id(+) = paaf.job_id
                 AND ppf.payroll_id = paaf.payroll_id
                 AND haou.organization_id = paaf.organization_id
                 AND paaf.business_group_id = 81
                 AND petf.element_name = 'Total Advance Adjustment'
                 AND peevf.effective_start_date >= '31-May-2018'
                 AND papf.person_id = NVL ( :p_person_id, papf.person_id)
                 AND TO_CHAR(peevf.effective_start_date,'MON-YY')=TO_CHAR(:p_date_from,'MON-YY')
                 --and peevf.effective_start_date between :p_date_from and :p_date_to
                 AND papf.person_id = paaf.person_id
                 AND pelf.element_type_id = petf.element_type_id
                 AND peef.element_type_id = petf.element_type_id
                 AND paaf.assignment_id = peef.assignment_id
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (paaf.effective_start_date)
                                         AND TRUNC (paaf.effective_end_date)
                 AND papf.person_id = paaf.person_id
                 AND papf.current_emp_or_apl_flag = 'Y'
                 AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                         AND TRUNC (papf.effective_end_date)
                 AND peevf.element_entry_id = peef.element_entry_id
                 AND pivf.input_value_id = peevf.input_value_id
          UNION ALL
          SELECT DISTINCT
                 papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 ppa.effective_date AS start_date,
                 0,
                 pc.costed_value debit
            --   DECODE (pc.debit_or_credit, 'C', pc.costed_value) credit
            FROM apps.per_people_f papf,
                 apps.per_assignments_f paaf,
                 apps.pay_assignment_actions pav,
                 apps.pay_payroll_actions ppa,
                 apps.pay_costs pc,
                 apps.pay_cost_allocation_keyflex pca,
                 apps.pay_element_types_f pet,
                 apps.pay_run_results prr,
                 --PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
                 apps.pay_run_result_values prrv
           WHERE                                   -- pca.segment5 = '1060103'
                papf .person_id = paaf.person_id
                 AND paaf.assignment_id = pav.assignment_id
                 AND paaf.primary_flag = 'Y'
                 --   and ppa.action_type = 'C'
                 -- AND papf.employee_number = :p_employee_number
                 AND pet.element_name = 'Monthly Advance Adjustment'
                 AND papf.person_id = :p_person_id
                 AND pav.payroll_action_id = ppa.payroll_action_id
                 AND pav.assignment_action_id = pc.assignment_action_id
                 AND pc.cost_allocation_keyflex_id =
                        pca.cost_allocation_keyflex_id
                 AND pet.element_type_id = prr.element_type_id
                 AND prr.run_result_id = prrv.run_result_id
                 AND pc.run_result_id = prrv.run_result_id
                 AND pc.input_value_id = prrv.input_value_id
                 AND TO_CHAR(ppa.effective_date,'MON-YY')=TO_CHAR(:p_date_from,'MON-YY')
                 AND papf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_people_f
                          WHERE person_id = papf.person_id)
                 AND paaf.effective_end_date =
                        (SELECT MAX (effective_end_date)
                           FROM apps.per_assignments_f
                          WHERE assignment_id = paaf.assignment_id))
--GROUP BY employee_number,
--         employee_name
--         start_date,
--         loan_taken,
--         loan_adjusted
--ORDER BY start_date;