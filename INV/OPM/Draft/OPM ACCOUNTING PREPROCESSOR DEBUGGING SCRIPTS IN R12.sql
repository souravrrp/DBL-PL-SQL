--Orgn: &&organization_id 
--==================
SELECT * FROM mtl_parameters WHERE organization_id = :P_organization_id;

--Item details FOR Item: &&inv_item_id 
--=========================
SELECT *
FROM mtl_system_items_kfv
WHERE organization_id =
  :P_organization_id
AND inventory_item_id =
  :P_inv_item_id;

--Cost Type details FOR Cost Type: &&cost_type
--=================================
SELECT * FROM cm_mthd_mst WHERE cost_mthd_code = :P_cost_type;

--Period Balances FOR Item: &&inv_item_id Orgn: &&organization_id 
--==============================================
SELECT pbal.inventory_item_id AS item_id,
  pbal.primary_quantity       AS quantity,
  pbal.organization_id        AS mtl_organization_id,
  pbal.period_balance_id      AS perd_bal_id,
  NVL(pbal.lot_number,' '),
  pbal.subinventory_code,
  pbal.locator_id,
  pbal.costed_flag,
  pbal.acct_period_id
FROM org_acct_periods oap,
  gmf_period_balances pbal,
  gmf_fiscal_policies gfp,
  gl_ledgers gl,
  hr_organization_information hoi
