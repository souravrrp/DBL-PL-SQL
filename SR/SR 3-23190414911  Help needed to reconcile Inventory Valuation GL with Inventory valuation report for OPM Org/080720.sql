--1)
 select * from xla_events where event_id in (4940534, 4940535);

--2)
 select * from xla_ae_headers where event_id in (4940534, 4940535);

--3)
 select * from xla_ae_lines where ae_header_id in ( select ae_header_id from xla_ae_headers where event_id in (4940534, 4940535));