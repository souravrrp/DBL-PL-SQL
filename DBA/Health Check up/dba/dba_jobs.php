<?php ob_start(); session_start();?>
<html>
<head>
<title>DBA Jobs</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>DBA Jobs</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
if (!empty($_POST['owner'])) $owner = strtoupper($_POST['owner']);
else $owner = '%';
if (!empty($_POST['what'])) $what = strtoupper($_POST['what']);
else $what = '%';
if (!empty($_POST['id'])) $id= $_POST['id'];
else $id=NULL;

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addText("owner", 'Owner Pattern:', $owner);
$form->addText("what", 'What Pattern:', $what);
$form->addText("id", 'Object ID:', $id);
$form->addSubmit("submit", "Filter");
$form->display();
echo "<hr><br>";
//  php_beautifier->setBeautify(false);
if (empty($id)) {
   $SQL = 'select *
           from dba_jobs
           where schema_user like upper(:PATTERN) and 
                 upper(what) like upper(:WHAT)';
} else {
   $SQL = 'select *
           from dba_jobs
           where job=:ID';
}
//  php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (empty($id)) {
        $rs = $db->Execute($SQL,array('PATTERN'=>$owner,'WHAT'=>$what));
    } else {
        $rs = $db->Execute($SQL,array('ID'=>$id));

    }
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
