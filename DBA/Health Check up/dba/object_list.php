<?php session_start();?>
<html>
<head>
<title>Object List</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>List of <?=$_REQUEST['type'] ?>S For <?=$_REQUEST['own'] ?></h2>
<br>
<hr>
<?php
    require_once ('config.php');
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $ADODB_COUNTRECS = true;
    $db = NewADOConnection("oci8");
    if (isset($_GET['type']))
       $type = $_GET['type'];
    elseif (isset($_POST['type']))
       $type = $_POST['type'];
    else die("<h2>Unknown type!</h2><br");
    switch ($type) {
	case 'MVIEW':
		$otype='MATERIALIZED VIEW';
		$type= 'MATERIALIZED_VIEW';
		break;
       default:
	        $otype=$type;
                break;
    }
    if (isset($_GET['own']))
       $own = $_GET['own'];
    elseif (isset($_POST['own']))
       $own = $_POST['own'];
    else die("<h2>Unknown owner!</h2><br");

    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $LIST = 'select dba_helper.obj_info(:OWN,:TYP,object_name) as "Object Name",
                    dba_helper.obj_desc(:OWN,:TYP,object_name) as "Describe",
             status 
       from dba_objects
       where owner=:OWN and
             object_type=:OTYP and
             object_name between \'A\' and \'ZZZZZZZZ\' and
             object_name like upper(:PATTERN)
       order by object_name';
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Name pattern:', $pattern);
    $form->addHidden("type",$type);
    $form->addHidden("own",$own);
    $form->addSubmit("submit", "Filter");
    $form->addBlank(2);
    $form->display();    
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        $rs = $db->Execute($LIST, array('TYP'=>$type, 
                                        'OTYP'=>$otype,
                                        'OWN'=>$own,
                                        'PATTERN'=>$pattern));
        csr2html($rs, ' ');
        $db->close();
    }
    catch(Exception $e) {
        die($e->getMessage());
    }
?>
<hr>
</center>
</body>
</html>