WHERE oap.period_start_date >= TO_DATE(‘&&datefrom’
  ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
AND oap.schedule_close_date <= TO_DATE(‘&&dateto’
  ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
AND hoi.organization_id =
  &&organization_id
AND hoi.org_information_context = ‘Accounting Information’
AND gfp.legal_entity_id         = hoi.org_information2
AND gl.ledger_id                = gfp.ledger_id
AND oap.period_set_name         = gl.period_set_name
AND oap.organization_id         = pbal.organization_id
AND pbal.acct_period_id         = oap.acct_period_id
AND pbal.inventory_item_id      =
  &&inv_item_id
AND pbal.organization_id =
  &&organization_id ;
  
Item Costs 
==========
SELECT c.inventory_item_id ,
  c.organization_id ,
  c.period_id ,
  TO_CHAR (end_date, ‘MM/DD/YYYY hh24:mi:ss’) perd_end_date ,
  m.cost_mthd_code ,
  c.cost_type_id ,
  c.acctg_cost ,
  c.itemcost_id ,
  d.cost_cmpntcls_id ,
  d.cost_analysis_code ,
  d.cmptcost_amt
FROM gl_item_cst c,
  gl_item_dtl d,
  cm_mthd_mst m
WHERE d.itemcost_id     = c.itemcost_id
AND c.inventory_item_id =
  &&inv_item_id
AND c.organization_id =
  &&organization_id
AND c.cost_type_id   = m.cost_type_id
AND m.cost_mthd_code = ‘&&cost_type’
ORDER BY c.end_date DESC ;

Actual Cost Adjs 
============
SELECT d.inventory_item_id,
  d.organization_id,
  d.cost_cmpntcls_id,
  d.cost_analysis_code,
  d.cost_adjust_id,
  d.adjust_qty,
  d.adjust_qty_uom,
  d.adjust_cost,
  d.reason_code,
  NVL(d.adjustment_ind, DECODE(d.adjust_qty, 0, 1, 0)) adjustment_ind,
  TO_CHAR(d.adjustment_date,’MM/DD/YYYY hh24:mi:ss’),
  cmpt.usage_ind,
  d.adjust_status,
  d.subledger_ind,
  d.delete_mark
FROM cm_adjs_dtl d,
  cm_cmpt_mst cmpt,
  cm_mthd_mst m
WHERE d.inventory_item_id =
  &&inv_item_id
AND d.organization_id =
  &&organization_id
AND cmpt.cost_cmpntcls_id = d.cost_cmpntcls_id
AND d.cost_type_id        = m.cost_type_id
AND m.cost_mthd_code      = ‘&&cost_type’
AND d.adjustment_date    >= TO_DATE(‘&&datefrom’
  ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
AND d.adjustment_date <= TO_DATE(‘&&dateto’
  ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
ORDER BY d.inventory_item_id,
  d.organization_id,
  d.adjustment_date,
  d.cost_adjust_id ;
  
Lot Cost Adjs 
==========
SELECT lca.inventory_item_id,
  lca.lot_number,
  lca.reason_code,
  TO_CHAR(lca.adjustment_date,’MM/DD/YYYY hh24:mi:ss’) adjustment_date,
  lca.adjustment_id,
  lcad.cost_cmpntcls_id,
  lcad.cost_analysis_code,
  (NVL(lcad.adjustment_cost,0) * NVL(lca.onhand_qty,0)) delta_amount,
  lca.onhand_qty,
  lca.organization_id,
  lcad.adjustment_cost,
  cmpt.usage_ind ,
  lca.old_cost_header_id ,
  lca.new_cost_header_id ,
  lca.gl_posted_ind ,
  lca.applied_ind
FROM gmf_lot_cost_adjustment_dtls lcad,
  gmf_lot_cost_adjustments lca,
  cm_cmpt_mst cmpt,
  cm_mthd_mst m
WHERE lca.cost_type_id   = m.cost_type_id
AND m.cost_mthd_code     = ‘&&cost_type’
AND lca.adjustment_date >= TO_DATE(‘&&datefrom’
  ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
AND lca.adjustment_date <= TO_DATE(‘&&dateto’
  ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
AND lcad.adjustment_id    = lca.adjustment_id
AND cmpt.cost_cmpntcls_id = lcad.cost_cmpntcls_id
AND lca.inventory_item_id =
  &&inv_item_id
AND lca.organization_id =
  &&organization_id
ORDER BY 1,
  12,
  3,
  4,
  6,
  7,
  8 ;
  
GL Expense Allocation 
===============
SELECT gps.calendar_code,
  gps.period_code,
  gps.cost_type_id,
  ‘ ‘ dtl_cost_mthd_code,
  bas.inventory_item_id AS item_id,
  bas.whse_code,
  bas.cmpntcls_id,
  cmpt.cost_cmpntcls_code,
  bas.analysis_code,
  dtl.allocated_expense_amt,
  NVL(dtl.period_qty,0),
  bas.organization_id,
  dtl.period_id,
  dtl.alloc_id,
  dtl.line_no,
  dtl.allocdtl_id,
  cmpt.usage_ind ,
  mst.alloc_code ,
  dtl.ac_status ,
  dtl.delete_mark
FROM gl_aloc_dtl dtl,
  gl_aloc_bas bas,
  gl_aloc_mst mst,
  gmf_period_statuses gps,
  cm_cmpt_mst cmpt ,
  hr_organization_information hoi ,
  cm_mthd_mst m
WHERE mst.legal_entity_id       = hoi.org_information2
AND hoi.organization_id         = bas.organization_id
AND hoi.org_information_context = ‘Accounting Information’
AND bas.inventory_item_id       =
  &&inv_item_id
AND bas.organization_id =
  &&organization_id
AND cmpt.cost_cmpntcls_id = bas.cmpntcls_id
AND dtl.alloc_id          = mst.alloc_id
AND dtl.alloc_id          = bas.alloc_id
AND dtl.line_no           = bas.line_no
AND dtl.cost_type_id      = gps.cost_type_id
AND gps.period_id         = dtl.period_id
AND gps.start_date       >= TO_DATE(‘&&datefrom’
  ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
AND gps.end_date <= TO_DATE(‘&&dateto’
  ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
AND gps.legal_entity_id= hoi.org_information2
AND gps.cost_type_id   = m.cost_type_id
AND m.cost_mthd_code   = ‘&&cost_type’
AND gps.delete_mark    = 0
ORDER BY dtl.period_id,
  dtl.cost_type_id,
  bas.inventory_item_id,
  bas.organization_id,
  bas.cmpntcls_id,
  bas.analysis_code ;
  
Extract Header (COSTREVAL) 
====================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh
WHERE geh.entity_code   = ‘REVALUATION’
AND geh.event_type_code = ‘COSTREVAL’
AND geh.transaction_id IN
  (SELECT pbal.period_balance_id
  FROM org_acct_periods oap,
    gmf_period_balances pbal,
    gmf_fiscal_policies gfp,
    gl_ledgers gl,
    hr_organization_information hoi
  WHERE oap.period_start_date >= TO_DATE(‘&&datefrom’,’MM/DD/YYYY’)
  AND oap.schedule_close_date <= TO_DATE(‘&&dateto’,’MM/DD/YYYY’)
  AND hoi.organization_id      =
    &&organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND gfp.legal_entity_id         = hoi.org_information2
  AND gl.ledger_id                = gfp.ledger_id
  AND oap.period_set_name         = gl.period_set_name
  AND oap.organization_id         = pbal.organization_id
  AND pbal.acct_period_id         = oap.acct_period_id
  AND pbal.inventory_item_id      =
    &&inv_item_id
  AND pbal.organization_id =
    &&organization_id
  );

Extract Lines (COSTREVAL) 
==================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id     = geh.header_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘COSTREVAL’
AND geh.transaction_id IN
  (SELECT pbal.period_balance_id
  FROM org_acct_periods oap,
    gmf_period_balances pbal,
    gmf_fiscal_policies gfp,
    gl_ledgers gl,
    hr_organization_information hoi
  WHERE oap.period_start_date >= TO_DATE(‘&&datefrom’,’MM/DD/YYYY’)
  AND oap.schedule_close_date <= TO_DATE(‘&&dateto’,’MM/DD/YYYY’)
  AND hoi.organization_id      =
    &&organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND gfp.legal_entity_id         = hoi.org_information2
  AND gl.ledger_id                = gfp.ledger_id
  AND oap.period_set_name         = gl.period_set_name
  AND oap.organization_id         = pbal.organization_id
  AND pbal.acct_period_id         = oap.acct_period_id
  AND pbal.inventory_item_id      =
    &&inv_item_id
  AND pbal.organization_id =
    &&organization_id
  );
  
SLA Events (COSTREVAL) 
=================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  xla.xla_events xe
WHERE xe.event_id       = geh.event_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘COSTREVAL’
AND geh.transaction_id IN
  (SELECT pbal.period_balance_id
  FROM org_acct_periods oap,
    gmf_period_balances pbal,
    gmf_fiscal_policies gfp,
    gl_ledgers gl,
    hr_organization_information hoi
  WHERE oap.period_start_date >= TO_DATE(‘&&datefrom’,’MM/DD/YYYY’)
  AND oap.schedule_close_date <= TO_DATE(‘&&dateto’,’MM/DD/YYYY’)
  AND hoi.organization_id      =
    &&organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND gfp.legal_entity_id         = hoi.org_information2
  AND gl.ledger_id                = gfp.ledger_id
  AND oap.period_set_name         = gl.period_set_name
  AND oap.organization_id         = pbal.organization_id
  AND pbal.acct_period_id         = oap.acct_period_id
  AND pbal.inventory_item_id      =
    &&inv_item_id
  AND pbal.organization_id =
    &&organization_id
  );
  
Extract Header (ACTCOSTADJ) 
=======================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh
WHERE geh.entity_code   = ‘REVALUATION’
AND geh.event_type_code = ‘ACTCOSTADJ’
AND geh.transaction_id IN
  (SELECT d.cost_adjust_id
  FROM cm_adjs_dtl d,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE d.inventory_item_id =
    &&inv_item_id
  AND d.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = d.cost_cmpntcls_id
  AND d.cost_type_id        = m.cost_type_id
  AND m.cost_mthd_code      = ‘&&cost_type’
  AND d.adjustment_date    >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND d.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  );
  
Extract Lines (ACTCOSTADJ) 
===================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id     = geh.header_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘ACTCOSTADJ’
AND geh.transaction_id IN
  (SELECT d.cost_adjust_id
  FROM cm_adjs_dtl d,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE d.inventory_item_id =
    &&inv_item_id
  AND d.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = d.cost_cmpntcls_id
  AND d.cost_type_id        = m.cost_type_id
  AND m.cost_mthd_code      = ‘&&cost_type’
  AND d.adjustment_date    >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND d.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  );
  
Sla Events (ACTCOSTADJ) 
====================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  xla.xla_events xe
WHERE xe.event_id       = geh.event_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘ACTCOSTADJ’
AND geh.transaction_id IN
  (SELECT d.cost_adjust_id
  FROM cm_adjs_dtl d,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE d.inventory_item_id =
    &&inv_item_id
  AND d.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = d.cost_cmpntcls_id
  AND d.cost_type_id        = m.cost_type_id
  AND m.cost_mthd_code      = ‘&&cost_type’
  AND d.adjustment_date    >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND d.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  );
  
Extract Header (LOTCOSTADJ) 
=====================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh
WHERE geh.entity_code   = ‘REVALUATION’
AND geh.event_type_code = ‘LOTCOSTADJ’
AND geh.transaction_id IN
  (SELECT lca.adjustment_id
  FROM gmf_lot_cost_adjustment_dtls lcad,
    gmf_lot_cost_adjustments lca,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE lca.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code     = ‘&&cost_type’
  AND lca.adjustment_date >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND lca.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND lcad.adjustment_id    = lca.adjustment_id
  AND cmpt.cost_cmpntcls_id = lcad.cost_cmpntcls_id
  AND lca.inventory_item_id =
    &&inv_item_id
  AND lca.organization_id =
    &&organization_id
  );
  
Extract Lines (LOTCOSTADJ) 
===================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id     = geh.header_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘LOTCOSTADJ’
AND geh.transaction_id IN
  (SELECT lca.adjustment_id
  FROM gmf_lot_cost_adjustment_dtls lcad,
    gmf_lot_cost_adjustments lca,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE lca.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code     = ‘&&cost_type’
  AND lca.adjustment_date >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND lca.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND lcad.adjustment_id    = lca.adjustment_id
  AND cmpt.cost_cmpntcls_id = lcad.cost_cmpntcls_id
  AND lca.inventory_item_id =
    &&inv_item_id
  AND lca.organization_id =
    &&organization_id
  );
  
SLA Events (LOTCOSTADJ) 
==================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  xla.xla_events xe
WHERE xe.event_id       = geh.event_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘LOTCOSTADJ’
AND geh.transaction_id IN
  (SELECT lca.adjustment_id
  FROM gmf_lot_cost_adjustment_dtls lcad,
    gmf_lot_cost_adjustments lca,
    cm_cmpt_mst cmpt,
    cm_mthd_mst m
  WHERE lca.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code     = ‘&&cost_type’
  AND lca.adjustment_date >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND lca.adjustment_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND lcad.adjustment_id    = lca.adjustment_id
  AND cmpt.cost_cmpntcls_id = lcad.cost_cmpntcls_id
  AND lca.inventory_item_id =
    &&inv_item_id
  AND lca.organization_id =
    &&organization_id
  );
  
Extract Header (GLCOSTALOC) 
=====================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh
WHERE geh.entity_code   = ‘REVALUATION’
AND geh.event_type_code = ‘GLCOSTALOC’
AND geh.transaction_id IN
  (SELECT dtl.allocdtl_id
  FROM gl_aloc_dtl dtl,
    gl_aloc_bas bas,
    gl_aloc_mst mst,
    gmf_period_statuses gps,
    cm_cmpt_mst cmpt ,
    hr_organization_information hoi ,
    cm_mthd_mst m
  WHERE mst.legal_entity_id       = hoi.org_information2
  AND hoi.organization_id         = bas.organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND bas.inventory_item_id       =
    &&inv_item_id
  AND bas.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = bas.cmpntcls_id
  AND dtl.alloc_id          = mst.alloc_id
  AND dtl.alloc_id          = bas.alloc_id
  AND dtl.line_no           = bas.line_no
  AND dtl.cost_type_id      = gps.cost_type_id
  AND gps.period_id         = dtl.period_id
  AND gps.start_date       >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.end_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.legal_entity_id= hoi.org_information2
  AND gps.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code   = ‘&&cost_type’
  AND gps.delete_mark    = 0
  );
  
Extract Lines (GLCOSTALOC) 
====================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id     = geh.header_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘GLCOSTALOC’
AND geh.transaction_id IN
  (SELECT dtl.allocdtl_id
  FROM gl_aloc_dtl dtl,
    gl_aloc_bas bas,
    gl_aloc_mst mst,
    gmf_period_statuses gps,
    cm_cmpt_mst cmpt ,
    hr_organization_information hoi ,
    cm_mthd_mst m
  WHERE mst.legal_entity_id       = hoi.org_information2
  AND hoi.organization_id         = bas.organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND bas.inventory_item_id       =
    &&inv_item_id
  AND bas.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = bas.cmpntcls_id
  AND dtl.alloc_id          = mst.alloc_id
  AND dtl.alloc_id          = bas.alloc_id
  AND dtl.line_no           = bas.line_no
  AND dtl.cost_type_id      = gps.cost_type_id
  AND gps.period_id         = dtl.period_id
  AND gps.start_date       >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.end_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.legal_entity_id= hoi.org_information2
  AND gps.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code   = ‘&&cost_type’
  AND gps.delete_mark    = 0
  );
  
SLA Events (GLCOSTALOC) 
==================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  xla.xla_events xe
WHERE xe.event_id       = geh.event_id
AND geh.entity_code     = ‘REVALUATION’
AND geh.event_type_code = ‘GLCOSTALOC’
AND geh.transaction_id IN
  (SELECT dtl.allocdtl_id
  FROM gl_aloc_dtl dtl,
    gl_aloc_bas bas,
    gl_aloc_mst mst,
    gmf_period_statuses gps,
    cm_cmpt_mst cmpt ,
    hr_organization_information hoi ,
    cm_mthd_mst m
  WHERE mst.legal_entity_id       = hoi.org_information2
  AND hoi.organization_id         = bas.organization_id
  AND hoi.org_information_context = ‘Accounting Information’
  AND bas.inventory_item_id       =
    &&inv_item_id
  AND bas.organization_id =
    &&organization_id
  AND cmpt.cost_cmpntcls_id = bas.cmpntcls_id
  AND dtl.alloc_id          = mst.alloc_id
  AND dtl.alloc_id          = bas.alloc_id
  AND dtl.line_no           = bas.line_no
  AND dtl.cost_type_id      = gps.cost_type_id
  AND gps.period_id         = dtl.period_id
  AND gps.start_date       >= TO_DATE(‘&&datefrom’
    ||’ 00:00:00',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.end_date <= TO_DATE(‘&&dateto’
    ||’ 23:59:59',’MM/DD/YYYY hh24:mi:ss’)
  AND gps.legal_entity_id= hoi.org_information2
  AND gps.cost_type_id   = m.cost_type_id
  AND m.cost_mthd_code   = ‘&&cost_type’
  AND gps.delete_mark    = 0
  );
  
ORDER MANAGEMENT RELATED: 
ORDER header info FOR sales ORDER NUMBER: &ord_num 
=====================================
SELECT o.name operating_unit,
  h.header_id,
  h.ship_from_org_id inv_org,
  h.order_type_id,
  h.flow_status_code status,
  h.open_flag,
  booked_flag,
  h.cancelled_flag,
  h.ordered_date ord_dt
FROM oe_order_headers_all h,
  hr_operating_units o
WHERE header_id =
  &hid
AND o.organization_id                                                    = h.org_id;

ORDER line details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid 
==================================================
SELECT rtrim(l.line_number
  ||’.’
  || l.shipment_number
  ||’.’
  || l.option_number
  ||’.’
  || l.component_number
  ||’.’
  || l.service_number, ‘.’) line_num,
  l.line_id,
  l.split_from_line_id,
  l.split_by,
  l.flow_status_code status,
  l.source_document_type_id,
  l.org_id,
  l.ordered_item item,
  l.ordered_quantity qty1,
  l.order_quantity_uom um1,
  l.ordered_quantity2 qty2,
  l.ordered_quantity_uom2 um2,
  l.shipped_quantity sqty,
  l.shipping_quantity sgqty,
  l.ship_tolerance_above sta,
  l.ship_tolerance_below stb,
  l.fulfilled_flag ful_flag,
  l.shipping_interfaced_flag ship_int_flag,
  l.fulfilled_quantity fqty,
  l.invoiced_quantity invoice_qty,
  l.invoice_interface_status_code inv_int_sta_code,
  l.open_flag,
  l.booked_flag,
  l.cancelled_quantity cqty,
  l.cancelled_flag,
  l.inventory_item_id,
  l.ship_from_org_id,
  w.organization_code,
  w.process_enabled_flag,–w.loct_ctl wlc,
  m.lot_divisible_flag,
  m.tracking_quantity_ind,
  m.dual_uom_control dualum_ind,
  m.secondary_default_ind,
  m.primary_uom_code uom,
  m.secondary_uom_code uom2,
  m.dual_uom_deviation_high,
  m.dual_uom_deviation_low,
  m.lot_control_code lot_ctl,
  m.child_lot_flag sublot_ctl,
  m.location_control_code loct_ctl,
  m.grade_control_flag grade_ctl,
  m.lot_status_enabled status_ctl,
  –i.lot_indivisible, i.noninv_ind, i.dualum_ind, i.lot_ctl, i.sublot_ctl, i.loct_ctl,
  –i.grade_ctl,i.status_ctl,
  DECODE(m.ont_pricing_qty_source,’P’,’Primary’,’Secondary’) ont_pricing_qty_source,
  l.source_document_line_id sdli,
  l.source_type_code src_type,
  ott.name line_type,
  TO_CHAR(l.creation_date,’dd-mon-yyyy hh24:mi:ss’) cr_dt,
  TO_CHAR(l.last_update_date,’dd-mon-yyyy hh24:mi:ss’) upd_dt
FROM oe_order_lines_all l,
  mtl_parameters w,
  mtl_system_items_b m,
  oe_transaction_types_tl ott
WHERE l.header_id =
  &hid
AND l.line_id LIKE DECODE(‘&lineid’,’all’,’%’,’&lineid’)
AND l.ship_from_org_id  = w.organization_id
AND l.inventory_item_id = m.inventory_item_id
AND l.ship_from_org_id  = m.organization_id
AND l.line_type_id      = ott.transaction_type_id
AND ott.language        =
  ( SELECT fl.language_code FROM fnd_languages fl WHERE fl.installed_flag = ‘B’
  )
ORDER BY l.line_id;

Delivery line details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid 
====================================================
SELECT source_line_number,
  source_line_id,
  delivery_detail_id,
  split_from_delivery_detail_id,
  move_order_line_id,
  DECODE(rele ased_status,’R’,’R-Ready for rel’,’S’,’S-Rel to whse’,’Y’,’Y-Staged’, ‘C’,’C-Shipped’,’B’,’B-Backordered’,’D’,’D-Cancelled’,released_status) rel_sts,
  requested_quantity,
  requested_quantity_uom,
  requested_quantity2,
  requested_quantity_uom2,
  picked_quantity,
  picked_quantity2,
  shipped_quantity,
  shipped_quantity2,
  lot_number lotno,
  sublot_number slotno,
  oe_interfaced_flag oeif,
  inv_interfaced_flag invif,
  ship_tolerance_above sta,
  ship_tolerance_below stb,
  ship_set_id,
  inventory_item_id,
  src_requested_quantity,
  src_requested_quantity_uom,
  src_requested_quantity2,
  src_requested_quantity_uom2,
  organization_id inv_org,
  cancelled_quantity,
  cancelled_quantity2,
  delivered_quantity,
  delivered_quantity2,
  TO_CHAR(creation_date,’dd-mon-yyyy hh24:mi:ss’) cr_dt,
  TO_CHAR(last_update_date,’dd-mon-yyyy hh24:mi:ss’) upd_dt
FROM wsh_delivery_details
WHERE source_header_id =
  &hid
AND source_line_id LIKE DECODE(‘&lineid’,’all’,’%’,’&lineid’)
ORDER BY source_line_id,
  delivery_detail_id;
  
Reservation details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid 
====================================================
SELECT mso.sales_order_id,
  typ.name
INTO :sales_ord_id,
  :ord_type_name
FROM mtl_sales_orders mso,
  oe_order_headers_all ord,
  oe_transaction_types_tl typ
WHERE ord.header_id =
  &hid
AND ord.order_type_id = typ.transaction_type_id
AND language          =
  ( SELECT fl.language_code FROM fnd_languages fl WHERE fl.installed_flag = ‘B’
  )
AND mso.segment1 =
  &ord_num
AND typ.name = mso.segment2;
dbms_output.put_line(‘sales order id order number order type ‘);
dbms_output.put_line(‘——————————————————————‘);
dbms_output.put_line(rpad(TO_CHAR(:sales_ord_id), 16, ‘ ‘)||rpad(‘&ord_num’, 20, ‘ ‘)||:ord_type_name);
END;
/
SELECT res.reservation_id reserv_id,
  DECODE(res.ship_ready_flag, 1,’1=released’, 2,’2=submitted’, TO_CHAR(res.ship_ready_flag)) ship_ready,
  res.demand_source_header_id ds_head_id,
  TO_CHAR(LIN.line_number)
  || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.shipment_number))
  || DECODE(LIN.option_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.option_number))
  || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
  || ‘.’
  ||TO_CHAR(LIN.component_number))
  || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
  || DECODE(LIN.option_number, NULL, ‘.’, NULL )
  || ‘.’
  || TO_CHAR(LIN.service_number)) LINE,
  res.demand_source_line_id ds_line_id,
  res.primary_reservation_quantity res_q,
  res.primary_uom_code uom,
  res.secondary_reservation_quantity sec_res_q,
  inv_convert.inv_um_convert( res.inventory_item_id, res.lot_number, res.organization_id, 5, res.primary_reservation_quantity, res.primary_uom_code, res.secondary_uom_code, NULL, NULL) calc_sec_res_q,
  res.secondary_uom_code uom2,
  res.lot_number lot_num,
  res.organization_id orgn_id,
  res.subinventory_code subinv,
  — res.revision rev,
  res.locator_id loc_id,
  res.detailed_quantity dtl_q,
  res.secondary_detailed_quantity sec_dtl_q,
  res.inventory_item_id inventory_item_id,
  itm.segment1 item,
  res.requirement_date requird_d,
  res.demand_source_delivery ds_deliv,
  res.demand_source_type_id ds_type,
  — res.serial_number serial_num,
  res.supply_source_header_id ss_header_id,
  res.supply_source_line_id ss_source_line,
  res.supply_source_line_detail ss_source_line_det
  –enable_timestamp ,to_char(res.creation_date,’dd-mon hh24:mi:ss’) create_dt
  –enable_timestamp ,to_char(res.last_update_date,’dd-mon hh24:mi:ss’) update_dt
  –enable_timestamp ,res.request_id request_id
FROM mtl_reservations res,
  oe_order_lines_all lin,
  mtl_system_items_b itm
WHERE res.demand_source_header_id          = :sales_ord_id
AND res.demand_source_type_id             IN (2,8,9,21,22)
AND res.demand_source_line_id              = lin.line_id(+)
AND DECODE(‘&lineid’,’all’,’%’,’&lineid’) IN (‘%’,lin.line_id, lin.top_model_line_id, lin.ato_line_id, lin.link_to_line_id, lin.reference_line_id, lin.service_reference_line_id)
AND res.organization_id                    = itm.organization_id(+)
AND res.inventory_item_id                  = itm.inventory_item_id(+)
ORDER BY NVL(lin.top_model_line_id, lin.line_id),
  NVL(lin.ato_line_id, lin.line_id),
  NVL(lin.sort_order, ‘0000’),
  NVL(lin.link_to_line_id, lin.line_id),
  NVL(lin.source_document_line_id, lin.line_id),
  lin.line_id,
  res.reservation_id;
  
Allocation details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid 
==================================================
SELECT tmp.transaction_temp_id mtl_trns_id,
  tmp.move_order_line_id move_line_id,
  itm.segment1 item,
  TO_CHAR(LIN.line_number)
  || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.shipment_number))
  || DECODE(LIN.option_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.option_number))
  || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
  || ‘.’
  ||TO_CHAR(LIN.component_number))
  || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
  || DECODE(LIN.option_number, NULL, ‘.’, NULL )
  || ‘.’
  || TO_CHAR(LIN.service_number)) LINE,
  lin.line_id line_id,
  tmp.primary_quantity prm_q,
  tmp.secondary_transaction_quantity sec_q,
  inv_convert.inv_um_convert( tmp.inventory_item_id, 5, tmp.primary_quantity, itm.primary_uom_code, tmp.secondary_uom_code, NULL, NULL) tmp_cal_sec_q,
  lot.primary_quantity lot_prm_q,
  lot.secondary_quantity lot_sec_q,
  inv_convert.inv_um_convert( tmp.inventory_item_id, lot.lot_number, tmp.organization_id, 5, NVL(lot.primary_quantity,0), itm.primary_uom_code, tmp.secondary_uom_code, NULL, NULL) lot_cal_sec_q,
  tmp.secondary_uom_code uom2,
  lot.lot_number lot_num,
  tmp.subinventory_code from_sub,
  tmp.locator_id from_loc_id,
  tmp.pick_slip_number pick_slip,
  tmp.transfer_subinventory to_sub,
  tmp.transfer_to_location to_loc_id,
  tmp.process_flag process,
  tmp.lock_flag lck,
  tmp.transaction_mode trans_mode,
  tmp.error_code error_code,
  tmp.error_explanation error_expl
