<?php session_start();?>
<html>
<head>
<title>Instance Info</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Resource Limits and Utilization</h2>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $RES = 'select * from v$resource_limit';
    $NLS = 'select * from v$nls_parameters order by parameter';
    $INS = 'select * from v$instance';
    $DBR = 'select * from dba_registry';
    $DBS = 'select * from v$database';
    $DFORM=@$_SESSION['date_format'];
    if (!empty($DFORM)) 
       $DFORM="alter session set nls_date_format='".$DFORM."'";
    $SIZE='select sum(mb) from (
            select sum(bytes)/1048576 as mb from dba_data_files
                union all
            select sum(bytes)/1048576 as mb from dba_temp_files
                union all
            select sum(bytes)/1048576 as mb from v$log)';
    $PATCH='select * from dba_registry_history order by action_time desc';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if (!empty($DFORM)) 
           $db->Execute($DFORM);
        $rs = $db->Execute($RES);
        csr2html($rs, '  ');
        echo "<br><h2>NLS Parameters</h2><br>";
        $rs = $db->Execute($NLS);
        csr2html($rs, '  ');
        echo "<br><h2>Instance State</h2><br>";
        $rs = $db->Execute($INS);
        csr2html($rs, '  ');
        echo "<br><h2>DB Info</h2>";
        $rs=$db->Execute($SIZE);
        $row=$rs->FetchRow();
        echo "<h4>Database size is:",$row[0],"MB</h4><br>";
        echo "<br><h2>Database State</h2><br>";
        $rs = $db->Execute($DBS);
        csr2html($rs, '  ');
        $rs = $db->Execute($DBR);
        csr2html($rs, '  ');
        if ($_SESSION['version']>=10) {
            echo "<br><h2>Patchsets</h2><br>";
            $rs = $db->Execute($PATCH);
            csr2html($rs, '  ');
        }
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
