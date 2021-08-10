/* Formatted on 1/8/2020 2:31:29 PM (QP5 v5.287) */
  SELECT a.tablespace_name, b.file_name
    FROM dba_tablespaces a
         JOIN dba_data_files b ON (a.tablespace_name = b.tablespace_name)
ORDER BY tablespace_name;



SELECT a.tablespace_name, a.*
    FROM dba_tablespaces a;
    
    
select
*
FROM dba_free_space;

select
*
from
dba_data_files


