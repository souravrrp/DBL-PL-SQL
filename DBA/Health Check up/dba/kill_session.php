<?php ob_start(); session_start();?>
<html>
<head>
<title>Kill Session</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
require_once ('config.php');
$version=$_SESSION['version'];
$DSN = $_SESSION['DSN'];
$invoker = $_SESSION['invoker'];
$db = NewADOConnection("oci8");
if (!empty($_GET['sid'])) {
    $sid = $_GET['sid'];
    $serial = $_GET['serial'];
    $inst   = $_GET['inst'];
} else {
    $sid = $_POST['sid'];
    $serial = $_POST['serial'];
    $inst =   $_POST['inst'];
}
if (empty($inst)) {
	print "<h2>Warning:kill session $sid,$serial?</h2><hr><br>";
} else {
	print "<h2>Warning:kill session $sid,$serial on instance $inst?</h2><hr><br>";
}
if (empty($sid)) die("Kill session: sid cannot be empty!");
$kill = @$_POST['kill'];
if (empty($kill)) {
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addSubmit("kill", "Yes");
    $form->addSubmit("kill", "No");
    $form->addHidden('sid', $sid);
    $form->addHidden('serial', $serial);
    $form->addHidden('inst',$inst);
    $form->display();
    exit;
}
if (strtolower($kill) != 'yes') {
    header("Location: $invoker");
    exit;
}
if (empty($inst)) {
    $SQL = "alter system disconnect session '$sid,$serial' immediate";
} else {
	$SQL = "alter system kill session '$sid,$serial,@$inst' immediate";
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL);
    $db->close();
    header("Location: $invoker");
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</center>
</body>
</html>
