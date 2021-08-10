/* Formatted on 7/7/2019 2:43:43 PM (QP5 v5.287) */
SELECT 'ICM_LOG_NAME=' || fcp.logfile_name
  FROM fnd_concurrent_processes fcp, fnd_concurrent_queues fcq
 WHERE     fcp.concurrent_queue_id = fcq.concurrent_queue_id
       AND fcp.queue_application_id = fcq.application_id
       AND fcq.manager_type = '0'
       AND fcp.process_status_code = 'A';

--------------------------------------------------------------------------------to check the setting of the ICM in the Concurrent Manager environment

SELECT 'PCP' "name", VALUE
  FROM apps.fnd_env_context
 WHERE     variable_name = 'APPLDCP'
       AND concurrent_process_id = (SELECT MAX (concurrent_process_id)
                                      FROM apps.fnd_concurrent_processes
                                     WHERE concurrent_queue_id = 1)
UNION ALL
SELECT 'RAC' "name", DECODE (COUNT (*),  0, 'N',  1, 'N',  'Y') "value"
  FROM V$thread
UNION ALL
SELECT 'GSM' "name", NVL (v.profile_option_value, 'N') "value"
  FROM apps.fnd_profile_options p, apps.fnd_profile_option_values v
 WHERE     p.profile_option_name = 'CONC_GSM_ENABLED'
       AND p.profile_option_id = v.profile_option_id
UNION ALL
SELECT name, VALUE
  FROM apps.fnd_concurrent_queue_params
 WHERE queue_application_id = 0 AND concurrent_queue_id = 1;


 --------------------------------------------------------------------------------to check the details for all the enabled Concurrent Manager

SELECT fcq.application_id "Application Id",
       fcq.concurrent_queue_name,
       fcq.user_concurrent_queue_name "Service",
       fa.application_short_name,
       fcq.target_node "Node",
       fcq.max_processes "Target",
       fcq.node_name "Primary",
       fcq.node_name2 "Secondary",
       fcq.cache_size "Cache Size",
       fcp.concurrent_processor_name "Program Library",
       sleep_seconds
  FROM apps.fnd_concurrent_queues_vl fcq,
       apps.fnd_application fa,
       apps.fnd_concurrent_processors fcp
 WHERE     fcq.application_id = fa.application_id
       AND fcq.processor_application_id = fcp.application_id
       AND fcq.concurrent_processor_id = fcp.concurrent_processor_id
       AND fcq.enabled_flag = 'Y';

--------------------------------------------------------------------------------to check/find  the shift/max/min for All the concurrent Manager

SELECT fcq.application_id,
       fcq.concurrent_queue_name,
       fcq.user_concurrent_queue_name,
       ftp.application_id,
       ftp.concurrent_time_period_name,
       fa.application_short_name,
       ftp.description,
       fcqs.min_processes,
       fcqs.max_processes,
       fcqs.sleep_seconds,
       fcqs.service_parameters
  FROM apps.fnd_concurrent_queues_vl fcq,
       apps.fnd_concurrent_queue_size fcqs,
       apps.fnd_concurrent_time_periods ftp,
       apps.fnd_application fa
 WHERE     fcq.application_id = fcqs.queue_application_id
       AND fcq.concurrent_queue_id = fcqs.concurrent_queue_id
       AND fcqs.period_application_id = ftp.application_id
       AND fcqs.concurrent_time_period_id = ftp.concurrent_time_period_id
       AND ftp.application_id = fa.application_id;

--------------------------------------------------------------------------------to check all the values of Concurrent Manager related Site level profiles and there lookup

