<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Create Database</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Create Database Script</h2>
</center>
<hr>
<br>
<?php
# This script generates "create database" command for given instance.
# It works on both 10g and 9i databases.
require_once ('config.php');
$version = $_SESSION['version'];
$PAR = 'select value from v$parameter where name=:PAR';
$TEMP = "select tablespace_name from dba_tablespaces 
             where contents='TEMPORARY'";
$ARCH = 'select log_mode from v$database';
$NLS = 'select value from v$nls_parameters where parameter=:PAR';
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($PAR, array('PAR' => 'db_name'));
    $row = $rs->FetchRow();
    $db_name = $row[0];
    $rs = $db->Execute($PAR, array('PAR' => 'undo_tablespace'));
    $row = $rs->FetchRow();
    $undo_tbsp = $row[0];
    $rs = $db->Execute($TEMP);
    $row = $rs->FetchRow();
    $temp_tbsp = $row[0];
    $rs = $db->Execute($ARCH);
    $row = $rs->FetchRow();
    $archivelog = $row[0];
    $rs = $db->Execute($NLS, array('PAR' => 'NLS_CHARACTERSET'));
    $row = $rs->FetchRow();
    $charset = $row[0];
    $tail = <<<TAIL
;
@?/rdbms/admin/catalog
@?/rdbms/admin/catproc
spool off
TAIL;
    $head = <<<HEAD
connect / as sysdba
set echo on
set termout on
set trimout on 
set trimspool on 
spool create_$db_name.log
startup force nomount
CREATE DATABASE $db_name
CONTROLFILE REUSE
$archivelog
CHARACTER SET $charset
MAXINSTANCES 1
MAXDATAFILES 2048
MAXLOGFILES  30
MAXLOGMEMBERS 4
MAXKOGHISTORY 5120
HEAD;
    echo "<pre>";
    echo $head;
    echo "\nDATAFILE\n";
    print_files('SYSTEM');
    if ($version >= 10) {
        echo "SYSAUX DATAFILE\n";
        print_files('SYSAUX');
    }
    echo "LOGFILE\n";
    print_logs();
    echo "UNDO TABLESPACE $undo_tbsp DATAFILE\n";
    print_files($undo_tbsp);
    echo "DEFAULT TEMPORARY TABLESPACE $temp_tbsp TEMPFILE\n";
    print_files($temp_tbsp, 1);
    echo $tail;
    echo "</pre>";
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
function print_logs() {
    GLOBAL $db;
    GLOBAL $version;
    $THREAD = $_SESSION['inst_id'];
    // php_beautifier->setBeautify(FALSE)
    $GRPS = 'select max(group#) from v$log where thread#=:THREAD';
    $LGSZ = 'select group#,bytes from v$log where thread#=:THREAD 
             order by group#';
    if ($version >= 10) $LOGS = 'select member
	                             from v$logfile
                                 where group#=:GRP and
                                 is_recovery_dest_file=\'NO\'';
    else $LOGS = 'select member
	              from v$logfile
                  where group#=:GRP';
    // php_beautifier->setBeautify(TRUE)
    $rs = $db->Execute($GRPS, array("THREAD" => $THREAD));
    $row = $rs->FetchRow();
    $log_grps_cnt = $row[0];
    $rs = $db->Execute($LGSZ, array("THREAD" => $THREAD));
    $rowlogs = $rs->GetArray();
    foreach($rowlogs as &$r) {
        $log_grp_sizes[$r[0]] = $r[1];
    }
    foreach($rowlogs as &$r) {
        $i = $r[0];
        $rs = $db->Execute($LOGS, array("GRP" => $i));
        $j = 0;
        while ($row = $rs->FetchRow()) {
            $members[$j++] = $row[0];
        }
        if (empty($members)) {
            $members = array('No information, probably ASM');
        }
        foreach($members as &$m) {
            if (!preg_match("/^'.*'/", $m)) $m = sprintf("'%s'", $m);
        }
        $memb = implode(",", $members);
        echo "\t GROUP $i (", $memb, ") SIZE ", $log_grp_sizes[$i], " REUSE";
        if ($i == $log_grps_cnt) echo "\n";
        else echo ",\n";
    }
}
function print_files($tbsp, $tmp = 0) {
    GLOBAL $db;
    if ($tmp == 0) $kind = 'data_files';
    else $kind = 'temp_files';
    // php_beautifier->setBeautify(FALSE)
    $TBSP = "select extent_management,allocation_type,
                    segment_space_management, next_extent,block_size
             from dba_tablespaces
             where tablespace_name=:TBSP";
    $DATAF = "select file_id,file_name,bytes,autoextensible,
                     increment_by, maxbytes
              from dba_$kind
              where tablespace_name=:TBSP
              order by file_id";
    $MAXID = "select max(file_id) from dba_$kind
              where tablespace_name=:TBSP";
    // php_beautifier->setBeautify(TRUE)
    $rs = $db->Execute($MAXID, array("TBSP" => $tbsp));
    $row = $rs->FetchRow();
    $maxid = $row[0];
    $rs = $db->Execute($TBSP, array("TBSP" => $tbsp));
    $row = $rs->FetchRow();
    list($lmt, $alloc, $assm, $ext_sz, $bs) = $row;
    if ($alloc == 'UNIFORM') $alloc = "UNIFORM SIZE $ext_sz";
    else $alloc = 'AUTOALLOCATE';
    $rs = $db->Execute($DATAF, array("TBSP" => $tbsp));
    while ($row = $rs->FetchRow()) {
        list($id, $name, $bytes, $auto_ext, $inc, $max) = $row;
        if ($auto_ext == "YES") {
            printf("\t '%s' SIZE %dM REUSE\n", $name, $bytes);
            printf("\t AUTOEXTEND ON NEXT %d MAXSIZE %d", $inc*$bs, $max);
        } else printf("\t '%s' SIZE %d REUSE", $name, $bytes);
        if ($id == $maxid) echo "\n";
        else echo ",\n";
    }
    if ($tmp == 1) echo "\t EXTENT MANAGEMENT $lmt $alloc\n";
    else echo "\t EXTENT MANAGEMENT $lmt\n";
}
?>
</center>
</body>
</html>
