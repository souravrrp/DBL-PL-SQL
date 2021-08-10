---Shows active (in progress) transactions  
select username, terminal, osuser,
       t.start_time, r.name, t.used_ublk "ROLLB BLKS",
       decode(t.space, 'YES', 'SPACE TX',
          decode(t.recursive, 'YES', 'RECURSIVE TX',
             decode(t.noundo, 'YES', 'NO UNDO TX', t.status)
       )) status
from sys.v_$transaction t, sys.v_$rollname r, sys.v_$session s
where t.xidusn = r.usn
  and t.ses_addr = s.saddr;

----Display rollback segment statistics
Select rn.Name "Rollback Segment", rs.RSSize/1024 "Size (KB)", rs.Gets "Gets",
       rs.waits "Waits", (rs.Waits/rs.Gets)*100 "% Waits",
       rs.Shrinks "# Shrinks", rs.Extends "# Extends"
from   sys.v_$RollName rn, sys.v_$RollStat rs
where  rn.usn = rs.usn;

----Display database sessions using rollback segments
SELECT r.name "RBS", s.sid, s.serial#, s.username "USER", t.status,
       t.cr_get, t.phy_io, t.used_ublk, t.noundo,
       substr(s.program, 1, 78) "COMMAND"
FROM   sys.v_$session s, sys.v_$transaction t, sys.v_$rollname r
WHERE  t.addr = s.taddr
  and  t.xidusn = r.usn
ORDER  BY t.cr_get, t.phy_io;

--The following query provides clues about whether Oracle has been waiting for library cache activities:

Select sid, event, p1raw, seconds_in_wait, wait_time
From v$session_wait
Where event = 'library cache pin'
And state = 'WAITING';

--The below Query gives details of Users sessions wait time and state:

SELECT NVL (s.username, '(oracle)') AS username, s.SID, s.serial#, sw.event,
sw.wait_time, sw.seconds_in_wait, sw.state
FROM v$session_wait sw, v$session s
WHERE s.SID = sw.SID
ORDER BY sw.seconds_in_wait DESC;
