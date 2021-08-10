<?php session_start();?>
<html>
<head>
<title>Free Temp Space</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Free Temp Space</h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $rattrib = array("align"=>"left");
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    $TBSPC = 'select space,tot "Total",usd "Used",
                     round((1-(usd/tot))*100,2) "%Free" 
        from (
           select 
                tf.tablespace_name space,tf.total tot,nvl(tu.used,0) usd
           from (select tablespace_name,round(sum(bytes)/1048576) total
                 from dba_temp_files
                 group by tablespace_name) tf,
                 (select tablespace,
                         round(sum(s.blocks*t.block_size)/1048576,2) used
                  from gv$sort_usage s,dba_tablespaces t
                  where s.tablespace=t.tablespace_name
                  group by tablespace) tu
           where tf.tablespace_name=tu.tablespace(+) )';
    $PUSR = ' select s.inst_id "Instance",
               s.USERNAME,
               ss.sid,
               s.TABLESPACE,
               round(sum(s.blocks*t.block_size)/1048576,2) MB
               from gv$sort_usage s,dba_tablespaces t,gv$session ss
               where s.tablespace=t.tablespace_name
               and s.session_addr=ss.saddr
               and s.inst_id=ss.inst_id
               group by s.inst_id,s.USERNAME,ss.sid, s.TABLESPACE
               order by 4 desc';
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($TBSPC);
        csr2html($rs, '  ');
        $rs = $db->Execute($PUSR);
        if ($rs->RecordCount() >0) {
            echo "<h4>Consumption Per Session</h4><br>";
            csr2html($rs, '  ');
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
