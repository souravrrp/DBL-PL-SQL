<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Sessions, sorted by event</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Number of sessions, by event waited</h2>
<br>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$rattrib = array("align" => "right");
$SCHEMA = @$_SESSION['schema'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
// php_beautifier->setBeautify(false)
$SQL = 'SELECT sid,state,event,seconds_in_wait
        FROM   v$session_wait 
        WHERE sid in (SELECT sid from v$session
                      WHERE dba_helper.filter_schema(username,:SCHEMA)>0) and
              state=\'WAITING\'
        ORDER BY 4 desc';
$SQL1 = 'SELECT count(sid) "Waiting Sessions",event
         FROM v$session_wait 
         WHERE sid in (SELECT sid from v$session
                       WHERE dba_helper.filter_schema(username,:SCHEMA)>0) and
               state=\'WAITING\'
         GROUP BY event 
         ORDER BY 1 desc';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL1, array('SCHEMA' => $SCHEMA));
    csr2html($rs, '  ');
    echo "<h2>Sessions, by event waited</h2><br>";
    $rs = $db->Execute($SQL, array('SCHEMA' => $SCHEMA));
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
