<?php session_start();?>
<html>
<head>
<title>Redo Logs</title>
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
    $SQL1 = 'select * from v$logfile order by group#';
    $SQL2 = 'select thread#, sequence#, group#,
                    archived,bytes, first_change#,
                    to_char(first_time,\'DD-MON-RR HH24:MI:SS\') as START_TIME
             from v$log
             order by first_change# desc';

// php_beautifier->setBeautify(true)
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h2>Redo Log Status</h2><br>";
        $rs = $db->Execute($SQL2);
        csr2html($rs, '  ');
        echo "<h2>Redo Log Files</h2><br>";
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
