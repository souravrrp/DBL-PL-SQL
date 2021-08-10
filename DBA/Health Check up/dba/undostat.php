<?php session_start();?>
<html>
<head>
<title>Undo Statistics</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Undo Statistics</h2>
<hr>
<?php
require_once ('config.php');
$rattrib = array("align"=>"left");
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$dt = date("m/d/Y H:i:s");

if (isset($_POST['end'])) 
   $end = $_POST['end'];
else $end = $dt;
if (isset($_POST['start'])) 
   $start = $_POST['start'];
else $start = $_SESSION['startup'];

echo "<h4>Enter start/end of the period as MM/DD/YYYY HH24:MI:SS</h4>";
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(2);
$form->addText("start", 'Start:', $start, 20, 25);
$form->addText("end", 'End  :', $end, 20, 25);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
//  php_beautifier->setBeautify(false);
$NLS="alter session set NLS_DATE_FORMAT='MM/DD/YYYY HH24:MI:SS'";
$PER="select * from (
	   select begin_time,end_time,
			 undoblks,
			 txncount-lag(txncount) over (order by begin_time) Trans,
			 maxquerylen,
			 maxconcurrency,ssolderrcnt
	   from v\$undostat
	   where begin_time >= to_date(:BEG,'MM/DD/YYYY HH24:MI:SS') and
			 end_time   <= to_date(:END,'MM/DD/YYYY HH24:MI:SS') and
			 txncount>0
	   order by begin_time desc)
	   where trans>0";
 
$AVG="select round(avg(undoblks),2) AVG_UNDOBLKS,
			 round(avg(txncount),2) AVG_TXNCOUNT,
			 round(avg(maxquerylen),2) AVG_MAXQUERYLEN, 
		     round(avg(maxconcurrency),2) AVG_MAXCONCURRENCY
      from v\$undostat
      where txncount>0";

$MIN="select round(min(undoblks),2) MIN_UNDOBLKS,
    		 round(min(txncount),2) MIN_TXNCOUNT,
			 round(min(maxquerylen),2) MIN_MAXQUERYLEN, 
		     round(min(maxconcurrency),2) MIN_MAXCONCURRENCY
      from v\$undostat
	  where txncount>0";

$MAX="select round(max(undoblks),2) MAX_UNDOBLKS,
			 round(max(txncount),2) MAX_TXNCOUNT,
			 round(max(maxquerylen),2) MAX_MAXQUERYLEN, 
		     round(max(maxconcurrency),2) MAX_MAXCONCURRENCY
	   from v\$undostat
      where txncount>0";

//  php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $db->Execute($NLS);
    $rs = $db->Execute($PER, array('BEG'=>$start, 'END'=>$end));
    csr2html($rs);
    echo "<h3>Averages For All Collected Samples</h3><hr>";
    echo "<h4>Average Values</h4>";
    $rs = $db->Execute($AVG);
    csr2html($rs);
    echo "<h4>Minimum Values</h4>";
    $rs = $db->Execute($MIN);
    csr2html($rs);
    echo "<h4>Maximum Values</h4>";
    $rs = $db->Execute($MAX);
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
