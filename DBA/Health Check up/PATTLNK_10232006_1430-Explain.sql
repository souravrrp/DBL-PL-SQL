set verify off 
delete from plan_table where statement_id = 'PSI';
commit;

EXPLAIN PLAN
SET STATEMENT_ID = 'PSI'
for
<<<Insert Query Here>>>
/

set pagesize 60 linesize 132
SELECT * FROM TABLE(dbms_xplan.display('PLAN_TABLE','PSI','TYPICAL'));