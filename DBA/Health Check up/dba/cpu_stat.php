<?php session_start(); ?>
<html>
<head>
<title>CPU & OS stats</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>CPU and OS stats</h2>
<hr><br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
require_version(10);
$rattrib = array("align" => "center");
$STAT = 'SELECT inst_id,stat_name,value 
         FROM gv$osstat 
         ORDER BY inst_id,osstat_id';
$CPU = 'with ld as ( select inst_id,value as load from gv$osstat
                     where stat_name=\'LOAD\')
        select a.inst_id "Instance ID",
               round(100*to_number(a.value)/(to_number(a.value)+to_number(b.value)),2) "CPU Usage%",
               ld.load as "Load"
        from gv$osstat a,gv$osstat b,ld
        where a.stat_name=\'BUSY_TIME\' and b.stat_name=\'IDLE_TIME\' and
        a.inst_id=b.inst_id and
        a.inst_id=ld.inst_id and
        b.inst_id=ld.inst_id
        order by a.inst_id';

try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    echo "<h2>Overall CPU resource consumption per instance</h2>";
    $rs = $db->Execute($CPU);
    csr2html($rs, '  ');
    echo "<h2>All available OS stats indicators per instance</h2>";
    $rs = $db->Execute($STAT);
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
