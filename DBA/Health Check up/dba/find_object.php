<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Find Object</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Find Object</h2>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$typ = array('%' => 'ALL','OBJECT_ID' => 'OBJECT_ID');
$OBJ = @trim($_POST["obj"]);
$TYP = @strtoupper($_POST["typ"]);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (empty($OBJ)) {
        $SQL = 'SELECT distinct object_type 
                FROM dba_objects
                ORDER by object_type desc';
        $rs = $db->Execute($SQL);
        while ($row = $rs->FetchRow()) $typ[$row[0]] = $row[0];
        $db->close();
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(3);
        $form->addSelect("typ", 'Type:', $typ);
        $form->addText("obj", 'Object Name:', "", 32);
        $form->addSubmit("submit", "Find");
        $form->addBlank(2);
        $form->display();
    } elseif ($TYP == "OBJECT_ID") {
        $SQL = "SELECT owner,object_name,object_type,created 
                FROM  dba_objects 
                WHERE object_id = :OBJ";
        $rs = $db->Execute($SQL, array("OBJ" => $OBJ));
    } else {
        $SQL = "SELECT owner,
                       object_name,
                       object_type,
                       created,
                       dba_helper.obj_info(owner,
                                           object_type,
                                           object_name) as DDL
                FROM  dba_objects 
                WHERE object_name like upper(:OBJ) 
                AND   object_type like :TYP";
        $rs = $db->Execute($SQL, array("OBJ" => $OBJ, "TYP" => $TYP));
    }
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
