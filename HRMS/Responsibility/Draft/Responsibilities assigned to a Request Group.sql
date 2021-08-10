/* Formatted on 1/26/2020 11:30:25 AM (QP5 v5.287) */
  SELECT responsibility_name, request_group_name, frg.description
    FROM apps.fnd_request_groups frg, apps.fnd_responsibility_vl frv
   WHERE frv.request_group_id = frg.request_group_id
--AND request_group_name LIKE 'US SHRMS Reports % Processes'
--AND responsibility_name LIKE 'AKG Inventory -IT Support'
ORDER BY responsibility_name;

--------------------------------------------------------------------------------

SELECT frt.responsibility_name, frg.request_group_name, frg.description
  FROM fnd_request_groups frg,
       fnd_request_group_units frgu,
       fnd_concurrent_programs fcp,
       fnd_concurrent_programs_tl fcpt,
       fnd_responsibility_tl frt,
       fnd_responsibility frs
 WHERE     frgu.unit_application_id = fcp.application_id
       AND frgu.request_unit_id = fcp.concurrent_program_id
       AND frg.request_group_id = frgu.request_group_id
       AND frg.application_id = frgu.application_id
       AND fcpt.source_lang = USERENV ('LANG')
       AND fcp.application_id = fcpt.application_id
       AND fcp.concurrent_program_id = fcpt.concurrent_program_id
       AND frs.application_id = frt.application_id
       AND frs.responsibility_id = frt.responsibility_id
       AND frt.source_lang = USERENV ('LANG')
       AND frs.request_group_id = frg.request_group_id
       AND frs.application_id = frg.application_id
---- AND   fcp.concurrent_program_name = <shortname>
-- AND   fcpt.user_concurrent_program_name LIKE <User concurrent program>