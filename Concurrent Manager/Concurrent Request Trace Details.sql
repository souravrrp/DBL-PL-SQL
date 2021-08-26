/* Formatted on 8/25/2021 10:26:47 AM (QP5 v5.287) */
SELECT 'Request id: ' || request_id request_id,
       'Trace id: ' || oracle_Process_id oracle_Process_id,
       'Trace Flag: ' || req.enable_trace Trace_Flag,
          'Trace Name:
'
       || dest.VALUE
       || '/'
       || LOWER (dbnm.VALUE)
       || '_ora_'
       || oracle_process_id
       || '.trc' trace_file_name,
       'Prog. Name: ' || prog.user_concurrent_program_name concurrent_program_name,
          'File Name: '
       || execname.execution_file_name
       || execname.subroutine_name execution_name,
          'Status : '
       || DECODE (phase_code, 'R', 'Running')
       || '-'
       || DECODE (status_code, 'R', 'Normal')  concurrent_program_status,
       'SID Serial: ' || ses.sid || ',' || ses.serial# concurrent_sid_serial,
       'Module : ' || ses.module module_name
  FROM fnd_concurrent_requests req,
       v$session ses,
       v$process proc,
       v$parameter dest,
       v$parameter dbnm,
       fnd_concurrent_programs_vl prog,
       fnd_executables execname
 WHERE     req.request_id = &request
       AND req.oracle_process_id = proc.spid(+)
       AND proc.addr = ses.paddr(+)
       AND dest.name = 'user_dump_dest'
       AND dbnm.name = 'db_name'
       AND req.concurrent_program_id = prog.concurrent_program_id
       AND req.program_application_id = prog.application_id
       AND prog.application_id = execname.application_id
       AND prog.executable_id = execname.executable_id;