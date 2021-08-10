--CREATE USER XXRRP IDENTIFIED BY SOURAVRRP3012;
--
--GRANT CREATE SESSION TO XXRRP;


SELECT 
    username, 
    default_tablespace, 
    profile, 
    authentication_type
FROM
    dba_users
WHERE 
    account_status = 'OPEN';