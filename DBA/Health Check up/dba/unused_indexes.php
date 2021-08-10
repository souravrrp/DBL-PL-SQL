<?php session_start();?>
<html>
<head>
<title>Tables Without Indexes</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Tables w/o Indexes</h2>
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
$NOIX = <<< 'EOQ'
         select ss.owner,
                ss.object_name as index_name,
                ind.table_name,
                ss.tablespace_name
         from  v$segment_statistics ss, dba_indexes ind
         where ss.owner like :OWN and
               ss.owner not like '%SYS%' and
               ss.statistic_name='logical reads' and
               ss.value=0 and
               ss.object_type='INDEX' and
               ind.owner=ss.owner and
               ind.index_name=ss.object_name
         order by ss.owner,ind.table_name,ss.object_name
EOQ;
// php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($NOIX, array('OWN'=>$owner));
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
