<?php ob_start(); session_start();?>
<html>
<head>
  <title>DBA Helper</title>
</head>
<body bgcolor="#EFECC7">
<?php
    require_once ('config.php');
    require ('login_form.php');
    $DBA_HELPER="1.0.30";
    $_SESSION['dba_helper']=$DBA_HELPER;
    $db = NewADOConnection("oci8");
    if (!isset($_POST['user'])) {
        login_form('SYSTEM');
    } else {
        try {
            if (empty($_POST['database'])) {
                $_POST['database'] = @$_ENV['TWO_TASK'];
            }
            $DSN = array('phptype'=>'oci8', 'username'=>$_POST['user'], 'password'=>$_POST['passwd'], 'database'=>$_POST['database']);
            $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
            $_SESSION['DSN'] = $DSN;
            $db->close();
            header('Location: frames.html');
            exit;
        }
        catch(exception $e) {
            echo "<center>Exception:", $e->getMessage(), "</center>";
            login_form($_POST['user']);
        }
    } ?>
</body>
</html>
