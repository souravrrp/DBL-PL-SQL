<?php session_start();?>
<html>
<head>
<title>Users and Security</title>
</head>
<body bgcolor="#EFECC7">
<center>
<a href="create_user.php">Create User</a>
<a href="roles.php">Manage Roles</a>
<h2>Username Filter</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $SQL = 'select dba_helper.user_info(username) as "User Info",
             dba_helper.grnt_role(username) as "Grant Role",
             dba_helper.grnt_priv(username) as "Grant Priv.",
             dba_helper.chg_passw(username) as "Change Password",
             dba_helper.drop_user(username) as "Drop User",
             dba_helper.cr_user(username) as "Re-create User"
      from dba_users 
      where username like upper(:PATTERN)
      order by 1';
    
    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Username pattern:', $pattern);
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
