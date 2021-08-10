<?php session_start();?>
<html>
<head>
<title>Constraints List</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>List of foreign keys  for <?=$_GET['own'] ?></h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $ADODB_COUNTRECS = true;
    $OWN = $_GET['own'];
    $LIST = 'select dba_helper.const_info(:OWN,constraint_name) as "Constraint Name",
              status,
	      r_constraint_name
       from dba_constraints
       where owner=:OWN and
             constraint_type=\'R\'
       order by status desc,constraint_name';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($LIST, array('OWN'=>$OWN));
        csr2html($rs, ' ');
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
<hr>
</center>
</body>
</html>
