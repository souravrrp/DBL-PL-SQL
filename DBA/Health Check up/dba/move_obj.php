<?php ob_start();session_start();?>
<html>
<head>
<title>Relocate Database Objects</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $invoker = $_SESSION['invoker'];
    $sel_list=array();
    $own=@$_GET['own'];
    if (empty($own)) $own=@$_POST['own'];
    $name=@$_GET['name'];
    if (empty($name)) $name=@$_POST['name'];
    $type=@$_GET['type'];
    if (empty($type)) $type=@$_POST['type'];
    $params=array("OWN"=>$own,"NAME"=>$name);
//php_beautifier->setBeautify(false);
    switch ($type) {
        case "I":
            $MOV="ALTER INDEX $own.$name REBUILD TABLESPACE ";
            $DEF="SELECT tablespace_name 
                  FROM dba_indexes 
                  WHERE owner=:OWN AND
                        index_name=:NAME";
            echo "<h2>Relocate/Rebuild Indexes</h2><br><hr>";
            break;
        case "T":
            $MOV="ALTER TABLE $own.$name MOVE TABLESPACE ";
            $DEF="SELECT tablespace_name 
                  FROM dba_tables
                  WHERE owner=:OWN AND
                        table_name=:NAME";
            echo "<h2>Relocate Tables</h2><br><hr>";
            break;
        default:
           die( "<br><h2>Unknown object type to relocate</h2><br>");
    }
    $TS="SELECT tablespace_name,tablespace_name
         FROM DBA_TABLESPACES
         WHERE contents='PERMANENT' AND
               tablespace_name not like 'SYS%'
         ORDER BY 1";
//php_beautifier->setBeautify(true);
    $db = NewADOConnection("oci8");
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs=$db->Execute($TS);
        while ($row=$rs->FetchRow()) {
            $sel_list[$row[0]]=$row[1];
        }
        $rs=$db->Execute($DEF,$params);
        $row=$rs->FetchRow();
        $dflt_ts=$row[0];
        if (@empty($_POST['target'])) {
            $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
            $form->addBlank(3);
            $form->addSelect('target', 
                             'Target Tablespace:', 
                              $sel_list,
                              $dflt_ts);
            $form->addHidden('own',$own);
            $form->addHidden('name',$name);
            $form->addHidden('type',$type);
            $form->addSubmit("submit", "Change");
            $form->addBlank(2);
            $form->display(); 
       } else { 
            $MOV = $MOV.$_POST['target'];
            $db->Execute($MOV);
            header("location: $invoker");
            exit;
       }
    }
    catch(Exception $e) {
        print "$SQL<br>";
        die($e->getTraceAsString());
    }
?>
<hr>
</center>
</body>
</html>
