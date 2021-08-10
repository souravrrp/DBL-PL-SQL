<?php session_start();?>
<html>
<head>
<title>Generate Object Scripts </title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>DDL Script For User(All objects of the same type)</h2>
</center>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$OBJTYP = @$_POST['type'];
$PATTERN =@$_POST['pattern'];
if (empty($PATTERN)) $PATTERN='%';
$OWN = strtoupper(@$_POST['own']);
$types = array("TABLE"     => "TABLE", 
	       "INDEX"     => "INDEX",
               "CLUSTER"     => "CLUSTER",
               "PROCEDURE" => "PROCEDURE", 
               "FUNCTION"  => "FUNCTION", 
               "PACKAGE"   => "PACKAGE", 
               "SYNONYM"   => "SYNONYM", 
               "SEQUENCE"   => "SEQUENCE", 
               "VIEW"      => "VIEW",
               "MVIEW"     => "MVIEW");
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addText("own", 'Owner:', $OWN, 20, 64);
$form->addText("pattern", 'Pattern:', $PATTERN, 20, 64);
$form->addSelect("type", 'Object Type:', $types);
$form->addSubmit("submit", "Generate");
$form->addBlank(2);
$form->display();
$TERM = 'begin
          dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                           \'SQLTERMINATOR\',
                                            TRUE);
          end;';
$TERM = preg_replace("/\r/", "", $TERM);
$GET_DDL = 'select dbms_metadata.get_ddl(:TYP,object_name,owner) 
                from  dba_objects 
                where owner like :OWN and
                      object_type = :TYP and
                      object_name like :PATTERN
                order by owner';

$GET_MV  = "select dbms_metadata.get_ddl('MATERIALIZED_VIEW',object_name,owner) 
                from  dba_objects 
                where owner like :OWN and
                      object_type = 'MATERIALIZED VIEW' and
                      object_name like :PATTERN
                order by owner,object_name";
try {
    if (!empty($OBJTYP) && !empty($OWN)) {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $db->Execute($TERM);
        if ($OBJTYP=='MVIEW') {
           $rs = $db->Execute($GET_MV, array('OWN' => $OWN,
                                             'PATTERN' => $PATTERN));
        } else {
           $rs = $db->Execute($GET_DDL, array('TYP'=>$OBJTYP, 
                                              'OWN'=>$OWN,
                                              'PATTERN' => $PATTERN));
        }
        echo "<b><pre>";
        while ($row = $rs->Fetchrow()) {
            echo $row[0], "\n";
        }
        echo "</pre></b>";
        echo "<br><br><b>There were ", $rs->RecordCount(), 
             " objects satisfying the criteria</b><br>";
        $db->close();
    }
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<hr>
</body>
</html>
