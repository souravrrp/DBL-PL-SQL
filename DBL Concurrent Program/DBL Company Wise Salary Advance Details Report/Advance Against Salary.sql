/* Formatted on 24/Jul/19 2:19:54 PM (QP5 v5.227.12220.39754) */
select employee_number,
       employee_name,
       start_date,
       loan_taken,
       nvl (loan_adjusted, 0) loan_adjusted
  from (select papf.employee_number,
               (   papf.first_name
                || ' '
                || papf.middle_names
                || ' '
                || papf.last_name)
                  as employee_name,
               peevf.effective_start_date start_date,
               to_number (peevf.screen_entry_value) loan_taken,
               0 loan_adjusted
          from apps.pay_element_types_f petf,
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
         where     1 = 1
               and pj.job_id(+) = paaf.job_id
               and ppf.payroll_id = paaf.payroll_id
               and haou.organization_id = paaf.organization_id
               and paaf.business_group_id = 81
               and petf.element_name = 'Total Advance Adjustment'
               and peevf.effective_start_date >= '31-May-2018'
               and papf.person_id =
                      nvl (:p_person_id, papf.person_id)
               --and peevf.effective_start_date between :p_date_from and :p_date_to
               and papf.person_id = paaf.person_id
               and pelf.element_type_id = petf.element_type_id
               and peef.element_type_id = petf.element_type_id
               and paaf.assignment_id = peef.assignment_id
               and trunc (sysdate) between trunc (paaf.effective_start_date)
                                       and trunc (paaf.effective_end_date)
               and papf.person_id = paaf.person_id
               and papf.current_emp_or_apl_flag = 'Y'
               and trunc (sysdate) between trunc (papf.effective_start_date)
                                       and trunc (papf.effective_end_date)
               and peevf.element_entry_id = peef.element_entry_id
               and pivf.input_value_id = peevf.input_value_id
        union all
        select distinct
               papf.employee_number,
               (   papf.first_name
                || ' '
                || papf.middle_names
                || ' '
                || papf.last_name)
                  as employee_name,
               ppa.effective_date as payroll_month,
               0,
               pc.costed_value debit
          --   DECODE (pc.debit_or_credit, 'C', pc.costed_value) credit
          from apps.per_people_f papf,
               apps.per_assignments_f paaf,
               apps.pay_assignment_actions pav,
               apps.pay_payroll_actions ppa,
               apps.pay_costs pc,
               apps.pay_cost_allocation_keyflex pca,
               apps.pay_element_types_f pet,
               apps.pay_run_results prr,
               --PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
               apps.pay_run_result_values prrv
         where                                     -- pca.segment5 = '1060103'
              papf .person_id = paaf.person_id
               and paaf.assignment_id = pav.assignment_id
               and paaf.primary_flag = 'Y'
            --   and ppa.action_type = 'C'
               -- AND papf.employee_number = :p_employee_number
               and pet.element_name = 'Monthly Advance Adjustment'
               and papf.person_id = :p_person_id
               and pav.payroll_action_id = ppa.payroll_action_id
               and pav.assignment_action_id = pc.assignment_action_id
               and pc.cost_allocation_keyflex_id =
                      pca.cost_allocation_keyflex_id
               and pet.element_type_id = prr.element_type_id
               and prr.run_result_id = prrv.run_result_id
               and pc.run_result_id = prrv.run_result_id
               and pc.input_value_id = prrv.input_value_id
               and papf.effective_end_date =
                      (select max (effective_end_date)
                         from apps.per_people_f
                        where person_id = papf.person_id)
               and paaf.effective_end_date =
                      (select max (effective_end_date)
                         from apps.per_assignments_f
                        where assignment_id = paaf.assignment_id))
                        order by start_date;