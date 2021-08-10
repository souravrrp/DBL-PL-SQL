<?php session_start(); ?>
<html>
<head>
<title>Recyclebin by Owner</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Recyclebin by Owner</h2>
<br>
<hr>
<?php
require_once ('config.php');
require_version(10);
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
$BS   =  "select value from v\$parameter where lower(name)='db_block_size'";
$TABS = 'select owner,
                object_name,
                original_name,
                operation,
                type,
                (space*:BS)/1048576 "Space (MB)",
                ts_name,
                createtime,
                droptime,
                partition_name,
                can_undrop,
                can_purge
         from dba_recyclebin
         where owner like upper(:PATTERN)
          order by space desc nulls last';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($BS);
    $tmp = $rs->FetchRow();
    $bs = $tmp[0];
    $rs = $db->Execute($TABS, array('PATTERN' => $pattern, 'BS' => $bs));
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
