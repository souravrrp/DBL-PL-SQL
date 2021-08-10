<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Trace File Analysis</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Trace File Analysis</h2><br><hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$ver = $_SESSION['version'];
$sid = $_GET['sid'];
$serial = $_GET['serial'];
$file = '';
$id = 0;
# php_beautifier->setBeautify(false);
#  The query to generate the trace file name was obtained from the Rene
#  Nyffenegger's collection, available at:
#           http://www.adp-gmbh.ch/ora/misc/find_trace_file.html
$FILE = "select dba_helper.get_trace_file(:SID,:SERIAL) as FL from dual";
$EID = 'begin
        :ID:=trcanlzr.trca$p.get_tool_execution_id;
      end;';
$EXEC = 'begin
         trcanlzr.trca$i.trcanlzr(p_file_name => :FL, x_tool_execution_id =>:ID);
       end;';
$RPT = 'SELECT column_value 
      FROM TABLE(trcanlzr.trca$g.display_file(:ID, \'HTML\'))';
# php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    # Get the trace file name for the session identified by 'sid,serial#'.
    $rs = $db->Execute($FILE, array('SID' => $sid, 'SERIAL' => $serial));
    $row = $rs->FetchRow();
    $file = $row[0];
    # Get the execution ID. That is needed to query the report.
    $rs = $db->Prepare($EID);
    $db->OutParameter($rs, $id, 'ID');
    $db->Execute($rs);
    # Execute the main procedure and analyze the file.
    $rs = $db->Execute($EXEC, array('FL' => $file, 'ID' => $id));
    # Get and present the report.
    $rs = $db->Execute($RPT, array('ID' => $id));
    csr2ascii($rs);
    $db->close();
}
catch(Exception $e) {
    echo "ID is:$id<br>";
    echo "File is:$file<br>";
    die($e->getMessage());
}
?>
</center>
</body>
</html>
