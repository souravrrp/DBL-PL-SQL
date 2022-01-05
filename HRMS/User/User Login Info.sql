/* Formatted on 1/4/2022 4:54:57 PM (QP5 v5.374) */
SELECT * FROM fnd_login_resp_forms;

SELECT * FROM fnd_logins;

SELECT * FROM fnd_login_responsibilities;

  SELECT fu.user_name, frt.responsibility_name, MAX (fl.Start_time)
    FROM applsys.fnd_login_Responsibilities flr,
         fnd_user                          fu,
         applsys.fnd_logins                fl,
         fnd_responsibility_tl             frt
   WHERE     fl.login_id = flr.login_id
         AND fl.user_id = fu.user_id
         AND fu.user_name LIKE '%103908%'
         AND frt.responsibility_id = flr.responsibility_id
         AND frt.language = 'US'
GROUP BY frt.responsibility_name, fu.user_name
ORDER BY MAX (flr.start_time) DESC;


  SELECT usr.user_name,
         rsp.responsibility_name,
         MAX (ful.start_time)     "LAST_CONNECT"
    FROM apps.icx_sessions         ses,
         apps.fnd_user             usr,
         apps.fnd_logins           ful,
         apps.fnd_responsibility_tl rsp
   WHERE     ses.login_id(+) = ful.login_id
         AND ses.responsibility_id = rsp.responsibility_id(+)
         AND ses.responsibility_application_id = rsp.application_id(+)
         AND usr.user_id = ful.user_id
         AND usr.user_name = '103908'
--AND rsp.responsibility_name IS NOT NULL
GROUP BY usr.user_name, rsp.responsibility_name
ORDER BY usr.user_name, rsp.responsibility_name, last_connect;


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

  