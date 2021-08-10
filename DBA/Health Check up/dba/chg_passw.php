<?php ob_start(); session_start();?>
<html>
<head>
<title>Change Password</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Change Password</h2>
<br>
<hr>
<?php
require_once ('config.php');
define('HTML_FORM_TH_ATTR', 'align="left" valign="top"');
if (!empty($_GET['usr'])) {
    $USR = $_GET['usr'];
} else {
    $USR = $_POST['usr'];
    $PASSWD = $_POST['passwd'];
    $UNLOCK = $_POST['unlock'];
    $LOCK = $_POST['lock'];
    $VAL = $_POST['val'];
}
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    if (empty($_POST['usr'])) {
        $SEL = "select password from dba_users where username=:USR";
        $rs = $db->Execute($SEL, array('USR'=>$USR));
        $row = $rs->FetchRow();
        $VAL = $row[0];
        $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
        $form->addBlank(1, "Current password:$VAL");
        $form->addBlank(1);
        $form->addHidden('usr', $USR);
        $form->addCheckbox('val', 'By Value', FALSE);
        $form->addText('passwd', "New password:");
        $form->addBlank(1);
        $form->addCheckbox('lock', 'Lock Account', FALSE);
        $form->addCheckbox('unlock', 'Unlock Account', FALSE);
        $form->addSubmit("submit", "Change");
        $form->display();
    } else {
        if ($LOCK) {
            $db->Execute("alter user $USR account lock");
        } elseif ($UNLOCK) {
            $db->Execute("alter user $USR account unlock");
        }
        if (!empty($PASSWD)) {
            if ($VAL) {
                $ALTER = "alter user $USR identified by values '$PASSWD'";
            } else {
                $ALTER = "alter user $USR identified by $PASSWD";
            }
            $db->Execute($ALTER);
        }
        $db->close();
        header('location: security.php');
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
