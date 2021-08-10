<?php session_start();?>
<html>
<head>
<title>50 Most Fragmented Objects</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>50 Most Fragmented Objects</h2>
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
$FRAG = "select rownum as rank,owner,segment_name,segment_type,
         tablespace_name,extents#
   from (
         select owner,segment_name,segment_type,tablespace_name,
                count(extent_id) as Extents#
         from dba_extents
         where owner like :OWN
         group by owner, segment_name,segment_type,tablespace_name
         order by extents# desc
        )
   where rownum<=50";
// php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($FRAG, array('OWN'=>$owner));
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
