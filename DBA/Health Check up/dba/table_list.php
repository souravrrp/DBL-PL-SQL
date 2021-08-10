<?php session_start();?>
<html>
<head>
<title>Table List</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>List of tables for <?=$_REQUEST['own'] ?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
if (isset($_GET['own'])) $own = $_GET['own'];
elseif (isset($_POST['own'])) $own = $_POST['own'];
else die("<h2>Unknown owner!</h2><br");
$_SESSION['invoker'] = $_SERVER['PHP_SELF']."?own=$own";
$pattern = @$_POST['pattern'];
if (empty($pattern)) {
    $pattern = '%';
}
// php_beautifier->setBeautify(false);
    $LIST = 'SELECT dba_helper.tab_info(:OWN,table_name) as "Table Name",
                    tablespace_name,
                    num_rows "Num Rows", 
                    blocks,
                    avg_row_len "Avg Row Len",
                    partitioned "Part.",
                    temporary   "Temp.",  
                    monitoring  "Monitor",
                    compression "Compression",
                    dba_helper.move_obj(:OWN,table_name,\'T\') "Relocate"
             FROM dba_tables
             WHERE owner=:OWN and
                   table_name like upper(:PATTERN)
             ORDER by table_name';
// php_beautifier->setBeautify(true);
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Name pattern:', $pattern);
$form->addHidden("own", $own);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($LIST, array('OWN'=>$own, 'PATTERN'=>$pattern));
    csr2html($rs, ' ');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<hr>
</center>
</body>
</html>
