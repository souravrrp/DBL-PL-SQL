<?php session_start();?>
<html>
<head>
<title>Session Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");

$sid = @$_GET['sid'];
if (!empty($_POST['sid'])) {
    $sid = $_POST['sid'];
    $prevpat = @$_POST['prevpat'];
} ?>
         <h2>Session Statistics for SID=<?=$sid?></h2>
         <br>
<?php
if (!empty($_POST['pattern'])) {
    $pattern = strtolower($_POST['pattern']);
} else {
    $pattern = "%";
}

$SQL = 'select n.name,s.value 
      from v$sesstat s,v$statname n
      where s.sid=:SID and
            s.statistic#=n.statistic# and
            lower(n.name) like :PATT
      order by n.name';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addHidden('sid', $sid);
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '%');
    $prevpat = '%';
}
$form->addText('pattern', "Statistics Pattern:", $prevpat);
$form->addSubmit("submit", "Execute");
$form->display();

try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL, array('SID'=>$sid, 'PATT'=>$pattern));
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
