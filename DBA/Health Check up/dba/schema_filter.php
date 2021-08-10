<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Set Schema Filter</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Set Schema Filter</h2>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$act = @$_POST['active'];
if ($act) {
    $_SESSION['act_only'] = 1;
} else $_SESSION['act_only'] = 0;
if (!empty($_SESSION["schema"])) {
    unset($_SESSION["schema"]);
}
$SCHM = @$_POST["schema"];
if (!empty($SCHM)) {
    $_SESSION["schema"] = $SCHM;
    echo $_SESSION["schema"];
    header('Location: sessions.php');
} else {
    $usr = array('ALL' => 'ALL');
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $SQL = 'select distinct username from v$session';
        $rs = $db->Execute($SQL);
        while ($row = $rs->FetchRow()) {
            $usr[$row[0]] = $row[0];
        }
        $db->close();
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(3);
        $form->addSelect("schema", 'Schema:', $usr);
        $form->addCheckBox("active", 'Active Only:', FALSE);
        $form->addSubmit("submit", "Filter");
        $form->addBlank(2);
        $form->display();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
}
?>
</center>
</body>
</html>
