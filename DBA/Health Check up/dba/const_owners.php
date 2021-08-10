<?php session_start();?>
<html>
<head>
<title>Object Owners</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2><?=$_GET['type'] ?> Owners</h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $ADODB_COUNTRECS = true;
    $CONS = 'select   dba_helper.const_list(owner) as "Constraint Owner",
              count(*) as "Object Count"
       from dba_constraints
       where constraint_type=\'R\'
       group by owner
       order by 2 desc';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($CONS);
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
