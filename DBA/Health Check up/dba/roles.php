<?php session_start();?>
<html>
<head>
<title>Role Management</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>Role Management</h2>
<hr>
<?php
    require_once ('config.php');
    $rattrib = array("align"=>"left");
    $DSN = $_SESSION['DSN'];
    $ADODB_FETCH_MODE = ADODB_FETCH_NUM;
    $db = NewADOConnection("oci8");
    $SQL = 'select role,
                   dba_helper.grnt_role(role) as "Grant Role",
                   dba_helper.grnt_priv(role) as "Grant Priv.",
                   dba_helper.cr_user(role)  as "Re-create Role",
                   dba_helper.role_member(role)  as "Members"
            from dba_roles
      where role like upper(:PATTERN)
      order by 1';
    
    $pattern=@$_POST['pattern'];
    if (empty($pattern)) { $pattern='%'; }

    $form = new HTML_Form($_SERVER['PHP_SELF'], "POST");
    $form->addBlank(3);
    $form->addText("pattern", 'Role Name:', $pattern);
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
