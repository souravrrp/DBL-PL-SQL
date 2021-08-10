/* Formatted on 5/16/2021 12:52:36 PM (QP5 v5.287) */
SELECT last_connect,
       usr.user_name,
       resp.responsibility_key,
       function_type,
       icx.*
  FROM apps.icx_sessions icx
       JOIN apps.fnd_user usr ON usr.user_id = icx.user_id
       LEFT JOIN apps.fnd_responsibility resp
          ON resp.responsibility_id = icx.responsibility_id
 WHERE     last_connect >
                SYSDATE
              - NVL (FND_PROFILE.VALUE ('ICX_SESSION_TIMEOUT'), 30) / 60 / 24
       AND disabled_flag != 'Y'
       AND pseudo_flag = 'N'
       AND usr.user_name = '103908'