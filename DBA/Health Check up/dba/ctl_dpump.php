<?php ob_start(); session_start();?>
<html>
<head>
<title>Control Datapump  Job</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Control Datapump  Job <?=$_REQUEST['own']?>.<?=$_REQUEST['job']?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$INVOKER=$_SESSION['invoker'];
$DSN = $_SESSION['DSN'];
$db = NewADOConnection("oci8");

if (!empty($_GET['own'])) $USR = $_GET['own'];
else $USR = $_POST['own'];
if (!empty($_GET['job'])) $JOB = $_GET['job'];
else $JOB = $_POST['job'];

if (empty($_POST['action'])) {
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(1);
    $form->addHidden('own', $USR);
    $form->addHidden('job', $JOB);
    $form->addSubmit("action", "Stop");
    $form->addSubmit("action", "Start");
    $form->addSubmit("action", "Kill");
    $form->addBlank(1);
    $form->display();
    exit;
} else $action = $_POST['action'];
# php_beautifier->setBeautify(false)
$STOP =  "declare
          jobno number;
          begin
             jobno:=dbms_datapump.attach('$JOB','$USR');
             dbms_datapump.stop_job(jobno,1,1,60);
          end;";
$START=  "declare
          jobno number;
          begin
             jobno:=dbms_datapump.attach('$JOB','$USR');
             dbms_datapump.start_job(jobno);
          end;";
$KILL =  "declare
          jobno number;
          begin
             jobno:=dbms_datapump.attach('$JOB','$USR');
             dbms_datapump.stop_job(jobno,1,0,60);
          end;";
# php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    switch($action) {
        case "Stop":
            $db->Execute($STOP);
            break;
        case "Kill":
            $db->Execute($KILL);
            break;
        case "Start":
            $db->Execute($START);
            break;
        default:
            echo "<h1>Incorrect invocation of the script!</h1><br>";
     }
    header("Location: $INVOKER");
}
catch(Exception $e) {
       echo "START=$START<br>";
       die($e->getTraceAsString());
}
?>
<hr>
</center>
</body>
</html>
