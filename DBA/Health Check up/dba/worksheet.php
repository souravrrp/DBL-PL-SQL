<?php ob_start();session_start(); ?>
<html>
<head>
<title>SQL Worksheet</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>SQL Worksheet</h2>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$PAGESZ = @$_SESSION['pagesz'];
$PAGENO = 0;
if (!empty($_POST['pageno'])) $PAGENO = $_POST['pageno'];
if (!empty($_POST['reset'])) $PAGENO = 0;
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$SQL = trim(@$_POST['sql']);
$GLINE = "begin dbms_output.get_line(:LINE,:STAT); end;";
$ENABLE = "begin dbms_output.enable(1000000); end;";
$EXEC = @$_SESSION['exec'];
$stat = 0;
$line = "";
$_SESSION['prevsql'] = $SQL;
if (!defined(@$_POST['sql'])) {
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addTextarea("sql", 'SQL:', @$_SESSION['prevsql'], 65, 12);
    $form->addHidden('pageno', $PAGENO+1);
    $form->addSubmit("reset", "First Page");
    $form->addSubmit("submit", "Next Page");
    $form->addBlank(2);
    $form->display();
}
echo "<hr>";
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (isset($_SESSION['date_format'])) {
        $fmt = $_SESSION['date_format'];
        $NLS = "alter session set nls_date_format='$fmt'";
        $db->Execute($NLS);
    }
    if (isset($EXEC) && ($EXEC != $DSN['username'])) {
        $db->Execute("alter session set current_schema=$EXEC");
    }
    /* Enable use of DBMS_OUTPUT immediately after login */
    $db->Execute($ENABLE);
    /* Check whether we have a query or PL/SQL block */
    preg_match('/^select/i', $SQL, $match);
    preg_match('/^(declare|begin)/i', $SQL, $match1);
    /* Remove offending \r characters which kill PL/SQL parser and
    execute the SQL */
    if (!empty($SQL)) {
        $SQL = preg_replace("/\r/", " ", $SQL);
        if (empty($match)) 
           $db->Execute($SQL);
        else 
       	   $rs = $db->SelectLimit($SQL, $PAGESZ, $PAGENO*$PAGESZ);
    }
    /* If query, show tabular output */
    if (!empty($match)) {
        csr2html($rs, " ");
    }
    /* If PL/SQL block, show DBMS_OUPTPUT */
    if (!empty($match1)) {
        $gl = $db->PrepareSP($GLINE);
        $db->OutParameter($gl, $line, 'LINE');
        $db->OutParameter($gl, $stat, 'STAT');
        print "</center><pre>\n";
        do {
            $db->Execute($gl);
            print "$line\n";
        }
        while ($stat == 0);
        print "</pre>\n";
    }
    $db->close();
}
catch(Exception $e) {
    $db->RollbackTrans();
    $db->close();
    die($e->getMessage());
}
?>
<h4>PAGE <?=$PAGENO+1?></h4><br>
</center>
</body>
</html>
