/* Formatted on 5/18/2021 2:25:02 PM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION apex_fnd_user (p_username   IN VARCHAR2,
                                          p_password   IN VARCHAR2)
   RETURN BOOLEAN
IS
   l_e_password   VARCHAR2 (255);
   l_d_password   VARCHAR2 (255);
   l_user_exist   NUMBER;
   l_user_name    VARCHAR2 (255) := UPPER (p_username);
   l_password     VARCHAR2 (255) := p_password;
BEGIN
   --check if the user exist in the user's table
   SELECT COUNT (*)
     INTO l_user_exist
     FROM apps.fnd_user
    WHERE     user_name = l_user_name
          AND TRUNC (SYSDATE) BETWEEN TRUNC (start_date)
                                  AND TRUNC (NVL (end_date, SYSDATE));

   --if the user exist
   IF l_user_exist > 0
   THEN
      ---get Pass

      SELECT (SELECT test_package12.decrypt (
                        UPPER ('appsrpc999'),
                        usertable.encrypted_user_password)
                FROM DUAL)
                AS encrypted_user_password
        INTO l_d_password
        FROM apps.fnd_user usertable
       WHERE usertable.user_name = l_user_name;

      -- encrypt the password which has been recieved
      --l_e_password := encrypt_password (l_user_name, p_password);
      l_e_password := l_d_password;


      -- retrive the user's password
      /*
      SELECT password
        INTO l_password
        FROM tb_users
       WHERE user_name = l_user_name;
       */

      --compare the user's password with the encrypted password

      --if the passwords match return true, otherwise return false
      IF l_e_password = l_password
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   --if the user does not exist in the user's table return false
   ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END Apex_fnd_user;