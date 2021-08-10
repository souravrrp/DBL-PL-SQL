<?php session_start();?>
<html>
<head>
<title>Needs Recovery</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"left");
    $db   = NewADOConnection("oci8");
    require_version();
// php_beautifier->setBeautify(false);
    $SQL1 = 'select * from v$recover_file order by file#';
// php_beautifier->setBeautify(true)
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h2>Files To Recover</h2><br>";
        $rs = $db->Execute($SQL1);
        csr2html($rs, '  ');
        $rs->close();
        $db->close();
    }
    catch(Exception $e) {
        $db->RollbackTrans();
        die($e->getTraceAsString());
    }
?>
<br>
</center>
</body>
</html>
