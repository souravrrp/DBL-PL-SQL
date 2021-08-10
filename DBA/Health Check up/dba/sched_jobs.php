<?php ob_start(); session_start();?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2//EN">
<html>
<head>
<meta name="generator" content=
"HTML Tidy for Linux/x86 (vers 1st September 2004), see www.w3.org">
<title>Scheduler Jobs</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Scheduler Jobs</h2>
<br>
<hr>
<?php
require_once ('config.php');
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$DSN = $_SESSION['DSN'];
require_version(10);
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
if (!empty($_POST['owner'])) $owner = strtoupper($_POST['owner']);
else $owner = '%';
if (!empty($_POST['name'])) $name = strtoupper($_POST['name']);
else $name = '%';
if (!empty($_POST['program'])) $program = strtoupper($_POST['program']);
else $program = '%';
$attrib=array('OWNER'   => $owner,
              'NAME'    => $name,
              'PROGRAM' => $program);
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addText("owner", 'Owner Pattern:', $owner);
$form->addText("name", 'Name Pattern:', $name);
$form->addText("program", 'Program Pattern:', $program);
$form->addSubmit("submit", "Filter");
$form->display();
echo "<hr><br>";
//  php_beautifier->setBeautify(false);
$RUN = 'select rj.inst_id, 
               rj.session_id,
               rj.session_serial_num,
               rj.os_process_id,
               o.owner,
               o.object_name
        from gv$scheduler_running_jobs rj,dba_objects o
        where o.object_id=rj.job_id';
$SQL = 'select OWNER,JOB_NAME,JOB_TYPE,JOB_ACTION,PROGRAM_OWNER,PROGRAM_NAME,
               SCHEDULE_OWNER ,SCHEDULE_NAME,SCHEDULE_TYPE,REPEAT_INTERVAL,
               JOB_CLASS,ENABLED,STATE,FAILURE_COUNT,LAST_START_DATE,
               LAST_RUN_DURATION,
               dba_helper.enable_job(OWNER,JOB_NAME)  "Job Maintenance"
        from dba_scheduler_jobs
        where OWNER        like upper(:OWNER) and
              JOB_NAME     like upper(:NAME) and (
              PROGRAM_NAME like upper(:PROGRAM) OR
              PROGRAM_NAME IS NULL) 
        order by job_name';
$SCHED = 'select * from dba_scheduler_schedules';
//  php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    print "<h2>Running Jobs</h2>";
    $rs = $db->Execute($RUN);
    csr2html($rs);
    print "<br><h2>Job Descriptions</h2>";
    $rs = $db->Execute($SQL,$attrib);
    csr2html($rs);
    print "<br><h2>Database Schedules</h2>";
    $rs = $db->Execute($SCHED);
    csr2html($rs);
    print "<br>";
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
