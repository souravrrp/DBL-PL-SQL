<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Create User</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h1>Create User</h1>
<br>
<hr>
<?php
require_once ('config.php');
$invoker = 'security.php';
$DFLT = "select tablespace_name,tablespace_name 
       from dba_tablespaces
       where contents='PERMANENT'";
$TEMP = "select tablespace_name,tablespace_name 
       from dba_tablespaces
       where contents='TEMPORARY'";
if (empty($_POST['tbspc'])) {
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($DFLT);
        while ($row = $rs->FetchRow()) {
            $dflt[$row[0]] = $row[1];
        }
        $rs = $db->Execute($TEMP);
        while ($row = $rs->FetchRow()) {
            $temp[$row[0]] = $row[1];
        }
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addText("user", "Username:");
        $form->addText("pwd", "Password:");
        $form->addSelect('tbspc', 'Default Tablespace:', $dflt);
        $form->addSelect('temp', 'Temporary Tablespace:', $temp);
        $form->addSubmit("submit", "Create");
        $form->display();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
} else {
    $user = $_POST['user'];
    $pwd = $_POST['pwd'];
    $tbspc = $_POST['tbspc'];
    $temp = $_POST['temp'];
    $CRUSR = "create user $user identified by $pwd 
            default tablespace $tbspc
            temporary tablespace $temp";
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($CRUSR);
        header("Location: $invoker");
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
}
?>
</body>
</html>
