/* Formatted on 1/5/2022 3:01:05 PM (QP5 v5.374) */
---------------------****ALL RESPONSIBILITY LAST LOG IN BY USER*****------------

  SELECT fu.user_name,
         frt.responsibility_name,
         MAX (fl.Start_time)     "LAST_CONNECT"
    FROM applsys.fnd_login_Responsibilities flr,
         fnd_user                          fu,
         applsys.fnd_logins                fl,
         fnd_responsibility_tl             frt
   WHERE     fl.login_id = flr.login_id
         AND fl.user_id = fu.user_id
         --AND fu.user_name IN ('103908')
         AND (( :p_user_name IS NULL) OR (fu.user_name = :p_user_name))
         AND (   :p_responsibility_name IS NULL OR (UPPER (frt.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
         AND frt.responsibility_id = flr.responsibility_id
         AND frt.language = 'US'
GROUP BY frt.responsibility_name, fu.user_name
ORDER BY MAX (flr.start_time) DESC;

--------------------------------------------------------------------------------

  SELECT fu.user_name,
         frt.responsibility_name,
         MAX (fl.start_time)     "LAST_CONNECT"
    FROM apps.fnd_user             fu,
         apps.fnd_logins           fl,
         apps.icx_sessions         icxs,
         apps.fnd_responsibility_tl frt
   WHERE     fl.login_id = icxs.login_id(+)
         AND icxs.responsibility_id = frt.responsibility_id(+)
         AND icxs.responsibility_application_id = frt.application_id(+)
         AND fu.user_id = fl.user_id
         --AND fu.user_name = '103908'
         --AND frt.responsibility_name IS NOT NULL
         AND (( :p_user_name IS NULL) OR (fu.user_name = :p_user_name))
GROUP BY fu.user_name, frt.responsibility_name
ORDER BY fu.user_name, frt.responsibility_name, last_connect;

--------------------------------------------------------------------------------
SELECT DISTINCT
       fu.user_name                                           User_Name,
       fr.RESPONSIBILITY_KEY                                  Responsibility,
       (SELECT user_function_name
          FROM fnd_form_functions_vl fffv
         WHERE (fffv.function_id = ic.function_id))           Current_Function,
       TO_CHAR (ic.first_connect, 'dd-mm-yyyy hh24:mi:ss')    first_connect,
       TO_CHAR (ic.last_connect, 'dd-mm-yyyy hh24:mi:ss')     last_connect,
       ppx.full_name,
       fu.email_address,
       ppx.employee_number,
       pbg.name                                               Business_Group
  FROM fnd_user             fu,
       fnd_responsibility   fr,
       icx_sessions         ic,
       per_people_x         ppx,
       per_business_groups  pbg
 WHERE     fu.user_id = ic.user_id
       AND fr.responsibility_id = ic.responsibility_id
       AND ic.responsibility_id IS NOT NULL
       AND fu.employee_id = ppx.person_id(+)
       --AND ic.last_connect = SYSDATE - 1/24
       AND fu.user_name = '103908'
       AND ppx.business_group_id = pbg.business_group_id(+);

--------------------------------------------------------------------------------
  SELECT DISTINCT u.user_id,
                  u.user_name               user_name,
                  r.responsibility_name     responsiblity,
                  a.application_name        application
    FROM fnd_user             u,
         fnd_user_resp_groups g,
         fnd_application_tl   a,
         fnd_responsibility_tl r
   WHERE     g.user_id(+) = u.user_id
         AND g.responsibility_application_id = a.application_id
         AND a.application_id = r.application_id
         AND g.responsibility_id = r.responsibility_id
ORDER BY 1;

--------------------------------------------------------------------------------

SELECT * FROM fnd_login_resp_forms;

SELECT * FROM fnd_logins;

SELECT * FROM fnd_login_responsibilities;