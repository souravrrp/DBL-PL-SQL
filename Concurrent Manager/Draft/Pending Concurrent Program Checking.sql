/* Formatted on 2/14/2021 2:55:54 PM (QP5 v5.354) */
  SELECT cwr.REQUEST_DESCRIPTION,
         COUNT (DISTINCT cwr.request_id)     Peding_Requests
    --,fu.user_name
    FROM apps.fnd_concurrent_worker_requests cwr,
         apps.fnd_concurrent_queues_tl      cq,
         apps.fnd_user                      fu
   WHERE     (cwr.phase_code = 'P' OR cwr.phase_code = 'R')
         AND cwr.hold_flag != 'Y'
         AND cwr.requested_start_date <= SYSDATE
         AND cwr.concurrent_queue_id = cq.concurrent_queue_id
         AND cwr.queue_application_id = cq.application_id
         AND cq.LANGUAGE = 'US'
         AND cwr.requested_by = fu.user_id
         --and fu.user_name='25414'
         AND cq.user_concurrent_queue_name IN
                 (SELECT UNIQUE user_concurrent_queue_name
                    FROM apps.fnd_concurrent_queues_tl)
GROUP BY cwr.REQUEST_DESCRIPTION
--,fu.user_name
;

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