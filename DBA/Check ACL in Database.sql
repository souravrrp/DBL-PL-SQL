/* Formatted on 8/30/2021 4:31:12 PM (QP5 v5.287) */
--SET SERVEROUTPUT OFF
SET DEFINE OFF


  SELECT HOST,
         lower_port,
         upper_port,
         acl,
         DECODE (
            SYS.DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID (aclid,
                                                              'SCOTT',
                                                              'connect'),
            1, 'GRANTED',
            0, 'DENIED',
            NULL)
            privilege
    FROM dba_network_acls
   WHERE HOST IN
            (SELECT *
               FROM TABLE (
                       SYS.DBMS_NETWORK_ACL_UTILITY.DOMAINS (
                          'smtp.office365.com')))
ORDER BY SYS.DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL (HOST) DESC,
         lower_port,
         upper_port;