select TEMPORARY_TABLESPACE from dba_users where USERNAME = 'myuser'

------- free space inside that tablespace

select sum(free_blocks)
from gv$sort_segment
where tablespace_name = 'result'

--If you get the result 0 thats mean the temp tablespace doesn't have enough free space, otherwise you need to check segment (mostly happened for RAC) by executing the following command:

select inst_id, tablespace_name, total_blocks, used_blocks, free_blocks
from gv$sort_segment; 

--check total_blocks and used block and adjust the segment as needed.