<?php ob_start(); session_start();?>
<html>
<head>
<title>Kill Session</title>
</head>
<body bgcolor="#EFECC7">
<center>
<hr>
<?php
require_once ('config.php');
echo "<h2>Invoker=$invoker</h2><br>";
if (!empty($_GET['obj'])) {
    $obj  = strtoupper($_GET['obj']);
    $type = strtoupper($_GET['type']);
    $own  = strtoupper($_GET['own']);
}
if (empty($obj)) die("Object to compile cannoy be empty!");
$invoker = $_SESSION['invoker']."?pattern=$own";
$SQL = "alter $type $own.$obj compile";
if ($type=="BODY") 
    $SQL = "alter package $own.$obj compile body";
    
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL);
    $db->close();
    header("Location: $invoker");
}
catch(Exception $e) {
    header("Location: $invoker");
}
?>
</center>
</body>
</html>
