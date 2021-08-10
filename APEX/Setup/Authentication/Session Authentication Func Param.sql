/* Formatted on 5/17/2021 10:24:59 AM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION APEX_AUTHENTICATION (p_user_name IN VARCHAR2)
   RETURN BOOLEAN
IS
   v_result   NUMBER;
   v_func     BOOLEAN := FALSE;
BEGIN
   SELECT usr.user_id
     INTO v_result
     FROM apps.icx_sessions icx
          JOIN apps.fnd_user usr ON usr.user_id = icx.user_id
          LEFT JOIN apps.fnd_responsibility resp
             ON resp.responsibility_id = icx.responsibility_id
    WHERE     last_connect >
                   SYSDATE
                 -   NVL (APPS.FND_PROFILE.VALUE ('ICX_SESSION_TIMEOUT'), 30)
                   / 60
                   / 24
          AND disabled_flag != 'Y'
          AND pseudo_flag = 'N'
          AND usr.user_name = p_user_name;

   IF v_result IS NOT NULL
   THEN
      v_func := TRUE;
   ELSE
      v_func := FALSE;
   END IF;

   RETURN v_func;
END;