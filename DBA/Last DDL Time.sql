Select OBJECT_NAME, LAST_DDL_TIME
From user_objects
Where OBJECT_NAME='MY_TABLE'

SELECT object_name, object_type, last_ddl_time
  FROM dba_objects (or all_objects)
 WHERE owner = <<owner of table>>
   AND object_name = 'MY_TABLE'