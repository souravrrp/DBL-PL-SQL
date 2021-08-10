<?php session_start();?>
<html>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    $pat = '/^CORE\s+([0-9]+)/';
    $DSN = $_SESSION['DSN'];
    $DBA_HELPER=$_SESSION['dba_helper'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $_SESSION['schema']='ALL';
    $_SESSION['act_only']=0;
    $db   = NewADOConnection("oci8");
    $VER  = 'select * from v$version';
    $INST = "select userenv('INSTANCE') from dual";
    $TIM  = "select to_char(startup_time,'MM/DD/YYYY HH24:MI:SS'),
                    instance_number 
             from v\$instance";
    $DBID = 'select dbid from v$database';
    $INAME = "select value from v\$parameter where name='instance_name'";
    $DBASE="select value from v\$diag_info where name='ADR Base'";
    $DHOME="select value from v\$diag_info where name='ADR Home'";
    $matches=array();
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h4>DBA_Helper $DBA_HELPER: connected to database ", 
              strtoupper($DSN['database']), "</h4>\n";
        echo "<pre>\n";
        $rs1 = $db->Execute($VER);
        while ($row = $rs1->FetchRow()) {
            echo "\t", $row[0], "\n";
            if (preg_match($pat, $row[0], $match)) {
                $_SESSION['version'] = $match[1];
            }
        }
        if ($_SESSION['version']>=11) {
            $rs=$db->Execute($DBASE);
            $row=$rs->Fetchrow();
            $adr_base=$row[0];
            $rs=$db->Execute($DHOME);
            $row=$rs->Fetchrow();
            $adr_home=$row[0];
            $stat=preg_match("|$adr_base/(.*)|",$adr_home,$matches);
            if ($stat) {
				printf("\tADR Home:%s\n",$adr_home);
				$_SESSION['adr_home']=$matches[1];
			}
        }

        if (isset($_SESSION['date_format'])) 
           printf("\tDefault NLS date format:%s\n",$_SESSION['date_format']);
        if ( empty($_SESSION['pagesz']))
            $_SESSION['pagesz']=100;
 
        $rs1 = $db->Execute($INAME);
        $row = $rs1->FetchRow();
        $iname=$row[0];
        $_SESSION['iname']=$iname;
        $rs1 = $db->Execute($INST);
        $row = $rs1->FetchRow();
	    $inst=$row[0];
	    printf("\tInstance ID:%d NAME:%s\n",$inst,$iname);
        printf("\tPage size is:%d\n",$_SESSION['pagesz']);
        if ($_SESSION['binds'])
           printf("\tShowing bind values in trace\n");
        echo "</pre>\n";
        $rs2 = $db->Execute($TIM);
        $row = $rs2->FetchRow();
        $_SESSION['startup'] = $row[0];
        $_SESSION['inst_id'] = $row[1];
        $rs3 = $db->Execute($DBID);
        $row = $rs3->FetchRow();
        $_SESSION['dbid'] = $row[0];
        if ( empty($_SESSION['pagesz']))
            $_SESSION['pagesz']=100;
        $db->close();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</pre>
</body>
</html>
