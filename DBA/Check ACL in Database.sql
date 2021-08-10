SELECT host, lower_port, upper_port, acl FROM   dba_network_acls;

SELECT acl,
       principal,
       privilege,
       is_grant,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM   dba_network_acl_privileges;

SELECT host, lower_port, upper_port, privilege, status
FROM   user_network_acl_privileges;


---------------------------------------------------------------------------------------------------

/*


SET SERVEROUTPUT ON
SET DEFINE OFF

SELECT host, acl,
     DECODE(
          DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID(aclid, 'SCOTT', 'resolve'),
            1, 'GRANTED', 0, 'DENIED', NULL) privilege
     FROM dba_network_acls
    WHERE host IN
      (SELECT * FROM
         TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS('www.us.oracle.com'))) and
      lower_port IS NULL AND upper_port IS NULL
   ORDER BY DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) desc;
   
     SELECT host, lower_port, upper_port, acl,
     DECODE(
         DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID(aclid, 'SCOTT', 'connect'),
            1, 'GRANTED', 0, 'DENIED', null) privilege
     FROM dba_network_acls
    WHERE host IN
      (SELECT * FROM
         TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS('www.us.oracle.com')))
   ORDER BY DBMS_NETWORK_ACL_UTLITITY.DOMAIN_LEVEL(host) desc, lower_port, 
                                               upper_port;


*/