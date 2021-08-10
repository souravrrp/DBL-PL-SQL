<?php session_start(); ?>
<html>
<head>
<title>50 Hottest Objects</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$rattrib = array("align" => "left");
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$stat = strtoupper(@$_GET['stat']);
switch ($stat) {
    case "READS":
    case "WRITES":
        $stat = "PHYSICAL " . $stat;
    break;
    case "WAITS":
        $stat = "BUFFER BUSY " . $stat;
    break;
    case "GC":
        $stat = "GC BUFFER BUSY";
    break;
    case "CHANGES":
        $stat = "DB BLOCK CHANGES";
    break;
    case "LOCKS":
        $stat = "ROW LOCK WAITS";
    break;
    default:
        echo "Incorrect invocation of the HOT_OBJECTS script<BR>";
        exit;
}
echo "<h2>50 Hottest Objects (by $stat)</h2><br><hr>";
// php_beautifier->setBeautify(false)
$HOT  = "select owner,
                object_name,
                object_type,
                tablespace_name,
                value as \"$stat\"
         from (
                select owner,object_name,object_type,
                       tablespace_name,value,
                       row_number() over (order by value desc) as rn
                from v\$segment_statistics
                where upper(statistic_name)=:STAT
                order by rn
         )
         where rn<=50";
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($HOT, array('STAT' => $stat));
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
