/* Formatted on 1/6/2022 4:03:31 PM (QP5 v5.374) */
SELECT fr.responsibility_name,
       fme.prompt     prompt_name,
       fm.menu_name,
       fff.function_name,
       ff.form_name
  --,fr.*
  --,fm.*
  --,fme.*
  --,fff.*
  --,ff.*
  FROM apps.fnd_responsibility_vl  fr,
       apps.fnd_menus_vl           fm,
       apps.fnd_menu_entries_vl    fme,
       apps.fnd_form_functions_vl  fff,
       apps.fnd_form_vl            ff
 WHERE     1 = 1
       AND fr.menu_id = fm.menu_id(+)
       AND fm.menu_id = fme.menu_id(+)
       AND fme.function_id = fff.function_id(+)
       AND fff.form_id = ff.form_id(+)
       AND (   :p_reponsibility_name is null or (upper (fr.responsibility_name) like upper ('%'||:p_reponsibility_name||'%')))
       AND (   :p_menu_name IS NULL OR (UPPER (fm.menu_name) LIKE UPPER ('%' || :p_menu_name || '%')))
       AND (   :p_function_name IS NULL OR (UPPER (fff.user_function_name) LIKE UPPER ('%' || :p_function_name || '%')))
       AND (   :p_form_name IS NULL OR (UPPER (ff.form_name) LIKE UPPER ('%' || :p_form_name || '%')))
       AND fme.prompt IS NOT NULL;

--------------------------------------------------------------------------------
  SELECT faa.application_name     application,
         rtl.responsibility_name,
         ffl.user_function_name,
         ff.function_name,
         ffl.description,
         ff.type,
         rtl.language
         --,cmf.*
         --,ff.*
         --,ffl.*
         --,r.*
         --,rtl.*
         --,faa.*
    FROM fnd_compiled_menu_functions cmf,
         fnd_form_functions         ff,
         fnd_form_functions_tl      ffl,
         fnd_responsibility         r,
         fnd_responsibility_tl      rtl,
         apps.fnd_application_vl    faa
   WHERE     cmf.function_id = ff.function_id
         AND r.menu_id = cmf.menu_id
         AND rtl.responsibility_id = r.responsibility_id
         AND cmf.grant_flag = 'Y'
         AND ff.function_id = ffl.function_id
         AND r.application_id = faa.application_id
         AND (   :p_responsibility_name IS NULL OR (UPPER (rtl.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
         --AND UPPER(rtl.responsibility_name) LIKE UPPER('%DBL Ceramic Order Management Super User%')
         AND (   :p_function_name IS NULL OR (UPPER (ffl.user_function_name) LIKE UPPER ('%' || :p_function_name|| '%')))
         AND r.end_date IS NULL
         AND rtl.language = 'US'
         AND NVL(ffl.zd_edition_name,'SET2') = DECODE(ffl.zd_edition_name,'SET1','SET2','SET2')
         AND NVL(r.zd_edition_name,'SET2') = DECODE(r.zd_edition_name,'SET1','SET2','SET2')
         AND NVL(rtl.zd_edition_name,'SET2') = DECODE(rtl.zd_edition_name,'SET1','SET2','SET2')
         AND NVL(ff.zd_edition_name,'SET2') = DECODE(ff.zd_edition_name,'SET1','SET2','SET2')
ORDER BY rtl.responsibility_name;

--------------------------------------------------------------------------------

 SELECT responsibility_name, menu_structure.PATH navigation
    FROM (           SELECT LEVEL                                    padding,
                            menu_id,
                            RTRIM (reverse (SYS_CONNECT_BY_PATH (reverse (prompt), '>')),
                                   '>')                              PATH,
                            (SELECT menu_name
                               FROM fnd_menus fm
                              WHERE fm.menu_id = fme.menu_id)        menu_name,
                            entry_sequence,
                            sub_menu_id,
                            (SELECT menu_name
                               FROM fnd_menus fm
                              WHERE fm.menu_id = fme.sub_menu_id)    submenu_name,
                            function_id
                       FROM fnd_menu_entries_vl fme
                 CONNECT BY sub_menu_id = PRIOR menu_id
                 START WITH function_id = :function_id
          ORDER SIBLINGS BY entry_sequence) menu_structure,
         fnd_responsibility_vl fr
   WHERE menu_structure.menu_id = fr.menu_id
ORDER BY 1;