/* Formatted on 2/3/2022 10:17:44 AM (QP5 v5.374) */
SELECT fav.application_short_name            appl_short_name,
       fav.application_name,
       fcpl.user_concurrent_program_name     "Concurrent Program Name",
       fl.meaning                            execution_method,
       fe.execution_file_name
  FROM apps.fnd_concurrent_programs     fcp,
       apps.fnd_concurrent_programs_vl  fcpl,
       apps.fnd_executables             fe,
       apps.fnd_lookups                 fl,
       apps.fnd_application_vl          fav
 WHERE     1 = 1
       AND fcp.concurrent_program_id = fcpl.concurrent_program_id(+)
       AND fcp.executable_id = fe.executable_id(+)
       AND fcp.enabled_flag = 'Y'
       AND fcp.application_id = fav.application_id(+)
       AND (   :p_appl_name IS NULL
            OR (UPPER (fav.application_name) LIKE
                    UPPER ('%' || :p_appl_name || '%')))
       AND fl.lookup_type(+) = 'CP_EXECUTION_METHOD_CODE'
       AND fcp.execution_method_code = fl.lookup_code(+);