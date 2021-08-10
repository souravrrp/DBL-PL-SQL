<?php session_start(); ?>
<html>
<head>
<title>File Info</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Tablespace File Info for <?=$_GET['tblspc'] ?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$TBLSPC = trim($_REQUEST['tblspc']);
$file = trim($_REQUEST['file']);
$size = ($_REQUEST['size']);
$_SESSION['invoker'] = $_SERVER['PHP_SELF'] . "?tblspc=$TBLSPC";
echo "<h3>Add Data File</h3>";
$form = new HTML_Form($_SESSION['invoker'], "POST");
$form->addText('file', 'Datafile:', $file);
$form->addText('size', 'Size in MB:', $size);
$form->addHidden('tblspc', $TBLSPC);
$form->addSubmit("action", "Add");
$form->display();
if (empty($file) and !empty($size)) {
    $AFILE = "ALTER TABLESPACE $TBLSPC ADD DATAFILE SIZE $size M";
} elseif (!empty($file) and !empty($size)) {
    $AFILE = "ALTER TABLESPACE $TBLSPC ADD DATAFILE '$file' SIZE $size M";
} elseif (!empty($_POST['action']) and empty($size)) {
    die("Size of the file to be added must be specified.");
}
// php_beautifier->setBeautify(FALSE)
$FILE = 'select file_type,
          dba_helper.rsize(file_type,file_id) RESIZE,
          dba_helper.extnd(file_type,file_id) AUTOEXTEND,
          file_name,
          tablespace_name,
          autoextensible as autoextend,
          status,mb,
          "Max MB",
           "Incr." 
   from (
     select \'DATA\' FILE_TYPE,
            f.file_name,
            f.file_id,
            f.tablespace_name,
            f.status,
            round(f.bytes/1048576,2) MB,
            f.autoextensible,
            round(f.maxbytes/1048576,2) "Max MB",
            round((f.increment_by*t.block_size)/1048576,2) "Incr."
            from dba_data_files f,dba_tablespaces t
     where f.tablespace_name=t.tablespace_name
        union
     select \'TEMP\' FILE_TYPE,
            f.file_name,
            f.file_id,
            f.tablespace_name,
            f.status,
            round(f.bytes/1048576,2) MB,
            f.autoextensible,
            round(f.maxbytes/1048576,2) "Max MB",
            round((f.increment_by*t.block_size)/1048576,2) "Incr."
            from dba_temp_files f,dba_tablespaces t
     where f.tablespace_name=t.tablespace_name)
   where tablespace_name=upper(:TBLSPC)
   order by mb';
// php_beautifier->setBeautify(TRUE)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (!empty($AFILE)) {
        $rs = $db->Execute($AFILE);
    }
    $rs = $db->Execute($FILE, array('TBLSPC' => $TBLSPC));
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
