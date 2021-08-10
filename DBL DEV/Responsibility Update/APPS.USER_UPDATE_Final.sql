/* Formatted on 3/11/2020 11:15:07 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.USER_UPDATE
AS
   PROCEDURE update_responsibility
   IS
      CURSOR cur_update_responsibility
      IS
         SELECT user_name u_name,
                responsibility_name resp_name,
                purpose ppose
           FROM xxdbl.xxdbl_update_responsibilities xur
          WHERE xur.flag IS NULL;
   BEGIN
      FOR c_upd_resp IN cur_update_responsibility
      LOOP
         BEGIN
            IF c_upd_resp.ppose = 'ADD'
            THEN
               DECLARE
                  v_user_add   VARCHAR2 (30) := c_upd_resp.u_name; -- User Name
                  v_resp_add   VARCHAR2 (200) := c_upd_resp.resp_name; -- Responsibility Name

                  -- List of responsibilities to be added automatically
                  CURSOR cur_get_user
                  IS
                     SELECT resp.responsibility_key,
                            resp.responsibility_name,
                            app.application_short_name
                       FROM fnd_responsibility_vl resp, fnd_application app
                      WHERE     resp.application_id = app.application_id
                            AND resp.responsibility_name = v_resp_add;
               BEGIN
                  ----------------------------------------------------------------------------- add responsibiltiy
                  FOR c_get_new_user IN cur_get_user
                  LOOP
                     fnd_user_pkg.addresp (
                        username         => v_user_add,
                        resp_app         => c_get_new_user.application_short_name,
                        resp_key         => c_get_new_user.responsibility_key,
                        security_group   => 'STANDARD',
                        description      => NULL,
                        start_date       => SYSDATE,
                        end_date         => NULL);
                     DBMS_OUTPUT.put_line (
                           'responsibility '
                        || c_get_new_user.responsibility_name
                        || ' added !!!!!!');

                     UPDATE xxdbl.xxdbl_update_responsibilities xur
                        SET xur.flag = 'Y'
                      WHERE     c_upd_resp.ppose = 'ADD'
                            AND xur.RESPONSIBILITY_NAME =
                                   c_get_new_user.responsibility_name
                            AND xur.flag IS NULL;
                  END LOOP;
               END;

               COMMIT;
            ELSE
               DECLARE
                  v_user_end   VARCHAR2 (30) := c_upd_resp.u_name; -- User Name
                  v_resp_end   VARCHAR2 (200) := c_upd_resp.resp_name; -- Responsibility Name


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
                            AND b.user_name = v_user_end
                            AND a.responsibility_id = c.responsibility_id
                            AND a.responsibility_application_id =
                                   c.application_id
                            AND c.application_id = d.application_id
                            AND c.responsibility_name = v_resp_end;
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


                  ----------------------------------------------------------------------------- End Responsibiltiy
                  FOR c_end_resp IN cur_end_responsibilities
                  LOOP
                     fnd_user_pkg.addresp (
                        username         => v_user_end,
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


                     UPDATE xxdbl.xxdbl_update_responsibilities xur
                        SET xur.flag = 'N'
                      WHERE     c_upd_resp.ppose = 'END'
                            AND xur.RESPONSIBILITY_NAME = c_end_resp.res_name
                            AND xur.flag IS NULL;
                  END LOOP;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.put_line (
                        'Exception : ' || SUBSTR (SQLERRM, 1, 500));
                     ROLLBACK;
               END;
            END IF;
         END;
      END LOOP;
   END;

   PROCEDURE CREATE_USER
   IS
      CURSOR CUR_CREATE_NEW_USER
      IS
         SELECT user_name u_name, purpose ppose
           FROM xxdbl.XXDBL_CREATE_USER CUR
          WHERE CUR.flag IS NULL;
   BEGIN
      FOR C_NEW_USER IN CUR_CREATE_NEW_USER
      LOOP
         BEGIN
            IF C_NEW_USER.ppose = 'ADD'
            THEN
               DECLARE
                  v_user_name   VARCHAR2 (30) := C_NEW_USER.u_name; -- User Name
                  v_password    VARCHAR2 (200) := 'WelcomeDBL';    -- Password


                  CURSOR cur_get_user
                  IS
                     SELECT a.user_name create_user_name
                       FROM xxdbl.xxdbl_create_user a
                      WHERE     a.user_name = v_user_name
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM apps.fnd_user b
                                     WHERE a.user_name = b.user_name);
               BEGIN
                  FOR c_get_new_user IN cur_get_user
                  LOOP
                     fnd_user_pkg.createuser (
                        x_user_name              => UPPER (
                                                      c_get_new_user.create_user_name),
                        x_owner                  => NULL,
                        x_unencrypted_password   => v_password,
                        x_session_number         => USERENV ('sessionid'),
                        x_start_date             => SYSDATE,
                        x_end_date               => NULL);
                     DBMS_OUTPUT.put_line (
                           'User '
                        || c_get_new_user.create_user_name
                        || ' created !!!!!');

                     UPDATE xxdbl.xxdbl_create_user CUR
                        SET CUR.flag = 'Y'
                      WHERE     C_NEW_USER.ppose = 'ADD'
                            AND CUR.user_name =
                                   c_get_new_user.create_user_name
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM apps.fnd_user b
                                     WHERE CUR.user_name = b.user_name)
                            AND CUR.flag IS NULL;
                  END LOOP;

                  COMMIT;
               END;
            ELSE
               DECLARE
                  v_user_end       VARCHAR2 (30) := C_NEW_USER.u_name; -- User Name
                  v_end_password   VARCHAR2 (200) := 'EndofDBL';   -- Password


                  CURSOR C_END_USER_PASS
                  IS
                     SELECT b.start_date strt_dt, b.user_name usr_nme
                       FROM apps.fnd_user b
                      WHERE b.user_name = v_user_end;
               BEGIN
                  FOR C_END_USER IN C_END_USER_PASS
                  LOOP
                     fnd_user_pkg.createuser (
                        x_user_name              => UPPER (C_END_USER.usr_nme),
                        x_owner                  => NULL,
                        x_unencrypted_password   => v_end_password,
                        x_session_number         => USERENV ('sessionid'),
                        x_start_date             => C_END_USER.strt_dt,
                        x_end_date               => SYSDATE);
                     DBMS_OUTPUT.put_line (
                           'User '
                        || C_END_USER.usr_nme
                        || ' has been terminated !!!!!!');



                     UPDATE xxdbl.XXDBL_CREATE_USER CUR
                        SET CUR.flag = 'N'
                      WHERE     C_NEW_USER.ppose = 'END'
                            AND CUR.user_name = C_END_USER.usr_nme
                            AND CUR.flag IS NULL;
                  END LOOP;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     DBMS_OUTPUT.put_line (
                        'Exception : ' || SUBSTR (SQLERRM, 1, 500));
                     ROLLBACK;
               END;
            END IF;
         END;
      END LOOP;
   END;
END USER_UPDATE;
/