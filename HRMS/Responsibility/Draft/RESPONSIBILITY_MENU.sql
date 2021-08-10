/* Formatted on 11/7/2020 10:43:58 AM (QP5 v5.287) */
SELECT FU.USER_NAME,
       FR.RESPONSIBILITY_NAME,
       FME.PROMPT PROMPT_NAME,
       FF.FORM_NAME,
       FM.MENU_NAME,
       FFF.FUNCTION_NAME,
       RES.START_DATE,
       RES.END_DATE
  --,FM.*
  --,FF.*
  --,FFF.*
  FROM APPS.FND_MENU_ENTRIES_VL FME,
       APPS.FND_MENUS_VL FM,
       APPS.FND_FORM_FUNCTIONS_VL FFF,
       APPS.FND_FORM_VL FF,
       APPS.FND_RESPONSIBILITY_VL FR,
       APPS.FND_USER FU,
       APPS.FND_USER_RESP_GROUPS_DIRECT RES
 WHERE     1 = 1
       AND RES.RESPONSIBILITY_ID = FR.RESPONSIBILITY_ID
       --AND    ff.form_name = 'XXAKG_FUEL' --:p_fmb
       AND FFF.FORM_ID = FF.FORM_ID
       AND FME.FUNCTION_ID = FFF.FUNCTION_ID
       AND FM.MENU_ID = FME.MENU_ID
       AND FR.MENU_ID = FM.MENU_ID
       AND UPPER (FR.RESPONSIBILITY_NAME) LIKE
              UPPER ('%' || :P_REPONSIBILITY_NAME || '%')
       --AND (   :P_REPONSIBILITY_NAME IS NULL OR (UPPER (FR.RESPONSIBILITY_NAME) LIKE UPPER ('%'||:P_REPONSIBILITY_NAME||'%')))
       AND ( :P_EMP_NUM IS NULL OR (FU.USER_NAME = :P_EMP_NUM))
       AND FR.RESPONSIBILITY_ID = RES.RESPONSIBILITY_ID(+)
       AND RES.USER_ID = FU.USER_ID(+)
       AND FME.PROMPT IS NOT NULL;

--------------------------------------------------------------------------------

    SELECT    NVL2 (fme.sub_menu_id, '+', '-')
           || LPAD (
                 NVL (
                    (SELECT prompt
                       FROM apps.fnd_menu_entries_vl
                      WHERE     menu_id = fme.menu_id
                            AND sub_menu_id = fme.sub_menu_id
                            AND fme.function_id IS NULL),
                    (SELECT prompt
                       FROM apps.fnd_menu_entries_vl
                      WHERE     menu_id = fme.menu_id
                            AND function_id = fme.function_id
                            AND fme.sub_menu_id IS NULL)),
                   LENGTH (
                      NVL (
                         (SELECT prompt
                            FROM apps.fnd_menu_entries_vl
                           WHERE     menu_id = fme.menu_id
                                 AND sub_menu_id = fme.sub_menu_id
                                 AND fme.function_id IS NULL),
                         (SELECT prompt
                            FROM apps.fnd_menu_entries_vl
                           WHERE     menu_id = fme.menu_id
                                 AND function_id = fme.function_id
                                 AND fme.sub_menu_id IS NULL)))
                 + (LEVEL * 5),
                 '-')
              tree_structure
      FROM apps.fnd_menu_entries fme
START WITH fme.menu_id =
              (SELECT menu_id
                 FROM apps.fnd_responsibility fr,
                      apps.fnd_responsibility_tl frt
                WHERE     fr.responsibility_id = frt.responsibility_id
                      AND frt.responsibility_name = :p_responsibility_name) -- 'Application Developer'
CONNECT BY PRIOR fme.sub_menu_id = fme.menu_id;

---------------------------------------------------------------------------------------------------------------------

  SELECT lvl r_lvl,
         rownumber rw_num,
         entry_sequence seq,
         (lvl || '.' || rownumber || '.' || entry_sequence) menu_seq,
         menu_name,
         sub_menu_name,
         prompt,
         fm.description,
         TYPE,
         function_name,
         user_function_name,
         fff.description form_description
    FROM (    SELECT LEVEL lvl,
                     ROW_NUMBER ()
                     OVER (PARTITION BY LEVEL, menu_id, entry_sequence
                           ORDER BY entry_sequence)
                        AS rownumber,
                     entry_sequence,
                     (SELECT user_menu_name
                        FROM apps.fnd_menus_vl fmvl
                       WHERE 1 = 1 AND fmvl.menu_id = fmv.menu_id)
                        menu_name,
                     (SELECT user_menu_name
                        FROM apps.fnd_menus_vl fmvl
                       WHERE 1 = 1 AND fmvl.menu_id = fmv.sub_menu_id)
                        sub_menu_name,
                     function_id,
                     prompt,
                     description
                FROM apps.fnd_menu_entries_vl fmv
          START WITH menu_id =
                        (SELECT menu_id
                           FROM apps.fnd_responsibility_vl
                          WHERE UPPER (responsibility_name) =
                                   UPPER ( :resp_name))
          CONNECT BY PRIOR sub_menu_id = menu_id) fm,
         apps.fnd_form_functions_vl fff
   WHERE fff.function_id(+) = fm.function_id
ORDER BY lvl, entry_sequence;


---------------------------------------------------------------------------------

SELECT frv.menu_id,
       (SELECT user_menu_name
          FROM apps.fnd_menus_vl fmvl
         WHERE 1 = 1 AND fmvl.menu_id = fmv.menu_id)
          menu_name,
       fmv.function_id,
       fmv.prompt,
       fmv.description,
       TYPE,
       function_name,
       user_function_name,
       fff.description form_description
  FROM apps.fnd_responsibility_vl frv,
       apps.fnd_menu_entries_vl fmv,
       apps.fnd_form_functions_vl fff
 WHERE     1 = 1
       AND UPPER (responsibility_name) = UPPER ( :resp_name)
       AND frv.menu_id = fmv.menu_id
       AND fmv.function_id = fff.function_id(+);