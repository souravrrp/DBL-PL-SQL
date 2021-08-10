/* Formatted on 6/16/2021 2:05:05 PM (QP5 v5.287) */
SELECT xur.user_name,
       xur.email_address,
       ppf.object_version_number,
       ppf.employee_number l_employee_number,
       ppf.person_id,
       xur.flag
  FROM apps.xxdbl_email_update xur, apps.per_people_f ppf
 WHERE     xur.flag IS NULL
       AND ppf.employee_number = xur.user_name
       AND SYSDATE BETWEEN ppf.effective_start_date
                       AND ppf.effective_end_date;


SELECT *
  FROM apps.xxdbl_email_update
 WHERE flag = 'Y';

UPDATE apps.xxdbl_email_update
   SET flag = 'Y'
 WHERE 1 = 1;

DELETE apps.xxdbl_email_update
 WHERE flag = 'Y';


DROP PACKAGE apps.employee_update;

EXECUTE apps.xxdbl_employee_update.update_emp_email_addess('22-Jun-2021');

--EXECUTE apps.xxdbl_employee_update.update_emp_email_addess;