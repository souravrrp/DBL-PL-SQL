<?php session_start();?>
<html>
<head>
<title>Database Files</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Database Files & Tablespaces</h2>
<br>
<?php
    require_once ('config.php');
    $_SESSION['invoker']=$_SERVER['PHP_SELF'];
    $rattrib = array("align"=>"right");
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
         where f.tablespace_name=t.tablespace_name and 
               f.file_name like :PATT
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
         where f.tablespace_name=t.tablespace_name and
               f.file_name like :PATT)
       order by file_type,tablespace_name';
    $TBSP = "select * from dba_tablespaces order by tablespace_name";
    $PATT = '%';
    if (!empty($_POST['patt'])) {
        $PATT = $_POST['patt'];
    }
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText('patt', 'Filename pattern:', '%');
    $form->addSubmit("submit", "Filter");
    $form->addBlank(2);
    $form->display();
    echo "<hr>\n";
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<br><h3>Database Files<h3><br>";
        $rs = $db->Execute($FILE,array('PATT'=>$PATT));
        csr2html($rs, '  ');
        echo "<br><h3>Tablespaces<h3><br>";
        $rs = $db->Execute($TBSP);
        csr2html($rs, '  ');
        $db->close();
    }
    catch(Exception $e) {
        $db->RollbackTrans();
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
