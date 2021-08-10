<?php session_start();?>
<html>
<head>
<title>View Description</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>View <?=$_GET['name']?></h2>
<br>
<?php
    require_once ('config.php');
    $name = $_GET['name'];
    $type = $_GET['typ' ];
    switch($type) {
        case 'F':  
                   $SQL = 'select view_definition as "View Defintion" 
                   from v$fixed_view_definition
                   where view_name=:NAME';
                   break;
        case 'D':  
                   $SQL = 'select comments as "Description"
                   from dictionary 
                   where table_name=:NAME';
                   break;
        default:   
                   die("Incorrect invocation of view_desc.php!<br>");
    }

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL, array('NAME'=>$name));
        csr2html($rs, " ");
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
</center>
</body>
</html>
