<?php session_start();?>
<html>
<head>
<title>RMAN Jobs</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>RMAN Jobs</h2><br>
<hr>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"left");
    $db   = NewADOConnection("oci8");
    require_version(10);
$dt1=strtoupper(date("d-M-Y"));
$dt2='01-JAN-4000';
$fmt='DD-MON-YYYY';
if (!empty($_POST['dt1'])) $dt1=$_POST['dt1'];
if (!empty($_POST['dt2'])) $dt2=$_POST['dt2'];

// php_beautifier->setBeautify(false);
    $NLS_DATE="alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS'";
    $SQL1 = 'select dba_helper.job_output( SESSION_RECID,
                                          SESSION_STAMP) "Job Output",
                    START_TIME,END_TIME,INPUT_TYPE,STATUS,OUTPUT_DEVICE_TYPE,
                    round(ELAPSED_SECONDS,2) "Elapsed Seconds",
                    round(COMPRESSION_RATIO,2) "Compression Ratio",
                    OPTIMIZED, OUTPUT_BYTES_PER_SEC_DISPLAY "Output Rate",
                    TIME_TAKEN_DISPLAY "Time Taken"
             from v$rman_backup_job_details 
             where start_time between to_date(:DT1,:FMT) and to_date(:DT2,:FMT)
             order by start_time desc';
// php_beautifier->setBeautify(true)
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText('dt1','MIN DATE:',$dt1);
$form->addText('dt2','MAX DATE:',$dt2);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($NLS_DATE);
        $rs = $db->Execute($SQL1,array('DT1' => $dt1,
                                       'DT2' => $dt2,
                                       'FMT' => $fmt));
        csr2html($rs, '  ');
        $rs->close();
        $db->close();
    }
    catch(Exception $e) {
        $db->RollbackTrans();
        die($e->getTraceAsString());
    }
?>
<br>
</center>
</body>
</html>
