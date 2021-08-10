<?php ob_start(); session_start();?>
<html>
<head>
<title>Resize File</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Resize File</h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $db = NewADOConnection("oci8");
    if (!empty($_GET['type'])) {
        $TYPE = $_GET['type'];
        $FNO = $_GET['file'];
    } elseif (!empty($_POST['type'])) {
        $TYPE = $_POST['type'];
        $FNO = $_POST['file'];
        $SIZE = $_POST['size'];
    } else die("File was called incorrectly!<br>");
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $INFO = "select file_name,ceil(bytes/1048576) as MB
           from dba_".$TYPE."_files
           where file_id=:FNO";
        $rs = $db->Execute($INFO, array('FNO'=>$FNO));
        $row = $rs->FetchRow();
        if (!empty($_GET['file'])) {
            $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
            $form->addBlank(3);
            $form->addHidden('file', $FNO);
            $form->addHidden('type', $TYPE);
            $form->addText('size', $row[0].':', $row[1].'M');
            $form->addSubmit("submit", "Resize");
            $form->display();
        } elseif (!empty($SIZE)) {
            $RSZ = "alter database $TYPE"."file $FNO resize $SIZE";
            $db->Execute($RSZ);
            $db->close();
            $INVOKER = $_SESSION['invoker'];
            header("location: $INVOKER");
        }
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
<hr>
</center>
</body>
</html>
