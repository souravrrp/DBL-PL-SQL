<?php session_start();?>
<html>
<head>
<title><?=$_GET['own'] ?>.<?=$_GET['name'] ?> Info</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Description Of <?=$_GET['own'] ?>.<?=$_GET['name'] ?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$version=$_SESSION['version'];
if ($version >= 10) {
   $hist="\t\t\tc.histogram,\n\t\t\th.buckets,\n";
   $hist1="histogram,buckets,";
}
else {
   $hist="";
   $hist1="";
}
$db = NewADOConnection("oci8");
$own=$_GET['own'];
$tab=$_GET['name'];
$append="?own=$own&name=$tab";
$params = array('OWN'=>$own, 'TAB'=>$tab);
$_SESSION['invoker'] = $_SERVER['PHP_SELF'].$append;
// php_beautifier->setBeautify(false)
$DESC = "SELECT rownum num,column_name,type,len,precision,scale,$hist1 nullok
         FROM (
               SELECT c.column_name,
                      c.data_type as type,
                      c.data_length as len,
                      c.data_precision as precision,
                      c.data_scale as scale,
		              $hist
                      c.nullable as nullok
               FROM dba_tab_columns c,
                    (SELECT owner,table_name,column_name,count(*) as buckets
                     FROM dba_histograms
                     WHERE owner=:OWN and
                           table_name=:TAB 
                     GROUP BY owner,table_name,column_name ) h
               WHERE c.owner=:OWN and
                     c.table_name=:TAB and
                     c.table_name = h.table_name(+) and
                     c.column_name = h.column_name(+) and
                     c.owner = h.owner(+)
               ORDER BY c.column_id)";
$CONS = 'SELECT 
            dba_helper.obj_info(:OWN,
                decode(tc.constraint_type,
                       \'R\',
                       \'REF_CONSTRAINT\',
                       \'CONSTRAINT\'),
                cc.constraint_name) Name,
            tc.constraint_type,
            cc.column_name,
            cc.position,
            tc.status,
            tc.r_constraint_name
         FROM dba_cons_columns cc,dba_constraints tc
         WHERE cc.owner=tc.owner AND
               cc.table_name=tc.table_name AND
               cc.constraint_name=tc.constraint_name AND
               cc.owner=:OWN AND
               cc.table_name=:TAB
         ORDER BY tc.status,cc.constraint_name,cc.position';
$PART = 'SELECT partition_name,subpartition_count,tablespace_name,
                 partition_position,num_rows,blocks,composite
         FROM  dba_tab_partitions
         WHERE table_owner=:OWN AND
               table_name=:TAB
         ORDER BY partition_position';
$INDS = 'SELECT 
            dba_helper.obj_info(ic.index_owner,\'INDEX\',ic.index_name) Name,
            ti.tablespace_name,
            ti.index_type,
            ti.uniqueness,
            ti.status,
            ic.column_name,
            ic.column_position,
            ti.clustering_factor,
            ti.num_rows,
            ti.distinct_keys,
            dba_helper.move_obj(ic.index_owner,ic.index_name,\'I\') Relocate
          FROM dba_ind_columns ic,dba_indexes ti
          WHERE ic.index_owner=ti.owner AND
                ic.index_name=ti.index_name AND 
                ic.table_name=:TAB and 
                ic.table_owner=:OWN
          ORDER BY ic.index_name,ic.column_position';
$TRGS = "SELECT 
            owner,
            dba_helper.obj_info(owner,'TRIGGER',trigger_name) Name,
            trigger_type,
            status,
            triggering_event,
            action_type
            column_name,
            when_clause
         FROM DBA_TRIGGERS
         WHERE TABLE_OWNER=:OWN and 
               TABLE_NAME =:TAB
         ORDER BY trigger_name";
           
            
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($DESC, $params);
    csr2html($rs);
    ?>
<br>
<A href="object_info.php?own=<?=$_GET['own'] ?>&name=<?=$_GET['name'] ?>&type=TABLE" target="_blank">Generate DDL</A><BR>
<?php   
    $rs = $db->Execute($PART, $params);
    if ($rs->RecordCount() >0) {
        print "<h2>Partitions</h2><br>";
        csr2html($rs);
    }
    $rs = $db->Execute($CONS, $params);
    if ($rs->RecordCount() >0) {
        print "<h2>Constraints</h2><br>";
        csr2html($rs);
    }
    $rs = $db->Execute($TRGS, $params);
    if ($rs->RecordCount() >0) {
        print "<h2>Triggers</h2><br>";
        csr2html($rs);
    }
    $rs = $db->Execute($INDS, $params);
    if ($rs->RecordCount() >0) {
        print "<h2>Indexes</h2><br>";
        csr2html($rs);
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<br>
<A href="tab_data.php?own=<?=$_GET['own'] ?>&
                      name=<?=$_GET['name'] ?>"
target="_blank">Table Data</A>
<hr>
</center>
</body>
</html>
