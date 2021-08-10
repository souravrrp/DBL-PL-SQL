<?php session_start();?>
<html>
<head>
<title>Session Optimizer Environment</title>
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
    $SQL = 'select NAME,ISDEFAULT,VALUE
            from V$SES_OPTIMIZER_ENV
            where sid=:SID';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); ?>
        <br>
    <?php
        $rs = $db->Execute($SQL, array('SID'=>$sid));
        print "<h2>Session Optimizer Environment for SID=$sid</h2>";
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
