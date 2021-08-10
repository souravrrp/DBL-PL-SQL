<?php ob_start();session_start(); ?>
<html>
<head>
<title>Generate DB Link Scripts </title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>DDL Script For DB Links</h2>
</center>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$OWN = strtoupper(@$_POST['own']);
if (empty($OWN)) $OWN = '%';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addText("own", 'Owner:', $OWN, 20, 64);
$form->addSubmit("submit", "Generate");
$form->addBlank(1);
$form->display();
echo "<hr>";
// php_beautifier->setBeautify(false);
$TERM = 'begin
          dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                           \'SQLTERMINATOR\',
                                            TRUE);
          end;';
$TERM = preg_replace("/\r/", "", $TERM);
$GET_DDL = "SELECT owner,dbms_metadata.get_ddl('DB_LINK',object_name,owner) 
                   as \"DB Link\"
            FROM   dba_objects 
            WHERE  owner like :OWN and
                   object_type = 'DATABASE LINK'
            ORDER BY owner,object_name";
// php_beautifier->setBeautify(true);
try {
    if (!empty($OWN)) {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $db->Execute($TERM);
        $rs = $db->Execute($GET_DDL, array('OWN' => $OWN));
        csr2html($rs);
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
