<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Backup</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Backup Sets</h2><br>
<?php
require_once ('config.php');
$rattrib = array("align" => "left");
$fmt='DD-MON-YYYY';
$dt1=strtoupper(date("d-M-Y"));
$dt2='01-JAN-4000';
if (!empty($_POST['dt1'])) $dt1=$_POST['dt1'];
if (!empty($_POST['dt2'])) $dt2=$_POST['dt2'];
$btype = array('A' => 'ALL', 
               'L' => 'ARCHIVELOGS', 
               'D' => 'FULL DB', 
               'I' => 'INCREMENTAL');
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
$form->addText('dt1','MIN DATE:',$dt1);
$form->addText('dt2','MAX DATE:',$dt2);
$form->addSelect('btype', 'Backup Type:', $btype);
$form->addSubmit("submit", "Filter");
$form->addBlank(2);
$form->display();
if (empty($_POST['btype'])) $backup_type = 'A';
else $backup_type = $_POST['btype'];
// php_beautifier->setBeautify(false);
if ($backup_type=='A') {
    $SET = 'select set_count,set_stamp,pieces,
                    case backup_type 
                        when \'D\' then \'FULL DB\'
                        when \'I\' then \'INCREMENTAL\'
                        when \'L\' then \'ARCHIVE LOGS\'
                    end as "BKP. TYPE",
                    to_char(start_time,\'MM/DD/RR HH24:MI:SS\') 
                    as "START TIME",
                    to_char(completion_time,\'MM/DD/RR HH24:MI:SS\') 
                    as "FINISH TIME",
                    CONTROLFILE_INCLUDED as "CTL. FILE",
                    BLOCK_SIZE
            from v$backup_set
            where (set_count,set_stamp) in (select set_count,set_stamp
                                            from v$backup_piece
                                            where status=\'A\') and
                   completion_time between to_date(:DT1,:FMT) and 
                                           to_date(:DT2,:FMT)
            order by set_count,set_stamp';

    $PIECE = 'select set_count,set_stamp,piece#,tag,
                     to_char(start_time,\'MM/DD/RR HH24:MI:SS\') 
                     as "START TIME",
                     to_char(completion_time,\'MM/DD/RR HH24:MI:SS\') 
                     as "FINISH TIME",
		     media as TAPE, 
                     nvl(handle,\'*** DELETED ***\') as "HANDLE"
              from v$backup_piece
              where status=\'A\' and
                    completion_time between to_date(:DT1,:FMT) and 
                                            to_date(:DT2,:FMT)
              order by set_count,set_stamp,piece#';
} else {
    $SET = 'select set_count,set_stamp,pieces,
                    case backup_type 
                        when \'D\' then \'FULL DB\'
                        when \'I\' then \'INCREMENTAL\'
                        when \'L\' then \'ARCHIVE LOGS\'
                    end as "BKP. TYPE",
                    to_char(start_time,\'MM/DD/RR HH24:MI:SS\') 
                    as "START TIME",
                    to_char(completion_time,\'MM/DD/RR HH24:MI:SS\') 
                    as "FINISH TIME",
                    CONTROLFILE_INCLUDED as "CTL. FILE",
                    BLOCK_SIZE
            from v$backup_set
            where (set_count,set_stamp) in (select set_count,set_stamp
                                            from v$backup_piece
                                            where status=\'A\') and
                   backup_type = :BTYPE and
                   completion_time between to_date(:DT1,:FMT) and 
                                           to_date(:DT2,:FMT)
 
            order by set_count,set_stamp';

    $PIECE = 'select set_count,set_stamp,piece#,tag,
                     to_char(start_time,\'MM/DD/RR HH24:MI:SS\') 
                     as "START TIME",
                     to_char(completion_time,\'MM/DD/RR HH24:MI:SS\') 
                     as "FINISH TIME",
		     media as TAPE, 
                     nvl(handle,\'*** DELETED ***\') as "HANDLE"
              from v$backup_piece
              where status=\'A\' and
                     (set_count,set_stamp) in (select set_count,set_stamp
                                               from v$backup_set
                                               where backup_type = :BTYPE) and
                      completion_time between to_date(:DT1,:FMT) and 
                                              to_date(:DT2,:FMT)
              order by set_count,set_stamp,piece#';
}

$LOGS='select l.set_count,l.set_stamp,l.thread#,l.sequence#,
              to_char(l.first_time,\'MM/DD/RR HH24:MI:SS\') "START TIME",
              to_char(l.next_time,\'MM/DD/RR HH24:MI:SS\') "NEXT TIME",
              l.first_change#,l.next_change#,
              round((l.blocks+1)*l.block_size/1024) as "SIZE (KB)"
       from v$backup_redolog l,v$backup_set s, v$backup_piece p
       where l.set_stamp=s.set_stamp and
             l.set_count=s.set_count and
             s.backup_type=\'L\' and
             p.set_count=s.set_count and
             p.set_stamp=s.set_stamp and
             p.status=\'A\' and
             l.first_time between to_date(:DT1,:FMT) and 
                                  to_date(:DT2,:FMT)
       order by l.thread#,l.sequence#';

$DATA='select f.set_count,f.set_stamp,df.name,
              round((f.blocks+1)*f.block_size/1024) as "SIZE (KB)",
              f.checkpoint_change#,
              to_char(f.checkpoint_time,\'MM/DD/RR HH24:MI:SS\') as "TIMESTAMP",
              p.media as TAPE,
              f.marked_corrupt,
              f.media_corrupt,
              f.logically_corrupt
       from v$backup_datafile f,v$backup_set s, v$backup_piece p,
            v$datafile df
       where f.set_stamp=s.set_stamp and
             f.set_count=s.set_count and
             s.backup_type = :BTYPE and
             p.set_count=s.set_count and
             p.set_stamp=s.set_stamp and
             p.status=\'A\' and
             f.file#=df.file# and
             p.completion_time between to_date(:DT1,:FMT) and 
                                       to_date(:DT2,:FMT)
       order by f.set_stamp,f.set_count,f.checkpoint_change#';
// php_beautifier->setBeautify(true)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($backup_type == 'A')  { $rs = $db->Execute($SET,array('DT1'=>$dt1,
                                                              'DT2'=>$dt2,
                                                              'FMT'=>$fmt)); }
    else  { $rs = $db->Execute($SET, array('BTYPE' => $backup_type,
                                           'DT1'=>$dt1,
                                           'DT2'=>$dt2,
                                           'FMT'=>$fmt)); }
    csr2html($rs, '  ');
    echo "<h2>Backup Pieces</h2><br>";
    if ($backup_type == 'A') { $rs = $db->Execute($PIECE,array('DT1'=>$dt1,
                                                               'DT2'=>$dt2,
                                                               'FMT'=>$fmt)); }
    else { $rs = $db->Execute($PIECE, array('BTYPE' => $backup_type,
                                            'DT1'=>$dt1,
                                            'DT2'=>$dt2,
                                            'FMT'=>$fmt)); }

    csr2html($rs, '  ');
    if ($backup_type == 'L') {
        $rs = $db->Execute($LOGS,array( 'DT1'=>$dt1,
                                        'DT2'=>$dt2,
                                        'FMT'=>$fmt));
        echo "<h2>Archived Logs</h2><br>";
        csr2html($rs, '  ');
    } 
    if (($backup_type == 'I') || ($backup_type == 'D')) {
        $rs = $db->Execute($DATA,array('BTYPE' => $backup_type,
                                       'DT1'=>$dt1,
                                       'DT2'=>$dt2,
                                       'FMT'=>$fmt)); 
        echo "<h2>Archived Data Files</h2><br>";
        csr2html($rs, '  ');
    } 
    $rs->close();
    $db->close();
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
