/* Formatted on 5/9/2020 4:16:40 PM (QP5 v5.287) */
  SELECT DISTINCT hou.NAME,
                  forms.form_name
--                  formstl.user_form_name,
--                  func.function_name,
--                  func.user_function_name,
--                  fm.menu_name,
--                  menu.prompt menu_prompt,
--                  menu.description,
--                  restl.responsibility_name
    FROM fnd_form FORMS,
         fnd_form_tl FORMSTL,
         fnd_form_functions_VL FUNC,
         fnd_menu_entries_VL MENU,
         FND_MENUS FM,
         fnd_responsibility RES,
         fnd_responsibility_vl RESTL,
         apps.fnd_profile_options_vl fpo,
         apps.fnd_profile_option_values fpov,
         apps.hr_organization_units hou
   WHERE     1 = 1
         AND fpov.profile_option_value = TO_CHAR (hou.organization_id)
         AND fpo.profile_option_id = fpov.profile_option_id
         AND fpo.user_profile_option_name = 'MO: Operating Unit'
         AND RESTL.responsibility_id = fpov.level_value
         AND hou.NAME = 'CCL2'
         AND forms.form_id = formstl.form_id
         AND func.form_id = forms.form_id
         AND menu.function_id = func.function_id
         AND menu.menu_id = fm.menu_id
         AND res.menu_id = menu.menu_id
         AND res.responsibility_id = restl.responsibility_id
         AND UPPER (forms.form_name) LIKE '%XX%'
ORDER BY 1