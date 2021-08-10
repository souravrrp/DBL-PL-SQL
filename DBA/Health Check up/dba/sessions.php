<?php session_start();?>
<html>
<head>
<title>Sessions Main Menu</title>
</head>
<body bgcolor="#EFECC7">
<br>
<center>
<h2>Sessions</h2>
<hr>
<table border="1">
<tr><td><h4>Cumulative</h4></td><td><h4>Delta (10g or later only)</h4></td></tr>
<tr><td><A HREF="sessions_srt.php?sort=CPU" target="output">Sessions, by CPU</A>
</td>
<td><A HREF="sessions_delta.php?sort=CPU" target="output">Sessions, by CPU</A>
</td></tr>
<tr><td><A HREF="sessions_srt.php?sort=reads" target="output">Sessions, by Reads</A>
</td>
<td><A HREF="sessions_delta.php?sort=reads" target="output">Sessions, by Reads</A>
</td>
</tr>
<tr><td><A HREF="sessions_srt.php?sort=PGA" target="output">Sessions, by PGA.</A>
</td>
<td><A HREF="sessions_delta.php?sort=PGA" target="output">Sessions, by PGA.</A>
</td>
</tr>
</table>
<table border="1">
<tr><td><h4>Misc. Session Info</h4></td></tr>
<tr><td><A HREF="sessions_undo.php" target="output">Sessions, by Undo blks.</A>
</td></tr>
<tr><td><A HREF="sessions_wait.php" target="output"> Sessions, by waits</A>
</td></tr>
<tr><td><A HREF="sessions_srch.php" target="output">Search by SID or SPID</A>
</td></tr>
<tr><td><A HREF="schema_filter.php" target="output">Schema Filter</A>
</td></tr>
<tr><td><A HREF="client_trace.php" target="output">Client Trace</A>
<tr><td><A HREF="user_trace.php" target="output">User Trace</A>
</td></tr>
<tr><td><A HREF="kill_user.php" target="output">Kill User</A>
</td></tr>
</table>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    $SQL = "select owner,segment_name,tablespace_name,file_id,block_id
      from dba_extents
      where file_id=:FL and
      :BL between block_id and block_id+blocks
      order by file_id,block_id";
    if (!empty($_POST['file']) and !empty($_POST['block'])) {
        $file = trim($_POST['file']);
        $block = trim($_POST['block']);
        try {
            $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
            $rs = $db->Execute($SQL, array('FL'=>$file, 'BL'=>$block));
        }
        catch(Exception $e) {
            die($e->getMessage());
        }
        if ($rs->RecordCount() >0) {
            csr2html($rs);
        }
        $db->close();
    } ?>
<center>
<h2>Find Database Segment</h2>
<?php
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(1);
    $form->addText('file', "File:");
    $form->addText('block', "Block:");
    $form->addSubmit("submit", "Find");
    $form->addBlank(2);
    $form->display();
?>
</center>
<hr>
</body>
</html>
