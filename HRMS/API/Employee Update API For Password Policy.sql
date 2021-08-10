/* Formatted on 2/25/2021 11:39:47 AM (QP5 v5.287) */
DECLARE
   lc_user_name   VARCHAR2 (100) := '103908';
--ld_user_end_date   DATE := SYSDATE;
BEGIN
   fnd_user_pkg.updateuser (x_user_name                => lc_user_name,
                            x_owner                    => NULL,
                            x_unencrypted_password     => NULL,
                            x_start_date               => NULL,
                            x_end_date                 => NULL,
                            x_password_date            => NULL,
                            x_password_lifespan_days   => NULL, --NULL/NO OF DAYS
                            x_employee_id              => NULL,
                            x_email_address            => NULL);

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE (SQLERRM);
END;
/