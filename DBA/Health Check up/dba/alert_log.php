<?php ob_start();
session_start(); ?>
<html>
<head>
<title>Alert Log</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Alert Log</h2>
<hr>
<?php
require_once ('config.php');
$dateline = NULL;
$match = NULL;
$stack = array();
$rattrib = array("align" => "left");
$PAGESZ = $_SESSION['pagesz'];
$home=$_SESSION['adr_home'];
if (!empty($_POST['pageno'])) $PAGENO = $_POST['pageno'];
else $PAGENO = 0;
if (!empty($_POST['reset'])) $PAGENO = 0;
$tableAttrs = array("rules" => "rows,cols", "border" => "3", "align" => "center");
$hattr = array("style" => "background-color: #ADD8E6");
$table = new HTML_Table($tableAttrs);
$table->setAutoGrow(true);
if ($_SESSION['version'] < 11) {
    $SQL = 'select line from alert_log';
} else { $SQL = <<< 'EOQ'
  select originating_timestamp as thedate, message_level,
         message_group,module_id,process_id,
         thread_id,user_id,instance_id,
         message_text
         from v$diag_alert_ext
         where regexp_instr(message_text,:PATT)>0 and
               adr_home=:HOME
EOQ;
}
$pattern = @$_POST['pattern'];
$pgntn   = @$_POST['pgntn'];
$form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
$form->addBlank(3);
if (!empty($_POST['pattern'])) {
    $form->addHidden('prevpat', $_POST['pattern']);
    $prevpat = $_POST['pattern'];
} else {
    $form->addHidden('prevpat', '.*');
    $prevpat = '.*';
}
$form->addText("pattern", 'Pattern:', $prevpat);
$form->addCheckbox('pgntn', 'Disable Pagination:', FALSE);
$form->addHidden('pageno', $PAGENO + 1);
$form->addSubmit("reset", "First Page");
$form->addSubmit("submit", "Next Page");
$form->addBlank(2);
$form->display();
if (empty($pattern)) {
    exit;
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($_SESSION['version'] >= 11) {
	    if ($pgntn) {
            $rs=$db->Execute($SQL,
                             array('PATT'=>$pattern,
                                         'HOME' => $home));
	    } else {
            $rs = $db->SelectLimit($SQL, 
                                   $PAGESZ, $PAGENO * $PAGESZ,
                                   array('PATT'=>$pattern,
                                         'HOME' => $home));
	    }
        csr2html($rs," ");
        exit;
    }
    if ($pgntn) {
       $rs=$db->Execute($SQL);
    } else {
       $rs = $db->SelectLimit($SQL, $PAGESZ, $PAGENO * $PAGESZ);
    }
    $ncols = $rs->FieldCount();
    for ($i = 0;$i <= $ncols;$i++) {
        $cols[$i] = $rs->FetchField($i);
        $table->setHeaderContents(0, $i, $cols[$i]->name);
    }
    $table->setRowAttributes(0, $hattr);
    while ($row = $rs->fetchRow()) {
        if (strtotime($row[0])) {
            if ($match) {
                $match = NULL;
                foreach($stack as $s) {
                    $table->addRow($s, $rattrib);
                }
            }
            $stack = array();
        }
        array_push($stack, $row);
        if (preg_match("/$pattern/i", $row[0])) $match = 1;
    }
    if ($match) {
        foreach($stack as $s) {
            $table->addRow($s, $rattrib);
        }
    }
    $db->close();
    echo $table->toHTML();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
<h4>Page <?=$PAGENO + 1 ?></h4>
</center>
</body>
</html>
