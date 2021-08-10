--1)
 select * from gmf_xla_extract_headers where EVENT_ID in (4940534, 4940535);

--2)
 select * from gmf_xla_extract_lines where header_id in (select header_id from gmf_xla_extract_headers where EVENT_ID in (4940534, 4940535));

--3)
 select * from xla_events where event_id in (4940534, 4940535);

--4)
 select * from xla_ae_headers where event_id in (4940534, 4940535);

--5)
 select * from xla_ae_lines where ae_header_id in ( select ae_header_id from xla_ae_headers where event_id in (4940534, 4940535));

--6)
 select * from gl_je_lines where gl_sl_link_id in (select gl_sl_link_id from xla_ae_lines where ae_header_id in (select ae_header_id from xla_ae_headers where event_id in (4940534, 4940535)));
