<?php ob_start(); session_start();?>
<html>
<head>
<title>Object Errors</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Object Errors in <?=$_GET['own']?>.<?=$_GET['obj']?></h2>
<hr>
<?php
require_once ('config.php');
$invoker = $_SESSION['invoker'];
if (!empty($_GET['obj'])) {
    $obj  = strtoupper($_GET['obj']);
    $type = strtoupper($_GET['type']);
    $own  = strtoupper($_GET['own']);
}
if (empty($obj)) die("Object to compile cannoy be empty!");
if ($type=='BODY') 
    $type='PACKAGE BODY';

// php_beautifier->setBeautify(FALSE)
$SQL="SELECT line,position,text
      FROM dba_errors
      WHERE owner=:OWN and
            type=:TYPE and
            name=:OBJ
      ORDER BY line";
// php_beautifier->setBeautify(TRUE)
    
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL,array('OWN'=>$own,'TYPE'=>$type,'OBJ'=>$obj));
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</center>
</body>
</html>
