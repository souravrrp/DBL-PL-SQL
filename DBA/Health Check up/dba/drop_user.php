<?php ob_start(); session_start();?>
<html>
<head>
<title>Drop User</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>
Warning: Drop User <?=$_REQUEST['usr'] ?>?
</h2>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$invoker = 'security.php';
$db = NewADOConnection("oci8");
if (!empty($_GET['usr'])) {
    $usr = $_GET['usr'];
} else {
    $usr = $_POST['usr'];
}
$kill = @$_POST['kill'];
if (empty($kill)) {
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addSubmit("kill", "Yes");
    $form->addSubmit("kill", "No");
    $form->addHidden('usr', $usr);
    $form->display();
    exit;
}
if (strtolower($kill) != 'yes') {
    header("Location: $invoker");
    exit;
}
$SQL = "drop user $usr cascade";
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
