/* Formatted on 6/14/2021 12:57:46 PM (QP5 v5.287) */
SELECT p.profile_option_name "Internal name",
       fpv.PROFILE_OPTION_VALUE VALUE,
       cr.user_name "Created",
       TO_CHAR (fpv.creation_date, 'DD-MON-RRRR HH24:MI:SS') "Creation Date",
       upd.user_name "Updated",
       TO_CHAR (fpv.last_update_date, 'DD-MON-RRRR HH24:MI:SS') "Update Date",
       TO_CHAR (ll.start_time, 'DD-MON-RRRR HH:MI:SS') "Login Time"
  FROM fnd_profile_options p,
       fnd_profile_option_values fpv,
       fnd_user upd,
       fnd_user cr,
       fnd_logins ll
 WHERE     p.profile_option_id = fpv.profile_option_id(+)
       AND fpv.last_updated_by = upd.user_id(+)
       AND fpv.created_by = cr.user_id(+)
       AND fpv.last_update_login = ll.login_id(+)
       AND fpv.last_update_date > SYSDATE - 10;