<?php
    function csr2ascii(&$sth,$hr=1) {
        $ncols = $sth->FieldCount();
        if ($hr) print "<hr>";
        print "<pre>\n";
        while ($row = $sth->fetchRow()) {
            $buff="";
            for ($i = 0;$i <= $ncols;$i++) {
                $buff .= $row[$i];
            }
            print "$buff\n";
        }
        print "</pre>\n";
        if ($hr) print "<hr>";
}
?>