FROM mtl_material_transactions_temp tmp,
  mtl_transaction_lots_temp lot,
  oe_order_lines_all lin,
  mtl_system_items_b itm
WHERE tmp.demand_source_line   = lin.line_id
AND lin.line_category_code     = ‘ORDER’
AND lin.ship_from_org_id       = itm.organization_id(+)
AND lin.inventory_item_id      = itm.inventory_item_id(+)
AND lot.transaction_temp_id (+)= tmp.transaction_temp_id
AND lin.header_id              =
  &hid
AND DECODE(‘&lineid’,’all’,’%’,’&lineid’) IN (‘%’,lin.line_id, lin.top_model_line_id, lin.ato_line_id, lin.link_to_line_id, lin.reference_line_id, lin.service_reference_line_id);
–create index mtl_material_transactions_n99 on mtl_material_transactions(trx_source_line_id);
prompt mtl_material_transactions (trn) – picked lines
PROMPT
— This is commented out because it runs slowly without an index
–<do not run> CREATE INDEX MTL_MATL_TRANS_777
–<do not run> ON INV.MTL_MATERIAL_TRANSACTIONS
–<do not run> (trx_source_line_id);
SELECT
  /*moac_sql_no_changes*/
  trn.transaction_id mtl_trns_id,
  trn.move_order_line_id move_line_id,
  trn.OPM_COSTED_FLAG,
  trn.SHIPMENT_COSTED,
  trn.SO_ISSUE_ACCOUNT_TYPE,
  trn.COGS_RECOGNITION_PERCENT,
  trn.TRANSFER_PRICE,
  trn.FOB_POINT,
  trn.OWNING_ORGANIZATION_ID,
  trn.TRANSFER_ORGANIZATION_ID,
  trn.TRANSACTION_ACTION_ID,
  trn.TRANSACTION_SOURCE_TYPE_ID,
  trn.TRANSACTION_TYPE_ID,
  trn.TRANSACTION_QUANTITY,
  trn.TRANSACTION_UOM,
  trn.TRANSACTION_DATE,
  trn.TRANSFER_TRANSACTION_ID,
  cst.ACCTG_COST,
  cst.period_id,
  DECODE(trn.transaction_type_id, 52,’52=stage trans’, 33,’33=so issue’, trn.transaction_type_id) trans_type,
  (SELECT TO_CHAR(LIN.line_number)
    || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
    || TO_CHAR(LIN.shipment_number))
    || DECODE(LIN.option_number, NULL, NULL, ‘.’
    || TO_CHAR(LIN.option_number))
    || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
    || ‘.’
    ||TO_CHAR(LIN.component_number))
    || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
    || DECODE(LIN.option_number, NULL, ‘.’, NULL )
    || ‘.’
    || TO_CHAR(LIN.service_number))
  FROM oe_order_lines_all lin
  WHERE trn.trx_source_line_id = lin.line_id
  ) line,
  trn.trx_source_line_id line_id,
  trn.primary_quantity prm_q,
  trn.secondary_transaction_quantity sec_q,
  inv_convert.inv_um_convert( trn.inventory_item_id, 5, trn.primary_quantity, itm.primary_uom_code, trn.secondary_uom_code, NULL, NULL) trn_cal_sec_q,
  lot.primary_quantity lot_prm_q,
  lot.secondary_transaction_quantity lot_sec_q,
  inv_convert.inv_um_convert( trn.inventory_item_id, lot.lot_number, trn.organization_id, 5, NVL(lot.primary_quantity,0), itm.primary_uom_code, trn.secondary_uom_code, NULL, NULL) lot_cal_sec_q,
  trn.secondary_uom_code uom2,
  lot.lot_number lot_num,
  trn.subinventory_code from_sub,
  trn.locator_id from_loc_id,
  trn.pick_slip_number pick_slip,
  trn.transfer_subinventory to_sub,
  trn.transfer_locator_id to_loc_id,
  trn.organization_id orgn_id,
  trn.transaction_source_id
