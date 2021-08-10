<?php session_start();?>
<html>
<head>
<title>System events,by time waited</title>
</head>
<body bgcolor="#EFECC7">
<center>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align"=>"right");
    $db   = NewADOConnection("oci8");
    $SQL1 = 'select event,total_waits,time_waited,average_wait
      from   v$system_event
      order by time_waited desc';
    $SQL2 = 'select * from v$waitstat order by  time desc';
    $SQL3 = 'select stat_name,value from v$sys_time_model order by value desc';
    $SQL4 = <<<'EOQ'
          select nvl(to_char(inst_id),'Total:') as "Instance",
                function_name as "IO Function Name",
                read_mb,write_mb
          from (
              select inst_id,function_name,
                     sum(small_read_megabytes+large_read_megabytes) read_mb,
                     sum(small_write_megabytes+large_write_megabytes) write_mb
              from gv$iostat_function
              group by cube (inst_id,function_name) 
              order by inst_id,function_name
          )
EOQ;
    $FSP="alter system flush shared_pool";
    $BFP="alter system flush buffer_cache";
    $fsp=@$_POST['fsp'];
    $fbc=@$_POST['fbc'];
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        echo "<h2>System events,by time waited</h2><br>";
        $rs = $db->Execute($SQL1);
        csr2html($rs, '  ');
        $rs->close();
        if ($_SESSION['version']>=10) {
            echo "<h2>System Time Model</h2><br>";
            $rs = $db->Execute($SQL3);
            csr2html($rs, '  ');
            $rs->close(); 
        }   
        if ($_SESSION['version']>=11) {
            echo "<h2>IO details</h2><br>";
            $rs = $db->Execute($SQL4);
            csr2html($rs, '  ');
            $rs->close(); 
        }   
        echo "<br><h2>Block Contention Statistics</h2>";
        $rs = $db->Execute($SQL2);
        csr2html($rs, '  ');
        $rs->close(); 
        echo "<br>";
        if (isset($fsp)) {
           $db->Execute($FSP);
        } else if (isset($fbc)) {
           $db->Execute($FBC);
        }
        $db->close();
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addSubmit("fsp", "Flush Shared Pool");
        $form->addSubmit("fbc", "Flush Buffer Cache");
        $form->display();
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
