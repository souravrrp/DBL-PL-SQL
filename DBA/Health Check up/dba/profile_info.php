<?php session_start();?>
<html>
<head>
<title>Session Metric</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    require_version();
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $sid = $_GET['sid'];
    $serial = $_GET['serial'];
    if (!empty($_SESSION['date_format'])) 
       $fmt=$_SESSION['date_format'];
    else $fmt='DD-MON-YYYY HH24:MI:SS';
    $DATE_FMT="alter session set nls_date_format='$fmt'";
    $SQL = 'select * 
      from v$sessmetric
      where session_id=:SID and
            session_serial_num=:SERIAL';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); 
        $db->Execute($DATE_FMT);?>
        <h2>Basic Stats for  SID=<?=$sid?></h2>
        <br>
    <?php
        $rs = $db->Execute($SQL, array('SID'=>$sid,'SERIAL'=>$serial));
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
