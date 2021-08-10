<?php session_start();?>
<html>
<head>
<title>Session Info</title>
</head>
<body bgcolor="#EFECC7">
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$ver = $_SESSION['version'];
$sid = $_GET['sid'];
$serial = $_GET['serial'];
$addr=0;
$hash=0;
$sql_id=0;
$prev_addr=0;
$prev_hash=0;
$prev_id=0;
# php_beautifier->setBeautify(false);
if ($ver<10) {
    $GET_SQL = "select rawtohex(sql_address),sql_hash_value,
                       rawtohex(prev_sql_addr), prev_hash_value
                from v\$session
                where sid=:SID and
                serial#=:SERIAL";
} else {
    $GET_SQL = "select rawtohex(sql_address),sql_hash_value,sql_id,
                       rawtohex(prev_sql_addr), prev_hash_value, prev_sql_id
                from v\$session
                where sid=:SID and
                serial#=:SERIAL";
}
# php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($GET_SQL, array('SID'=>$sid, 'SERIAL'=>$serial));
    $row = $rs->FetchRow();
    $addr = $row[0];
    $hash = $row[1];
    if ($ver<10) {
        $prev_addr = $row[2];
        $prev_hash = $row[3];
    } else {
        $sql_id = $row[2];
        $prev_addr = $row[3];
        $prev_hash = $row[4];
        $prev_id = $row[5];
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<center>
<h2>Session Info for SID <?=$_GET['sid']?></h2>
<br><hr>
<h4>
<a href="wait_info.php?sid=<?=$sid
?>">Session Wait</a>
<br>
<a href="event_info.php?sid=<?=$sid
?>">Session Events</a>
<br>
<a href="stats_info.php?sid=<?=$sid
?>">Session Stats</a>
<br>
<a href="longops_info.php?sid=<?=$sid?>&serial=<?=$serial?>">
Session Longops</a>
<br>
<a href="sess_trace.php?sid=<?=$sid?>&serial=<?=$serial?>&onoff=ON">
Session Trace Start</a>
<br>
<a href="sess_trace.php?sid=<?=$sid?>&serial=<?=$serial?>&onoff=OFF">
Session Trace Stop</a>
<br>
<a href="sess_tkprof.php?sid=<?=$sid?>&serial=<?=$serial?>"> TKPROF</a>
<br>
<a href="sql_info.php?addr=<?=$addr
?>&hash=<?=$hash
?>&id=<?=$sql_id
?>">Current SQL</a>
<br>
<a href="sql_info.php?addr=<?=$prev_addr
?>&hash=<?=$prev_hash
?>&id=<?=$prev_id
?>">Previous SQL</a>
<hr>
</h4>
</center>
</body>
</html>
