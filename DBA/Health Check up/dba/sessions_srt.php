<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Sessions, sorted by given criteria</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$SCHEMA = @$_SESSION['schema'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$sort = $_GET['sort'];
if (empty($sort)) {
    $sort = $_SESSION['sort'];
} else {
    $_SESSION['sort'] = $sort;
}
if (empty($sort)) {
    die("Cannot form SQL. Empty calling string<br>\n");
}
print "<h2>Sessions, sorted by $sort</h2><br>";
$SN = null;
// php_beautifier->setBeautify(false)
if (@$_SESSION['act_only']) 
    $fmt = 'SELECT sess.username,
             decode(sess.status,\'INACTIVE\',\'Inact \' || 
             round((sess.last_call_et/60),0) ||\' min\', 
                   \'ACTIVE\', \'Active\',sess.status) status,
             dba_helper.kill_session(sess.username,sess.sid,sess.serial#) kill,
             dba_helper.session_info(sess.sid,sess.serial#) Info,
             sess.sid,sess.serial# serial,p.spid "System PID",
             sess.program,sess.osuser,sess.machine,stat.value %s,
             to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In",
             server,module,client_info
            FROM v$session sess,v$sesstat stat,v$statname sn,v$process p
            WHERE sess.sid=stat.sid and
             sess.paddr=p.addr and
             sess.status=\'ACTIVE\' and
             stat.statistic#=sn.statistic# and 
             sn.name=:SN and
             dba_helper.filter_schema(sess.username,:SCHEMA)>0
            ORDER BY 11 desc';
else 
    $fmt = 'SELECT sess.username,
             decode(sess.status,\'INACTIVE\',\'Inact \' || 
             round((sess.last_call_et/60),0) ||\' min\', 
                   \'ACTIVE\', \'Active\',sess.status) status,
             dba_helper.kill_session(sess.username,sess.sid,sess.serial#) kill,
             dba_helper.session_info(sess.sid,sess.serial#) Info,
             sess.sid,sess.serial# serial,p.spid "System PID",
             sess.program,sess.osuser,sess.machine,stat.value %s,
             to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In",
             server,module,client_info
            FROM v$session sess,v$sesstat stat,v$statname sn,v$process p
            WHERE sess.sid=stat.sid and
             sess.paddr=p.addr and
             stat.statistic#=sn.statistic# and 
             sn.name=:SN and
             dba_helper.filter_schema(sess.username,:SCHEMA)>0
            ORDER BY 11 desc';
// php_beautifier->setBeautify(true)
switch ($sort) {
    case "CPU":
        $SN = 'CPU used by this session';
        $SQL = sprintf($fmt, "CPU");
    break;
    case "reads":
        $SN = 'physical reads';
        $SQL = sprintf($fmt, '"Physical Reads"');
    break;
    case "writes":
        $SN = 'physical writes';
        $SQL = sprintf($fmt, '"Physical Writes"');
    break;
    case "PGA":
        $SN = 'session pga memory';
        $SQL = sprintf($fmt, '"Allocated PGA"');
    break;
    default:
        die("Invalid sort string: $sort. Cannot continue.<br>\n");
    break;
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL, array('SCHEMA' => $SCHEMA, 'SN' => $SN));
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