FROM mtl_material_transactions trn,
  mtl_transaction_lot_numbers lot,
  mtl_system_items_b itm,
  gl_item_cst cst,
  gmf_fiscal_policies gfp,
  gmf_period_statuses gps,
  gmf_organization_definitions god,
  cm_mthd_mst cmm
WHERE trn.trx_source_line_id IN
  (SELECT DISTINCT line_id
  FROM oe_order_lines_all lin1
  WHERE lin1.header_id =
    &hid
  AND DECODE(‘&lineid’,’all’,’%’,’&lineid’) IN (‘%’,lin1.line_id, lin1.top_model_line_id, lin1.ato_line_id, lin1.link_to_line_id, lin1.reference_line_id, lin1.service_reference_line_id)
  )
AND trn.organization_id            = itm.organization_id
AND trn.inventory_item_id          = itm.inventory_item_id
AND lot.transaction_id (+)         = trn.transaction_id
AND trn.transaction_source_type_id = 2
AND gfp.cost_type_id               = cmm.cost_type_id
AND cst.period_id                  = gps.period_id
AND gps.legal_entity_id            = gfp.legal_entity_id
AND gfp.legal_entity_id            = god.legal_entity_id
AND trn.organization_id            = god.organization_id
AND trn.transaction_date          >= gps.start_date
AND trn.transaction_date          <= gps.end_date
ORDER BY trn.trx_source_line_id,
  trn.transaction_id;
