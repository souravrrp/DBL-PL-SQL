--Error Message:Could Not Reserve Records Due to Database Record Lock
--1. Identify the Oracle serial ID, SID ID and terminate without shutting the database down.

--1.1 Make sure that the user is logged off.

--1.1.1 Type ps -ef |grep

--1.1.2 Kill all processes related to that user.

--1.2 Identify SID, serial#

select distinct
acc.object, ses.osuser, ses.process,
ses.sid, ses.serial#
from v$access acc,
v$session ses
where (acc.owner != 'SYS'
or acc.object = 'PLAN_TABLE')
and acc.sid = ses.sid
and ses.status != 'INACTIVE'
and ses.type != 'BACKGROUND'
and acc.object not in ('V$ACCESS','V$SESSION')
and ses.audsid != userenv('SESSIONID')
order by 1,2,3
/


--1.3. Double-check the identified SID and serial ID:

SELECT osuser,
username,
process,
sid,
serial#,
status,
to_char(logon_time,'DD-MON HH24:MI:SS') logon_time,
machine,
program
FROM v$session
WHERE sid = &SID_NUM
/

--1.4. ALTER SYSTEM KILL SESSION '&SID_NUM,&SERIAL_NUM';
--Alternatively use the following scripts to identify the blocking session:

-- check for locked tables
select a.object_id, a.session_id, substr(b.object_name, 1, 40)
from v$locked_object a,
dba_objects b
where a.object_id = b.object_id
order by b.object_name ;

--find_blocked.sql
select sid,
decode(block ,0,'NO','YES') BLOCKER,
decode(request,0,'NO','YES') WAITER
from v$lock
where request > 0 or block > 0 order by block desc
/

SELECT 'alter system kill session '''||vs.sid||','||vs.serial#||'''' ,al.
object_name, al.object_type, vs.status,
fu.user_name,vs.process,vs.osuser,vs.username,
to_char(vs.logon_time,'DD-MON HH24:MI:SS') logon_time, vs.program
FROM fnd_logins fl, fnd_user fu, all_objects al, v$lock vl, v$session vs
WHERE fl.pid = vl.sid
AND vl.id1 = al.object_id (+)
AND fl.user_id = fu.user_id
AND to_char (start_time, 'DD-MON-RR') = to_char (sysdate, 'DD-MON-RR')
and vs.sid=vl.sid
and vl.sid = &sid

'ALTERSYSTEMKILLSESSION'''||VS.SID||','||VS.SERIAL#||''''