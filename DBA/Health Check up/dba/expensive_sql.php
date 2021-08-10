<?php session_start(); ?>
<html>
<head>
<title>Expensive SQL</title>
</head>
<body bgcolor="#EFECC7">	
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$db = NewADOConnection("oci8");
$ver = $_SESSION['version'];
$exec = @$_SESSION['exelim'];
if (isset($_POST['pattern'])) {
    $pattern = $_POST['pattern'];
} else {
    $pattern = "%";
}
$orderby = $_REQUEST['order'];
if (!is_numeric($exec)) $exec = 1000000000;
// php_beautifier->setBeautify(false)
if ($ver<10) {
$SQL = 'select * from (
    select  dba_helper.sql_info(rawtohex(ADDRESS),HASH_VALUE) SQL,
            substr(sql_text,1,40) "SQL Beginning",
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
    where executions<=:EXEC
    order by '.$orderby.' desc) 
    where rownum<100';
} else {
$SQL = 'select * from (
    select  dba_helper.sql_info(rawtohex(ADDRESS),HASH_VALUE,SQL_ID) SQL,
            substr(sql_text,1,40) "SQL Beginning",
            SQL_ID,
            PARSING_SCHEMA_NAME,
            EXECUTIONS,
	        DISK_READS,
	        CEIL(DISK_READS/EXECUTIONS) AS AVG_DISK_READS,
	        BUFFER_GETS,
	        CEIL(BUFFER_GETS/EXECUTIONS) AS AVG_BUFFER_GETS,
	        ROWS_PROCESSED,
	        CEIL(ROWS_PROCESSED/EXECUTIONS) AS AVG_ROWS_PROCESSES,
	        CPU_TIME,
	        CEIL(CPU_TIME/EXECUTIONS) AS AVG_CPU_TIME,
	        ELAPSED_TIME,
	        CEIL(ELAPSED_TIME/EXECUTIONS) AS AVG_ELAPSED_TIME,
	        PARSE_CALLS,
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
    where executions between 1 and :EXEC and
          parsing_schema_name like :NAME
    order by '.$orderby.' desc) 
    where rownum<100';
}
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']); ?>
    <center>
        <h2>SQL, by <?=$orderby ?></h2>
         <br>
    </center>
    <?php
    if ($ver >= 10) {
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(3);
        $form->addText("pattern", 'Owner pattern:', $pattern);
        $form->addHidden('order', $orderby);
        $form->addSubmit("submit", "Filter");
        $form->addBlank(2);
        $form->display();
        $rs = $db->Execute($SQL, array("EXEC" => $exec, "NAME" => $pattern));
    } else {
        $rs = $db->Execute($SQL, array("EXEC" => $exec));
    }
    csr2html($rs, 'n/a');
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
</body>
</html>
