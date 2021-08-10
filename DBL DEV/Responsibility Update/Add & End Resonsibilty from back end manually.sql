/* Formatted on 1/23/2020 1:08:57 PM (QP5 v5.287) */
DECLARE
   v_user_name   VARCHAR2 (30) := '103908'; -- User Name
   --v_password  varchar2(30) :='johnytips';  -- Password
   
   
   -- List of responsibilities to be added automatically
   CURSOR cur_get_responsibilities
   IS
      SELECT resp.responsibility_key,
             resp.responsibility_name,
             app.application_short_name
        FROM fnd_responsibility_vl resp, fnd_application app
       WHERE     resp.application_id = app.application_id
             AND resp.responsibility_name IN
                    ('DBL GROUP: AR - Manager');

   -- List of responsibilities to be end date automatically
   CURSOR cur_end_responsibilities
   IS
      SELECT a.start_date strt_dt,
             c.responsibility_key res_key,
             c.responsibility_name res_name,
             d.application_short_name app_short_name
        FROM apps.fnd_user_resp_groups_direct a,
             apps.fnd_user b,
             fnd_responsibility_vl c,
             fnd_application_vl d
       WHERE     a.user_id = b.user_id
             AND b.user_name = v_user_name
             AND a.responsibility_id = c.responsibility_id
             AND a.responsibility_application_id = c.application_id
             AND c.application_id = d.application_id
             AND c.responsibility_name IN
                    ('Oracle Pricing Administrator');
BEGIN
   ----------------------------------------------------------------------------- Create User
   --   fnd_user_pkg.createuser (
   --           x_user_name             => upper(v_user_name)
   --          ,x_owner                 => null
   --          ,x_unencrypted_password  => v_password
   --          ,x_session_number        => userenv('sessionid')
   --          ,x_start_date            => sysdate
   --          ,x_end_date              => null );
   --   dbms_output.put_line ('User '||v_user_name||' created !!!!!');

   ----------------------------------------------------------------------------- Add Responsibiltiy
   FOR c_get_resp IN cur_get_responsibilities
   LOOP
      fnd_user_pkg.addresp (username         => v_user_name,
                            resp_app         => c_get_resp.application_short_name,
                            resp_key         => c_get_resp.responsibility_key,
                            security_group   => 'STANDARD',
                            description      => NULL,
                            start_date       => SYSDATE,
                            end_date         => NULL);
      DBMS_OUTPUT.put_line (
            'Responsibility '
         || c_get_resp.responsibility_name
         || ' added !!!!!!');
   END LOOP;

   ----------------------------------------------------------------------------- End Responsibiltiy
   FOR c_end_resp IN cur_end_responsibilities
   LOOP
      fnd_user_pkg.addresp (username         => v_user_name,
                            resp_app         => c_end_resp.app_short_name,
                            resp_key         => c_end_resp.res_key,
                            security_group   => 'STANDARD',
                            description      => NULL,
                            start_date       => c_end_resp.strt_dt,
                            end_date         => SYSDATE);
      DBMS_OUTPUT.put_line (
            'Responsibility '
         || c_end_resp.res_name
         || ' has been terminated !!!!!!');
   END LOOP;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Exception : ' || SUBSTR (SQLERRM, 1, 500));
      ROLLBACK;
END;