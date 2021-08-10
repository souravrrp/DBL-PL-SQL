<?php
require_once ('config.php');
require_once "HTML/Table.php";
function csr2html(&$sth, $fill = "n/a") {
    GLOBAL $rattrib;
    $ncols = $sth->FieldCount();
    for ($i = 0;$i <= $ncols;$i++) {
        $cols[$i] = $sth->FetchField($i);
    }
    $tableAttrs = array("rules" => "rows,cols", 
                        "rules" => "all", 
                        "border" => "3", 
                        "align" => "center");
    $hattr = array("style" => "background-color: #ADD8E6");
    $table = new HTML_Table($tableAttrs);
    $table->setAutoGrow(true);
    $table->setAutoFill($fill);
    for ($i = 0;$i < $ncols;$i++) {
        $table->setHeaderContents(0, $i, $cols[$i]->name);
    }
    $table->setRowAttributes(0, $hattr);
    $i = 0;
    while ($row = $sth->fetchRow()) {
        $table->addRow($row, $rattrib);
    }
?>
   <center>
   <?=$table->toHTML() ?>
   <br><b><?=$sth->RecordCount() ?> Records Returned</b><br>
   </center>
<?php
}
?>
