create or replace directory 
bdump as '/oracle/diag/rdbms/home/O11/trace';
/
grant read on directory bdump to public
/
drop table system.alert_log
/
create table system.alert_log (
line varchar2(512) )
organization external
(
type oracle_loader
default directory bdump
access parameters 
  (
      records delimited by newline
      nobadfile nologfile nodiscardfile
      fields (line char(512)
  )
)
	location('alert_O11.log') )
	reject limit unlimited
/

drop public synonym alert_log;
create public synonym alert_log for system.alert_log;
