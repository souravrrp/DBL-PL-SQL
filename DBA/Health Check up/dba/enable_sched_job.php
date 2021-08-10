<?php ob_start(); session_start();?>
<html>
<head>
<title>Enable/Disable Scheduler Job</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Enable/Disable Job <?=$_REQUEST['own']?>.<?=$_REQUEST['job']?></h2>
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
    $form->addSubmit("action", "Enable");
    $form->addSubmit("action", "Disable");
    $form->addSubmit("action", "Stop");
    $form->addSubmit("action", "Start");
    $form->addBlank(1);
    $form->display();
    exit;
} else $action = $_POST['action'];
# php_beautifier->setBeautify(false)
$ENABLE= "begin
              dbms_scheduler.enable('$USR.$JOB');
          end;";
$DISABLE="begin
             dbms_scheduler.disable('$USR.$JOB');
          end;";
$STOP =  "begin
             dbms_scheduler.stop_job('$USR.$JOB');
          end;";
$START = "begin
             dbms_scheduler.run_job('$USR.$JOB');
          end;";
# php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    switch($action) {
        case "Enable":
            $db->Execute($ENABLE);
            break;
        case "Disable":
            $db->Execute($DISABLE);
            break;
        case "Stop":
            $db->Execute($STOP);
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
       die($e->getTraceAsString());
}
?>
<hr>
</center>
</body>
</html>
