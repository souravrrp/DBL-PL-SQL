<?php ob_start(); session_start();?>
<html>
<head>
<title>Session Wait Info</title>
</head>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    $sid = $_GET['sid'];
    $SQL = 'select event,p1text,p1,p2text,p2,p3text,p3,wait_time,state
      from v$session_wait 
      where sid=:SID';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); ?>
    <center>
        <h2>Session Wait Info for SID=<?=$sid
?></h2>
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
