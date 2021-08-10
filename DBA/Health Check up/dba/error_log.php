<?php ob_start(); session_start(); ?>
<html>
<head>
<title>Error Log</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Error Log</h2>
<hr>
<?php
require_once ('config.php');
$rattrib = array("align" => "left");
$version=$_SESSION['version'];
$home=$_SESSION['adr_home'];
$PAGESZ=$_SESSION['pagesz'];
if ( !empty($_POST['pageno']))
    $PAGENO=$_POST['pageno'];
else $PAGENO=0;
if (!empty($_POST['reset']))
    $PAGENO=0;
if ($version == 10) {
    $SQL = 'SELECT "LINENO"    ,
            "THEDATE"  ,
            "ORA_ERROR",
            "LINE"
    FROM
            (SELECT *
            FROM
                    (SELECT lineno ,
                            line   ,
                            thedate,
                            MAX(
                            CASE
                                    WHEN (ora_error LIKE \'%ORA-%\')
                                    THEN rtrim(SUBSTR(ora_error,1,instr(ora_error,\' \')-1),\':\')
                                    ELSE NULL
                            END ) over (partition BY thedate) ora_error
                    FROM
                            (SELECT lineno                                     ,
                                    line                                       ,
                                    MAX(thedate) over (order by lineno) thedate,
                                    lead(line) over (order by lineno) ora_error
                            FROM
                                    (SELECT rownum lineno              ,
                                            SUBSTR( line, 1, 132 ) line,
                                            CASE
                                                    WHEN line LIKE \'___ ___ __ __:__:__ ____\'
                                                    THEN to_date(line, \'Dy Mon DD hh24:mi:ss yyyy\',\'NLS_DATE_LANGUAGE = AMERICAN\')
                                                    WHEN line LIKE \'___ ___ __ __:__:__ ___ ____\'
                                                    THEN to_date(regexp_replace(line,\' [A-Z]{3} (\d{4})\',\'\\1\'), \'Dy Mon DD hh24:mi:ss yyyy\',\'NLS_DATE_LANGUAGE = AMERICAN\')
                                                    ELSE NULL
                                            END thedate
                                    FROM    alert_log
                                    )
                            )
                    )
            )
    WHERE   ora_error IS NOT NULL
        AND thedate   >= (TRUNC(sysdate) - :DAYS)
    ORDER BY 1,2';
} elseif ($version == 9) {
    $SQL = 'SELECT "LINENO"    ,
            "THEDATE"  ,
            "ORA_ERROR",
            "LINE"
    FROM
            (SELECT *
            FROM
                    (SELECT lineno ,
                            line   ,
                            thedate,
                            MAX(
                            CASE
                                    WHEN (ora_error LIKE \'%ORA-%\')
                                    THEN rtrim(SUBSTR(ora_error,1,instr(ora_error,\' \')-1),\':\')
                                    ELSE NULL
                            END ) over (partition BY thedate) ora_error
                    FROM
                            (SELECT lineno                                     ,
                                    line                                       ,
                                    MAX(thedate) over (order by lineno) thedate,
                                    lead(line) over (order by lineno) ora_error
                            FROM
                                    (SELECT rownum lineno              ,
                                            SUBSTR( line, 1, 132 ) line,
                                            CASE
                                                    WHEN line LIKE \'___ ___ __ __:__:__ ____\'
                                                    THEN to_date(line, \'Dy Mon DD hh24:mi:ss yyyy\',\'NLS_DATE_LANGUAGE = AMERICAN\')
                                                    ELSE NULL
                                            END thedate
                                    FROM    alert_log
                                    )
                            )
                    )
            )
    WHERE   ora_error IS NOT NULL
        AND thedate   >= (TRUNC(sysdate) - :DAYS)
    ORDER BY 1,2';
} elseif ($version == 11) {
    $SQL= <<< 'EOQ'
            select originating_timestamp as thedate, message_level,
                  message_group,module_id,process_id,
                  thread_id,user_id,instance_id,
                  message_text
            from v$diag_alert_ext
            where originating_timestamp> trunc(systimestamp) - :DAYS and
            message_text like '%ORA-%' and
            ADR_HOME=:HOME
EOQ;
}
$pattern = @$_POST['pattern'];
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '3');
    $prevpat = '3';
}
$form->addText("pattern", 'Days back:', $prevpat);
$form->addHidden('pageno', $PAGENO+1);
$form->addSubmit("reset", "First Page");
$form->addSubmit("submit", "Next Page");
$form->addBlank(2);
$form->display();
if (empty($pattern)) {
    exit;
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($version < 11) {
       $rs = $db->SelectLimit($SQL, $PAGESZ,$PAGENO*$PAGESZ,
                              array('DAYS' => $pattern));
    } else {
       $rs = $db->SelectLimit($SQL, $PAGESZ,$PAGENO*$PAGESZ,
                                    array('DAYS' => $pattern,
                                    'HOME' => $home));
    }
    csr2html($rs);
    $db->close();
}
catch(Exception $e) {
	echo "$SQL";
    die($e->getTraceAsString());
}
?>
<h4>Page <?=$PAGENO+1?></h4>
</center>
</body>
</html>
