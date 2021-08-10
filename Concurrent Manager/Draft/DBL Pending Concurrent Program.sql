/* Formatted on 2/14/2021 2:54:10 PM (QP5 v5.354) */
  SELECT DISTINCT
         c.USER_CONCURRENT_PROGRAM_NAME,
         ROUND (((SYSDATE - a.actual_start_date) * 24 * 60 * 60 / 60), 2)
             AS Process_time,
         a.request_id,
         a.parent_request_id,
         a.request_date,
         a.actual_start_date,
         a.actual_completion_date,
         (a.actual_completion_date - a.request_date) * 24 * 60 * 60
             AS end_to_end,
         (a.actual_start_date - a.request_date) * 24 * 60 * 60
             AS lag_time,
         d.user_name,
         a.phase_code,
         a.status_code,
         a.argument_text,
         a.priority
    FROM apps.fnd_concurrent_requests   a,
         apps.fnd_concurrent_programs   b,
         apps.FND_CONCURRENT_PROGRAMS_TL c,
         apps.fnd_user                  d
   WHERE     a.concurrent_program_id = b.concurrent_program_id
         AND b.concurrent_program_id = c.concurrent_program_id
         AND a.requested_by = d.user_id
         AND status_code = 'R' --USE THIS CONDITION IF YOU WANT TO SEE ONLY RUNNING REQUESTS--
ORDER BY Process_time DESC;

--------------------------------------------------------------------------------Background Process

  SELECT fcr.request_id,
         fcr.parent_request_id,
         fu.user_name
             requestor,
         TO_CHAR (fcr.requested_start_date, 'MON-DD-YYYY HH24:MM:SS')
             START_DATE,
         fr.responsibility_key
             responsibility,
         fcp.concurrent_program_name,
         fcpt.user_concurrent_program_name,
         DECODE (fcr.status_code,
                 'A', 'Waiting',
                 'B', 'Resuming',
                 'C', 'Normal',
                 'D', 'Cancelled',
                 'E', 'Error',
                 'F', 'Scheduled',
                 'G', 'Warning',
                 'H', 'On Hold',
                 'I', 'Normal',
                 'M', 'No Manager',
                 'Q', 'Standby',
                 'R', 'Normal',
                 'S', 'Suspended',
                 'T', 'Terminating',
                 'U', 'Disabled',
                 'W', 'Paused',
                 'X', 'Terminated',
                 'Z', 'Waiting')
             status,
         DECODE (fcr.phase_code,
                 'C', 'Completed',
                 'I', 'Inactive',
                 'P', 'Pending',
                 'R', 'Running')
             phase,
         fcr.completion_text
    FROM apps.fnd_concurrent_requests   fcr,
         apps.fnd_concurrent_programs   fcp,
         apps.fnd_concurrent_programs_tl fcpt,
         apps.fnd_user                  fu,
         apps.fnd_responsibility        fr
   WHERE     fcr.status_code IN ('Q', 'I')
         AND fcr.hold_flag = 'N'
         AND fcr.requested_start_date > SYSDATE
         AND fu.user_id = fcr.requested_by
         AND fcr.concurrent_program_id = fcp.concurrent_program_id
         AND fcr.concurrent_program_id = fcpt.concurrent_program_id
         AND fcr.responsibility_id = fr.responsibility_id
ORDER BY fcr.requested_start_date, fcr.request_id;