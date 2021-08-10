<?php session_start();?>
<html>
<head>
<title>Object Owners</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2><?=$_REQUEST['type'] ?> Owners</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");

if (isset($_GET['type'])) $type = $_GET['type'];
elseif (isset($_POST['type'])) $type = $_POST['type'];
else die("<h2>Cannot determine object type!</h2><br>");
switch ($type) {
case 'MVIEW':
	$otype='MATERIALIZED VIEW';
	break;
default:
	$otype=$type;
}


if (isset($_POST['pattern'])) $pattern = $_POST['pattern'];
else $pattern = '%';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Owner pattern:', $pattern);
$form->addHidden("type", $type);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();

// php_beautifier->setBeautify(false)
$OBJS = 'select dba_helper.obj_list(owner,:TYPE) as "Object Owner",
                count(*) as "Object Count"
         from dba_objects
         where object_type=:OTYPE and
               owner like upper(:PATTERN)
         group by owner
         order by 2 desc';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($OBJS, array('OTYPE'=>$otype, 
                                    'TYPE'=>$type,
                                    'PATTERN'=>$pattern));
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
