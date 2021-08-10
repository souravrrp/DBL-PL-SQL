<?php session_start();?>
<html>
<head>
<title>Session Events</title>
</head>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $sid = $_GET['sid'];
    $SQL = 'select event,total_waits,time_waited,average_wait,max_wait
      from v$session_event
      where sid=:SID
      order by time_waited desc';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); ?>
    <center>
        <h2>Session Event Info for SID=<?=$sid?></h2>
        <br>
    </center>
    <?php
        $rs = $db->Execute($SQL, array('SID'=>$sid));
        csr2html($rs, '  ');
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
</body>
</html>
