<?php session_start();?>
<html>
<head>
<title>System Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>System Statistics</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
if (!empty($_POST['pattern'])) {
    $pattern = strtolower($_POST['pattern']);
} else {
    $pattern = "%";
}
$SQL = 'select name "Statistic Name",value "Statistic Value"
		     from   v$sysstat
		     where lower(name) like :PATT
             order by 1';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '%');
    $prevpat = '%';
}
$form->addText('pattern', "Statistics Pattern:", $prevpat);
$form->addSubmit("submit", "Execute");
$form->display();
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL, array('PATT'=>$pattern));
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
