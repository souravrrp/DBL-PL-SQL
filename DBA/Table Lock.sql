select
   c.owner,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.osuser,
   b.machine
from
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;
   
   
   select
(select username || ' - ' || osuser from v$session where sid=a.sid) blocker,
a.sid || ', ' ||
(select serial# from v$session where sid=a.sid) sid_serial,
' is blocking ',
(select username || ' - ' || osuser from v$session where sid=b.sid) blockee,
b.sid || ', ' ||
(select serial# from v$session where sid=b.sid) sid_serial
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2;

select
distinct to_name object_locked
from
v$object_dependency
where
to_address in
(
select /*+ ordered */
w.kgllkhdl address
from
dba_kgllock w,
dba_kgllock h,
v$session w1,
v$session h1
where
(((h.kgllkmod != 0) and (h.kgllkmod != 1)
and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
and
(((w.kgllkmod = 0) or (w.kgllkmod= 1))
and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
and w.kgllktype = h.kgllktype
and w.kgllkhdl = h.kgllkhdl
and w.kgllkuse = w1.saddr
and h.kgllkuse = h1.saddr
)