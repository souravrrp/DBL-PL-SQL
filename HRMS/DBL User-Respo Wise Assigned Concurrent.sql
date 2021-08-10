SELECT --distinct
       rg.application_id                    "Application ID",
       fat.application_name                 "Application Name",
       fa.application_short_name            "Application Short Name",
       fa.basepath                          "Basepath",
       rv.responsibility_name               "Responsibility Name",
       rg.request_group_name                "Request Group Name",
       cpt.user_concurrent_program_name     "Concurrent Program Name",
       DECODE(rgu.request_unit_type,
              'P', 'Program',
              'S', 'Set',
              rgu.request_unit_type)        "Unit Type",
       cp.concurrent_program_name           "Concurrent Program Short Name"
       --,rgu.*
  FROM fnd_request_groups          rg,
       fnd_request_group_units     rgu,
       fnd_concurrent_programs     cp,
       fnd_concurrent_programs_tl  cpt,
       fnd_application             fa,
       fnd_application_tl          fat
       ,apps.fnd_responsibility_vl rv
 WHERE rg.request_group_id       =  rgu.request_group_id
   AND rgu.request_unit_id       =  cp.concurrent_program_id
   AND cp.concurrent_program_id  =  cpt.concurrent_program_id
   AND rg.application_id         =  fat.application_id
   AND fa.application_id         =  fat.application_id
   AND cpt.language              =  USERENV('LANG')
   AND fat.language              =  USERENV('LANG')
   AND fa.zd_edition_name        =  'SET2'
   AND fat.zd_edition_name       =  'SET2'
   AND rg.zd_edition_name        =  'SET2'
   AND cpt.zd_edition_name       =  'SET2'
   AND cp.zd_edition_name        =  'SET2'
   AND rgu.zd_edition_name       =  'SET2'
   AND rv.request_group_id       =  rgu.request_group_id
   and rv.application_id         =  rgu.application_id
   AND     (:p_responsibility_name IS NULL OR (UPPER (rv.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
   --AND cpt.user_concurrent_program_name in ('DBL AR Invoice Details')
   --AND ((:P_CONCURRENT_PROGRAM_NAME IS NULL) OR (UPPER (cpt.user_concurrent_program_name) = UPPER (:P_CONCURRENT_PROGRAM_NAME)))
   AND     ((:p_concurrent_program_name IS NULL) OR (UPPER(cpt.user_concurrent_program_name) LIKE UPPER('%'||:p_concurrent_program_name||'%') ))
   AND EXISTS(SELECT 1 FROM apps.fnd_user_resp_groups_direct  urgd, apps.fnd_user fu
   WHERE  urgd.user_id = fu.user_id(+)
   AND urgd.responsibility_id = rv.responsibility_id
   AND ( :p_user_name IS NULL OR (UPPER (fu.user_name) = UPPER ( :p_user_name))));