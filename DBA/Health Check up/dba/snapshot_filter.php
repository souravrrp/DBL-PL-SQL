<?php session_start();
ob_start(); ?>
<html>
<head>
<title>Generate AWR Report</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Generate AWR Report</h2>
<hr>
<?php
require_once ('config.php');
require_version(10);
$version=$_SESSION['version'];
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$inst = $_SESSION['inst_id'];
$dbid = $_SESSION['dbid'];
if ($version == 10) {
    $AWR  = "select output 
             from table(dbms_workload_repository.awr_report_html(
                                                :DBID,
                                                :INST,
                                                :BEG,
                             ..                 :OVR))";
} elseif ($version == 11) {
    $AWR  = "select output 
             from table(dbms_workload_repository.awr_report_html(
                                                :DBID,
                                                :INST,
                                                :BEG,
                                                :OVR,
                                                0))";
}
$SQLB = 'with beg as (select snap_id,begin_interval_time 
                      from dba_hist_snapshot
                      order by begin_interval_time desc)
         select snap_id,begin_interval_time from beg where rownum<35';


$beg = @$_POST["beg"];
$end = @$_POST["end"];
if ( $beg > $end ) {
   die("Beginning must come before the end.<BR>");
}

try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQLB);
    while ($row = $rs->FetchRow()) {
        $BEG[$row[0]] = $row[1];
    }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addSelect("beg", 'Begining:', $BEG);
    $form->addSelect("end", 'End:', $BEG);
    $form->addSubmit("submit", "Generate");
    $form->addBlank(2);
    $form->display();
    if (isset($beg) and isset($end) and ($beg < $end)) {
       print("DBDID:$dbid INST:$inst\n");
       print("BEG: $beg  OVR: $end\n");
       $rs=$db->Execute($AWR,array("DBID"=>$dbid,
                                   "INST"=>$inst,
                                   "BEG"=>$beg,
                                   "OVR"=>$end));
       while ($row=$rs->Fetchrow()) {
           echo $row[0];
       }
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
