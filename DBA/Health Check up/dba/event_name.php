<?php session_start();?>
<html>
<head>
<title>Event Descriptions</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Event Descriptions</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    $DSN = $_SESSION['DSN'];
    $version=$_SESSION['version'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    if ($version >= 10) 
       $SQL = 'select NAME as "Event Name",
                      PARAMETER1,
                      PARAMETER2,
                      PARAMETER3,
                      WAIT_CLASS
               from v$event_name
               where lower(name) like lower(:PATTERN)
               order by 1';
    else 
       $SQL = 'select NAME as "Event Name",
                      PARAMETER1,
                      PARAMETER2,
                      PARAMETER3
               from v$event_name
               where lower(name) like lower(:PATTERN)
               order by 1';

    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Event name pattern:', $pattern);
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
