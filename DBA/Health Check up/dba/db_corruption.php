<?php session_start();?>
<html>
<head>
<title>DB Corruption</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"right");
    $db   = NewADOConnection("oci8");
    $SQL1 = 'select * from v$database_block_corruption
             order by file#,block#';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h2>DB Block Corruption</h2><br><hr><br>";
        $rs = $db->Execute($SQL1);
        csr2html($rs, '  ');
        $rs->close();
        $db->close();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
<br>
</center>
</body>
</html>
