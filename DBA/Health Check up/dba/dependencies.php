<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Dependencies</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Dependencies</h2>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
// php_beautifier->setBeautify(false);
$QR1="SELECT owner,type,name 
      FROM dba_dependencies
      WHERE referenced_owner like :OWN and
            referenced_name  =    :OBJ and
            referenced_type  =    :TYP
      ORDER BY owner,type,name";
$QR2="SELECT owner,type,name 
      FROM dba_dependencies
      WHERE referenced_owner like :OWN and
            referenced_link_name  =  :OBJ
      ORDER BY owner,type,name";
// php_beautifier->setBeautify(true);
$otype = array("TABLE" => "TABLE", 
               "VIEW" => "VIEW",
               "SYNONYM" => "SYNONYM", 
               "SEQUENCE" => "SEQUENCE", 
               "PACKAGE" => "PACKAGE",             
               "PROCEDURE" => "PROCEDURE", 
               "FUNCTION" => "FUNCTION", 
               "TYPE" => "TYPE",
               "DB_LINK" => "DB_LINK");
if (!empty($_POST["own"])) {
    $own = strtoupper($_POST["own"]);
} else $own = "%";
if (!empty($_POST["obj"])) {
    $obj = strtoupper($_POST["obj"]);
} else $obj = NULL;
if (!empty($_POST["type"])) {
    $type = strtoupper($_POST["type"]);
} else $type = NULL;
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addSelect("type", 'Object type:', $otype);
$form->addText("own", "Owner:", $own, 32);
$form->addText("obj", "Object_name:", $obj, 32);
$form->addSubmit("submit", "Filter");
$form->addBlank(1);
$form->display();
if (!empty($obj) and !empty($type)) {
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if ($type != "DB_LINK") { 
           $SQL = $QR1; 
           $rs = $db->Execute($SQL, array('OWN' => $own, 
                                          'OBJ' => $obj,
                                          'TYP' => $type));
        } else { 
           $SQL = $QR2; 
           $rs = $db->Execute($SQL, array('OWN' => $own, 
                                          'OBJ' => $obj));
        }
                                          
        csr2html($rs, " ");
        printf("<H3>%d dependent objects found.</H3>",$rs->RecordCount());
        $db->close();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
}
?>
</center>
</body>
</html>
