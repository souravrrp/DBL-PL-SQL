/* Formatted on 4/29/2020 2:48:37 PM (QP5 v5.287) */
  SELECT fl.meaning,
         fcp.process_status_code,
         DECODE (fcq.concurrent_queue_name,
                 'WFMLRSVC', 'maile r container',
                 'WFALSNRSVC', 'listener container',
                 fcq.concurrent_queue_name),
         fcp.concurrent_process_id,
         os_process_id,
         fcp.logfile_name
    FROM fnd_concurrent_queues fcq,
         fnd_concurrent_processes fcp,
         fnd_lookups fl
   WHERE     fcq.concurrent_queue_id = fcp.concurrent_queue_id
         AND fcp.process_status_code = 'A'
         AND fl.lookup_type = 'CP_PROCESS_STATUS_CODE'
         AND fl.lookup_code = fcp.process_status_code
         AND concurrent_queue_name IN ('WFMLRSVC')
ORDER BY fcp.logfile_name;

select running_processes
    from apps.fnd_concurrent_queues
   where concurrent_queue_name = 'WFMLRSVC';
   
   select component_status
    from apps.fnd_svc_components
   where component_id =
        (select component_id
           from apps.fnd_svc_components
          where component_name = 'Workflow Notification Mailer');
          
          
          
          
            Possible values:
  RUNNING
  STARTING
  STOPPED_ERROR
  DEACTIVATED_USER
  DEACTIVATED_SYSTEM
 Stop notification mailer
  sqlplus apps/<apps password>
  declare
       p_retcode number;
       p_errbuf varchar2(100);
       m_mailerid fnd_svc_components.component_id%TYPE;
  begin
       -- Find mailer Id
       -----------------
       select component_id
         into m_mailerid
         from fnd_svc_components
        where component_name = 'Workflow Notification Mailer';
       --------------
       -- Stop Mailer
       --------------
       fnd_svc_component.stop_component(m_mailerid, p_retcode, p_errbuf);
       commit;
  end;
  /
Start notification mailer
  sqlplus apps/<apps password>
  declare
       p_retcode number;
       p_errbuf varchar2(100);
       m_mailerid fnd_svc_components.component_id%TYPE;
  begin
       -- Find mailer Id
       -----------------
       select component_id
         into m_mailerid
         from fnd_svc_components
        where component_name = 'Workflow Notification Mailer';
       --------------
       -- Start Mailer
       --------------
       fnd_svc_component.start_component(m_mailerid, p_retcode, p_errbuf);
       commit;
  end;
  /