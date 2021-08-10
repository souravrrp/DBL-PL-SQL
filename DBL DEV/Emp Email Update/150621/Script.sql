/* Formatted on 6/22/2021 2:32:31 PM (QP5 v5.287) */
DECLARE
   l_effective_date             DATE := '22-Jun-2021';
   v_effective_start_date       DATE;
   v_effective_end_date         DATE;
   v_full_name                  VARCHAR2 (100);
   v_comment_id                 NUMBER;
   v_name_combination_warning   BOOLEAN;
   v_assign_payroll_warning     BOOLEAN;
   v_orig_hire_warning          BOOLEAN;

   CURSOR cur_update_email
   IS
      SELECT xur.user_name,
             xur.EMAIL_ADDRESS,
             ppf.object_version_number,
             ppf.employee_number l_employee_number,
             ppf.person_id
        FROM APPS.XXDBL_EMAIL_UPDATE xur, apps.per_people_f ppf
       WHERE     xur.flag IS NULL
             AND ppf.employee_number = xur.user_name
             AND SYSDATE BETWEEN ppf.effective_start_date
                             AND ppf.effective_end_date;
BEGIN
   FOR cur_upd_email IN cur_update_email
   LOOP
      BEGIN
         DECLARE
            v_user_name                   VARCHAR2 (30) := cur_upd_email.user_name; -- User Name
            l_per_object_version_number   NUMBER
               := cur_upd_email.object_version_number;
            l_email_add                   VARCHAR2 (100)
                                             := cur_upd_email.EMAIL_ADDRESS;
            l_person_id                   NUMBER := cur_upd_email.person_id;
         BEGIN
            hr_person_api.update_person (
               p_validate                   => FALSE,
               p_effective_date             => TO_DATE (l_effective_date, 'DD-MON-YYYY'),
               p_datetrack_update_mode      => 'UPDATE',          --CORRECTION
               p_person_id                  => l_person_id,
               p_object_version_number      => l_per_object_version_number,
               p_employee_number            => v_user_name,
               p_email_address              => l_email_add,
               p_effective_start_date       => v_effective_start_date,
               p_effective_end_date         => v_effective_end_date,
               p_full_name                  => v_full_name,
               p_comment_id                 => v_comment_id,
               p_name_combination_warning   => v_name_combination_warning,
               p_assign_payroll_warning     => v_assign_payroll_warning,
               p_orig_hire_warning          => v_orig_hire_warning);
         END;

         UPDATE apps.xxdbl_email_update xur
            SET xur.flag = 'Y'
          WHERE xur.user_name = cur_upd_email.user_name AND xur.flag IS NULL;

         COMMIT;
      END;
   END LOOP;
END;