prompt mtl_transactions_interface (mti)
prompt
SELECT
  /*MOAC_SQL_NO_CHANGES*/
  TO_CHAR(LIN.line_number)
  || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.shipment_number))
  || DECODE(LIN.option_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.option_number))
  || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
  || ‘.’
  ||TO_CHAR(LIN.component_number))
  || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
  || DECODE(LIN.option_number, NULL, ‘.’, NULL )
  || ‘.’
  || TO_CHAR(LIN.service_number)) LINE,
  lin.line_id line_id,
  det.delivery_detail_id del_detail_id,
  itm.segment1 item,
  tmp.primary_quantity prm_q,
  secondary_transaction_quantity sec_q,
  tmp.subinventory_code from_sub,
  tmp.locator_id from_loc_id,
  tmp.process_flag process,
  tmp.lock_flag lck,
  tmp.transaction_mode trans_mode,
  tmp.error_code error_code,
  tmp.error_explanation error_expl
FROM mtl_transactions_interface tmp,
  wsh_delivery_details det,
  oe_order_lines_all lin,
  mtl_system_items_b itm
WHERE tmp.source_line_id   = lin.line_id
AND lin.line_category_code = ‘order’
AND lin.ship_from_org_id   = itm.organization_id(+)
AND lin.inventory_item_id  = itm.inventory_item_id(+)
AND det.source_line_id     = lin.line_id
AND lin.header_id          =
  &hid
AND DECODE(‘&lineid’,’all’,’%’,’&lineid’) IN (‘%’,lin.line_id, lin.top_model_line_id, lin.ato_line_id, lin.link_to_line_id, lin.reference_line_id, lin.service_reference_line_id)
UNION ALL
SELECT TO_CHAR(LIN.line_number)
  || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.shipment_number))
  || DECODE(LIN.option_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.option_number))
  || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
  || ‘.’
  ||TO_CHAR(LIN.component_number))
  || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
  || DECODE(LIN.option_number, NULL, ‘.’, NULL )
  || ‘.’
  || TO_CHAR(LIN.service_number)) LINE,
  lin.line_id line_id,
  det.delivery_detail_id del_detail_id,
  itm.segment1 item,
  tmp.primary_quantity prm_q,
  tmp.secondary_transaction_quantity sec_q,
  tmp.subinventory_code from_sub,
  tmp.locator_id from_loc_id,
  tmp.process_flag process,
  tmp.lock_flag lck,
  tmp.transaction_mode trans_mode,
  tmp.error_code error_code,
  tmp.error_explanation error_expl
FROM mtl_transactions_interface tmp,
  wsh_delivery_details det,
  oe_order_lines_all lin,
  mtl_system_items_b itm
WHERE tmp.trx_source_line_id = lin.line_id
AND lin.line_category_code   = ‘return’
AND lin.ship_from_org_id     = itm.organization_id(+)
AND lin.inventory_item_id    = itm.inventory_item_id(+)
AND det.source_line_id       = lin.line_id
AND lin.header_id            =
  &hid
AND DECODE(‘&lineid’,’all’,’%’,’&lineid’)                         IN (‘%’,lin.line_id, lin.top_model_line_id, lin.ato_line_id, lin.link_to_line_id, lin.reference_line_id, lin.service_reference_line_id);

Trip details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid 
==============================================
SELECT wdd.source_header_id,
  wdd.source_line_id,
  assign.delivery_assignment_id,
  assign.delivery_id,
  assign.delivery_detail_id,
  deli.name deli_name,
  deli.status_code deli_status,
  legs.delivery_leg_id,
  legs.pick_up_stop_id,
  — legs.drop_off_stop_id,
  DECODE(stops.pending_interface_flag, NULL, ‘Not Pending’, ‘Y’, ‘Pending’, stops.pending_interface_flag) pif,
  stops.status_code trip_stop_status,
  stops.actual_departure_date,
  trips.name trip_name,
  trips.trip_id,
  trips.status_code trip_status
FROM wsh_delivery_details wdd,
  wsh_delivery_assignments assign,
  wsh_new_deliveries deli,
  wsh_delivery_legs legs,
  wsh_trip_stops stops,
  wsh_trips trips
WHERE wdd.source_header_id =
  &hid
AND wdd.source_line_id LIKE DECODE(‘&lineid’,’all’,’%’,’&lineid’)
AND wdd.delivery_detail_id =assign.delivery_detail_id
AND assign.delivery_id     = deli.delivery_id
AND deli.delivery_id       =legs.delivery_id
AND legs.pick_up_stop_id   = stops.stop_id
AND stops.trip_id          = trips.trip_id
ORDER BY assign.delivery_assignment_id,
  assign.delivery_id,
  assign.delivery_detail_id;
  
Move ORDER details FOR sales ORDER NUMBER: &ord_num AND line_id: &lineid
 ===================================================
