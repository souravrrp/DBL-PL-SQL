/* Formatted on 7/13/2019 11:55:14 AM (QP5 v5.287) */
  SELECT SUBSTR (pro1.user_profile_option_name, 1, 35) Profile,
         DECODE (pov.level_id,
                 10001, 'Site',
                 10002, 'Application',
                 10003, 'Resp',
                 10004, 'User')
            Option_Level,
         DECODE (pov.level_id,
                 10001, 'Site',
                 10002, appl.application_short_name,
                 10003, resp.responsibility_name,
                 10004, u.user_name)
            Level_Value,
         NVL (pov.profile_option_value, 'Is Null') Profile_option_Value
    FROM apps.fnd_profile_option_values pov,
         apps.fnd_responsibility_tl resp,
         apps.fnd_application appl,
         apps.fnd_user u,
         apps.fnd_profile_options pro,
         apps.fnd_profile_options_tl pro1
   WHERE     pro1.user_profile_option_name LIKE ('%Ledger%')
         AND pro.profile_option_name = pro1.profile_option_name
         AND pro.profile_option_id = pov.profile_option_id
         AND resp.responsibility_name LIKE '%General%Ledger%' /* comment this line  if you need to check profiles for all responsibilities */
         AND pov.level_value = resp.responsibility_id(+)
         AND pov.level_value = appl.application_id(+)
         AND pov.level_value = u.user_id(+)
ORDER BY 1, 2;

--------------------------------------------------------------------------------

  SELECT SUBSTR (pro1.user_profile_option_name, 1, 35) Profile,
         DECODE (pov.level_id,
                 10001, 'Site',
                 10002, 'Application',
                 10003, 'Resp',
                 10004, 'User')
            Option_Level,
         DECODE (pov.level_id,
                 10001, 'Site',
                 10002, appl.application_short_name,
                 10003, resp.responsibility_name,
                 10004, u.user_name)
            Level_Value,
         NVL (pov.profile_option_value, 'Is Null') Profile_option_Value
    FROM apps.fnd_profile_option_values pov,
         apps.fnd_responsibility_tl resp,
         apps.fnd_application appl,
         apps.fnd_user u,
         apps.fnd_profile_options pro,
         apps.fnd_profile_options_tl pro1
   WHERE     pro.profile_option_name = pro1.profile_option_name
         AND pro.profile_option_id = pov.profile_option_id
         AND resp.responsibility_name LIKE '%General%Ledger%'
         AND pov.level_value = resp.responsibility_id(+)
         AND pov.level_value = appl.application_id(+)
         AND pov.level_value = u.user_id(+)
ORDER BY 1, 2;

--------------------------------------------------------------------------------

SELECT FPO.PROFILE_OPTION_ID, FPOT.PROFILE_OPTION_NAME PROFILE_SHORT_NAME
, FPOT.USER_PROFILE_OPTION_NAME PROFILE_NAME
, DECODE(FPOV.LEVEL_ID,10001,'site',10002,'Appl',10003,'Resp',10004,'User') PROFILE_LEVEL
, DECODE(FPOV.LEVEL_ID,10001,NULL, 10002,FA.APPLICATION_SHORT_NAME,10003,FR.RESPONSIBILITY_NAME,10004,FU.USER_NAME) LEVEL_VALUE
, FPOV.PROFILE_OPTION_VALUE PROFILE_VALUE
, FPOV.CREATION_DATE
,(SELECT USER_NAME FROM APPS.FND_USER
   WHERE USER_ID = FPOV.CREATED_BY) "Created By"
, FPOV.LAST_UPDATE_DATE
,(SELECT USER_NAME FROM APPS.FND_USER
   WHERE USER_ID = FPOV.LAST_UPDATED_BY) "Last Update By"
--, FPOV.*
FROM APPS.FND_PROFILE_OPTION_VALUES FPOV
, APPS.FND_PROFILE_OPTIONS FPO
, APPS.FND_PROFILE_OPTIONS_TL FPOT
, APPS.FND_APPLICATION FA
, APPS.FND_RESPONSIBILITY_TL FR
, APPS.FND_USER FU  
WHERE 1=1 
--AND (FPO.PROFILE_OPTION_NAME LIKE NVL(:PROFILE_OPTION_NAME,FPO.PROFILE_OPTION_NAME)
--AND FPOT.USER_PROFILE_OPTION_NAME LIKE NVL(:USER_PROFILE_OPTION_NAME,FPOT.USER_PROFILE_OPTION_NAME))
AND FPO.PROFILE_OPTION_NAME=FPOT.PROFILE_OPTION_NAME
AND FPO.PROFILE_OPTION_ID = FPOV.PROFILE_OPTION_ID
AND FA.APPLICATION_ID(+)=FPOV.LEVEL_VALUE
AND FR.RESPONSIBILITY_ID(+)=FPOV.LEVEL_VALUE
AND FU.USER_ID(+)=FPOV.LEVEL_VALUE
AND FU.USER_NAME='8824'
ORDER BY 3