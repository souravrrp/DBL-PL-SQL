/* Formatted on 6/20/2021 4:33:36 PM (QP5 v5.287) */
-- Create the schedule.

BEGIN
   DBMS_SCHEDULER.create_schedule (
      schedule_name     => 'XXDBL_MVIEW_SCHEDULER',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=hourly; byminute=0',
      end_date          => NULL,
      comments          => 'Repeats hourly, on the hour, for ever.');
END;
/


BEGIN
   DBMS_SCHEDULER.create_job (
      job_name          => 'TEST_FULL_JOB_DEFINITION',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN DBMS_STATS.gather_schema_stats(''SCOTT''); END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=hourly; byminute=0',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/



BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'EXECUTE dbms_mview.refresh(''APPS.XXDBL_INV_CON_RPT_MVIEW'',method => ''C'',ATOMIC_REFRESH=>FALSE)',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=hourly; byminute=0',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/


--------------------------------------------------------------------------------

-- Display the schedule details.

SELECT owner, schedule_name FROM dba_scheduler_schedules;

--------------------------------------------------------------------------------

BEGIN
   SYS.DBMS_SCHEDULER.drop_schedule (schedule_name => 'XXDBL_MVIEW_SCHEDULER');
END;
/


BEGIN
   SYS.DBMS_SCHEDULER.DROP_JOB (job_name => 'APPS.XXDBL_MVIEW_SCHEDULER');
END;
/

--------------------------------------------------------------------------------

BEGIN
   DBMS_SCHEDULER.set_attribute (
      name        => 'APPS.XXDBL_MVIEW_SCHEDULER',
      attribute   => 'job_action',
      VALUE       => 'BEGIN EXECUTE dbms_mview.refresh(''APPS.XXDBL_INV_CON_RPT_MVIEW'',''C'',ATOMIC_REFRESH=>FALSE) END;');
END;
/


  SELECT *
    FROM all_scheduler_job_run_details
   WHERE 1 = 1 AND job_name = 'XXDBL_MVIEW_SCHEDULER'
ORDER BY actual_start_date DESC