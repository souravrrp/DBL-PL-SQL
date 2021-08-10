/* Formatted on 7/8/2020 12:15:14 PM (QP5 v5.287) */
BEGIN
   FND_USER_PKG.UPDATEUSER (x_user_name              => 'teamsearch',
                            x_owner                  => 'SEED',
                            x_unencrypted_password   => 'oracle@123',
                            x_password_date          => SYSDATE + 500);
END;