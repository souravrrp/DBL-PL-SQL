/* Formatted on 8/19/2020 11:15:22 AM (QP5 v5.287) */
--xxdbl_recp_rout_thread_assign


select
*
from
xxdbl_thread_formula_upd_stg

/*
DECLARE
   l_routing_ver   NUMBER;
BEGIN
   SELECT NVL (MAX (routing_vers), -1)
     --INTO l_routing_ver
     FROM gmd_routings_b
    WHERE routing_no = 'RS01150-ST-THROUGHPUT ROUTE' AND ROUTING_STATUS = 700;

   DBMS_OUTPUT.put_line (
         'Routing Version : '
      || 'RS01150-ST-THROUGHPUT ROUTE'
      || '  exist '
      || l_routing_ver);
END;
*/