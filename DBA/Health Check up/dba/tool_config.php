<?php ob_start();session_start();?>
<html>
<head>
<title>Tool Config</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>NLS Tool Config</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    $ver=$_SESSION['version'];
    $exelim=null;
    $DSN = $_SESSION['DSN'];
    $binds=FALSE;
    $_SESSION['binds']=FALSE;
    if (isset($_POST['binds'])) {
       $binds=$_POST['binds'];
       $_SESSION['binds']=$_POST['binds'];
    }
    if (isset($_POST['date_format']))
       $format=$_POST['date_format'];
    elseif (isset($_SESSION['date_format'])) 
       $format=$_SESSION['date_format'];
    else $format='DD-MON-YYYY HH24:MI:SS';
    if (isset($_POST['pagesz']))
       $pagesz=$_POST['pagesz'];
    elseif (isset($_SESSION['pagesz'])) 
       $pagesz=$_SESSION['pagesz'];
    else $pagesz=100;
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("date_format", 'NLS_DATE_FORMAT:', $format,30,64);
    $form->addText("pagesz", 'Page Size:',$pagesz,10);
    $form->addText("exelim", 'Max executions in "Expensive SQL":', $exelim,10);
    $form->addCheckBox('binds','Show binds in trace:',$binds);
    $form->addSubmit("submit", "Set");
    $form->addBlank(2);
    $form->display();

    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if (isset($_POST['pagesz'])) 
           $_SESSION['pagesz']=$_POST['pagesz'];
        if (isset($_POST['binds'])) 
           $_SESSION['binds']=1;
        if (isset($_POST['exelim'])) 
           $_SESSION['exelim']=$_POST['exelim'];
        if (isset($_POST['date_format'])) {
           $SQL = "alter session set nls_date_format='$format'";
           $_SESSION['date_format']=$format;
           $db->Execute($SQL);
           header("location: init.php");
           exit;
        }
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
</center>
</body>
</html>
