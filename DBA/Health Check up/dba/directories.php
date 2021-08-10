<?php session_start();?>
<html>
<head>
<title>Directories</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Directories</h2><br>
<hr>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"left");
    $db   = NewADOConnection("oci8");
    require_version(9);
// php_beautifier->setBeautify(false);
    $SQL1 = 'select * from dba_directories order by directory_name';
// php_beautifier->setBeautify(true)
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
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
