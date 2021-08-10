/* Formatted on 7/15/2021 4:16:59 PM (QP5 v5.287) */
SELECT TEMPORARY_TABLESPACE
  FROM dba_users
 WHERE USERNAME = 'APPS';

SELECT SUM (free_blocks)
  FROM gv$sort_segment
 WHERE tablespace_name = 'result';

SELECT inst_id,
       tablespace_name,
       total_blocks,
       used_blocks,
       free_blocks
  FROM gv$sort_segment;