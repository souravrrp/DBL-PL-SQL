<?php session_start();?>
<html>
<head>
<title>DDL for <?=$_GET['own'] ?>.<?=$_GET['name'] ?></title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>DDL For <?=$_GET['own'] ?>.<?=$_GET['name'] ?></h2>
</center>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    $OBJTYP = $_GET['type'];
    switch ($OBJTYP) {
        case "MATERIALIZED VIEW":
             $OBJTYP="MATERIALIZED_VIEW";
             break;
        case "JOB":
             $OBJTYP="PROCOBJ";
             break;
    }
    $OWN = $_GET['own'];
    $NAME = $_GET['name'];
    $TERM = 'begin
          dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                           \'SQLTERMINATOR\',
                                            TRUE);
          end;';
    $TERM = preg_replace("/\r/", "", $TERM);
    $GET_DDL = 'select dbms_metadata.get_ddl(:TYP,:NAME,:OWN) as "Create Statement"
          from dual';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $db->Execute($TERM);
        $rs = $db->Execute($GET_DDL,array('TYP'=>$OBJTYP,
                                          'NAME'=>$NAME,
                                          'OWN'=>$OWN));
        echo "<b><pre>";
        while ($row = $rs->Fetchrow()) {
            echo $row[0], "\n";
        }
        echo "</pre></b>";
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
<hr>
</body>
</html>
