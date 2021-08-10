/* Formatted on 3/10/2020 5:54:57 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY USER_UPDATE
AS
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
                  v_password    VARCHAR2 (200) := 'WelcomeDBL'; -- Password
               BEGIN
                  fnd_user_pkg.createuser (
                     x_user_name              => UPPER (v_user_name),
                     x_owner                  => NULL,
                     x_unencrypted_password   => v_password,
                     x_session_number         => USERENV ('sessionid'),
                     x_start_date             => SYSDATE,
                     x_end_date               => NULL);
                  DBMS_OUTPUT.put_line (
                     'User ' || v_user_name || ' created !!!!!');

                  UPDATE xxdbl.XXDBL_CREATE_USER CUR
                     SET CUR.flag = 'Y'
                   WHERE     C_NEW_USER.ppose = 'ADD'
                         AND CUR.user_name = v_user_name
                         AND CUR.flag IS NULL;
                    
                    
                   COMMIT;
               END;

               
            ELSE
               DECLARE
                  v_user_end       VARCHAR2 (30) := C_NEW_USER.u_name; -- User Name
                  v_end_password   VARCHAR2 (200) := 'EndofDBL'; -- Password



                  CURSOR C_END_USER_PASS
                  IS
                     SELECT a.start_date strt_dt
                       FROM apps.fnd_user b
                      WHERE b.user_name = v_user_end;
               BEGIN
                  FOR C_END_USER IN C_END_USER_PASS
                  LOOP
                     fnd_user_pkg.createuser (
                        x_user_name              => UPPER (v_user_end),
                        x_owner                  => NULL,
                        x_unencrypted_password   => v_end_password,
                        x_session_number         => USERENV ('sessionid'),
                        x_start_date             => C_END_USER.strt_dt,
                        x_end_date               => SYSDATE);
                     DBMS_OUTPUT.put_line (
                           'User '
                        || v_user_name
                        || ' has been terminated !!!!!!');
                        
                        

                     UPDATE xxdbl.XXDBL_CREATE_USER CUR
                        SET CUR.flag = 'N'
                      WHERE     C_NEW_USER.ppose = 'END'
                            AND CUR.user_name = v_user_end
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