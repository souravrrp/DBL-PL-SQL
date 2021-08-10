<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Sessions, sorted by UNDO blocks consumption</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Sessions, by UNDO blocks consumption</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$SCHEMA = @$_SESSION['schema'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
// php_beautifier->setBeautify(false)
$SQL = 'SELECT sess.username,
         dba_helper.kill_session(sess.username,sess.sid,sess.serial#) kill,
         dba_helper.session_info(sess.sid,sess.serial#) Info,
         sess.sid,sess.serial# serial,p.spid "System PID",
         sess.program,sess.osuser,sess.machine,
         t.used_ublk "Undo blocks",t.status "Trans. Status",
         to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In"
        FROM v$session sess,v$transaction t,v$process p
        WHERE  sess.saddr=t.ses_addr and
         sess.paddr=p.addr and
         dba_helper.filter_schema(sess.username,:SCHEMA)>0
        ORDER BY t.status,t.used_ublk desc';
// php_beautifier->setBeautify(true)
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
