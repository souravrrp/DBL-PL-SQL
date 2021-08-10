<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Kill All Sessions for User</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Kill All Sessions for User</h2>
<hr>
<?php
require_once ('config.php');
# require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$sids=array();
$CLTS="select distinct username from V\$SESSION where type='USER'";
$SIDS='select sid,serial# from v$session where username=:USR';
$FMT="alter system disconnect session '%d,%d' immediate";


$user= @$_POST['user'];
$opcode = @$_POST['opcode'];

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if (!empty($user) and ($opcode=="Kill")) {
           $rs=$db->Execute($SIDS,array('USR'=>$user));
            while($row=$rs->FetchRow()) {
                $sids[$row[0]]=$row[1];
            }
            foreach ($sids as $key => $val) {
                $cmd=sprintf($FMT,$key,$val);
                 try {
                      $db->Execute($cmd);
                 } 
                 catch(Exception $e) {
                     print "$cmd<br>";
                     printf("Cannot kill :'%d,%d'<br>Err:%s<br>",
                     $key,$val, $e->getTraceAsString());
                 }
	    }
	} elseif ($opcode=="Return") {
	    header('Location: sessions.php');
        } 
        $rs = $db->Execute($CLTS);
        while ($row = $rs->FetchRow()) {
            $clts[$row[0]] = $row[0];
        }
        $db->close();
       	$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
       	$form->addBlank(3);
       	$form->addSelect("user", 'Users:', $clts);
       	$form->addSubmit("opcode", "Kill");
       	$form->addSubmit("opcode", "Return");
       	$form->addBlank(2);
       	$form->display();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
