/* Formatted on 8/30/2021 12:20:15 PM (QP5 v5.287) */
BEGIN
   SYS.DBMS_NETWORK_ACL_ADMIN.create_acl (
      acl           => 'power_users_apex.xml',
      description   => 'Access to Apex Email',
      principal     => 'APEX_200100',
      is_grant      => TRUE,
      privilege     => 'connect',
      start_date    => SYSTIMESTAMP,
      end_date      => NULL);
END;
/

BEGIN
   SYS.DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'power_users_apex.xml',
                                             principal   => 'APEX_200100',
                                             IS_GRANT    => TRUE,
                                             PRIVILEGE   => 'resolve');
   COMMIT;
END;
/

BEGIN
   SYS.DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'power_users_apex.xml',
                                          HOST         => 'smtp.office365.com',
                                          lower_port   => 587,
                                          upper_port   => NULL);
   COMMIT;
END;
/

BEGIN
   SYS.DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'power_users_apex.xml',
                                          HOST         => 'smtp.office365.com',
                                          lower_port   => 25,
                                          upper_port   => NULL);
   COMMIT;
END;
/

BEGIN
  SYS.DBMS_NETWORK_ACL_ADMIN.unassign_acl (
    acl         => 'power_users_apex.xml',
    host        => 'smtp.office365.com', 
    lower_port  => 25,
    upper_port  => NULL); 

  COMMIT;
END;
/