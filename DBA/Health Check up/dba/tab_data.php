<?php session_start();?>
<html>
<head>
<title> <?=$_REQUEST['own'] ?>.<?=$_REQUEST['name'] ?> Data</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Data In <?=$_REQUEST['own'] ?>.<?=$_REQUEST['name'] ?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$PAGESZ=@$_SESSION['pagesz'];
$PAGENO=0;
if (!empty($_POST['pageno'])) 
   $PAGENO=$_POST['pageno'];
if (!empty($_POST['reset'])) $PAGENO=0;
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
if (!empty($_POST['own']))
     $OWN=$_POST['own'];
else $OWN=$_GET['own'];
if (!empty($_POST['name']))
     $NAME=$_POST['name'];
else $NAME=$_GET['name'];
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$DATA = 'SELECT * FROM '.$OWN.'.'.$NAME;
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addHidden('pageno', $PAGENO+1);
$form->addHidden('own', $OWN);
$form->addHidden('name', $NAME);
$form->addSubmit("reset", "First Page");
$form->addSubmit("submit", "Next Page");
$form->addBlank(2);
$form->display();
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->SelectLimit($DATA,$PAGESZ,$PAGESZ*$PAGENO);
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<hr>
<h4>PAGE <?=$PAGENO+1?></h4><br>
</center>
</body>
</html>