SELECT fpo.profile_option_name,
       fpo.profile_option_id,
       fpov.profile_option_value,
       fpov.level_id,
       fa.application_short_name,
       fpo.user_profile_option_name,
       fpo.sql_validation,
       fpo.description
  FROM apps.FND_PROFILE_OPTIONS_VL fpo,
       apps.FND_PROFILE_OPTION_VALUES fpov,
       apps.fnd_application fa
 WHERE     fpo.application_id = 0
       AND fpo.site_enabled_flag = 'Y'
       AND (   fpo.profile_option_name LIKE 'CONC_%'
            OR fpo.profile_option_name LIKE 'FS_%'
            OR fpo.profile_option_name LIKE 'PRINTER%'
            OR fpo.profile_option_name IN ('EDITOR_CHAR',
                                           'FNDCPVWR_FONT_SIZE',
                                           'MAX_PAGE_LENGTH',
                                           'APPLWRK'))
       AND fpo.profile_option_id = fpov.profile_option_id
       AND fpo.application_id = fpov.application_id
       AND fpo.application_id = fa.application_id
       AND fpov.level_id = 10001;

--------------------------------------------------------------------------------To check the status all the manager in the system from backend/ query to check concurrent manager status from backend

SELECT q.user_concurrent_queue_name service_name,
       a.application_name srvc_app_name,
       a.application_short_name srvc_app_short_name,
       q.concurrent_queue_name service_short_name,
       DECODE (
          (SELECT COUNT (*)
             FROM apps.fnd_concurrent_processes fcp1
            WHERE     fcp1.concurrent_queue_id = q.concurrent_queue_id
                  AND fcp1.queue_application_id = q.application_id
                  AND (   fcp1.process_status_code IN ('C', 'M')
                       OR (    fcp1.process_status_code IN ('A', 'D', 'T')
                           AND EXISTS
                                  (SELECT 1
                                     FROM gv$session
                                    WHERE fcp1.session_id = audsid)))) /*actual_processes */
                                                                      ,
          0, DECODE (q.max_processes, 0, 'NOT_STARTED', 'DOWN'),
          q.max_processes, 'UP',
          'WARNING')
          service_status,
       q.max_processes target_processes,
       (SELECT COUNT (*)
          FROM apps.fnd_concurrent_processes fcp2
         WHERE     fcp2.concurrent_queue_id = q.concurrent_queue_id
               AND fcp2.queue_application_id = q.application_id
               AND (   fcp2.process_status_code IN ('C', 'M') /* Connecting or Migrating */
                    OR (    fcp2.process_status_code IN ('A', 'D', 'T')
                        AND EXISTS
                               (SELECT 1
                                  FROM gv$session
                                 WHERE fcp2.session_id = audsid))))
          actual_processes,
       '' MESSAGE,
       s.service_handle srvc_handle
  FROM apps.fnd_concurrent_queues_vl q,
       apps.fnd_application_vl a,
       apps.fnd_cp_services s
 WHERE q.application_id = a.application_id AND s.service_id = q.manager_type
UNION
/* Need to cover the case where a manager has no rows in FND_CONCURRENT_PROCESSES. Outer joins won't cut it. */
SELECT q.user_concurrent_queue_name service_name,
       a.application_name srvc_app_name,
       a.application_short_name srvc_app_short_name,
       q.concurrent_queue_name srvc_short_name,
       DECODE (q.max_processes, 0, 'NOT_STARTED', 'DOWN') service_status,
       q.max_processes target_processes,
       0 actual_processes,
       '' MESSAGE,
       s.service_handle srvc_handle
  FROM apps.fnd_concurrent_queues_vl q,
       apps.fnd_application_vl a,
       apps.fnd_cp_services s
 WHERE     q.application_id = a.application_id
       AND s.service_id = q.manager_type
       AND NOT EXISTS
              (SELECT 1
                 FROM apps.fnd_concurrent_processes p
                WHERE     process_status_code IN ('C',
                                                  'M',
                                                  'A',
                                                  'D',
                                                  'T')
                      AND q.concurrent_queue_id = p.concurrent_queue_id
                      AND q.application_id = p.queue_application_id);



