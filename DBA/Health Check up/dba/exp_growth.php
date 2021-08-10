<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Export Tablespace Growth></title>
</head>
<body bgcolor="#EFECC7">
<?php
require_once ('config.php');
require_once('PEAR.php');
PEAR::setErrorHandling (PEAR_ERROR_DIE);
require('Mail.php');
require('Mail/mime.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$INVOKER=$_SESSION['invoker'];
$start=$_REQUEST['start'];
$pattern=$_REQUEST['patt'];
echo "<center><h2>Export TBS Growth Data</h2></center><br>";
echo "<h4>Tablespace names:$pattern</h4>";
echo "<h4>Export dates from:$start</h4>";
echo "<center>";
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("email", 'Send to:');
$form->addHidden('patt',$pattern);
$form->addHidden('start',$start);
$form->addSubmit("submit", "Export");
$form->addBlank(2);
$form->display();
// php_beautifier->setBeautify(false)
$SPACE = <<<EOQ
with detail as (select run_date,
       tbspace,
       used_space,
       used_space-lag(used_space) over (order by tbspace,run_date) growth
from capacity.space_detail
where tbspace not like '%UNDO%'
order by tbspace,run_date)
select  run_date,
        tbspace "Tablespace",
        used_space "Used Space(MB)",
        growth
from detail
where run_date>=to_date(:STRT,'YYYY-MM-DD') and
      tbspace like :PATTERN
EOQ;
$GROWTH = <<< EOQ
with detail as (select run_date,
       tbspace,
       used_space,
       used_space-lag(used_space) over (order by tbspace,run_date) growth
from capacity.space_detail
where tbspace not like '%UNDO%'
order by tbspace,run_date)
select  tbspace "Tablespace",
        round(avg(growth),2) "Average Growth (MB)"
from detail
where run_date>=to_date(:STRT,'YYYY-MM-DD') and
      tbspace like :PATTERN
group by tbspace
EOQ;

$DBDATA = <<<EOQ
with db_growth as (
select run_date,
       uspace "Used Space(MB)",
       uspace-lag(uspace) over (order by run_date) as growth
       from capacity.db_size)
       select * from db_growth
where run_date>=to_date(:STRT,'YYYY-MM-DD')
order by run_date
EOQ;

if (!isset($_POST['email']) or empty($_POST['email'])) exit;
$email=$_POST['email'];

$hdrs = array(
    'From' => 'dba_helper@vmsinfo.com',
    'To'   => $email,
     'Subject' => "TBS growth data for TBS like $pattern since $start"
);

$tbody = <<< EOB
Attached are tablespace growth details for the tablespaces conforming to the 
Oracle pattern $pattern, since the following date: $start
Also attached is the file with the growth information for the entire DB 
since the same date. 
--
Kindest regards,
Your DBA Helper.
EOB;
$mail =& Mail::factory('smtp');
if (!$mail) die("Cannot connect to the SMTP server");
$mime = new Mail_mime($crlf);
$mime->setTXTBody($tbody);
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SPACE, array('PATTERN' => $pattern,'STRT'=>$start));
    csr2xls($rs,"/tmp/tbs_space_detail.xls","Tablespace Details");
    $mime->addAttachment("/tmp/tbs_space_detail.xls", 
                    'Content-Type: application/vnd.ms-excel; charset=UTF-8');
    $rs = $db->Execute($GROWTH, array('PATTERN' => $pattern,'STRT'=>$start));
    csr2xls($rs,"/tmp/tbspace_growth.xls","Tablespace Growth");
    $mime->addAttachment("/tmp/tbspace_growth.xls", 
                    'Content-Type: application/vnd.ms-excel; charset=UTF-8');
    $rs = $db->Execute($DBDATA, array('STRT'=>$start));
    csr2xls($rs,"/tmp/DB_growth.xls","DB Growth");
    $mime->addAttachment("/tmp/DB_growth.xls", 
                    'Content-Type: application/vnd.ms-excel; charset=UTF-8');
    $db->close();
    $body = $mime->get();
    $hdrs = $mime->headers($hdrs);
    $mail->send($email, $hdrs, $body);
    header("location: $INVOKER");
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</center>
</body>
</html>
