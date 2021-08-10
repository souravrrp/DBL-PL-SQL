<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Module Trace Start/Stop</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2></h2>
<hr>
<?php
require_once ('config.php');
require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$ACTS = 'select distinct action from V$SESSION';
$MODS = 'select distinct module from V$SESSION';
$SERVS = 'select distinct name from dba_services';
$START_TRC = <<<EOQ
declare
bnds boolean := FALSE;
begin
if (:BINDS = 'on') then 
   bnds:=TRUE;
end if;
DBMS_MONITOR.SERV_MOD_ACT_TRACE_ENABLE(
   service_name  => :SERVICE,
   module_name   => :MODULE,
   action_name   => :ACTION,
   waits         => TRUE,
   binds         => bnds,
   instance_name => NULL);
end;
EOQ;
$STOP_TRC = <<<EOQ
begin
DBMS_MONITOR.SERV_MOD_ACT_TRACE_DISABLE(
   service_name  => :SERVICE,
   module_name   => :MODULE,
   action_name   => :ACTION,
   instance_name => NULL);
end;
EOQ;
$action = @$_POST['action'];
if (empty($action)) $action = '###ALL_ACTIONS';
$module = @$_POST['module'];
$service = @$_POST['service'];
$opcode = @$_POST['opcode'];
$binds = @$_POST['binds'];
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (!empty($action) and !empty($module) and !empty($service) ) {
        $args = array('SERVICE' => $service, 
                      'MODULE'  => $module, 
                      'ACTION'  => $action, 
                      'BINDS'   => $binds);
        if ($opcode == 'Start') {
            $db->execute($START_TRC, $args);
        } elseif ($opcode == 'Stop') {
            $db->execute($STOP_TRC, $args);
        }
        $db->close();
        header('Location: sessions.php');
    } else {
        $rs = $db->Execute($ACTS);
        while ($row = $rs->FetchRow()) {
            $acts[$row[0]] = $row[0];
        }
        $rs = $db->Execute($MODS);
        while ($row = $rs->FetchRow()) {
            $mods[$row[0]] = $row[0];
        }
        $rs = $db->Execute($SERVS);
        while ($row = $rs->FetchRow()) {
            $servs[$row[0]] = $row[0];
        }
        $db->close();
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(3);
        $form->addSelect("action", 'Action:', $acts);
        $form->addSelect("module", 'Module:', $mods);
        $form->addSelect("service", 'Service:', $servs);
        $form->addCheckBox("binds", 'Binds in trace:', FALSE);
        $form->addSubmit("opcode", "Start");
        $form->addSubmit("opcode", "Stop");
        $form->addBlank(2);
        $form->display();
    }
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
