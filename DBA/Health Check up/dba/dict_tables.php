<?php session_start();?>
<html>
<head>
<title>Dictionary Views Descriptions</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Dictionary View Descriptions</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    if (isset($_GET['typ'])) 
       $type=$_GET['typ'];
    elseif (isset($_POST['typ']))
       $type=$_POST['typ'];
    else die("<h2>Type of search not set!</h2><br>");
    switch ($type) {
       case 'D':
          $SQL = 'select table_name as "NAME",
                         \'<a href="desc_obj.php?name=\'||table_name||\'">Description</a>\'
                         as "Description"
                 from dictionary
                 where lower(table_name) like lower(:PATTERN) 
                 order by 1';
          break;
       case 'F':
          $SQL = 'select NAME,
                         \'<a href="view_desc.php?name=\'||name||\'&typ=F">Description</a>\'
                         as "Description"
                 from v$fixed_table
                 where lower(name) like lower(:PATTERN) and
                       type=\'VIEW\'
                 order by 1';
          break;
       default:
          die("<h2>Cannot determine the needed SQL</h2><br>");
    }
 
    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Name pattern:', $pattern);
    $form->addHidden("typ",$type);
    $form->addSubmit("submit", "Filter");
    $form->addBlank(2);
    $form->display();

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($SQL, array('PATTERN'=>$pattern));
        csr2html($rs);
        $db->close();
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