SELECT DISTINCT trl.line_id mo_line_id,
  trh.request_number mo_number,
  — trl.header_id mv_hdr_id,
  trl.line_number mv_line_num,
  DECODE(trl.line_status, 1, ‘1=Incomplete’, 2, ‘2=Pend Aprvl’, 3, ‘3=Approved’, 4, ‘4=Not Apprvd’, 5, ‘5=Closed’, 6, ‘6=Canceled’, 7, ‘7=Pre Apprvd’, 8, ‘8=Part Aprvd’) mv_line_stat,
  TO_CHAR(LIN.line_number)
  || DECODE(LIN.shipment_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.shipment_number))
  || DECODE(LIN.option_number, NULL, NULL, ‘.’
  || TO_CHAR(LIN.option_number))
  || DECODE(LIN.component_number, NULL, NULL, DECODE(LIN.option_number, NULL, ‘.’,NULL)
  || ‘.’
  ||TO_CHAR(LIN.component_number))
  || DECODE(LIN.service_number,NULL,NULL, DECODE(LIN.component_number, NULL, ‘.’ , NULL)
  || DECODE(LIN.option_number, NULL, ‘.’, NULL )
  || ‘.’
  || TO_CHAR(LIN.service_number)) LINE,
  trl.txn_source_line_id ord_line_id,
  det.delivery_detail_id ,
  itm.segment1 item,
  trl.quantity qty,
  trl.primary_quantity prm_q,
  trl.quantity_delivered dlv_q,
  trl.quantity_detailed dtl_q,
  trl.secondary_quantity sec_q,
  trl.secondary_quantity_detailed sec_dtl_q,
  trl.secondary_quantity_delivered sec_dlv_q,
  trl.move_order_type_name move_type_name,
  DECODE(trl.transaction_source_type_id,2,’Sales Order’,trl.transaction_source_type_id) trns_src_type,
  trl.transaction_type_name trns_type_name,
  trl.organization_id orgn_id,
  trl.from_subinventory_code from_sub,
  trl.from_locator_id from_loc_id,
  trl.to_subinventory_code to_sub,
  trl.to_locator_id to_loc_id,
  trl.lot_number lot_num,
  trl.transaction_header_id trns_head_id
FROM mtl_txn_request_lines_v trl,
  mtl_txn_request_headers trh,
  wsh_delivery_details det,
  oe_order_lines_all lin,
  mtl_system_items_b itm
WHERE trl.line_id = det.move_order_line_id
  –trl.txn_source_line_id = lin.line_id
AND lin.ship_from_org_id  = itm.organization_id(+)
AND lin.inventory_item_id = itm.inventory_item_id(+)
AND det.source_line_id    = lin.line_id
AND trl.header_id         = trh.header_id
AND lin.header_id         =
  &hid
AND DECODE(‘&lineid’,’all’,’%’,’&lineid’)              IN (‘%’,lin.line_id, lin.top_model_line_id, lin.ato_line_id, lin.link_to_line_id, lin.reference_line_id, lin.service_reference_line_id);

Extract Header details FOR sales ORDER NUMBER: &ord_num 
========================================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt
WHERE geh.transaction_id           = mmt.transaction_id
AND mmt.transaction_source_type_id = 2
AND mmt.trx_source_line_id        IN
  (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
  );
  
Extract Lines FOR sales ORDER NUMBER: &ord_num 
==================================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id                = geh.header_id
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 2
AND mmt.trx_source_line_id        IN
  (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
  );
  
SLA Events FOR sales ORDER NUMBER: &ord_num 
=================================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt ,
  xla.xla_events xe
WHERE xe.event_id                  = geh.event_id
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 2
AND mmt.trx_source_line_id        IN
  (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
  );
  
SLA Headers FOR sales ORDER NUMBER: &ord_num 
==================================
SELECT ah.*
FROM xla.xla_ae_headers ah
WHERE ah.application_id = 555
AND ah.event_id        IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    inv.mtl_material_transactions mmt
  WHERE geh.transaction_id           = mmt.transaction_id
  AND mmt.transaction_source_type_id = 2
  AND mmt.trx_source_line_id        IN
    (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
    )
  );

SLA Lines FOR sales ORDER NUMBER: &ord_num 
================================
SELECT al.*
FROM xla.xla_ae_headers ah ,
  xla.xla_ae_lines al
WHERE al.ae_header_id = ah.ae_header_id
AND ah.application_id = 555
AND ah.event_id      IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    inv.mtl_material_transactions mmt
  WHERE geh.transaction_id           = mmt.transaction_id
  AND mmt.transaction_source_type_id = 2
  AND mmt.trx_source_line_id        IN
    (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
    )
  );
  
SLA Distributions FOR sales ORDER NUMBER: &ord_num 
=====================================
SELECT dl.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt,
  xla.xla_distribution_links dl
WHERE dl.event_id                  = geh.event_id
AND dl.application_id              = 555
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 2
AND mmt.trx_source_line_id        IN
  (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
  );
  
Item Cost details 
============
SELECT a.*
FROM gl_item_dtl a
WHERE a.itemcost_id IN
  (SELECT itemcost_id
  FROM gl_item_cst
  WHERE (inventory_item_id, organization_id,cost_type_id, period_id) IN
    (SELECT DISTINCT mmt.inventory_item_id,
      mmt.organization_id,
      gps.cost_type_id,
      gps.period_id
    FROM gmf_organization_definitions god,
      gmf_period_statuses gps,
      gmf_fiscal_policies gfp,
      cm_mthd_mst mthd,
      mtl_material_transactions mmt
    WHERE mmt.transaction_source_type_id = 2
    AND god.organization_id              = mmt.organization_id
    AND gfp.legal_entity_id              = god.legal_entity_id
    AND mthd.cost_type_id                = gfp.cost_type_id
    AND gps.legal_entity_id              = gfp.legal_entity_id
    AND gps.cost_type_id                 = gfp.cost_type_id
    AND mmt.transaction_date            >= gps.start_date
    AND mmt.transaction_date            <= gps.end_date
    AND mmt.trx_source_line_id          IN
      (SELECT DISTINCT line_id FROM oe_order_lines_all WHERE header_id = &hid
      )
    )
  );
  
COGS RELATED:
Run Following Queries BY entering related SO# numbers AND RMA# Numbers FOR which COGS/DCOGS being analized **/ 
OE Headers 
==========
SELECT * FROM oe_order_headers_all WHERE order_number IN ( ‘&so_number’);

OE lines 
=====
SELECT oeh.order_number,
  oeh.header_id,
  oeh.order_type_id,
  oel.*
FROM oe_order_headers_all oeh,
  oe_order_lines_all oel
WHERE oel.header_id   = oeh.header_id
AND oeh.order_number IN ( ‘&so_number’);

MMT rows              
=======
SELECT oeh.order_number,
  oeh.header_id oe_header_id,
  oeh.order_type_id,
  mmt.*
FROM oe_order_headers_all oeh,
  oe_order_lines_all oel,
  mtl_material_transactions mmt
WHERE mmt.trx_source_line_id        = oel.line_id
AND oel.header_id                   = oeh.header_id
AND mmt.transaction_source_type_id IN (2, 12)
AND oeh.order_number               IN ( ‘&so_number’);

COGS events                         
===========
SELECT *
FROM cst_cogs_events
WHERE cogs_om_line_id IN
  (SELECT oel.line_id
  FROM oe_order_headers_all oeh,
    oe_order_lines_all oel
  WHERE oel.header_id   = oeh.header_id
  AND oeh.order_number IN ( ‘&so_number’)
  ) ;

Extract Headers 
===========
SELECT oeh.order_number,
  oeh.header_id oe_header_id,
  oeh.order_type_id,
  geh.*
FROM oe_order_headers_all oeh,
  oe_order_lines_all oel,
  mtl_material_transactions mmt,
  gmf_xla_extract_headers geh
WHERE mmt.transaction_id            = geh.transaction_id
AND mmt.trx_source_line_id          = oel.line_id
AND oel.header_id                   = oeh.header_id
AND mmt.transaction_source_type_id IN (2, 12)
AND oeh.order_number               IN ( ‘&so_number’);

Extract Lines                       
=========
SELECT oeh.order_number,
  oeh.header_id oe_header_id,
  oeh.order_type_id,
  gel.*
FROM oe_order_headers_all oeh,
  oe_order_lines_all oel,
  mtl_material_transactions mmt,
  gmf_xla_extract_headers geh,
  gmf_xla_extract_lines gel
WHERE gel.header_id                      = geh.header_id
AND geh.transaction_id                   = mmt.transaction_id
AND mmt.trx_source_line_id               = oel.line_id
AND oel.header_id                        = oeh.header_id
AND mmt.transaction_source_type_id      IN (2, 12)
AND oeh.order_number                    IN ( ‘&so_number’);

INVENTORY RELATED: 
Material transactions 
==============
SELECT *
FROM mtl_material_transactions
WHERE organization_id =
  &&orgid
