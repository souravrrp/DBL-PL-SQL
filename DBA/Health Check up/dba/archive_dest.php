<?php session_start();?>
<html>
<head>
<title>Archive Dest Status</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    require_version();
// php_beautifier->setBeautify(false);
    $SQL1 = 'select DEST_ID,STATUS,BINDING,TARGET,DESTINATION,
                    LOG_SEQUENCE,FAIL_SEQUENCE,ERROR
             from v$archive_dest
             where status != \'INACTIVE\'';
    $SQL2 = 'select DEST_ID,DESTINATION,TYPE,STATUS,PROTECTION_MODE,
                    STANDBY_LOGFILE_COUNT,STANDBY_LOGFILE_ACTIVE,
                    SYNCHRONIZED,SYNCHRONIZATION_STATUS
             from v$archive_dest_status
             where status != \'INACTIVE\'';
             
// php_beautifier->setBeautify(true)
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h2>Archive Dest Description</h2><br>";
        $rs = $db->Execute($SQL1);
        csr2html($rs, '  ');
        $rs->close();
        echo "<h2>Archive Dest Status</h2><br>";
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
