<?php session_start();?>
<html>
<head>
<title>Foreign Keys w/o Index</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Foreign Keys w/o Index</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$_SESSION['invoker'] = $_SERVER['PHP_SELF'];
$rattrib = array("align"=>"right");
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");

$owner = strtoupper(@$_POST['owner']);
if (empty($owner)) $owner= '%';

$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("owner", 'Owner pattern:', $owner);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
// PHP beautifier doesn't quite work with SQL statements.
// php_beautifier->setBeautify(false)
$FKEY = "select col.owner,
                col.table_name,
                col.column_name,
                con.constraint_name
         from (
             select owner,table_name,column_name
             from dba_cons_columns
             where (owner,table_name,constraint_name) in
                   (select owner,table_name,constraint_name
                    from dba_constraints
                    where owner like :OWN 
                    and constraint_type='R')
             minus
             select table_owner,table_name,column_name
             from dba_ind_columns
             where table_owner like :OWN) col,
             dba_cons_columns con
         where con.owner=col.owner and
               con.table_name=col.table_name and
               con.column_name=col.column_name
         order by 1,2,3,4";
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($FKEY, array('OWN'=>$owner));
    csr2html($rs, '  ');
    $db->close();
}
catch(Exception $e) {
    $db->RollbackTrans();
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
