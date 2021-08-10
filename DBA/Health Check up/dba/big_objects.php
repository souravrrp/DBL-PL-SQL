<?php session_start();?>
<html>
<head>
<title>50 Largest Objects</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>50 Largest Objects</h2>
<br><hr>
<?php
require_once ('config.php');
$rattrib = array("align"=>"left");

$owner = strtoupper(@$_POST['owner']);
if (empty($owner)) $owner = '%';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("owner", 'Owner pattern:', $owner);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();

// php_beautifier->setBeautify(false)
$LARG = "select rownum as rank,
                owner,
                segment_name,
                segment_type,
                tablespace_name,
                mb
         from (
                select owner,segment_name,segment_type,
                       tablespace_name,round(bytes/1048576,2) as MB
                from dba_segments
                where owner like :OWN
                order by MB desc
         )
         where rownum<=50";

// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($LARG,array('OWN'=>$owner));
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
