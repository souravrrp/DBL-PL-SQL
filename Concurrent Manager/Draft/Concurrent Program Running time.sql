/* Formatted on 7/7/2019 5:17:24 PM (QP5 v5.287) */
  SELECT f.request_id,
         pt.user_concurrent_program_name user_concurrent_program_name,
         f.actual_start_date actual_start_date,
         f.actual_completion_date actual_completion_date,
            FLOOR (
                 (  (f.actual_completion_date - f.actual_start_date)
                  * 24
                  * 60
                  * 60)
               / 3600)
         || ' HOURS '
         || FLOOR (
                 (  (  (f.actual_completion_date - f.actual_start_date)
                     * 24
                     * 60
                     * 60)
                  -   FLOOR (
                           (  (f.actual_completion_date - f.actual_start_date)
                            * 24
                            * 60
                            * 60)
                         / 3600)
                    * 3600)
               / 60)
         || ' MINUTES '
         || ROUND (
               (  (  (f.actual_completion_date - f.actual_start_date)
                   * 24
                   * 60
                   * 60)
                -   FLOOR (
                         (  (f.actual_completion_date - f.actual_start_date)
                          * 24
                          * 60
                          * 60)
                       / 3600)
                  * 3600
                - (  FLOOR (
                          (  (  (f.actual_completion_date - f.actual_start_date)
                              * 24
                              * 60
                              * 60)
                           -   FLOOR (
                                    (  (  f.actual_completion_date
                                        - f.actual_start_date)
                                     * 24
                                     * 60
                                     * 60)
                                  / 3600)
                             * 3600)
                        / 60)
                   * 60)))
         || ' SECS '
            time_difference,
         DECODE (
            p.concurrent_program_name,
            'ALECDC', p.concurrent_program_name || '[' || f.description || ']',
            p.concurrent_program_name)
            concurrent_program_name,
         DECODE (f.phase_code,
                 'R', 'Running',
                 'C', 'Complete',
                 f.phase_code)
            Phase,
         f.status_code
    FROM apps.fnd_concurrent_programs p,
         apps.fnd_concurrent_programs_tl pt,
         apps.fnd_concurrent_requests f
   WHERE     f.concurrent_program_id = p.concurrent_program_id
         AND f.program_application_id = p.application_id
         AND f.concurrent_program_id = pt.concurrent_program_id
         AND f.program_application_id = pt.application_id
         AND pt.language = USERENV ('Lang')
         --AND f.actual_start_date IS NOT NULL
         and pt.USER_CONCURRENT_PROGRAM_NAME = 'Check Event Alert'
ORDER BY f.actual_completion_date - f.actual_start_date DESC;

--------------------------------------------------------------------------------

  SELECT fcr.oracle_session_id,
         fcr.request_id rqst_id,
         fcr.requested_by rqst_by,
         fu.user_name,
         fr.responsibility_name,
         fcr.concurrent_program_id cp_id,
         fcp.user_concurrent_program_name cp_name,
         TO_CHAR (fcr.actual_start_date, 'DD-MON-YYYY HH24:MI:SS')
            act_start_datetime,
         DECODE (fcr.status_code, 'R', 'R:Running', fcr.status_code) status,
         ROUND ( ( (SYSDATE - fcr.actual_start_date) * 60 * 24), 2) runtime_min,
         ROUND ( ( (SYSDATE - fcr.actual_start_date) * 60 * 60 * 24), 2)
            runtime_sec,
         fcr.oracle_process_id "oracle_pid/SPID",
         fcr.os_process_id os_pid,
         fcr.argument_text,
         fcr.outfile_name,
         fcr.logfile_name,
         fcr.enable_trace
    FROM apps.fnd_concurrent_requests fcr,
         apps.fnd_user fu,
         apps.fnd_responsibility_tl fr,
         apps.fnd_concurrent_programs_tl fcp
   WHERE     fcr.status_code LIKE 'R'
         AND fu.user_id = fcr.requested_by
         AND fr.responsibility_id = fcr.responsibility_id
         AND fcr.concurrent_program_id = fcp.concurrent_program_id
         AND fcr.program_application_id = fcp.application_id
         AND ROUND ( ( (SYSDATE - fcr.actual_start_date) * 60 * 24), 2) > 60
ORDER BY fcr.concurrent_program_id, request_id DESC;