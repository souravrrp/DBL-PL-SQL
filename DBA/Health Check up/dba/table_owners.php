<?php session_start();?>
<html>
<head>
<title>Table Owners</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Table Owners</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
if (isset($_POST['pattern'])) $pattern = $_POST['pattern'];
else $pattern = '%';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("pattern", 'Owner pattern:', $pattern);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
// php_beautifier->setBeautify(false)
$TABS = 'select dba_helper.tab_list(t.owner) as "Table Owner",
                count(t.table_name) as "Table Count",
                dba_helper.er_diag(t.owner) as "ER Diagram"
         from dba_tables t
         where t.owner like upper(:PATTERN) 
         group by t.owner
         order by t.owner';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($TABS, array('PATTERN'=>$pattern));
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
