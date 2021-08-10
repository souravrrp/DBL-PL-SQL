<?php session_start();?>
<html>
<head>
<title>DataGuard Status</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>DataGuard Events</h2>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"right");
    $db   = NewADOConnection("oci8");

// php_beautifier->setBeautify(false);
    $SQL1 = 'select to_char(TIMESTAMP,\'DD-MON-YYYY HH24:MI:SS\') as time_stamp,
                    FACILITY,SEVERITY,DEST_ID,ERROR_CODE,MESSAGE,CALLOUT
             from   v$dataguard_status
             order by timestamp desc';
    $SQL2='select * from v$archive_processes';

// php_beautifier->setBeautify(true)
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL1);
        csr2html($rs, '  ');
        echo "<h2>Archiver Processes</h2><br>";
        $rs = $db->Execute($SQL2);
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
