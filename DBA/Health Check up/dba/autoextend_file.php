<?php ob_start(); session_start();?>
<html>
<head>
<title>Autoextend File</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Autoextend File</h2>
<br>
<hr>
<?php
    require_once ('config.php');
    if (!empty($_GET['type'])) {
        $TYPE = $_GET['type'];
        $FNO = $_GET['file'];
    } elseif (!empty($_POST['type'])) {
        $TYPE = $_POST['type'];
        $FNO = $_POST['file'];
        $EXT = $_POST['ext'];
        $MAX = $_POST['max'];
        $INC = $_POST['inc'];
    } else die("File was called incorrectly!<br>");
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $INFO = "select f.file_name,
                  f.autoextensible,
                  ceil(f.maxbytes/1048576) as MAXMB,
                  ceil((f.increment_by*t.block_size)/1048576) as INCMB
           from dba_".$TYPE."_files f,dba_tablespaces t
           where f.tablespace_name=t.tablespace_name and
                 f.file_id=:FNO";
        $rs = $db->Execute($INFO, array('FNO'=>$FNO));
        $row = $rs->FetchRow();
        if (!empty($_GET['file'])) {
            $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
            $form->addBlank(2);
            $form->addBlank(1, $row[0]);
            $form->addHidden('file', $FNO);
            $form->addHidden('type', $TYPE);
            if ($row[1] == "YES") {
                $form->addCheckbox('ext', 'Autoextend', TRUE);
            } else {
                $form->addCheckbox('ext', 'Autoextend', FALSE);
            }
            $form->addText('max', 'Max Size:', $row[2].'M');
            $form->addText('inc', 'Increment by:', $row[3].'M');
            $form->addSubmit("submit", "Set");
            $form->display();
        }
        if (!empty($MAX)) {
            if ($EXT) {
                $RSZ = "alter database $TYPE"."file $FNO autoextend on "."next $INC maxsize $MAX";
            } else {
                $RSZ = "alter database $TYPE"."file $FNO autoextend off";
            }
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
