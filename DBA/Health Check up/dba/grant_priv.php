<?php ob_start();session_start();?>
<html>
<head>
<title>Grant Privilege</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Grant Privilege</h2>
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
if (!empty($_POST['priv'])) $PRIV = $_POST['priv'];
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    //  php_beautifier->setBeautify(false);
    if ( $action == "Grant" ) {
       $INFO = 'select distinct privilege 
                from dba_sys_privs
                where privilege not in (select privilege from dba_sys_privs
                                        where grantee=:USR)
                order by 1';
    } else {
       $INFO = 'select privilege from dba_sys_privs
                where grantee=:USR
                order by 1';
    }
    //  php_beautifier->setBeautify(true);
    $rs = $db->Execute($INFO, array('USR'=>$USR));
    while ($row = $rs->FetchRow()) {
        $priv_list[] = $row[0];
    }
    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addHidden('usr', $USR);
    $form->addHidden('action', $action);
    if ($action == "Grant") {
        $form->addSelect('priv', "Grant to $USR:", $priv_list, 
                          null, 5, 'Grantable Privileges', true);
        $form->addSubmit("submit", "Grant");
    } else {
        $form->addSelect('priv', "Revoke from $USR:", $priv_list, 
                          null, 5, 'User Privileges', true);
        $form->addSubmit("submit", "Revoke");
    }
    @$form->display();
    if (!empty($PRIV)) {
        foreach($PRIV as $i) {
            $to_grnt = $priv_list[$i];
            if ($action == "Grant") $GRNT = "grant $to_grnt to $USR";
            else $GRNT = "revoke $to_grnt from $USR";
            $db->Execute($GRNT);
        }
        header("Location: security.php");
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
