<?php ob_start(); session_start();?>
<html>
<head>
<title>Grant Role</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Grant Role</h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$db = NewADOConnection("oci8");

if (!empty($_GET['usr'])) $USR = $_GET['usr'];
else $USR = $_POST['usr'];

if (empty($_POST['action'])) {
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(1);
    $form->addHidden('usr', $USR);
    $form->addSubmit("action", "Grant");
    $form->addSubmit("action", "Revoke");
    $form->addBlank(1);
    $form->display();
    exit;
} else $action = $_POST['action'];

if (!empty($_POST['role'])) $ROLE = $_POST['role'];

try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if ($action == "Grant") {
        //  php_beautifier->setBeautify(false);
        $INFO = 'select role_name from (
                     select role as role_name from dba_roles
                        minus
                     select granted_role as role_name from dba_role_privs
                     where grantee=:USR
                     )
                 order by 1';
    } else {
        $INFO = 'select granted_role as role_name from dba_role_privs
                 where grantee=:USR
                 order by 1';
    }
        //  php_beautifier->setBeautify(true);
        $rs = $db->Execute($INFO, array('USR'=>$USR));
        while ($row = $rs->FetchRow()) {
            $role_list[] = $row[0];
        }
        if (count($role_list)==0) {
           echo "<h3>No roles were granted to $USR</h3><hr>";
           exit(0);
        }
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(3);
        $form->addHidden('usr', $USR);
        $form->addHidden('action', $action);
        if ($action == "Grant") {
            $form->addSelect('role', "Grant to $USR:", $role_list, 
                             null, 5, 'Grantable Roles', true);
            $form->addSubmit("submit", "Grant");
        } else {
            $form->addSelect('role', "Revoke from $USR:", $role_list, 
                             null, 5, 'User Roles', true);
            $form->addSubmit("submit", "Revoke");
        }
        $form->addBlank(2);
        $form->display();
        if (!empty($ROLE)) {
            foreach($ROLE as $i) {
                $to_grnt = $role_list[$i];
                if ($action == "Grant") $GRNT = "grant $to_grnt to $USR";
                else $GRNT = "revoke $to_grnt from $USR";
                $db->Execute($GRNT);
            }
            header('Location: security.php');
        }
    }
    catch(Exception $e) {
        die($e->getTraceAsString());
    }
?>
<hr>
</center>
</body>
</html>
