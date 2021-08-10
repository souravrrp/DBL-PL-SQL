<?php session_start(); ?>
<html>
<head>
<title>Session LONGOPS</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$DATE_FORMAT = "alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS'";
$db = NewADOConnection("oci8");
$sid = @$_GET['sid'];
$serial = @$_GET['serial'];
?>
         <h2>LONGOPS for SID=<?=$sid
?></h2>
         <br>
<?php
// php_beautifier->setBeautify(false)
$SQL = 'select * from v$session_longops 
        where sid=:SID and serial#=:SERIAL
        order by nvl(time_remaining,0) desc,last_update_time desc';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $db->Execute($DATE_FORMAT);
    $rs = $db->Execute($SQL, array('SID' => $sid, 'SERIAL' => $serial));
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
