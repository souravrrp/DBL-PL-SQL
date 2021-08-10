    SELECT 
    frt.responsibility_name,
    fnu.user_name, 
    frg.request_group_name,
    fcpt.user_concurrent_program_name
    FROM apps.fnd_Responsibility fr, 
    apps.fnd_responsibility_tl frt,
    apps.fnd_request_groups frg, 
    apps.fnd_request_group_units frgu,
    apps.fnd_concurrent_programs_tl fcpt
    ,apps.fnd_user fnu
    ,apps.FND_USER_RESP_GROUPS_DIRECT grp
    WHERE frt.responsibility_id = fr.responsibility_id
    AND frg.request_group_id = fr.request_group_id
    AND frgu.request_group_id = frg.request_group_id
    AND fcpt.concurrent_program_id = frgu.request_unit_id
    AND frt.LANGUAGE = USERENV('LANG')
    AND fcpt.LANGUAGE = USERENV('LANG')
--    AND fcpt.user_concurrent_program_name ='AKC Move Order Report'-- :conc_prg_name
    AND FNU.USER_ID=grp.USER_ID
    AND frt.RESPONSIBILITY_ID=grp.RESPONSIBILITY_ID
    AND FNU.user_name='32053'
    AND frt.RESPONSIBILITY_NAME='AKG RMC Pricing Manager'
    ORDER BY 1,2,3,4

------------------------------------------------------------------------------------------------
            
      SELECT frt.responsibility_name,
               frg.request_group_name,
               frg.description
  FROM fnd_request_groups frg
             ,fnd_request_group_units frgu
             ,fnd_concurrent_programs fcp
             ,fnd_concurrent_programs_tl fcpt
             ,fnd_responsibility_tl frt
             ,fnd_responsibility frs
 WHERE frgu.unit_application_id = fcp.application_id
 AND   frgu.request_unit_id = fcp.concurrent_program_id
 AND   frg.request_group_id = frgu.request_group_id
 AND   frg.application_id = frgu.application_id
 AND   fcpt.source_lang = USERENV('LANG')
 AND   fcp.application_id = fcpt.application_id
 AND   fcp.concurrent_program_id = fcpt.concurrent_program_id
 AND   frs.application_id = frt.application_id
 AND   frs.responsibility_id = frt.responsibility_id
 AND   frt.source_lang = USERENV('LANG')
 AND   frs.request_group_id = frg.request_group_id
 AND   frs.application_id = frg.application_id
---- AND   fcp.concurrent_program_name = <shortname>
 AND   fcpt.user_concurrent_program_name LIKE 'AKG Rejected Tyre Report'
 
 
 
 SELECT fu.user_name,
  frt.responsibility_name,
  TO_CHAR(furg.start_date,'DD-MON-YYYY') start_date,
  furg.end_date
FROM fnd_user fu ,
  fnd_user_resp_groups_direct furg ,
  fnd_responsibility_vl frt
WHERE fu.user_id                 = furg.user_id
AND frt.responsibility_id        = furg.responsibility_id
AND frt.application_id           = furg.responsibility_application_id
AND NVL(furg.end_date,sysdate+1) > sysdate
AND NVL(frt.end_date,sysdate +1) > sysdate
AND NVL(fu.end_date,sysdate  +1) > sysdate
AND frt.responsibility_name      ='Application Developer'
            
            