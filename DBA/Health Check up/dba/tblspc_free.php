<?php session_start();?>
<html>
<head>
<title>Available Free Space</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Available Free Space</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$rattrib = array("align"=>"right");
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
// php_beautifier->setBeautify(false);
$SQL='select  dba_helper.ts_info(fs.tablespace_name) as "Tablespace",  
              dba_helper.seg_info(fs.tablespace_name) as "Segments",
              nvl(fs.mb,0) as "Free MB", 
              ts.mb        as "Total MB",  
              round(100*nvl(fs.mb,0)/ts.mb,2) as "Pct. Free"
      from  (select tablespace_name, round(sum(bytes)/1048576,2) mb
             from dba_free_space
             group by tablespace_name 
                union 
             select tablespace_name,0 
             from   dba_tablespaces t
             where  contents != \'TEMPORARY\' and
             not exists (select 1 from dba_free_space
                         where tablespace_name = t.tablespace_name)) fs,
             (select tablespace_name,round(sum(bytes)/1048576,2) mb
              from dba_data_files
              group by tablespace_name) ts
      where ts.tablespace_name = fs.tablespace_name and
            ts.tablespace_name like upper(:PATT)
      order by 5';
$pattern=@$_POST['pattern'];
if (empty($pattern)) { $pattern='%'; }

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Name pattern:', $pattern);
$form->addHidden("typ",$type);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();

// php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL,array('PATT'=>$pattern));
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
