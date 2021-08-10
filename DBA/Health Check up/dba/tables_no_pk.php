<?php session_start();?>
<html>
<head>
<title>Tables Without Primary Key</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Tables w/o Primary Key</h2>
<br><hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$rattrib = array("align"=>"left");
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");

$owner = strtoupper(@$_POST['owner']);
if (empty($owner)) $owner = '%';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("owner", 'Owner pattern:', $owner);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
// php_beautifier->setBeautify(false);
$NOPK = "select owner,table_name,tablespace_name,temporary,nested,
                last_analyzed
         from dba_tables t
         where t.owner like :OWN and
               not exists ( select 1 from dba_constraints 
                            where constraint_type='P' and
                                  owner=t.owner and
                                  table_name=t.table_name)
         order by owner,table_name";
// php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($NOPK, array('OWN'=>$owner));
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    $db->RollbackTrans();
    die($e->getTraceAsString());
}
?>
<hr>
</center>
</body>
</html>
