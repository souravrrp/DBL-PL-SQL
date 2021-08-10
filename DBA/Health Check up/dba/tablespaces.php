<?php session_start();?>
<html>
<head>
<title>Tablespace Recreation Statements</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Create Tablespace SQL</h2>
</center>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $rattrib = array("align"=>"left");
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $PATT = '%';
    if (!empty($_POST['patt'])) {
        $PATT = $_POST['patt'];
    }
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText('patt', 'Tablespace pattern:', '%');
    $form->addSubmit("submit", "Filter");
    $form->addHidden("do", "Y");
    $form->addBlank(2);
    $form->display();
    echo "<hr>\n";
    $TERM = "begin
       dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                         'SQLTERMINATOR',
                                         TRUE);
       end;";
    $TERM = preg_replace("/\r/", "", $TERM);
    $SQL = "select dbms_metadata.get_ddl('TABLESPACE',tablespace_name) SQL
      from dba_tablespaces 
      where tablespace_name !='SYSTEM' 
      and tablespace_name like upper(:PATT)
      order by contents,tablespace_name";
    if (!empty($_POST['do'])) try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $db->Execute($TERM);
        $rs = $db->Execute($SQL, array('PATT'=>$PATT));
        echo "<b><pre>\n";
        while ($row = $rs->FetchRow()) {
            echo $row[0], "\n";
        }
        echo "</pre></b>\n";
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
<br>
<hr>
</body>
</html>
