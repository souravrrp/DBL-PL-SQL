/* Formatted on 5/16/2021 11:47:34 AM (QP5 v5.354) */
CREATE OR REPLACE FUNCTION APEX_AUTHENTICATION
    RETURN BOOLEAN
IS
    v_result   NUMBER;
    v_func     BOOLEAN := FALSE;
BEGIN
    SELECT usr.user_id
      INTO v_result
      FROM apps.icx_sessions  icx
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
           AND usr.user_id = apps.fnd_global.user_id;

    IF v_result IS NOT NULL
    THEN
        v_func := TRUE;
    ELSE
        v_func := FALSE;
    END IF;

    RETURN v_func;
END;