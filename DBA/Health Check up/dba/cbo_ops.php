<?php session_start(); ?>
<html>
<head>
<title>CBO Stats Operations</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>CBO Stats Operations</h2>
<br>
<?php
require_once ('config.php');
$rattrib = array("align" => "center");
$version = $_SESSION['version'];
$OPS=<<<EOQ
    SELECT * FROM DBA_OPTSTAT_OPERATIONS 
    WHERE START_TIME >= SYSTIMESTAMP - 14
    ORDER BY START_TIME DESC
EOQ
;
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($OPS);
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
