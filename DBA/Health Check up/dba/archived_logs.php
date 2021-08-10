<?php ob_start(); session_start();?>
<html>
<head>
<title>Archived Logs</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Archived Logs</h2>
<?php
require_once ('config.php');
$rattrib = array("align"=>"left");
$fmt=$_SESSION['date_format'];
if (empty($fmt)) $fmt='DD-MON-YYYY';
$mod=0;
if (!empty($_POST['dt1'])) $dt1=$_POST['dt1'];
if (!empty($_POST['dt2'])) $dt2=$_POST['dt2'];
if (!empty($_POST['thrd'])) $thread=$_POST['thrd'];
if (!empty($_POST['seq1'])) $seq1=$_POST['seq1'];
if (!empty($_POST['seq2'])) $seq2=$_POST['seq2'];
else $seq2=$seq1;
$attr=array('DT1'  => $dt1,
            'DT2'  => $dt2,
            'FMT'  => $fmt,
            'THRD' => $thread,
            'SQ1'  => $seq1,
            'SQ2'  => $seq2);
    
// php_beautifier->setBeautify(false);
$SQL1 = 'select DEST_ID,
  	        NVL(NAME,\'*** DELETED ***\') as "ARCHIVE NAME",
		THREAD#,SEQUENCE#,FIRST_CHANGE#,
		to_char(FIRST_TIME,\'DD-MON-YYYY HH24:MI:SS\') as 
                           "FIRST_TIME",
		NEXT_CHANGE#,
		to_char(NEXT_TIME,\'DD-MON-YYYY HH24:MI:SS\') as 
                           "NEXT TIME",
		STANDBY_DEST,ARCHIVED, APPLIED,
                        (blocks+1)*block_size as "SIZE"
  	 from v$archived_log 
	 where 1 = 1 ';

if (!empty($dt1) & !empty($dt2)) {
   $SQL1=$SQL1.
         "AND FIRST_TIME BETWEEN TO_DATE(:DT1,:FMT) and TO_DATE(:DT2,:FMT)";
   $mod=1;
}
if (!empty($thread)) {
   $SQL1=$SQL1." AND THREAD# = :THRD";
   $mod=1;
}
if (!empty($seq1) ) {
   $SQL1=$SQL1." AND SEQUENCE# BETWEEN :SQ1 AND :SQ2";
   $mod=1;
}
// php_beautifier->setBeautify(true)

$SQL1=$SQL1.' order by dest_id,thread#,sequence# desc';
$SWITCH="alter system switch logfile";
$ARCH="alter system archive log current";
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addText('dt1','MIN DATE:',$dt1);
$form->addText('dt2','MAX DATE:',$dt2);
$form->addText('thrd','Thread#:',$thread);
$form->addText('seq1','Low Seq#:',$seq1);
$form->addText('seq2','Hi Seq#:',$seq2);
$form->addSubmit("action", "Search");
$form->addSubmit("action", "Switch Logs");
$form->addSubmit("action", "Archive Logs");
$form->display();

try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($mod) {
	$rs = $db->Execute($SQL1,$attr);
	csr2html($rs, '  ');
        $rs->close();
    }
    if ($_POST['action'] == "Switch Logs") {
        $db->Execute($SWITCH);
    } 
    if ($_POST['action'] == "Archive Logs") {
        $db->Execute($ARCH);
    } 
    $db->close();
}
catch(Exception $e) {
    $db->RollbackTrans();
    die($e->getTraceAsString());
}
?>
<br>
<hr>
</center>
</body>
</html>
