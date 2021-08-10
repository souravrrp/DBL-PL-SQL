/* Formatted on 3/23/2020 9:24:21 AM (QP5 v5.287) */
BEGIN
   DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
      HOST         => 'ebs1227vis',
      lower_port   => 25,
      upper_port   => 25,
      ace          => xs$ace_type (privilege_list   => xs$name_list ('smtp'),
                                   principal_name   => 'APPS',
                                   principal_type   => XS_ACL.PTYPE_DB));
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
      HOST         => 'www-proxy.example.com',
      lower_port   => 80,
      upper_port   => 80,
      ace          => xs$ace_type (
                        privilege_list   => xs$name_list ('http_proxy'),
                        principal_name   => 'APPS',
                        principal_type   => XS_ACL.PTYPE_DB));
END;
/

BEGIN
   DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
      HOST         => 'ebs1227vis.example.com',
      lower_port   => 443,
      upper_port   => 443,
      ace          => xs$ace_type (privilege_list   => xs$name_list ('http'),
                                   principal_name   => 'APPS',
                                   principal_type   => XS_ACL.PTYPE_DB));
END;