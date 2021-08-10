<?php ob_start(); session_start();?>
<html>
<head>
<title>Re-Create User</title>
</head>
<body bgcolor="#EFECC7">
<center>
<h2>
Re-Create <?=$_REQUEST['usr'] ?>
</h2>
</center>
<hr>
<?php
require_once ('config.php');
$DSN = $_SESSION['DSN'];
$invoker = 'security.php';
$db = NewADOConnection("oci8");
$usr = $_GET['usr'];
$TERM = 'begin
         dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                           \'SQLTERMINATOR\',
                                           TRUE);
         end;';
$TERM = preg_replace("/\r/", "", $TERM);

$CRE = 'select dbms_metadata.get_ddl(\'USER\',:USR)
                as "CREATE USER" from dual';

$PRV = "select 'grant '||granted_role||' to '||grantee||';'
               from dba_role_privs
               where grantee=:USR
             union all
             select 'grant '||privilege||' to '||grantee||';'
               from dba_sys_privs
               where grantee=:USR";
$OBJ = "select 'grant '||privilege||' on '||owner||'.'||table_name||
                    ' to '||grantee||';'
             from dba_tab_privs
             where grantee=:USR";
$QOT = "select 'alter user ',
               username,
               ' quota ',
               decode(max_bytes,-1,'UNLIMITED',max_bytes),
               ' on ',
               tablespace_name||';'
        from dba_ts_quotas
        where username=:USR";
       
try {
    $db->Connect($DSN['database'], $DSN['username'], $DSN['password']);
    $db->Execute($TERM);
    $rs = $db->Execute($CRE,array('USR'=>$usr));
    csr2ascii($rs,0);
    $rs = $db->Execute($PRV,array('USR'=>$usr));
    csr2ascii($rs,0);
    $rs = $db->Execute($OBJ,array('USR'=>$usr));
    csr2ascii($rs,0);
    $rs = $db->Execute($QOT,array('USR'=>$usr));
    csr2ascii($rs,0);
    $db->close();
}
catch(Exception $e) {
    die($e->getMessage());
}
?>
<hr>
</body>
</html>
