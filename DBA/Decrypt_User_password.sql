SELECT usr.user_name, usr.user_id,usr.description,
       get_pwd.decrypt
          ((SELECT (SELECT get_pwd.decrypt
                              (fnd_web_sec.get_guest_username_pwd,
                               usertable.encrypted_foundation_password
                              )
                      FROM DUAL) AS apps_password
              FROM fnd_user usertable
             WHERE usertable.user_name =
                      (SELECT SUBSTR
                                  (fnd_web_sec.get_guest_username_pwd,
                                   1,
                                     INSTR
                                          (fnd_web_sec.get_guest_username_pwd,
                                           '/'
                                          )
                                   - 1
                                  )
                         FROM DUAL)),
           usr.encrypted_user_password
          ) PASSWORD
  FROM fnd_user usr
 WHERE usr.user_name = '&USER_NAME';
 
 -------------------------------------------------------------------------------
 SELECT usr.user_name,
       apps.get_pwd.decrypt
          ((SELECT (SELECT apps.get_pwd.decrypt
                              (apps.fnd_web_sec.get_guest_username_pwd,
                               usertable.encrypted_foundation_password
                              )
                      FROM DUAL) AS apps_password
              FROM apps.fnd_user usertable
             WHERE usertable.user_name =
                      (SELECT SUBSTR
                                  (apps.fnd_web_sec.get_guest_username_pwd,
                                   1,
                                     INSTR
                                          (apps.fnd_web_sec.get_guest_username_pwd,
                                           '/'
                                          )
                                   - 1
                                  )
                         FROM DUAL)),
           usr.encrypted_user_password
          ) PASSWORD
  FROM apps.fnd_user usr
 WHERE usr.user_name = '&USER_NAME';