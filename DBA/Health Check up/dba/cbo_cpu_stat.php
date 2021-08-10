<?php session_start(); ?>
<html>
<head>
<title>CBO CPU Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>CBO CPU Statistics</h2>
<br>
<?php
require_once ('config.php');
$rattrib = array("align" => "center");
$version = $_SESSION['version'];
$SQL = 'select * from sys.aux_stats$';
$OE = 'select * from  V$SYS_OPTIMIZER_ENV';
$GETP = "begin
           :PVAL:=dbms_stats.get_param(:PNAME);
       end;";
$SETP = "begin
           dbms_stats.set_param(:PNAME,:PVAL);
       end;";
$PREFS = <<<'EOQ'
   select sname "Preference Name",
          spare4 "Value",
          sval2  "Last Change"
   from SYS.OPTSTAT_HIST_CONTROL$
EOQ;
$parms = array("CASCADE", "DEGREE", "ESTIMATE_PERCENT", "METHOD_OPT", "NO_INVALIDATE", "GRANULARITY", "AUTOSTATS_TARGET");
$parvalues = array();
$pname = NULL;
$pval = NULL;
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL);
    csr2html($rs, '  ');
    if ($version >= 10) {
        $setp = $db->PrepareSP($SETP);
        $db->InParameter($setp, $pname, 'PNAME');
        $db->InParameter($setp, $pval, 'PVAL');
        foreach ($parms as & $p) {
            if (!empty($_POST[$p])) {
                $pname = $p;
                $pval = $_POST[$p];
                $db->Execute($setp);
            }
        }
        $stmt = $db->PrepareSP($GETP);
        $db->InParameter($stmt, $pname, 'PNAME');
        $db->OutParameter($stmt, $pval, 'PVAL');
        print "<br><h2>Default CBO Parameters</h2><br>";
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        foreach ($parms as & $p) {
            $pname = $p;
            $db->Execute($stmt);
            $form->addText($pname, $pname, $pval, 64);
        }
        $form->addSubmit("submit", "Change");
        $form->display();
        if ($version >= 11) {
            $rs = $db->Execute($PREFS);
            echo "<h2>Global DBMS_STATS Preferences</h2><br>";
            csr2html($rs, '  ');
        }
        print "<br><h2>System Optimizer Environment</h2><br>";
        $rs = $db->Execute($OE);
        csr2html($rs, '  ');
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</center>
</body>
</html>
