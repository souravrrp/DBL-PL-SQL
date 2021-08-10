<?php session_start();?>
<html>
<head>
<title>File I/O Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>File I/O Statistics</h2>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $SQL = 'select f.name "File Name",
             s.file#,
             s.PHYRDS "Number of Reads",
             s.PHYWRTS "Number of Writes",
             s.PHYBLKRD "Blocks Read",
             s.PHYBLKWRT "Blocks Written",
             s.SINGLEBLKRDS "Single Blk Reads",
             s.AVGIOTIM  "AVG. I/O Time"
      from v$datafile f,v$filestat s
      where f.file#=s.file#
      order by 3 desc';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL);
        csr2html($rs, '  ');
        $db->close();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
