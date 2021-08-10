<?php ob_start(); session_start();?>
<html>
<head>
<title>Enable/Disable SQL Trace</title>
</head>
<body bgcolor="#EFECC7">
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$ver = $_SESSION['version'];
$sid = $_GET['sid'];
$serial = $_GET['serial'];
$onoff = $_GET['onoff'];
$INVOKER = "session_info.php?sid=$sid&serial=$serial";
if (empty($onoff)) {
    die("ONOFF undefined, routine called incorrectly! <br>");
}
if (($ver<10) and (!defined($_SESSION['binds']))) {
    $TRACEON = "begin
                    sys.dbms_support.start_trace_in_session(:SID,:SERIAL,TRUE);
                end;";
    $TRACEOFF = "begin
                     sys.dbms_support.stop_trace_in_session(:SID,:SERIAL);
                 end;";
} elseif ($ver<10) {
    $TRACEON = "begin
                    sys.dbms_support.start_trace_in_session(:SID,
                                                            :SERIAL,
                                                            TRUE,
                                                            TRUE);
                end;";
    $TRACEOFF = "begin
                     sys.dbms_support.stop_trace_in_session(:SID,:SERIAL);
                 end;";
} elseif ($_SESSION['binds'])  {
    $TRACEON = "begin
                    sys.dbms_monitor.session_trace_enable(:SID,
                                                          :SERIAL,
                                                          TRUE,
                                                          TRUE);
                end;";
    $TRACEOFF = "begin
                             sys.dbms_monitor.session_trace_disable(:SID,:SERIAL);
                             end;";
} else {
    $TRACEON = "begin
                             sys.dbms_monitor.session_trace_enable(:SID, :SERIAL, TRUE);
                             end;";
    $TRACEOFF = "begin
                             sys.dbms_monitor.session_trace_disable(:SID,:SERIAL);
                             end;";
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($onoff == 'ON') {
        $stmt = $db->prepareSP($TRACEON);
    } else {
        $stmt = $db->prepareSP($TRACEOFF);
    }
    $db->InParameter($stmt, $sid, 'SID');
    $db->InParameter($stmt, $serial, 'SERIAL');
    $db->Execute($stmt);
    $db->close();
    header("Location: $INVOKER");
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</body>
</html>
