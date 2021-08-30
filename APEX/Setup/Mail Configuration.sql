CONN HR/HR@LIVE

BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl ( 
    acl         => 'power_users_apex.xml');
COMMIT;
END;
/

begin
DBMS_NETWORK_ACL_ADMIN.create_acl(
  acl => 'power_users_apex.xml',
  description  =>  'Access to Apex Email',
  principal=>'APEX_200200',
  IS_GRANT=>TRUE,
  PRIVILEGE=>'connect',
  START_DATE=>SYSTIMESTAMP,
  END_DATE=>NULL);
  COMMIT;
end;
/

begin
DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
  acl => 'power_users_apex.xml',
  principal=>'APEX_200200',
  IS_GRANT=>TRUE,
  PRIVILEGE=>'resolve');
  COMMIT;
end;
/

begin
DBMS_NETWORK_ACL_ADMIN.assign_acl(
  acl => 'power_users_apex.xml',
  host=>'mail.ubs-bd.com',
  lower_port=>26,
  upper_port=>null);
  COMMIT;
end;
/


Now Go to Internal Workspace >>Instance Settings>>Email Tab>>

SMTP Host Address 			: 	mail.ubs-bd.com
SMTP Host Port				:	26
SMTP Authentication Username		:	prince@ubs-bd.com
SMTP Authentication Password		:	xxxyyyxxxxxxx
Default Email From Address		:	prince@ubs-bd.com

	

