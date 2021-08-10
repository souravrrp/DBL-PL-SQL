/* Formatted on 3/23/2021 11:25:47 AM (QP5 v5.354) */
  SELECT rs.user_request_set_name            "Request Set",
         rss.display_sequence                seq,
         cp.user_concurrent_program_name     "Concurrent Program",
         e.executable_name,
         e.execution_file_name,
         lv.meaning                          file_type,
         fat.application_name                "Application Name"
    --,rs.*
    --,rss.*
    --,rsp.*
    --,cp.*
    --,e.*
    --,lv.*
    --,fat.*
    FROM fnd_request_sets_vl       rs,
         fnd_req_set_stages_form_v rss,
         fnd_request_set_programs  rsp,
         fnd_concurrent_programs_vl cp,
         fnd_executables           e,
         fnd_lookup_values         lv,
         fnd_application_tl        fat
   WHERE     1 = 1
         AND rs.application_id = rss.set_application_id
         AND rs.request_set_id = rss.request_set_id
         AND rs.user_request_set_name = :p_request_set_name
         AND e.application_id = fat.application_id
         AND rss.set_application_id = rsp.set_application_id
         AND rss.request_set_id = rsp.request_set_id
         AND rss.request_set_stage_id = rsp.request_set_stage_id
         AND rsp.program_application_id = cp.application_id
         AND rsp.concurrent_program_id = cp.concurrent_program_id
         AND cp.executable_id = e.executable_id
         AND cp.executable_application_id = e.application_id
         AND lv.lookup_type = 'CP_EXECUTION_METHOD_CODE'
         AND lv.lookup_code = e.execution_method_code
         AND lv.LANGUAGE = 'US'
         AND fat.LANGUAGE = 'US'
         --AND fat.zd_edition_name = 'SET1'
         --AND rsp.zd_edition_name = 'SET1'
         AND DECODE (fat.zd_edition_name, 'SET2', 'SET1') = 'SET1'
         AND DECODE (rsp.zd_edition_name, 'SET2', 'SET1') = 'SET1'
         AND e.zd_edition_name = 'SET1'
         AND lv.zd_edition_name = 'SET1'
         AND rs.end_date_active IS NULL
ORDER BY 1, 2;

-- Starting OF Script TO find THE request SET assigned TO A responsibility

  SELECT frt.responsibility_name,
         fcpt.user_request_set_name,
         frst.request_set_stage_id,
         frst.user_stage_name
    --,frst.*
    FROM apps.fnd_Responsibility     fr,
         apps.fnd_responsibility_tl  frt,
         apps.fnd_request_groups     frg,
         apps.fnd_request_group_units frgu,
         apps.fnd_request_Sets_tl    fcpt,
         fnd_request_set_stages_tl   frst
   WHERE     frt.responsibility_id = fr.responsibility_id
         AND frg.request_group_id = fr.request_group_id
         AND frgu.request_group_id = frg.request_group_id
         AND fcpt.request_set_id = frgu.request_unit_id
         AND frst.request_set_id = fcpt.request_set_id
         AND frst.LANGUAGE = fcpt.LANGUAGE
         AND frt.LANGUAGE = USERENV ('LANG')
         AND fcpt.LANGUAGE = USERENV ('LANG')
         AND frst.zd_edition_name = 'SET1'
         AND fcpt.user_request_set_name = :request_set_name
ORDER BY frt.responsibility_name,
         frst.request_set_stage_id,
         fcpt.user_request_set_name,
         frst.user_stage_name;



--------------------------------------------------------------------------------


  SELECT frt.responsibility_name,
         frg.request_group_name,
         frgu.request_unit_type,
         frgu.request_unit_id,
         fcpt.user_request_set_name
    FROM apps.fnd_Responsibility     fr,
         apps.fnd_responsibility_tl  frt,
         apps.fnd_request_groups     frg,
         apps.fnd_request_group_units frgu,
         apps.fnd_request_Sets_tl    fcpt
   WHERE     frt.responsibility_id = fr.responsibility_id
         AND frg.request_group_id = fr.request_group_id
         AND frgu.request_group_id = frg.request_group_id
         AND fcpt.request_set_id = frgu.request_unit_id
         AND frt.LANGUAGE = USERENV ('LANG')
         AND fcpt.LANGUAGE = USERENV ('LANG')
         AND fcpt.user_request_set_name = :request_set_name
ORDER BY 1,
         2,
         3,
         4;


-----------------------Request Set Run Details----------------------------------


SELECT DISTINCT
       r.request_id,
       u.user_name                                                     requestor,
       u.description                                                   requested_by,
       CASE
           WHEN pt.user_concurrent_program_name = 'Report Set'
           THEN
               DECODE (
                   r.description,
                   NULL, pt.user_concurrent_program_name,
                      r.description
                   || ' ('
                   || pt.user_concurrent_program_name
                   || ')')
           ELSE
               pt.user_concurrent_program_name
       END                                                             job_name,
       u.email_address,
       frt.responsibility_name                                         requested_by_resp,
       r.request_date,
       r.requested_start_date,
       DECODE (r.hold_flag,  'Y', 'Yes',  'N', 'No')                   on_hold,
       r.printer,
       r.number_of_copies                                              print_count,
       r.argument_text                                                 PARAMETERS,
       r.resubmit_interval                                             resubmit_every,
       r.resubmit_interval_unit_code                                   resubmit_time_period,
       TO_CHAR ((r.requested_start_date), 'HH24:MI:SS')                start_time,
       NVL2 (r.resubmit_interval,
             'Periodically',
             NVL2 (r.release_class_id, 'On specific days', 'Once'))    AS schedule_type
  FROM apps.fnd_user                    u,
       apps.fnd_printer_styles_tl       s,
       apps.fnd_concurrent_requests     r,
       apps.fnd_responsibility_tl       frt,
       apps.fnd_concurrent_programs_tl  pt,
       apps.fnd_concurrent_programs     pb
 WHERE     pb.application_id = r.program_application_id
       AND r.responsibility_id = frt.responsibility_id
       AND pb.concurrent_program_id = pt.concurrent_program_id
       AND u.user_id = r.requested_by
       AND s.printer_style_name(+) = r.print_style
       AND pb.concurrent_program_id = r.concurrent_program_id
       AND pb.application_id = pt.application_id
       AND pt.user_concurrent_program_name = 'Report Set';