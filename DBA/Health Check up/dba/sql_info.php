<?php session_start();?>
<html>
<head>
<title>Current SQL Statement</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>SQL Statement</h2>
<br>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ver = $_SESSION['version'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    $addr = $_GET['addr'];
    $hash = $_GET['hash'];
    $id   = $_GET['id'];
    $plan = "<a href=\"plan_info.php?addr=$addr&hash=$hash&id=$id\">Explain Plan</a>";
    $SQL = 'select /*+ RULE */ sql_text sql
      from v$sqltext
      where address=hextoraw(:ADDR) and
            hash_value=:HASH 
      order by piece';
    $sqltext = "";
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL, array('ADDR'=>$addr, 'HASH'=>$hash));
        $cnt = $rs->RecordCount();
        while ($row = $rs->FetchRow()) {
            $sqltext.= $row[0];
        } ?>
    <table rules="rows,cols" border="3" align="center">
    <tr>
    <th style="background-color: #ADD8E6">SQL</th>
    </tr>
    <tr> 
    <td><?=$sqltext?></td>
    </tr>
    </table>
    <?php
        if ($cnt>0) {
            print "<br>$plan<br>";
        }
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
</center>
</body>
</html>
