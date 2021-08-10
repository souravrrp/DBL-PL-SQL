/* Formatted on 2/13/2020 2:32:22 PM (QP5 v5.287) */
WITH sessions_inline
     AS (SELECT client_identifier user_name,
                (SELECT responsibility_name
                   FROM fnd_responsibility_vl
                  WHERE responsibility_key = SUBSTR (action,
                                                       INSTR (action,
                                                              '/',
                                                              1,
                                                              1)
                                                     + 1))
                   responsibility,
                DECODE (SUBSTR (module,
                                  INSTR (module,
                                         ':',
                                         1,
                                         2)
                                + 1,
                                  INSTR (module,
                                         ':',
                                         1,
                                         3)
                                - INSTR (module,
                                         ':',
                                         1,
                                         2)
                                - 1),
                        'frm', 'Forms Screen',
                        'wf', 'Workflow',
                        'cp', 'Concurrent Process',
                        'fwk', 'Self Service Page',
                        'bes', 'Business Event',
                        'gsm', 'Workflow')
                   usage_type,
                SUBSTR (module,
                          INSTR (module,
                                 ':',
                                 1,
                                 3)
                        + 1)
                   ebs_module,
                ses.*
           FROM v$session ses
          WHERE 1 = 1)
  SELECT obj.object_name,
         user_name,
         responsibility,
         usage_type,
         ebs_module,
         DECODE (usage_type,
                 'Forms Screen', DECODE (ebs_module,
                                         'FNDSCSGN', 'EBS Navigator',
                                         (SELECT user_form_name
                                            FROM fnd_form_vl
                                           WHERE form_name = ebs_module)))
            forms_screen,
         DECODE (
            usage_type,
            'Concurrent Process', (SELECT user_concurrent_program_name
                                     FROM fnd_concurrent_programs_vl
                                    WHERE concurrent_program_name = ebs_module))
            concurrent_program,
         DECODE (
            usage_type,
            'Concurrent Process', (SELECT user_concurrent_queue_name
                                     FROM fnd_concurrent_queues_vl
                                    WHERE concurrent_queue_name = ebs_module))
            concurrent_manager
    FROM sessions_inline ses, v$locked_object lck, all_objects obj
   WHERE lck.session_id = ses.sid AND obj.object_id = lck.object_id
ORDER BY ses.usage_type;