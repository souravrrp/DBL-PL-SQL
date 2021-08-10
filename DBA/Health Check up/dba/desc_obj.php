<?php session_start(); ?>
<html>
<head>
<title>Describe <?=$_GET['name'] ?></title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Describe  <?=$_GET['name'] ?></h2>
</center>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$tableAttrs = array("rules" => "rows,cols", "border" => "3", "align" => "center");
$hattr = array("style"=>"background-color: #ADD8E6");
$hdr = array("name", "type", "max_length");
$OBJTYP = @strtoupper($_GET['type']);
if (empty($OBJTYP)) $OBJTYP = 'TABLE';
$OWN = $_GET['own'];
$NAME = $_GET['name'];
switch ($OBJTYP) {
    case 'TABLE':
    case 'VIEW':
    case 'MVIEW':
        if (!empty($OWN)) {
            $SQL = "select * from $OWN.$NAME where rownum < 1";
        } else {
            $SQL = "select * from $NAME where rownum < 1";
        }
    break;
    default:
        echo "<H2>This object type cannot be described.</H2><br>";
        exit;
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($SQL);
    $nf = $rs->FieldCount();
    $table = new HTML_Table($tableAttrs);
    $table->setAutoGrow(true);
    for ($i = 0;$i < 3;$i++) {
        $table->setHeaderContents(0, $i, strtoupper($hdr[$i]));
    }
    $table->setRowAttributes(0, $hattr);
    for ($colno = 0;$colno < $nf;) {
        $desc = $rs->FetchField($colno++);
        $row = array();
        foreach($hdr as $h) {
            array_push($row, $desc->$h);
        }
        $table->addRow($row);
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<?=$table->toHTML() ?>
<hr>
</body>
</html>
