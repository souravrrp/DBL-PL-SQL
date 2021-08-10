<?php
    $err=@error_reporting(E_ALL ^ E_DEPRECATED ^ E_NOTICE);
//  The next two lines will include the stuff necessary to use ADOdb
//  Modify them to reflect ADODB location on your system.
    require_once ('adodb/adodb.inc.php');
    require_once ('adodb/adodb-exceptions.inc.php');
//  require_once 'Spreadsheet/Excel/Writer.php';
//  The next line will remove time limit. That is a must for lentgthy 
//  DB operation like tablespace creation
    set_time_limit(0);
//  Do not modify anything below this line.
    require_once('csr2html.php');
    require_once('csr2ascii.php');
    require_once('HTML/Form.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $rattrib = array("align" => "middle");
    $db = NewADOConnection("oci8");
// Function to simplify requiring specific database version.
    function require_version($required=10) {
        $given=$_SESSION['version'];
        if ($given < $required) {
            echo "<h2>This feature requires Oracle version $required</h2><br>";
            exit(0);
        }
    }
    function csr2csv($sth,$file) {
        $fh=fopen($file,"w");
        if (!$fh) die("Cannot open file $file for writing!<br>");
        $ncols = $sth->FieldCount();
        for ($i = 0;$i <= $ncols;$i++) {
             $cols[$i] = $sth->FetchField($i)->name;
        }
        if(!fputcsv($fh,$cols)) die("Problem writing to file $file<br>");
        while ($row = $sth->fetchRow()) {
            if(!fputcsv($fh,$row)) die("Problem writing to file $file<br>");
        }
        fclose($fh);
    }
    function csr2xls($sth,$file,$name="WorkBook") {
        $lineno=0;
        $workbook = new Spreadsheet_Excel_Writer($file);
        $format_bold =& $workbook->addFormat();
        $format_bold->setBold();
        $format_bold->setAlign('left');
        $format_left =& $workbook->addFormat();
        $format_left->setAlign('left');
        $worksheet = & $workbook->addWorksheet($name);
        $ncols = $sth->FieldCount();
        for ($i = 0;$i <= $ncols;$i++) {
             $cols[$i] = $sth->FetchField($i)->name;
        }
        $worksheet->writeRow($lineno++,0,$cols,$format_bold);
        while ($row = $sth->fetchRow()) {
             $worksheet->writeRow($lineno++,0,$row,$format_left);
        }
        $workbook->close();
        $cnt=$sth->Recordcount();
        return($cnt);
    }
?>
