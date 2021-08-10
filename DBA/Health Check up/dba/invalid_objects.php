<?php session_start();?>
<html>
<head>
<title>Invalid Object Owners</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Invalid Object Owners</h2>
<br>
<hr>
<?php
require_once ('config.php');
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
if (isset($_REQUEST['pattern'])) $pattern = $_REQUEST['pattern'];
else $pattern = '%';
if (isset($_REQUEST['type'])) $type = $_REQUEST['type'];
else $type = '%';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Owner pattern:', $pattern);
$form->addText("type", 'Object type pattern:', $type);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
// php_beautifier->setBeautify(false)
$OBJS = "SELECT owner,object_type,object_name,status,
                dba_helper.compile(owner,object_type,object_name) compile,
                dba_helper.errors(owner,object_type,object_name)  errors,
                case 
                   when object_type='PACKAGE BODY' THEN object_type
                   else  dba_helper.obj_info(owner,object_type,object_name)
                end as DDL
         FROM dba_objects
         WHERE owner like upper(:PATTERN) and
               object_type like upper(:TYPE) and
               status='INVALID'
         ORDER BY owner,object_type,object_name";
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($OBJS, array('PATTERN'=>$pattern,'TYPE'=>$type));
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
