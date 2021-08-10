<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Sessions Search</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Sessions Search</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$SCHEMA = @$_SESSION['schema'];
$INST=$_SESSION['inst_id'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$crit=array("sess.sid"         => "SID",
            "p.spid"           => "SPID",
            "sess.program"     => "PROGRAM",
            "sess.machine"     => "MACHINE",
            "sess.username"    => "USERNAME",
            "sess.osuser"      => "OSUSER",
            "sess.client_info" => "CLIENT_INFO",
            "sess.module"      => "MODULE");
$oper=array(" = "    => "EQUAL",
            " like " => "LIKE");
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addSelect('crit', 'Search by:', $crit);
$form->addSelect('oper', 'Operation:', $oper);
$form->addText('item',"Item:");
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
if (empty($_POST['crit'])) exit;
$cond=$_POST['crit'].$_POST['oper'].':ITEM order by 1,6';
// php_beautifier->setBeautify(false)
$SQL = 'SELECT sess.inst_id,sess.username,
        decode(sess.status,\'INACTIVE\',\'Inact \' || 
        round((sess.last_call_et/60),0) ||\' min\', 
              \'ACTIVE\', \'Active\',sess.status) status,
        dba_helper.kill_session(sess.username,sess.sid,sess.serial#,
                                sess.inst_id) kill,
        dba_helper.session_info(sess.sid,sess.serial#,sess.inst_id)  Info,
        sess.sid,sess.serial# serial,p.spid "System PID",
        sess.program,sess.osuser,sess.machine, server,
        to_char(logon_time,\'  MM/DD/YYYY HH24:MI\') "Logged In",
        sess.module, sess.client_info
        FROM gv$session sess, gv$process p
        WHERE sess.paddr=p.addr and 
              sess.inst_id=p.inst_id and ';
// php_beautifier->setBeautify(true)
$SQL .= $cond;
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL, array('ITEM' => trim($_POST['item']),'INST'=>$INST));
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
