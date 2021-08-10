<?php session_start(); ?>
<html>
<head>
<title>>Lock Waiters/Blockers</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Lock Waiters/Blockers</h2>
<br>
<?php
require_once ('config.php');
$version = $_SESSION['version'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
// php_beautifier->setBeautify(false)
if ($version==9) {
    $SQL = 'SELECT /*+ RULE */
               s1.username "Waiter",
               s1.sid,s1.serial#,
               dba_helper.get_obj(l1.id1,l1.id2) "Object",
               l1.type,
               l1.request,
               s2.username "Blocker",
               s2.sid, s2.serial#, 
               dba_helper.kill_session(s2.username,s2.sid,s2.serial#) Kill,
               s2.machine,s2.osuser
            FROM  v$session s1,v$session s2,v$lock l1,v$lock l2
            WHERE s1.sid=l1.sid AND
               l1.request>0 AND
               l1.id1=l2.id1 AND
               s2.sid=l2.sid AND
               l2.request=0';
} elseif ($version==10) {
    $SQL = 'SELECT 
               s1.username "Waiter",
               s1.sid,s1.serial#,
               dba_helper.get_obj(s1.row_wait_obj#,0) "Object",
               s1.row_wait_file# "File",
               s1.row_wait_block# "Block#",
               l1.type,
               l1.request,
               s2.username "Blocker",
               s2.sid, s2.serial#, s2.inst_id
               dba_helper.kill_session(s2.username,s2.sid,s2.serial#) Kill,
               s2.machine,s2.osuser
            FROM  v$session s1,gv$session s2,v$lock l1
            WHERE s1.sid=l1.sid AND
               l1.request>0 AND
               s2.sid=s1.blocking_session AND
               s2.inst_id=s1.blocking_instance';
} else {
	$SQL ='SELECT 
               s1.username "Waiter",
               s1.sid,s1.serial#,
               dba_helper.get_obj(s1.row_wait_obj#,0) "Object",
               s1.row_wait_file# "File",
               s1.row_wait_block# "Block#",
               l1.type,
               l1.request,
               s2.username "Blocker",
               s2.sid, s2.serial#, 
               s2.inst_id "Instance",
               dba_helper.kill_session(s2.username,s2.sid,s2.serial#,s2.inst_id) Kill,
               s2.machine,s2.osuser
            FROM  v$session s1,gv$session s2,v$lock l1
            WHERE s1.sid=l1.sid AND
               l1.request>0 AND
               s2.inst_id=s1.blocking_instance AND
               s2.sid=s1.blocking_session';
}
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL);
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<A HREF="sessions.php" target="output">Sessions</A>
</center>
</body>
</html>
