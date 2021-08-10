/* Formatted on 11/7/2020 10:43:25 AM (QP5 v5.287) */
SELECT fmv.user_menu_name "MAIN MENU NAME",
       fmv.menu_name "MAIN MENU CODE",
       fme.prompt "PROMT",
       fmv1.user_menu_name "SUBMENU NAME",
       fmv1.menu_name "SUBMENU CODE",
       fff.user_function_name "FUNCTION NAME",
       fff.function_name "FUNCTION CODE",
       fme.description "DESCRIPTION",
       fme1.prompt "PROMT1",
       fmv2.user_menu_name "SUBMENU1 NAME",
       fmv2.menu_name "SUBMENU1 CODE",
       fff1.user_function_name "FUNCTION1 NAME",
       fff1.function_name "FUNCTION1 CODE",
       fme1.description "DESCRIPTION1",
       fme2.prompt "PROMT2",
       fmv3.user_menu_name "SUBMENU2 NAME",
       fmv3.menu_name "SUBMENU2 CODE",
       fff2.user_function_name "FUNCTION2 NAME",
       fff2.function_name "FUNCTION2 CODE",
       fme2.description "DESCRIPTION2",
       fme3.prompt "PROMT3",
       fmv4.user_menu_name "SUBMENU3 NAME",
       fmv4.menu_name "SUBMENU3 CODE",
       fff3.user_function_name "FUNCTION3 NAME",
       fff3.function_name "FUNCTION3 CODE",
       fme3.description "DESCRIPTION3",
       fme4.prompt "PROMT4",
       fmv5.user_menu_name "SUBMENU4 NAME",
       fmv5.menu_name "SUBMENU4 CODE",
       fff4.user_function_name "FUNCTION4 NAME",
       fff4.function_name "FUNCTION4 CODE",
       fme4.description "DESCRIPTION4"
  FROM fnd_menu_entries_vl fme,
       fnd_menu_entries_vl fme1,
       fnd_menu_entries_vl fme2,
       fnd_menu_entries_vl fme3,
       fnd_menu_entries_vl fme4,
       fnd_menu_entries_vl fme5,
       fnd_menus_vl fmv,
       fnd_menus_vl fmv1,
       fnd_menus_vl fmv2,
       fnd_menus_vl fmv3,
       fnd_menus_vl fmv4,
       fnd_menus_vl fmv5,
       fnd_form_functions_vl fff,
       fnd_form_functions_vl fff1,
       fnd_form_functions_vl fff2,
       fnd_form_functions_vl fff3,
       fnd_form_functions_vl fff4
 WHERE     1 = 1
       --AND fme.menu_id in ( 93236 )
       --AND ( :p_menu_id IS NULL OR (fme.menu_id = :p_menu_id))
       --AND fmv.type='STANDARD' 
       AND (   :p_menu_name IS NULL      OR (fmv.menu_name = :p_menu_name))
       and (   :p_user_menu_name is null or upper (fmv.user_menu_name) like upper ('%' || :p_user_menu_name || '%'))
       --and (   :p_menu_name is null or upper (fmv.menu_name) like upper ('%' || :p_menu_name || '%'))
       AND fme.sub_menu_id = fme1.menu_id(+)
       AND fme.menu_id = fmv.menu_id(+)
       AND fme.function_id = fff.function_id(+)
       AND fme1.sub_menu_id = fme2.menu_id(+)
       AND fme1.menu_id = fmv1.menu_id(+)
       AND fme1.function_id = fff1.function_id(+)
       AND fme2.sub_menu_id = fme3.menu_id(+)
       AND fme2.menu_id = fmv2.menu_id(+)
       AND fme2.function_id = fff2.function_id(+)
       AND fme3.sub_menu_id = fme4.menu_id(+)
       AND fme3.menu_id = fmv3.menu_id(+)
       AND fme3.function_id = fff3.function_id(+)
       AND fme4.sub_menu_id = fme5.menu_id(+)
       AND fme4.menu_id = fmv4.menu_id(+)
       AND fme4.function_id = fff4.function_id(+)
       AND fme5.menu_id = fmv5.menu_id(+);
       
------------------------------EMPLOYEE_WISE_RESPONSIBILITY_MENU-----------------

SELECT fu.user_name,
       fr.responsibility_name,
       fme.prompt prompt_name,
       ff.form_name,
       fm.menu_name,
       fff.function_name,
       res.start_date,
       res.end_date
  --,FM.*
  --,FF.*
  --,FFF.*
  FROM apps.fnd_menu_entries_vl fme,
       apps.fnd_menus_vl fm,
       apps.fnd_form_functions_vl fff,
       apps.fnd_form_vl ff,
       apps.fnd_responsibility_vl fr,
       apps.fnd_user fu,
       apps.fnd_user_resp_groups_direct res
 WHERE     1 = 1
       AND res.responsibility_id = fr.responsibility_id
       --AND    ff.form_name = 'XXAKG_FUEL' --:p_fmb
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