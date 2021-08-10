<?php session_start();?>
<html>
<head>
<title>Lock Holders</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Lock Holders</h2>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $_SESSION['invoker'] = $_SERVER['PHP_SELF'];
    $rattrib = array("align"=>"middle");
    $db = NewADOConnection("oci8");
    if (isset($_POST['user'])) $user=strtoupper($_POST['user']);
    else $user='%';
    if (isset($_POST['sid'])) $sid=$_POST['sid'];
    else $sid='%';
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText('user',"User:",$user);
    $form->addText('sid',"SID:",$sid);
    $form->addSubmit("submit", "Filter");
    $form->addBlank(2);
    $form->display();
    $SQL = 'select /*+ RULE */ 
             s.username,
             s.sid,s.serial#,
             dba_helper.get_obj(lock_id1,lock_id2) object,
             l.lock_type,
             l.mode_held,
             l.mode_requested, 
             l.blocking_others
      from v$session s,
      (select sid session_id, 
       decode(type, \'MR\', \'Media Recovery\', 
                    \'RT\', \'Redo Thread\', 
                    \'UN\', \'User Name\', 
                    \'TX\', \'Transaction\', 
                    \'TM\', \'DML\', 
                    \'UL\', \'PL/SQL User Lock\', 
                    \'DX\', \'Distributed Xaction\', 
                    \'CF\', \'Control File\', 
                    \'IS\', \'Instance State\', 
                    \'FS\', \'File Set\', 
                    \'IR\', \'Instance Recovery\', 
                    \'ST\', \'Disk Space Transaction\', 
                    \'TS\', \'Temp Segment\', 
                    \'IV\', \'Library Cache Invalidation\', 
                    \'LS\', \'Log Start or Switch\', 
                    \'RW\', \'Row Wait\', 
                    \'SQ\', \'Sequence Number\', 
                    \'TE\', \'Extend Table\', 
                    \'TT\', \'Temp Table\', type) lock_type, 
        decode(lmode, 0, \'None\', /* Mon Lock equivalent */ 
                      1, \'Null\', /* N */ 
                      2, \'Row-S (SS)\', /* L */ 
                      3, \'Row-X (SX)\', /* R */ 
                      4, \'Share\', /* S */ 
                      5, \'S/Row-X (SSX)\', /* C */ 
                      6, \'Exclusive\', /* X */ to_char(lmode)) mode_held, 
       decode(request,0, \'None\', /* Mon Lock equivalent */ 
                      1, \'Null\', /* N */ 
                      2, \'Row-S (SS)\', /* L */ 
                      3, \'Row-X (SX)\', /* R */ 
                      4, \'Share\', /* S */ 
                      5, \'S/Row-X (SSX)\', /* C */ 
                      6, \'Exclusive\', /* X */ to_char(request)) mode_requested,
       id1 lock_id1, id2 lock_id2, ctime last_convert, 
       decode(block, 0, \'Not Blocking\', /* Not blocking any other processes */ 
                     1, \'Blocking\', /* This lock blocks other processes */ 
                     2, \'Global\', /* This lock is global, so we can\'t tell */ 
                     to_char(block)) blocking_others from v$lock ) l
      where s.sid=l.session_id and
            s.sid like :SID and
            nvl(s.username,\'SYS\') like :USR 
      order by blocking_others,username';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL,array("SID"=>$sid,"USR"=>$user));
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
