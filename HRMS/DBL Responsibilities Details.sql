/* Formatted on 11/7/2020 11:14:49 AM (QP5 v5.354) */
------------------------------MODULE_WISE_RESPONSIBILITY_DETAILS----------------
SELECT rv.application_id,
       fa.application_short_name     module_name,
       fa.application_name,
       rv.responsibility_id,
       rv.responsibility_key,
       rv.responsibility_name,
       rv.description,
       rg.request_group_name,
       fmv.menu_name,
       fmv.user_menu_name,
       rv.start_date,
       rv.end_date
       --,FA.*
       --,RV.*
       ,RG.*
  FROM apps.fnd_responsibility_vl  rv,
       apps.fnd_application_vl     fa,
       fnd_request_groups          rg,
       fnd_menus_vl                fmv
 WHERE     1 = 1
       AND rv.application_id = fa.application_id(+)
       AND rv.menu_id = fmv.menu_id
       AND (   :p_responsibility_name IS NULL OR (UPPER (rv.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
       AND (   :p_application_name IS NULL OR (UPPER (fa.application_name) LIKE UPPER ('%' || :p_application_name || '%')))
       AND (   :p_module_name IS NULL OR (UPPER (fa.application_short_name) = UPPER ( :p_module_name)))
       --AND SYSDATE BETWEEN START_DATE AND END_DATE
       --AND RV.responsibility_name IN ('Inventory')
       AND rv.request_group_id = rg.request_group_id(+)
       AND rg.zd_edition_name = DECODE(rg.zd_edition_name,'SET1','SET2','SET2')
       --AND rv.application_id = rg.application_id
       --AND rg.zd_edition_name = NVL('SET1','SET2')
       AND rv.end_date IS NULL;



------------------------------RESPONSIBILITY_WISE_FORM_MENU---------------------

SELECT fr.responsibility_name,
       fme.prompt     prompt_name,
       ff.form_name,
       fm.menu_name,
       fff.function_name
  --,FM.*
  --,FF.*
  --,FFF.*
  FROM apps.fnd_menu_entries_vl    fme,
       apps.fnd_menus_vl           fm,
       apps.fnd_form_functions_vl  fff,
       apps.fnd_form_vl            ff,
       apps.fnd_responsibility_vl  fr
 WHERE     1 = 1
       --AND    ff.form_name = 'XXAKG_FUEL' --:p_fmb
       AND fff.form_id = ff.form_id
       AND fme.function_id = fff.function_id
       AND fm.menu_id = fme.menu_id
       AND fr.menu_id = fm.menu_id
       AND UPPER (fr.responsibility_name) LIKE
               UPPER ('%' || :p_reponsibility_name || '%')
       --AND (   :P_REPONSIBILITY_NAME IS NULL OR (UPPER (FR.RESPONSIBILITY_NAME) LIKE UPPER ('%'||:P_REPONSIBILITY_NAME||'%')))
       AND fme.prompt IS NOT NULL;
       
       
       
------------------------------OU_WISE_RESPONSIBILITY_DETAILS--------------------

  SELECT frv.responsibility_name, fpov.profile_option_value org_id, hou.NAME
    FROM apps.fnd_profile_options_vl   fpo,
         apps.fnd_responsibility_vl    frv,
         apps.fnd_profile_option_values fpov,
         apps.hr_organization_units    hou
   WHERE     1 = 1                                 
         AND fpov.profile_option_value = TO_CHAR (hou.organization_id)
         -- and hou.NAME = <OU Name>
         AND (   :p_ou_name IS NULL OR (UPPER (hou.name) = UPPER ( :p_ou_name)))
         AND (   :p_responsibility_name IS NULL OR (UPPER (frv.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
         AND fpo.profile_option_id = fpov.profile_option_id
         AND fpo.user_profile_option_name = 'MO: Operating Unit'
         AND frv.responsibility_id = fpov.level_value
ORDER BY frv.responsibility_name;