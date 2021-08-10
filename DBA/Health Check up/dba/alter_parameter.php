<?php ob_start(); session_start();?>
<html>
<head>
<title>Change Instance Parameters</title>
</head>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    if (!empty($_GET['parameter'])) {
        $PARAM = $_GET['parameter'];
        $_SESSION['parameter'] = $PARAM;
    } else {
        $PARAM = $_SESSION['parameter'];
    }
    if (empty($PARAM)) {
        die("Parameter is not defined. Aborting...\n");
    }
    $scope = array('MEMORY'=>'MEMORY', 'SPFILE'=>'SPFILE', 'BOTH'=>'BOTH');
    try {
        $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
        if (!empty($_POST['par_val'])) {
            $SQL = "alter system set ".$PARAM."=".$_POST['par_val'].
                   " SCOPE=".$_POST['scope'];
            $db->Execute($SQL);
            $db->close();
            header('Location: parameters.php');
        } else { ?>
       <center>
       <h3>Dynamic Parameter Change</h3>
       <hr>
       <?php
            $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
            $form->addBlank(3);
            $form->addText("par_val", "$PARAM:");
            $form->addSelect('scope', 'Scope:', $scope);
            $form->addSubmit("submit", "Change");
            $form->addBlank(2);
            $form->display(); ?>
       <hr>
       </center>
       <?php
        }
    }
    catch(Exception $e) {
        print "$SQL<br>";
        die($e->getTraceAsString());
    }
?>
</body>
</html>
