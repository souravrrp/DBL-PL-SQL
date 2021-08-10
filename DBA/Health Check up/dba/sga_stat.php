<?php session_start(); ?>
<html>
<head>
<title>SGA Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>SGA Statistics</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$rattrib = array("align" => "center");
if (!empty($_POST['pattern'])) {
    $pattern = strtolower($_POST['pattern']);
} else {
    $pattern = "%";
}
$SHOW = 'select * from v$sga';
$SGA = 'select * from v$sgastat where name like :PATT';
$PGA = 'select * from v$pgastat';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '%');
    $prevpat = '%';
}
$form->addText('pattern', "Stat Name Pattern:", $prevpat);
$form->addSubmit("submit", "Execute");
$form->display();
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    echo "<h2>SHOW SGA</h2><br>";
    $rs = $db->Execute($SHOW);
    csr2html($rs, '  ');
    echo "<h2>SGA Statistics</h2><br>";
    $rs = $db->Execute($SGA, array('PATT' => $pattern));
    csr2html($rs, '  ');
    echo "<h2>PGA Statistics</h2><br>";
    $rs = $db->Execute($PGA);
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
