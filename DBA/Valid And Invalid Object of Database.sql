SELECT owner, object_name, object_type
FROM     all_objects
WHERE  status = 'INVALID';

SELECT count(*)
FROM  dba_objects
WHERE  status = 'INVALID';