<?php session_start();?>
<html>
<head>
<title>Datapump Jobs</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Data Pump Jobs</h2><br>
<hr>
<br>
<?php
    require_once ('config.php');
    $_SESSION['invoker'] = $_SERVER['PHP_SELF'];
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"left");
    $db   = NewADOConnection("oci8");
    require_version(10);
// php_beautifier->setBeautify(false);
    $SQL1 = 'select OWNER_NAME,
                    JOB_NAME,
                    OPERATION,
                    JOB_MODE,
                    STATE,
                    DEGREE,
                    ATTACHED_SESSIONS,
                    DATAPUMP_SESSIONS,
                    dba_helper.ctl_pump(OWNER_NAME,JOB_NAME) JOB_CTL
             from dba_datapump_jobs order by state';
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
