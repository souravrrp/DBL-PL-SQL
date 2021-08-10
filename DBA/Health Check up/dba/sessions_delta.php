<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Session Monitoring, delta</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Sessions Delta, sorted by <?=$_GET['sort']?></h2><br>
<?php
require_once ('config.php');
require_version(10);
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
$SN = null;
// php_beautifier->setBeautify(false)
if (@$_SESSION['act_only']) {
    $fmt = 'SELECT sess.username,
              dba_helper.kill_session(sess.username,sess.sid,sess.serial#) kill,
              dba_helper.session_info(sess.sid,sess.serial#) Info,
              sess.sid,sess.serial# serial,p.spid "System PID",
              sess.status,sess.program,sess.osuser,sess.machine,
              to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In",
	      dlt.CPU,dlt.physical_reads,dlt.pga_memory,
              server,module,client_info
            FROM v$session sess,v$sessmetric dlt,v$process p
            WHERE sess.sid=dlt.session_id and
	          sess.serial#=dlt.session_serial_num and
                  sess.paddr=p.addr and
                  sess.status=\'ACTIVE\' and
                  dba_helper.filter_schema(sess.username,:SCHEMA)>0
                  ORDER BY %d desc';
} else {
    $fmt = 'SELECT sess.username,
              dba_helper.kill_session(sess.username,sess.sid,sess.serial#) kill,
              dba_helper.session_info(sess.sid,sess.serial#) Info,
              sess.sid,sess.serial# serial,p.spid "System PID",
              sess.status,sess.program,sess.osuser,sess.machine,
              to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In",
	      dlt.CPU,dlt.physical_reads,dlt.pga_memory,
              server,module,client_info
            FROM v$session sess,v$sessmetric dlt,v$process p
            WHERE sess.sid=dlt.session_id and
	          sess.serial#=dlt.session_serial_num and
                  sess.paddr=p.addr and
                  dba_helper.filter_schema(sess.username,:SCHEMA)>0
                  ORDER BY %d desc';
}
// php_beautifier->setBeautify(true)
switch ($sort) {
    case "CPU":
        $SQL = sprintf($fmt, 12);
    break;
    case "reads":
        $SQL = sprintf($fmt, 13);
    break;
    case "PGA":
        $SQL = sprintf($fmt, 14);
    break;
    default:
        die("Invalid sort string: $sort. Cannot continue.<br>\n");
    break;
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL, array('SCHEMA' => $SCHEMA));
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
