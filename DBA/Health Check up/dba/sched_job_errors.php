<?php session_start();?>
<html>
<head>
<title>Scheduler Job Errors</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Scheduler Job Errors</h2>
<br>
<hr>
<?php
require_once ('config.php');
require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
if (isset($_POST['pattern'])) $pattern = $_POST['pattern'];
elseif (isset($_POST['huser'])) $pattern =  $_POST['huser'];
else $pattern='';
if (isset($_POST['days'])) $days = $_POST['days'];
elseif (isset($_POST['hdays'])) $days =  $_POST['hdays'];
else $days=3;
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Owner pattern:', $pattern);
$form->addText("days", 'Days back:', $days);
$form->addHidden('huser',$pattern);
$form->addHidden('hdays',$days);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
if (empty($pattern)) exit;
// php_beautifier->setBeautify(false)
$SPACE = 'select owner,log_date,job_name,status,error#,actual_start_date
          from dba_scheduler_job_run_details
          where error#>0 and
                owner like upper(:PATTERN) and 
                log_date>=trunc(sysdate - :DAYS)
          order by log_date desc';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SPACE, array('PATTERN'=>$pattern,'DAYS'=>$days));
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</center>
</body>
</html>
