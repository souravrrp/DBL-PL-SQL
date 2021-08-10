select
*
from
v$dblink

select
*
from
GV$DBLINK

SELECT * FROM DBA_DB_LINKS

SELECT * FROM ALL_DB_LINKS

SELECT * FROM USER_DB_LINKS



CREATE DATABASE LINK dblink 
    CONNECT TO remote_user IDENTIFIED BY password
    USING '(DESCRIPTION=
                (ADDRESS=(PROTOCOL=TCP)(HOST=oracledb.example.com)(PORT=1521))
                (CONNECT_DATA=(SERVICE_NAME=service_name))
            )';