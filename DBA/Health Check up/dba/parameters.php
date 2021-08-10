<?php session_start();?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2//EN">
<html>
<head>
<meta name="generator" content=
"HTML Tidy for Linux/x86 (vers 1st September 2004), see www.w3.org">
<title>Instance Parameters</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Instance Parameters</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
if (isset($_POST['pattern'])) $pattern = strtoupper($_POST['pattern']);
else $pattern = '%';
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(1);
$form->addText("pattern", 'Pattern:', $pattern);
$form->addSubmit("submit", "Filter");
$form->display();
//  php_beautifier->setBeautify(false);
$SQL = 'select dba_helper.change_param(name,issys_modifiable) "Name",
               value,
               isdefault,
               ismodified,
               description 
        from v$parameter2
        where upper(name) like :PATTERN
        order by name';
$OBS = 'select name as "Obsolete Parameters"
        from v$obsolete_parameter 
        where isspecified=\'TRUE\'';
//  php_beautifier->setBeautify(true);
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL,array('PATTERN'=>$pattern));
    csr2html($rs);
    $rs=$db->Execute($OBS);
    if ($rs->RecordCount( ) > 0) {
       echo "<H2>Obsolete Parameters Specified</H2>";
       csr2html($rs);
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