AND inventory_item_id =
  &&invitemid
AND transaction_id =
  &&transid;
  
Lot NUMBER transactions 
=================
SELECT *
FROM mtl_transaction_lot_numbers
WHERE organization_id =
  &&orgid
AND inventory_item_id =
  &&invitemid
AND transaction_id =
  &&transid;
  
MTL Parameter organization details Organization id: &&orgid 
==========================================
SELECT * FROM mtl_parameters WHERE organization_id = &&orgid;

Item details FOR Organization id: &&orgid AND item id: &&invitemid 
==============================================
SELECT *
FROM mtl_system_items_kfv
WHERE organization_id =
  &&orgid
AND inventory_item_id =
  &&invitemid;
  
Extract Header details FOR Transaction id: &&transid 
====================================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh
WHERE geh.entity_code   = ‘INVENTORY’
AND geh.transaction_id IN
  (SELECT t.transaction_id
  FROM mtl_material_transactions t
  WHERE t.transaction_id =
    &&transid
  );
  
Extract Lines details FOR Transaction id: &&transid 
===================================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_xla_extract_lines gel
WHERE geh.entity_code   = ‘INVENTORY’
AND gel.header_id       = geh.header_id
AND geh.transaction_id IN
  (SELECT t.transaction_id
  FROM mtl_material_transactions t
  WHERE t.transaction_id =
    &&transid
  );
  
Sla Events FOR Transaction id: &&transid 
============================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  xla.xla_events xe
WHERE geh.entity_code   = ‘INVENTORY’
AND xe.event_id         = geh.event_id
AND geh.transaction_id IN
  (SELECT t.transaction_id
  FROM mtl_material_transactions t
  WHERE t.transaction_id =
    &&transid
  );
  
Item Component Cost details FOR Transaction id: &&transid 
==========================================
SELECT a.*
FROM gl_item_dtl a
WHERE a.itemcost_id IN
  (SELECT itemcost_id
  FROM gl_item_cst
  WHERE (inventory_item_id, organization_id,cost_type_id, period_id) IN
    (SELECT DISTINCT mmt.inventory_item_id,
      mmt.organization_id,
      gps.cost_type_id,
      gps.period_id
    FROM gmf_organization_definitions god,
      gmf_period_statuses gps,
      gmf_fiscal_policies gfp,
      cm_mthd_mst mthd,
      mtl_material_transactions mmt
    WHERE god.organization_id = mmt.organization_id
    AND mmt.transaction_id    =
      &&transid
    AND mmt.organization_id =
      &&orgid
    AND mmt.inventory_item_id =
      &&invitemid
    AND gfp.legal_entity_id   = god.legal_entity_id
    AND mthd.cost_type_id     = gfp.cost_type_id
    AND gps.legal_entity_id   = gfp.legal_entity_id
    AND gps.cost_type_id      = gfp.cost_type_id
    AND mmt.transaction_date >= gps.start_date
    AND mmt.transaction_date <= gps.end_date
    )
  );
  
PURCHASING RELATED: 
PO Header details FOR purchase ORDER id: &&poheaderid 
=======================================
SELECT * FROM po.po_headers_all WHERE po_header_id = &poheaderid;

PO Line details FOR purchase ORDER id: &&poheaderid 
=====================================
SELECT * FROM po_lines_all WHERE po_header_id = &poheaderid;

PO Line location details FOR purchase ORDER id: &&poheaderid 
===========================================
SELECT * FROM po_line_locations WHERE po_header_id = &poheaderid;

PO distribution details FOR purchase ORDER id: &&poheaderid 
==========================================
SELECT * FROM po_distributions WHERE po_header_id = &poheaderid;

RCV Transactions FOR purchase ORDER id: &&poheaderid 
=======================================
SELECT * FROM po.rcv_transactions WHERE po_header_id = &&poheaderid;

RCV accounting txns FOR purchase ORDER id: &&poheaderid 
=========================================
SELECT * FROM gmf.gmf_rcv_accounting_txns WHERE po_header_id = &&poheaderid;

MMT txns FOR purchase ORDER id: &&poheaderid 
==================================
SELECT *
FROM inv.mtl_material_transactions
WHERE transaction_source_type_id = 1
AND rcv_transaction_id          IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  );
  
Opm financials data 
===============
Extract Header details FOR purchase ORDER id: &&poheaderid: 
==========================================
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt
WHERE geh.transaction_id           = mmt.transaction_id
AND mmt.transaction_source_type_id = 1
AND mmt.rcv_transaction_id        IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  )
UNION ALL
SELECT geh.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_rcv_accounting_txns mmt
WHERE geh.transaction_id    = mmt.rcv_transaction_id
AND mmt.rcv_transaction_id IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  );
  
Extract Lines details FOR purchase ORDER id: &&poheaderid 
========================================
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt ,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id                = geh.header_id
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 1
AND mmt.rcv_transaction_id        IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  )
UNION ALL
SELECT gel.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_rcv_accounting_txns mmt ,
  gmf.gmf_xla_extract_lines gel
WHERE gel.header_id         = geh.header_id
AND geh.transaction_id      = mmt.rcv_transaction_id
AND mmt.rcv_transaction_id IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  );
  
Sla Events FOR purchase ORDER id: &&poheaderid 
=================================
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt ,
  xla.xla_events xe
WHERE xe.event_id                  = geh.event_id
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 1
AND mmt.rcv_transaction_id        IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  )
UNION ALL
SELECT xe.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_rcv_accounting_txns mmt,
  xla.xla_events xe
WHERE xe.event_id           = geh.event_id
AND geh.transaction_id      = mmt.rcv_transaction_id
AND mmt.rcv_transaction_id IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  );
  
Sla Header details FOR purchase ORDER id: &&poheaderid 
======================================
SELECT ah.*
FROM xla.xla_ae_headers ah
WHERE ah.application_id = 555
AND ah.event_id        IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    inv.mtl_material_transactions mmt
  WHERE geh.transaction_id           = mmt.transaction_id
  AND mmt.transaction_source_type_id = 1
  AND mmt.rcv_transaction_id        IN
    (SELECT transaction_id
    FROM po.rcv_transactions
    WHERE po_header_id =
      &&poheaderid
    )
  )
UNION ALL
SELECT ah.*
FROM xla.xla_ae_headers ah
WHERE ah.application_id = 555
AND ah.event_id        IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    gmf.gmf_rcv_accounting_txns mmt
  WHERE geh.transaction_id    = mmt.rcv_transaction_id
  AND mmt.rcv_transaction_id IN
    (SELECT transaction_id
    FROM po.rcv_transactions
    WHERE po_header_id =
      &&poheaderid
    )
  );
  
Sla Lines details FOR purchase ORDER id: &&poheaderid 
======================================
SELECT al.*
FROM xla.xla_ae_headers ah ,
  xla.xla_ae_lines al
WHERE al.ae_header_id = ah.ae_header_id
AND ah.application_id = 555
AND ah.event_id      IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    inv.mtl_material_transactions mmt
  WHERE geh.transaction_id           = mmt.transaction_id
  AND mmt.transaction_source_type_id = 1
  AND mmt.rcv_transaction_id        IN
    (SELECT transaction_id
    FROM po.rcv_transactions
    WHERE po_header_id =
      &&poheaderid
    )
  )
UNION ALL
SELECT al.*
FROM xla.xla_ae_headers ah ,
  xla.xla_ae_lines al
WHERE al.ae_header_id = ah.ae_header_id
AND ah.application_id = 555
AND ah.event_id      IN
  (SELECT geh.event_id
  FROM gmf.gmf_xla_extract_headers geh,
    gmf.gmf_rcv_accounting_txns mmt
  WHERE geh.transaction_id    = mmt.rcv_transaction_id
  AND mmt.rcv_transaction_id IN
    (SELECT transaction_id
    FROM po.rcv_transactions
    WHERE po_header_id =
      &&poheaderid
    )
  );
  
Sla Distributions FOR purchase ORDER id: &&poheaderid 
======================================
SELECT dl.*
FROM gmf.gmf_xla_extract_headers geh,
  inv.mtl_material_transactions mmt ,
  xla.xla_distribution_links dl
