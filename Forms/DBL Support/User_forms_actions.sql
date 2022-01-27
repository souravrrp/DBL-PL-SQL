/* Formatted on 11/7/2020 1:00:30 PM (QP5 v5.354) */
  SELECT *
    FROM apps.fnd_login_resp_forms
ORDER BY START_TIME DESC;

  SELECT ffv.user_form_name,
         ff.FUNCTION_ID,
         ff.FUNCTION_name,
         TO_CHAR (flr.end_time, 'dd-mon-yyyy hh24:mi:ss')       end_time,
         TO_CHAR (flr.start_time, 'dd-mon-yyyy hh24:mi:ss')     start_time,
         (flr.end_time - flr.start_time) * 24 * 60              duration
    FROM apps.FND_LOGIN_RESP_FORMS flr,
         apps.fnd_form_functions_vl ff,
         apps.fnd_form_vl          ffv
   WHERE     login_id IN (SELECT login_id
                            FROM apps.FND_LOGINS
                           WHERE user_id = 1613)
         AND flr.form_id = ff.form_id
         AND TRUNC (flr.start_time) = TRUNC (SYSDATE)
         AND ((flr.end_time - flr.start_time) * 24 * 60) > 1 / 20 -- 3 seconds
         AND ffv.form_id = ff.form_id
ORDER BY flr.start_time DESC;

-------------------------------------------------------------------------------------------------------------------------------

  SELECT DISTINCT faa.application_name     application,
                  rtl.responsibility_name,
                  ffl.user_function_name,
                  ff.function_name,
                  ffl.description,
                  ff.TYPE
    FROM apps.fnd_compiled_menu_functions cmf,
         apps.fnd_form_functions         ff,
         apps.fnd_form_functions_tl      ffl,
         apps.fnd_responsibility         r,
         apps.fnd_responsibility_vl      rtl,
         apps.fnd_application_all_view   faa
   WHERE     cmf.function_id = ff.function_id
         AND r.menu_id = cmf.menu_id
         AND rtl.responsibility_id = r.responsibility_id
         AND cmf.grant_flag = 'Y'
         AND ff.function_id = ffl.function_id
         AND faa.application_id(+) = r.application_id
         AND UPPER (rtl.responsibility_name) LIKE '%TEST%'
         AND r.end_date IS NULL
         AND rtl.end_date IS NULL
ORDER BY rtl.responsibility_name;


-------------------------------------------------------------------------------------------------------------------


  SELECT responsibility_name,
         frg.request_group_name,
         fcpv.user_concurrent_program_name,
         fcpv.description
    FROM apps.fnd_request_groups        frg,
         apps.fnd_request_group_units   frgu,
         apps.fnd_concurrent_programs_vl fcpv,
         apps.fnd_responsibility_vl     frv
   WHERE     frgu.request_unit_type = 'P'
         AND frgu.request_group_id = frg.request_group_id
         AND frgu.request_unit_id = fcpv.concurrent_program_id
         AND frv.request_group_id = frg.request_group_id
ORDER BY responsibility_name;


---------------------------------------------------------------------------------------------------------------------


SELECT ff.FORM_NAME,
       ff.USER_FORM_NAME,
       ff.DESCRIPTION     form_description,
       fff.FUNCTION_NAME,
       fff.USER_FUNCTION_NAME
  FROM apps.fnd_form_vl ff, apps.FND_FORM_FUNCTIONS_VL fff
 WHERE ff.FORM_ID = fff.FORM_ID AND ff.form_name = 'MRPCHORG';



 -------------------------------------------------------------------------------------------------------------------------

SELECT fnf.application_id,
       fa.APPLICATION_NAME,
       ff.FUNCTION_NAME,
       ffl.USER_FUNCTION_NAME,
       ffl.description,
       fnf.form_name,
       ff.parameters,
       ff.TYPE
  FROM apps.fnd_form_functions_tl  ffl,
       apps.fnd_form_functions     ff,
       apps.fnd_form               fnf,
       apps.fnd_application_tl     fa
 WHERE     ff.function_name LIKE 'JACNDDPS'
       AND ffl.FUNCTION_ID = ff.FUNCTION_ID
       AND fnf.form_id = ff.form_id
       AND fa.application_id = fnf.application_id
       --–and fa.APPLICATION_ID=******
       AND ff.TYPE = 'FORM';