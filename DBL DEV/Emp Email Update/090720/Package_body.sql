/* Formatted on 7/9/2020 9:33:54 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_employee_update
IS
   PROCEDURE update_emp_email_addess
   IS
      l_employee_number             per_people_f.employee_number%TYPE;
      l_person_id                   per_people_f.person_id%TYPE := 218;
      l_per_object_version_number   per_people_f.object_version_number%TYPE;
      v_effective_start_date        DATE;
      v_effective_end_date          DATE;
      v_full_name                   VARCHAR2 (100);
      v_comment_id                  NUMBER;
      v_name_combination_warning    BOOLEAN;
      v_assign_payroll_warning      BOOLEAN;
      v_orig_hire_warning           BOOLEAN;
   BEGIN
      SELECT object_version_number, employee_number
        INTO l_per_object_version_number, l_employee_number
        FROM apps.per_people_f
       WHERE     person_id = l_person_id
             AND SYSDATE BETWEEN effective_start_date AND effective_end_date;

      hr_person_api.update_person (
         p_validate                   => FALSE,
         p_effective_date             => TO_DATE ('30-JUN-2020', 'DD-MON-YYYY'),
         p_datetrack_update_mode      => 'CORRECTION',
         p_person_id                  => l_person_id,
         p_object_version_number      => l_per_object_version_number,
         p_employee_number            => l_employee_number,
         p_email_address              => 'test@merckserono.net',
         p_effective_start_date       => v_effective_start_date,
         p_effective_end_date         => v_effective_end_date,
         p_full_name                  => v_full_name,
         p_comment_id                 => v_comment_id,
         p_name_combination_warning   => v_name_combination_warning,
         p_assign_payroll_warning     => v_assign_payroll_warning,
         p_orig_hire_warning          => v_orig_hire_warning);



      COMMIT;
   END update_emp_email_addess;
END xxdbl_employee_update;
/