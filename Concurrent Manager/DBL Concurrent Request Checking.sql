/**************************************************************************
 *    PURPOSE: To find out information about a Concurrent Request         *
 **************************************************************************/
 SELECT fcrs.request_id,
         fcrs.requestor,
         apps.xx_com_pkg.get_emp_name_from_user_name(fcrs.requestor) requestor_name,
         frt.responsibility_name,
         fcrs.user_concurrent_program_name,
         fcrs.actual_start_date,
         fcrs.actual_completion_date, 
         FLOOR ( ( (NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) / 3600) || ':' || FLOOR ( ( ( (NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) - FLOOR ( ( ( NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) / 3600) * 3600) / 60) || ':' || ROUND ( ( ( (NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) - FLOOR ( ( ( NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) / 3600) * 3600 - ( FLOOR ( (  ( (  NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) - FLOOR ( ( ( NVL(fcrs.actual_completion_date,SYSDATE) - fcrs.actual_start_date) * 24 * 60 * 60) / 3600) * 3600) / 60) * 60))) "HOURS:MINUTES:SECONDS",
         fcrs.argument_text,
         DECODE (fcrs.status_code, 'A', 'Waiting', 'B', 'Resuming', 'C', 'Normal', 'D', 'Cancelled', 'E', 'Errored', 'F', 'Scheduled', 'G', 'Warning', 'H', 'On Hold', 'I', 'Normal', 'M', 'No Manager', 'Q', 'Standby', 'R', 'Normal', 'S', 'Suspended', 'T', 'Terminating', 'U', 'Disabled', 'W', 'Paused', 'X', 'Terminated', 'Z', 'Waiting', fcrs.status_code) "Status",
         DECODE (fcrs.phase_code, 'C', 'Completed', 'I', 'Inactive', 'R', 'Running', 'A', 'Active', fcrs.phase_code) "Phase Code",
         fcrs.completion_text,
         fcrs.responsibility_application_id,
         fcrs.save_output_flag,
         fcrs.request_date,
         DECODE (fcrs.execution_method_code, 'B', 'Request Set Stage Function', 'Q', 'SQL*Plus', 'H', 'Host', 'L', 'SQL*Loader', 'A', 'Spawned', 'I', 'PL/SQL Stored Procedure', 'P', 'Oracle Reports', 'S', 'Immediate', fcrs.execution_method_code) execution_method,
         fcrs.concurrent_program_id,
         fcrs.program_short_name,
         fcrs.printer,
         fcrs.parent_request_id
         --,frt.*
    FROM fnd_conc_req_summary_v fcrs, fnd_responsibility_tl frt
   WHERE     1 = 1
         AND (   :p_concurrent_program_name is null or (upper (fcrs.user_concurrent_program_name) like upper ('%' || :p_concurrent_program_name || '%')))
         AND ( ( :p_requestor_id IS NULL) OR (requestor = :p_requestor_id))
         AND ( ( :p_concurrent_phase IS NULL) OR (fcrs.phase_code = :p_concurrent_phase))
         AND trunc(fcrs.actual_start_date) between nvl(:p_report_date_from,trunc(fcrs.actual_start_date)) and nvl(:p_report_date_to,trunc(fcrs.actual_start_date))
         and ( ( :p_parameter is null) or (upper (fcrs.argument_text) like upper ('%' || :p_parameter || '%')))
         --AND frt.zd_edition_name =  NVL('SET1','SET2')
         AND NVL(frt.zd_edition_name,'SET2') =  DECODE(frt.zd_edition_name,'SET1','SET2','SET2')
         --AND user_concurrent_program_name IN( 'DBL Discrete Inventory Store Ledger')
         --AND argument_text LIKE '%'
         --AND requestor not in ('SYSADMIN','INVADMIN')
         --AND request_id = 9686914
         --AND fcrs.actual_start_date < SYSDATE
         --AND fcrs.phase_code = 'R'
         --AND fcrs.status_code not in ('P','D','Q','C','R')
         --AND trunc(fcrs.actual_start_date) =trunc(SYSDATE)
         --AND trunc(fcrs.actual_completion_date) = trunc(SYSDATE)
         AND frt.language = 'US'
         AND fcrs.responsibility_id = frt.responsibility_id
ORDER BY fcrs.actual_start_date DESC, fcrs.requestor ASC;