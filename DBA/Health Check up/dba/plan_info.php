<?php session_start();?>
<html>
<head>
<title>Explain Plan</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Execution Plan</h2>
</center>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ver = $_SESSION['version'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $addr = $_GET['addr'];
    $hash = $_GET['hash'];
    $id   = $_GET['id'];
    $attr= array('ADDR'=>$addr, 'HASH'=>$hash); 
    $CHLD='select min(child_number) 
           from V$SQL_PLAN
           where address=hextoraw(:ADDR) and
                 hash_value=:HASH';
    if ($ver < 10) {
        $SQL = 'select level,operation,options,object_name,
                       optimizer,cost,cardinality
                from (
                      select * from   V$SQL_PLAN
                      where address=hextoraw(:ADDR) and 
                            hash_value=:HASH and 
                            child_number = :CHILD
                )
                connect by prior id = parent_id
                start with id=0';
    } else {
        $SQL = "select * 
                from table(dbms_xplan.display_cursor(:ID,:CHILD,'ADVANCED'))";
    }
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs=$db->Execute($CHLD,$attr);
        $row=$rs->FetchRow();
        $child=$row[0];
        if ($ver >= 10) $attr=array('ID'=>$id);
        $attr['CHILD']=$child;
        
        $rs = $db->Execute($SQL, $attr);
        if ($ver < 10) 
           csr2html($rs, " ");
        else csr2ascii($rs);
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
</body>
</html>