WHERE dl.event_id                  = geh.event_id
AND dl.application_id              = 555
AND geh.transaction_id             = mmt.transaction_id
AND mmt.transaction_source_type_id = 1
AND mmt.rcv_transaction_id        IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  )
UNION ALL
SELECT dl.*
FROM gmf.gmf_xla_extract_headers geh,
  gmf.gmf_rcv_accounting_txns mmt ,
  xla.xla_distribution_links dl
WHERE dl.event_id           = geh.event_id
AND dl.application_id       = 555
AND geh.transaction_id      = mmt.rcv_transaction_id
AND mmt.rcv_transaction_id IN
  (SELECT transaction_id
  FROM po.rcv_transactions
  WHERE po_header_id =
    &&poheaderid
  );
  
Item Cost details 
============
SELECT a.*
FROM gl_item_dtl a
WHERE a.itemcost_id IN
  (SELECT itemcost_id
  FROM gl_item_cst
  WHERE (inventory_item_id, organization_id,cost_type_id, period_id) IN
    (SELECT DISTINCT mmt.inventory_item_id,
      mmt.organization_id,
      gps.cost_type_id,
      gps.period_id
    FROM gmf_organization_definitions god,
      gmf_period_statuses gps,
      gmf_fiscal_policies gfp,
      cm_mthd_mst mthd,
      mtl_material_transactions mmt,
      rcv_transactions rct
    WHERE mmt.transaction_source_type_id = 1
    AND god.organization_id              = mmt.organization_id
    AND mmt.rcv_transaction_id           = rct.transaction_id
    AND rct.po_header_id                 =
      &&poheaderid
    AND gfp.legal_entity_id   = god.legal_entity_id
    AND mthd.cost_type_id     = gfp.cost_type_id
    AND gps.legal_entity_id   = gfp.legal_entity_id
    AND gps.cost_type_id      = gfp.cost_type_id
    AND mmt.transaction_date >= gps.start_date
    AND mmt.transaction_date <= gps.end_date
    )
  );
  

PRODUCTION MANAGEMENT: 
Batch Header details FOR Batch id: &&batch_id 
================================
SELECT * FROM gme_batch_header WHERE batch_id=’&&batch_id’;

Recipe details FOR Batch id: &&batch_id 
============================
SELECT r.*
FROM gme_batch_header b ,
  gmd_recipes r ,
  gmd_recipe_validity_rules vr
WHERE b.batch_id=
  &&batch_id
AND b.recipe_validity_rule_id                          =vr.recipe_validity_rule_id
AND vr.recipe_id                                       =r.recipe_id;

Recipe Validity Rules details FOR Batch id: &&batch_id 
======================================
SELECT vr.*
FROM gme_batch_header b ,
  gmd_recipes r ,
  gmd_recipe_validity_rules vr
WHERE b.batch_id=
  &&batch_id
AND b.recipe_validity_rule_id                   =vr.recipe_validity_rule_id
AND vr.recipe_id                                =r.recipe_id;

Batch Material Details FOR Batch id: &&batch_id 
=================================
SELECT d.* FROM gme_material_details d WHERE d.batch_id = &&batch_id;

Inventory Transactions details FOR Batch id: &&batch_id 
=======================================
SELECT t.*
FROM mtl_material_transactions t
WHERE t.transaction_source_id =
  &&batch_id
AND t.transaction_source_type_id                              = 5;

Batch Material Transaction Pairs FOR Batch NUMBER: &&batch_id 
=============================================
SELECT * FROM gme_transaction_pairs p WHERE p.batch_id = &&batch_id;

Batch RESOURCE Transactions details FOR Batch NUMBER: &&batch_id 
===============================================
SELECT t.*
FROM gme_batch_header h,
  gme_resource_txns t
WHERE h.batch_id =
  &&batch_id
AND h.batch_id                        = t.doc_id
AND t.doc_type                        = ‘PROD’;

Yield Layers FOR Batch id: &&batch_id 
===========================
SELECT *
FROM gmf_incoming_material_layers il
WHERE (il.mmt_organization_id, il.mmt_transaction_id) IN
  (SELECT DISTINCT t.organization_id,
    t.transaction_id
  FROM mtl_material_transactions t
  WHERE t.transaction_source_id =
    &&batch_id
  AND t.transaction_source_type_id = 5
  );
  
Material Consumption Layers FOR Batch id: &&batch_id 
=======================================
SELECT *
FROM gmf_outgoing_material_layers ol
WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN
  (SELECT DISTINCT t.organization_id,
    t.transaction_id
  FROM mtl_material_transactions t
  WHERE t.transaction_source_id =
    &&batch_id
  AND t.transaction_source_type_id = 5
  );
  
RESOURCE Consumption Layers FOR Batch id: &&batch_id 
========================================
SELECT *
FROM gmf_resource_layers il
WHERE il.poc_trans_id IN
  (SELECT t.poc_trans_id
  FROM gme_resource_txns t
  WHERE t.doc_id =
    &&batch_id
  AND t.doc_type = ‘PROD’
  );
  
VIB Details FOR Batch id: &&batch_id 
==========================
SELECT *
FROM gmf_batch_vib_details bvd
WHERE bvd.requirement_id IN
  (SELECT br.requirement_id
  FROM gmf_batch_requirements br
  WHERE br.batch_id =
    &&batch_id
  );
  
Batch Requirement Details FOR Batch id: &&batch_id 
=====================================
SELECT * FROM gmf_batch_requirements br WHERE br.batch_id = &&batch_id;

Layer cost details FOR Batch id: &&batch_id 
==============================
SELECT *
FROM gmf_layer_cost_details c
WHERE c.layer_id IN
  (SELECT il.layer_id
  FROM gme_batch_header h,
    mtl_material_transactions t,
    gmf_incoming_material_layers il
  WHERE h.batch_id =
    &&batch_id
  AND h.batch_id                   = t.transaction_source_id
  AND t.transaction_source_type_id = 5
  AND il.mmt_transaction_id        = t.transaction_id
  AND il.mmt_organization_id       = t.organization_id
  );
  
Extract Header details FOR Batch id: &&batch_id 
=================================
SELECT *
FROM gmf_xla_extract_headers
WHERE entity_code      = ‘PRODUCTION’
AND source_document_id =
  &l_batch_id;
  
Extract Lines details FOR Batch id: &&batch_id 
=================================
SELECT *
FROM gmf_xla_extract_lines
WHERE header_id IN
  (SELECT header_id
  FROM gmf_xla_extract_headers
  WHERE entity_code      = ‘PRODUCTION’
  AND source_document_id =
    &l_batch_id
  );
  
Sla Events FOR Batch id: &&batch_id 
==========================
SELECT xe.*
FROM gmf_xla_extract_headers eh,
  xla_events xe
WHERE eh.event_id         = xe.event_id
AND xe.application_id     =555
AND eh.entity_code        = ‘PRODUCTION’
AND eh.source_document_id =
  &l_batch_id;
  
Item Component Cost details FOR Batch id: &&batch_id 
=======================================
SELECT a.*
FROM gl_item_dtl a
WHERE a.itemcost_id IN
  (SELECT itemcost_id
  FROM gl_item_cst
  WHERE (inventory_item_id, organization_id,cost_type_id, period_id) IN
    (SELECT DISTINCT mmt.inventory_item_id,
      mmt.organization_id,
      gps.cost_type_id,
      gps.period_id
    FROM gmf_organization_definitions god,
      gmf_period_statuses gps,
      gmf_fiscal_policies gfp,
      cm_mthd_mst mthd,
      mtl_material_transactions mmt
    WHERE mmt.transaction_source_type_id = 5
    AND god.organization_id              = mmt.organization_id
    AND mmt.transaction_source_id        =
      &&batch_id
    AND gfp.legal_entity_id   = god.legal_entity_id
    AND mthd.cost_type_id     = gfp.cost_type_id
    AND gps.legal_entity_id   = gfp.legal_entity_id
    AND gps.cost_type_id      = gfp.cost_type_id
    AND mmt.transaction_date >= gps.start_date
    AND mmt.transaction_date <= gps.end_date
    )
  );