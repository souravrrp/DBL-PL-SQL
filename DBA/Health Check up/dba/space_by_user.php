<?php session_start();?>
<html>
<head>
<title>Space by User</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Space by User</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
if (isset($_POST['pattern'])) $pattern = $_POST['pattern'];
else $pattern = '%';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Owner pattern:', $pattern);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
// php_beautifier->setBeautify(false)
$SPACE = 'select owner,ceil(sum(bytes)/1048576) as "Allocated Space (MB)"
          from dba_segments
          where owner like upper(:PATTERN) 
          group by owner
          order by 2 desc';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SPACE, array('PATTERN'=>$pattern));
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
