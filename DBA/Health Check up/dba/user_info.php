<?php session_start(); ?>
<html>
<head>
<title>User Info</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>User Info for <?=$_GET['user'] ?></h2>
<br>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$ADODB_FETCH_MODE = ADODB_FETCH_NUM;
$ADODB_COUNTRECS = true;
$db = NewADOConnection("oci8");
$usr = $_GET['user'];
// php_beautifier->setBeautify(FALSE)

$USRINFO = 'select USERNAME,
                   ACCOUNT_STATUS STATUS,
                   EXPIRY_DATE EXPIRES,
                   DEFAULT_TABLESPACE "DFLT. TBLSPCE",
                   TEMPORARY_TABLESPACE "TEMP. TBLSPCE",
                   CREATED,PROFILE,
                   INITIAL_RSRC_CONSUMER_GROUP "CONSUMER GROUP"
            from  dba_users
            where username=:USR';
$ROLES = 'select granted_role,admin_option,default_role 
          from dba_role_privs
          where grantee=:USR
          order by granted_role';
$PRIVS = 'select privilege,admin_option
          from dba_sys_privs
          where grantee=:USR
          order by privilege';
$TABS = 'select OWNER,TABLE_NAME,PRIVILEGE,GRANTOR,GRANTABLE
         from dba_tab_privs
         where grantee=:USR';
$QUOTAS = 'select * from dba_ts_quotas where username=:USR';
$CREATE = 'select dbms_metadata.get_ddl(\'USER\',:USR) 
                  as "CREATE USER" from dual';
$TERM = 'begin
         dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                           \'SQLTERMINATOR\',
                                           TRUE);
         end;';
$TERM = preg_replace("/\r/", "", $TERM);
// php_beautifier->setBeautify(TRUE)
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $rs = $db->Execute($USRINFO, array('USR' => $usr));
    echo "<h3>General Info</h3><br>";
    csr2html($rs, '  ');
    $rs->close();
    $db->Execute($TERM);
    $rs = $db->Execute($CREATE, array('USR' => $usr));
    echo "<h3>Create User Stmt.</h3><br>";
    csr2html($rs, '  ');
    $rs->close();
    $rs = $db->Execute($ROLES, array('USR' => $usr));
    echo "<h3>Roles for $usr</h3><br>";
    csr2html($rs, '  ');
    $rs->close();
    $rs = $db->Execute($PRIVS, array('USR' => $usr));
    echo "<h3>Privileges for $usr</h3><br>";
    csr2html($rs, '  ');
    $rs->close();
    $rs = $db->Execute($TABS, array('USR' => $usr));
    if ($rs->RecordCount() > 0) {
        echo "<h3>Tables granted to $usr</h3><br>";
        csr2html($rs, '  ');
    }
    $rs->close();
    $rs = $db->Execute($QUOTAS, array('USR' => $usr));
    if ($rs->RecordCount() > 0) {
        echo "<h3>Tablespace quotas granted to $usr</h3><br>";
        csr2html($rs, '  ');
    }
    $db->close();
}
catch(Exception $e) {
    die($e->getTraceAsString());
}
?>
</center>
</body>
</html>
