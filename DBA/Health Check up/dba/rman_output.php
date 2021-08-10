<?php ob_start(); session_start();?>
<html>
<head>
<title>RMAN Job Output</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>RMAN Job Output</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
require_version(10);
$sid = $_GET['sid'];
$recid = $_GET['recid'];
$stamp = $_GET['stamp'];
$OUT="select output from v\$rman_output
      where session_recid=:RECID and session_stamp=:STAMP";
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs=$db->Execute($OUT,array("RECID"=>$recid,"STAMP"=>$stamp));
    csr2html($rs, '  ');
    $rs->close();
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</body>
</html>
