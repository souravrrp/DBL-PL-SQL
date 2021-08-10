/* Formatted on 2/9/2020 10:39:58 AM (QP5 v5.287) */
  SELECT employee_number,
         employee_name,
         designation,
         TO_CHAR ( :p_date_from) from_date,
         TO_CHAR ( :p_date_to) date_to,
         --TO_CHAR (start_date, 'MON-YYYY') payroll_month,
         --0 opening_balance,
         SUM(NVL(loan_taken,0)) debit_amount,
         SUM(NVL (loan_adjusted, 0)) credit_amount,
         SUM(NVL(loan_taken,0)) - SUM(NVL (loan_adjusted, 0)) closing_balance
    FROM (SELECT papf.employee_number,
                 (   papf.first_name
                  || ' '
                  || papf.middle_names
                  || ' '
                  || papf.last_name)
                    AS employee_name,
                 SUBSTR (pj.name, INSTR (pj.name, '.') + 1) designation,
                 peevf.effective_start_date start_date,
                 TO_NUMBER (peevf.screen_entry_value) loan_taken,
                 0 loan_adjusted
            FROM apps.pay_element_types_f petf,
                 apps.pay_element_links_f pelf,
                 apps.pay_element_entries_f peef,
                 apps.per_all_assignments_f paaf,
                 apps.per_all_people_f papf,
                 apps.per_jobs pj,
                 apps.hr_all_organization_units haou,
                 apps.pay_payrolls_f ppf,
                 apps.pay_element_entry_values_f peevf,
                 apps.pay_input_values_f pivf
           WHERE     1 = 1
                 AND pj.job_id(+) = paaf.job_id
                 AND ppf.payroll_id = paaf.payroll_id
                 AND haou.organization_id = paaf.organization_id
                 AND paaf.business_group_id = 81
                 AND petf.element_name = 'Total Advance Adjustment'
                 AND peevf.effective_start_date >= '31-May-2018'
                 AND paaf.payroll_id = :p_payroll_id
                 --AND papf.person_id = NVL ( :p_person_id, papf.person_id)
                 AND TRUNC (peevf.effective_start_date) BETWEEN NVL (
                                                                   :p_date_from,
                                                                   TRUNC (
                                                                      peevf.effective_start_date))
                                                            AND NVL (
                                                                   :p_date_to,
                                                                   TRUNC (
                                                                      peevf.effective_start_date))
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
                 SUBSTR (pj.name, INSTR (pj.name, '.') + 1) designation,
                 ppa.effective_date AS start_date,
                 0 loan_taken,
                 pc.costed_value loan_adjusted
            FROM apps.per_people_f papf,
                 apps.per_assignments_f paaf,
                 apps.pay_assignment_actions pav,
                 apps.pay_payroll_actions ppa,
                 apps.pay_costs pc,
                 apps.per_jobs pj,
                 apps.pay_cost_allocation_keyflex pca,
                 apps.pay_element_types_f pet,
                 apps.pay_run_results prr,
                 apps.pay_run_result_values prrv
           WHERE     papf.person_id = paaf.person_id
                 AND paaf.assignment_id = pav.assignment_id
                 AND paaf.primary_flag = 'Y'
                 AND pet.element_name = 'Monthly Advance Adjustment'
                 AND pj.job_id(+) = paaf.job_id
                 --AND papf.person_id = :p_person_id
                 AND paaf.payroll_id = :p_payroll_id
                 AND pav.payroll_action_id = ppa.payroll_action_id
                 AND pav.assignment_action_id = pc.assignment_action_id
                 AND pc.cost_allocation_keyflex_id =
                        pca.cost_allocation_keyflex_id
                 AND pet.element_type_id = prr.element_type_id
                 AND prr.run_result_id = prrv.run_result_id
                 AND pc.run_result_id = prrv.run_result_id
                 AND pc.input_value_id = prrv.input_value_id
                 AND TRUNC (ppa.effective_date) BETWEEN NVL (
                                                           :p_date_from,
                                                           TRUNC (
                                                              ppa.effective_date))
                                                    AND NVL (
                                                           :p_date_to,
                                                           TRUNC (
                                                              ppa.effective_date))
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
         designation
--         ,start_date
--         loan_taken,
--         loan_adjusted
--ORDER BY start_date