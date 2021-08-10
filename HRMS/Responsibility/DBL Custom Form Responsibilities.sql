-----------------------------USER WISE FORMS REPONSIBILITY----------------------

SELECT fu.user_name,
       fr.responsibility_name,
       fme.prompt     prompt_name,
       ff.form_name,
       fm.menu_name,
       fff.function_name,
       res.start_date,
       res.end_date
  --,FM.*
  --,FF.*
  --,FFF.*
  FROM apps.fnd_menu_entries_vl          fme,
       apps.fnd_menus_vl                 fm,
       apps.fnd_form_functions_vl        fff,
       apps.fnd_form_vl                  ff,
       apps.fnd_responsibility_vl        fr,
       apps.fnd_user                     fu,
       apps.fnd_user_resp_groups_direct  res
 WHERE     1 = 1
       AND res.responsibility_id = fr.responsibility_id
       --AND    ff.form_name = 'XXARBILL' --:p_fmb
       AND fff.function_name LIKE 'XX%'
       AND fff.form_id = ff.form_id
       AND fme.function_id = fff.function_id
       AND fm.menu_id = fme.menu_id
       AND fr.menu_id = fm.menu_id
       AND UPPER (fr.responsibility_name) LIKE
               UPPER ('%' || :p_reponsibility_name || '%')
       --AND (   :P_REPONSIBILITY_NAME IS NULL OR (UPPER (FR.RESPONSIBILITY_NAME) LIKE UPPER ('%'||:P_REPONSIBILITY_NAME||'%')))
       AND ( :p_emp_num IS NULL OR (fu.user_name = :p_emp_num))
       AND fr.responsibility_id = res.responsibility_id(+)
       AND res.user_id = fu.user_id(+)
       AND fme.prompt IS NOT NULL;


-----------------------------OU WISE CUSTOM FORMS REPONSIBILITY-----------------


  SELECT DISTINCT hou.name,
                  forms.form_name,
                  formstl.user_form_name,
                  func.function_name,
                  func.user_function_name,
                  fm.menu_name,
                  menu.prompt     menu_prompt,
                  menu.description,
                  restl.responsibility_name
    FROM fnd_form                      forms,
         fnd_form_tl                   formstl,
         fnd_form_functions_vl         func,
         fnd_menu_entries_vl           menu,
         fnd_menus                     fm,
         fnd_responsibility            res,
         fnd_responsibility_vl         restl,
         apps.fnd_profile_options_vl   fpo,
         apps.fnd_profile_option_values fpov,
         apps.hr_organization_units    hou
   WHERE     1 = 1
         AND fpov.profile_option_value = TO_CHAR (hou.organization_id)
         AND fpo.profile_option_id = fpov.profile_option_id
         AND fpo.user_profile_option_name = 'MO: Operating Unit'
         AND restl.responsibility_id = fpov.level_value
         --AND hou.name IN ('CCL2')
         AND (   :p_unit_name IS NULL OR (UPPER (hou.name) = UPPER ( :p_unit_name)))
         AND forms.form_id = formstl.form_id
         AND func.form_id = forms.form_id
         AND menu.function_id = func.function_id
         AND menu.menu_id = fm.menu_id
         AND res.menu_id = menu.menu_id
         AND res.responsibility_id = restl.responsibility_id
         and ( :p_reponsibility_name is null or (upper (restl.responsibility_name) like upper ('%'||:p_reponsibility_name||'%')))
         AND UPPER (forms.form_name) LIKE '%XX%'
ORDER BY 1;