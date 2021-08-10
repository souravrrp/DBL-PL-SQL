<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Client ID Trace Start/Stop</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Client ID Trace Start/Stop</h2>
<hr>
<?php
require_once ('config.php');
require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$sids=array();
$CLTS="select distinct client_info from V\$SESSION where type='USER'";
$SIDS='select sid,serial# from v$session where client_info=:CLIENT';

$START_TRC = <<<EOQ
DECLARE
  bnds BOOLEAN := FALSE;
BEGIN
  IF (:BINDS='on') THEN
     bnds   :=TRUE;
  END IF;
  sys.dbms_monitor.session_trace_enable(:SID, :SERIAL, TRUE, bnds);
END;
EOQ;

$STOP_TRC = <<<EOQ
begin
:BINDS:=NULL;
sys.dbms_monitor.session_trace_disable(:SID,:SERIAL);
end;
EOQ;


$client = @$_POST['client'];
$binds  = @$_POST['binds'];
$opcode = @$_POST['opcode'];

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if (!empty($client)) {
                $rs=$db->Execute($SIDS,array('CLIENT'=>$client));
                while($row=$rs->FetchRow()) {
                        $sids[$row[0]]=$row[1];
                }
                foreach ($sids as $key => $val) {
                    $args=array('SID'     => $key,
                                'SERIAL'  => $val, 
                                'BINDS'   => $binds);
		    if ($opcode == 'Start') {
                       $SQL=$START_TRC;
                       $db->execute($SQL,$args);
                    } elseif ($opcode == 'Stop') {
                       $SQL=$STOP_TRC;
                       $db->execute($SQL,$args);
                    }
		}
		$db->close();
		header('Location: sessions.php');
		} else {
        	$rs = $db->Execute($CLTS);
        	while ($row = $rs->FetchRow()) {
            	$clts[$row[0]] = $row[0];
        	}
        	$db->close();
        	$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
       		$form->addBlank(3);
        	$form->addSelect("client", 'Clients:', $clts);
        	$form->addCheckBox("binds", 'Binds in trace:', FALSE);
        	$form->addSubmit("opcode", "Start");
        	$form->addSubmit("opcode", "Stop");
        	$form->addBlank(2);
        	$form->display();
        }
    }
    catch(Exception $e) {
#         print "$SQL<br>";
#         print "Client = $client<br>";
#         print "Binds  = $binds<br>";
#         print "Opcode = $opcode<br>";
#         print "<br><br>";
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
