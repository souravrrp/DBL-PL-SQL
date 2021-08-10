/* Formatted on 8/9/2021 12:42:47 PM (QP5 v5.354) */
SELECT logfile_name
  FROM fnd_concurrent_requests
 WHERE request_id = 21133312;

--------------------------------------------------------------------------------

SELECT fcpp.concurrent_request_id req_id, fcp.node_name, fcp.logfile_name
  FROM apps.fnd_conc_pp_actions fcpp, apps.fnd_concurrent_processes fcp
 WHERE     fcpp.processor_id = fcp.concurrent_process_id
       --AND fcpp.action_type = 6
       AND fcpp.concurrent_request_id = '21133312';