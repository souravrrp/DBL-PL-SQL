/* Formatted on 8/30/2021 4:32:54 PM (QP5 v5.287) */
SELECT any_path
  FROM resource_view
 WHERE any_path LIKE '/sys/acls/%.xml';

  SELECT acl,
         principal,
         privilege,
         is_grant,
         TO_CHAR (start_date, 'DD-MON-YYYY') AS start_date,
         TO_CHAR (end_date, 'DD-MON-YYYY') AS end_date
    FROM dba_network_acl_privileges
ORDER BY acl, principal, privilege;


SELECT *
  FROM dba_network_acls
 WHERE 1 = 1 AND acl = '/sys/acls/power_users_apex.xml';

SELECT * FROM dba_network_acl_privileges;

SELECT HOST,
       lower_port,
       upper_port,
       privilege,
       status
  FROM user_network_acl_privileges;