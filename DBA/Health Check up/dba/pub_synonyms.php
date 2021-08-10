<?php session_start();?>
<html>
<head>
<title>Public Synonyms</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Create Public Synonyms For Single Owner</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $SQL = "select 'create or replace public synonym '||synonym_name||' for '||
                   table_owner||'.'||table_name||';' as create_command 
      from dba_synonyms
      where owner='PUBLIC' and
            table_owner != 'SYS' and
            table_owner like upper(:PATTERN)";
    
    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Owner:', $pattern);
    $form->addSubmit("submit", "Filter");
    $form->addBlank(2);
    $form->display();

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL, array('PATTERN'=>$pattern));
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
