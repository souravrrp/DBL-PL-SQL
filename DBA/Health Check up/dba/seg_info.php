<?php session_start();?>
<html>
<head>
<title>Segment Info</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Segments in <?=$_GET['tblspc'] ?></h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    $TBLSPC = $_GET['tblspc'];
    $_SESSION['invoker'] = $_SERVER['PHP_SELF']."?tblspc=$TBLSPC";
    $FILE = 'select owner,
             segment_name,
             segment_type,
             dba_helper.get_lob(owner,segment_name,segment_type,partition_name) 
                as "LOB TABLE",
             partition_name,
             round(bytes/1048576,2) MB
       from dba_segments
       where tablespace_name=upper(:TBLSPC)
       order by MB desc,owner,segment_type';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($FILE, array('TBLSPC'=>$TBLSPC));
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
