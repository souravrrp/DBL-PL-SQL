<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Object Access</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Object Access</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
// php_beautifier->setBeautify(FALSE)
$otype = array('TABLE' => 'TABLE', 
               'VIEW' => 'VIEW', 
               'INDEX' => 'INDEX', 
               'PACKAGE' => 'PACKAGE', 
               'PROCEDURE' => 'PROCEDURE', 
               'SEQUENCE' => 'SEQUENCE', 
               'FUNCTION' => 'FUNCTION');
// php_beautifier->setBeautify(TRUE)
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addSelect('otype', 'Object type:', $otype);
$form->addText('own', "Owner:");
$form->addText('name', "Object name:");
$form->addText('sid', "Session ID:");
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
$own = @strtoupper($_POST['own']);
$type = @strtoupper($_POST['otype']);
$name = @strtoupper($_POST['name']);
$sid = @$_POST['sid'];
// php_beautifier->setBeautify(FALSE)
if (empty($sid)) {
    $SQL = 'SELECT /*+ RULE */ 
                        a.inst_id,a.sid,a.owner,a.object,a.type,
               		s.username,s.program,s.machine,s.osuser
            FROM        gv$access a,gv$session s
            WHERE 	a.type=:OTYPE and
              		a.owner like :OWN and
             	 	a.object like :NAME and
              		s.sid=a.sid and
              		s.inst_id=a.inst_id
            ORDER BY 1,2';
} else {
    $SQL = 'SELECT /*+ RULE */
                        a.inst_id,a.sid,a.owner,a.object,a.type,
               		s.username,s.program,s.machine,s.osuser
            FROM gv$access a,gv$session s
            WHERE 	a.sid=:SID and
                        a.type=:OTYPE and
              		s.sid=a.sid and
              		s.inst_id=a.inst_id
            ORDER BY 1,2';
}
// php_beautifier->setBeautify(TRUE)
if (empty($name) and empty($sid)) exit;
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    // php_beautifier->setBeautify(FALSE)
    if (empty($sid)) {
        $rs = $db->Execute($SQL, array('OTYPE' => $type, 
                                       'OWN' =>   $own, 
                                       'NAME' =>  $name));
    } else {
        $rs = $db->Execute($SQL, array('SID' => $sid, 'OTYPE' => $type));
    }
    // php_beautifier->setBeautify(TRUE)
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
