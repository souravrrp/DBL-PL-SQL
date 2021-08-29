SELECT cpt.user_concurrent_program_name     "Concurrent Program Name",
       DECODE(rgu.request_unit_type,
              'P', 'Program',
              'S', 'Set',
              rgu.request_unit_type)        "Unit Type",
       cp.concurrent_program_name           "Concurrent Program Short Name",
       rg.application_id                    "Application ID",
       rg.request_group_name                "Request Group Name",
       fat.application_name                 "Application Name",
       fa.application_short_name            "Application Short Name",
       fa.basepath                          "Basepath"
       --,rgu.*
       --,cp.*
  FROM fnd_request_groups          rg,
       fnd_request_group_units     rgu,
       fnd_concurrent_programs     cp,
       fnd_concurrent_programs_tl  cpt,
       fnd_application             fa,
       fnd_application_tl          fat
 WHERE rg.request_group_id       =  rgu.request_group_id
   AND rgu.request_unit_id       =  cp.concurrent_program_id
   AND cp.concurrent_program_id  =  cpt.concurrent_program_id
   AND rg.application_id         =  fat.application_id
   AND fa.application_id         =  fat.application_id
   AND cpt.language              =  USERENV('LANG')
   AND fat.language              =  USERENV('LANG')
   AND fat.zd_edition_name       =  DECODE(fat.zd_edition_name,'SET1','SET2','SET2')
   AND fa.zd_edition_name        =  DECODE(fa.zd_edition_name,'SET1','SET2','SET2')
   AND rg.zd_edition_name        =  DECODE(rg.zd_edition_name,'SET1','SET2','SET2')
   AND cpt.zd_edition_name       =  DECODE(cpt.zd_edition_name,'SET1','SET2','SET2')
   AND cp.zd_edition_name        =  DECODE(cp.zd_edition_name,'SET1','SET2','SET2')
   AND rgu.zd_edition_name       =  DECODE(rgu.zd_edition_name,'SET1','SET2','SET2')
   AND ((:P_REQUEST_GROUP_NAME IS NULL) OR (UPPER (rg.request_group_name) = UPPER (:P_REQUEST_GROUP_NAME)))
   --AND cpt.user_concurrent_program_name in ('DBL AR Invoice Details')
   --AND ((:P_CONCURRENT_PROGRAM_NAME IS NULL) OR (UPPER (cpt.user_concurrent_program_name) = UPPER (:P_CONCURRENT_PROGRAM_NAME)))
   AND ((:P_CONCURRENT_PROGRAM_NAME IS NULL) OR (UPPER(cpt.user_concurrent_program_name) LIKE UPPER('%'||:P_CONCURRENT_PROGRAM_NAME||'%')))
   AND cp.enabled_flag='Y';
   

--------------------------------------------------------------------------------

SELECT *
  FROM fnd_concurrent_programs_tl cpt
 WHERE     1 = 1
       AND cpt.user_concurrent_program_name =
           'DBL ECO Bill Statement (As PI)';


SELECT *
  FROM fnd_request_groups rg
 WHERE 1 = 1 AND rg.request_group_name = 'DBL_INV_VIEW';

SELECT *
  FROM fnd_request_group_units rgu
 WHERE 1 = 1 AND rgu.request_unit_id = 136378 --concurrent_program_id
 AND request_group_id = 1770;

--------------------------------------------------------------------------------

SELECT --distinct
       cpt.user_concurrent_program_name     "Concurrent Program Name",
       DECODE(rgu.request_unit_type,
              'P', 'Program',
              'S', 'Set',
              rgu.request_unit_type)        "Unit Type",
       cp.concurrent_program_name           "Concurrent Program Short Name",
       rg.application_id                    "Application ID",
       rg.request_group_name                "Request Group Name",
       rv.responsibility_name               "Responsibility Name",
       fat.application_name                 "Application Name",
       fa.application_short_name            "Application Short Name",
       fa.basepath                          "Basepath"
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
   AND fa.zd_edition_name        =  NVL('SET1','SET2')
   AND fat.zd_edition_name       =  NVL('SET1','SET2')
   AND rg.zd_edition_name        =  NVL('SET1','SET2')
   AND cpt.zd_edition_name       =  NVL('SET1','SET2')
   AND cp.zd_edition_name        =  NVL('SET1','SET2')
   AND rgu.zd_edition_name       =  NVL('SET1','SET2')
   AND rv.request_group_id       =  rgu.request_group_id
   and rv.application_id         =  rgu.application_id
   AND     (:p_responsibility_name IS NULL OR (UPPER (rv.responsibility_name) LIKE UPPER ('%' || :p_responsibility_name || '%')))
   --AND cpt.user_concurrent_program_name in ('DBL AR Invoice Details')
   --AND ((:P_CONCURRENT_PROGRAM_NAME IS NULL) OR (UPPER (cpt.user_concurrent_program_name) = UPPER (:P_CONCURRENT_PROGRAM_NAME)))
   AND     ((:p_concurrent_program_name IS NULL) OR (UPPER(cpt.user_concurrent_program_name) LIKE UPPER('%'||:p_concurrent_program_name||'%') ));