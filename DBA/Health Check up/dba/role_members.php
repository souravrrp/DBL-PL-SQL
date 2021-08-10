<?php session_start();?>
<html>
<head>
<title>Role Members for <?=$_GET['role']?></title>
</head>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $role= $_GET['role'];
    $SQL = 'select dba_helper.grnt_role(grantee) as "Role Members"
      from dba_role_privs
      where granted_role=:ROLE
      order by grantee';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); ?>
    <center>
        <h2>Role Members For <?=$role?></h2>
        <br>
    </center>
    <?php
        $rs = $db->Execute($SQL, array('ROLE'=>$role));
        csr2html($rs, '  ');
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
</body>
</html>
