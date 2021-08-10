<?php session_start(); ?>
<html>
<head>
<title>SQL Lookup By ID</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>SQL Lookup By ID</h2>
<br>
<hr>
</center>
<?php
require_once ('config.php');
require_version(10);
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$ver = $_SESSION['version'];
$sqlid=trim(@$_POST['sqlid']);
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText("sqlid", 'SQL ID:',$sqlid,25);
$form->addSubmit("submit", "Search");
$form->addBlank(2);
$form->display();
if (empty($sqlid)) { exit; }
// php_beautifier->setBeautify(false)
$SQL = 
    'select  dba_helper.sql_info(rawtohex(ADDRESS),HASH_VALUE,SQL_ID) SQL,
            substr(sql_text,1,40) "SQL Beginning",
                SQL_ID,
            PARSING_SCHEMA_NAME,    
	        DISK_READS,
	        BUFFER_GETS,
	        ROWS_PROCESSED,
	        CPU_TIME,
	        ELAPSED_TIME,
	        PARSE_CALLS,
	        EXECUTIONS,
	        FETCHES,
	        SORTS,
	        OPEN_VERSIONS,
	        USERS_OPENING,
	        USERS_EXECUTING,
	        FIRST_LOAD_TIME,
	        INVALIDATIONS,
                SHARABLE_MEM,
	        RUNTIME_MEM,	
	        OPTIMIZER_MODE,
	        OPTIMIZER_COST
    from v$sql 
    where SQL_ID=:ID';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); 
    $rs = $db->Execute($SQL,array("ID"=>$sqlid));
    csr2html($rs, 'n/a');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</body>
</html>
