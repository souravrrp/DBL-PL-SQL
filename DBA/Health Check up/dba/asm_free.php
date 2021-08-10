<?php ob_start();session_start(); ?>
<html>
<head>
<title>ASM Free Space</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>ASM Free Space</h2>
<br><hr><br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$rattrib = array("align" => "center");
// php_beautifier->setBeautify(false);
$ASM = 'SELECT DISTINCT GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,
               round((free_mb/total_mb)*100,2) "PCT Free",OFFLINE_DISKS
            FROM GV$ASM_DISKGROUP
            ORDER BY  GROUP_NUMBER';
$DGFRA = 'select * from  V$FLASH_RECOVERY_AREA_USAGE';
// php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($ASM);
    csr2html($rs, '  ');
    $rs = $db->Execute($DGFRA);
    echo "<BR><H2>Flash Recovery Area Usage</H2>";
    $rs = $db->Execute($DGFRA);
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<br><hr>
</center>
</body>
</html>
