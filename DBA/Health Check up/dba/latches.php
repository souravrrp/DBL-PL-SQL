<?php ob_start();session_start();?>
<html>
<head>
<title>Latches</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Latches</h2>
<br>
<?php
require_once ('config.php');
# require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
if (!empty($_POST['pattern'])) 
    $pattern =$_POST['pattern'];

$SQL = 'select name,latch#,child#,level#,gets,misses,
	                    immediate_gets,immediate_misses,spin_gets
             from v$latch_children
		     where addr = hextoraw(:PATT)
             order by name,immediate_misses desc';
$SQL1 = 'select CHILD#  "cCHILD"
     ,      rawtohex(ADDR)    "sADDR"
     ,      GETS              "sGETS"
     ,      MISSES            "sMISSES"
     ,      SLEEPS            "sSLEEPS" 
     from v$latch_children 
     where name = \'cache buffers chains\'
     order by 5, 1, 2, 3';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '');
}
$form->addText('pattern', "Address:", $prevpat);
$form->addSubmit("submit", "Execute");
$form->display();
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (!empty($pattern)) {
        $rs = $db->Execute($SQL, array('PATT'=>$pattern));
        csr2html($rs, '  ');
    }
    $rs = $db->Execute($SQL1);
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