--------------------------------------------------------------------------------To check All the running jobs with DB session details on the current DB node

  SELECT fcrv.request_id REQUEST,
         DECODE (fcrv.phase_code,
                 'P', 'Pending',
                 'R', 'Running',
                 'I', 'Inactive',
                 'Completed')
            PHASE,
         DECODE (fcrv.status_code,
                 'A', 'Waiting',
                 'B', 'Resuming',
                 'C', 'Normal',
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
                 'Z', 'Waiting',
                 fcrv.status_code)
            STATUS,
         SUBSTR (fcrv.program, 1, 25) PROGRAM,
         SUBSTR (fcrv.requestor, 1, 9) REQUESTOR,
         TO_CHAR (fcrv.actual_start_date, 'MM/DD/RR HH24:MI') START_TIME,
         ROUND ( ( (SYSDATE - fcrv.actual_start_date) * 1440), 2) RUN_TIME,
         SUBSTR (fcr.oracle_process_id, 1, 7) OSPID,
         vs.sid SID
    --substr(fcr.os_process_id,1,7)OS_PID
    FROM apps.fnd_conc_req_summary_v fcrv,
         apps.fnd_concurrent_requests fcr,
         v$session vs,
         v$process vp
   WHERE     fcrv.phase_code = 'R'
         AND fcrv.request_id = fcr.request_id
         AND fcr.oracle_process_id = vp.spid
         AND vs.paddr = vp.addr
ORDER BY PHASE, STATUS, REQUEST DESC;

--------------------------------------------------------------------------------To find the sid from the request id

SELECT s.inst_id,
       fcr.request_id,
       fv.requestor,
       fv.Program cmgr_job,
       p.PID,
       p.SERIAL#,
       p.USERNAME p_user,
       p.SPID,
       TO_CHAR (s.logon_time, 'DD-MON-YY HH24:MI:SS') Logon_Time,
       s.program,
       s.command,
       s.sid,
       s.serial#,
       s.username,
       s.process,
       s.machine,
       s.action,
       s.module
  FROM apps.fnd_concurrent_requests fcr,
       apps.FND_CONC_REQ_SUMMARY_V fv,
       gv$session s,
       gv$process p
 WHERE     1 = 1
       AND fcr.request_id = &request_id
       AND p.SPID = fcr.oracle_process_id
       AND s.process = fcr.OS_PROCESS_ID
       AND s.inst_id = p.inst_id
       AND p.addr = s.paddr
       AND fv.request_id = fcr.request_id;

--------------------------------------------------------------------------------find Pending request in all Concurrent Manager/query to find pending concurrent requests

  SELECT request_id, b.user_concurrent_queue_name
    FROM apps.fnd_concurrent_worker_requests a, apps.fnd_concurrent_queues_vl b
   WHERE     a.phase_code = 'P'
         AND a.status_code = 'I'
         AND a.hold_flag != 'Y'
         AND a.requested_start_date <= SYSDATE
         AND a.concurrent_queue_id = b.concurrent_queue_id
         AND a.control_code IS NULL
         --and a.concurrent_queue_name != 'FNDCRM'
         AND a.concurrent_queue_name NOT IN ('FNDCRM')
ORDER BY request_id, b.user_concurrent_queue_name;

--------------------------------------------------------------------------------

SELECT    'Concurrent program '
       || fcp.concurrent_program_name
       || ' is '
       || DECODE (fcqc.include_flag,
                  'I', 'included in ',
                  'E', 'excluded from ')
       || fcqv.user_concurrent_queue_name
          specialization_rule_details
  FROM fnd_concurrent_queues_vl fcqv,
       fnd_concurrent_queue_content fcqc,
       fnd_concurrent_programs fcp
 WHERE     fcqv.concurrent_queue_id = fcqc.concurrent_queue_id
       AND fcqc.type_id = fcp.concurrent_program_id
       AND fcp.concurrent_program_name = '<PROGRAM_SHORT_NAME>';