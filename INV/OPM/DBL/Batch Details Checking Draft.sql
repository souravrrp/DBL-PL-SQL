	
1)Batch Header details for Batch id &&batch_id	
	
select * from gme_batch_header where batch_no='&&batch_no';	
	
	
2)  Recipe details for Batch id: &&batch_id 	
	
select r.*	
  from gme_batch_header b	
      ,gmd_recipes r	
      ,gmd_recipe_validity_rules vr	
    where b.batch_id=&&batch_id	
      and b.recipe_validity_rule_id=vr.recipe_validity_rule_id	
      and vr.recipe_id=r.recipe_id;	
	
	
3)  Recipe Validity Rules details for Batch id: &&batch_id 	
select vr.*	
  from gme_batch_header b	
      ,gmd_recipes r	
      ,gmd_recipe_validity_rules vr	
    where b.batch_id=&&batch_id	
      and b.recipe_validity_rule_id=vr.recipe_validity_rule_id	
      and vr.recipe_id=r.recipe_id;	
	
4)  Batch Material Details for Batch id: &&batch_id 	
SELECT d.*	
FROM  gme_material_details d	
WHERE d.batch_id=&&batch_id;	
	
5)  Inventory Transactions details for Batch id: &&batch_id 	
SELECT t.*	
FROM   mtl_material_transactions t	
WHERE t.transaction_source_id = &&batch_id	
AND   t.transaction_source_type_id = 5;	

6) Lot Inventory Transactions details for Batch id: &&batch_id 	
SELECT mtln.*	
FROM   mtl_transaction_lot_numbers mtln
where mtln.transaction_id in (select t.transaction_id from mtl_material_transactions t	
WHERE t.transaction_source_id = &&batch_id	
AND   t.transaction_source_type_id = 5)

6.1) Resource transactions
select * from gme_resource_txns where doc_id in 
(select batch_id from gme_batch_header where batch_no='&&batch_no');

	
7)  Batch Material Transaction Pairs for Batch Number: &&batch_id 	
SELECT  * 	
FROM gme_transaction_pairs p	
WHERE p.batch_id = &&batch_id;	
   	
	
8)  Yield Layers for Batch id: &&batch_id 	
SELECT *	
FROM gmf_incoming_material_layers il	
WHERE (il.mmt_organization_id, il.mmt_transaction_id) IN 	
	(SELECT DISTINCT t.organization_id, t.transaction_id
	 FROM mtl_material_transactions t
	 WHERE t.transaction_source_id = &&batch_id
	 AND   t.transaction_source_type_id = 5);
	
	
9)  Material Consumption Layers for Batch id: &&batch_id 	
SELECT *	
FROM gmf_outgoing_material_layers ol	
WHERE (ol.mmt_organization_id, ol.mmt_transaction_id) IN 	
	(SELECT DISTINCT t.organization_id, t.transaction_id
	 FROM mtl_material_transactions t
	 WHERE t.transaction_source_id = &&batch_id
	 AND   t.transaction_source_type_id = 5);
	
10)  Resource Consumption Layers for Batch id: &&batch_id 	
SELECT *	
FROM gmf_resource_layers il	
WHERE il.poc_trans_id IN 	
	(SELECT t.poc_trans_id 
	FROM gme_resource_txns t
	WHERE t.doc_id = &&batch_id
	AND   t.doc_type = 'PROD');
	
	
	
11)  VIB Details for Batch id: &&batch_id  	
SELECT *	
FROM gmf_batch_vib_details bvd	
WHERE bvd.requirement_id IN	
	(SELECT br.requirement_id
	FROM gmf_batch_requirements br
	WHERE br.batch_id = &&batch_id);
	
	
	
12)  Batch Requirement Details for Batch id: &&batch_id  	
SELECT *	
FROM gmf_batch_requirements br	
WHERE br.batch_id = &&batch_id; 	
	
	
	
	
13)  Layer cost details for Batch id: &&batch_id  	
SELECT *	
FROM gmf_layer_cost_details c	
WHERE	
	 c.layer_id IN 
	(SELECT il.layer_id
	FROM gme_batch_header h, mtl_material_transactions t, gmf_incoming_material_layers il
	WHERE h.batch_id = &&batch_id
	AND    h.batch_id = t.transaction_source_id
	AND    t.transaction_source_type_id = 5
	AND    il.mmt_transaction_id         =   t.transaction_id
        AND    il.mmt_organization_id       =    t.organization_id	
	);
	
	
	
	
14)  Extract Header details for Batch id: &&batch_id 	
select geh.* 	
from gmf.gmf_xla_extract_headers geh	
where geh.entity_code='PRODUCTION'	
and geh.source_document_id = &&batch_id
	 
	
	
	
	
15)  Extract Lines details for Batch id: &&batch_id 	
select gel.* 	
from gmf.gmf_xla_extract_headers geh, gmf.gmf_xla_extract_lines gel 	
where geh.entity_code='PRODUCTION'	
and  gel.header_id = geh.header_id	
and   geh.source_document_id = &&batch_id
	
	
	
	
16)  Sla Events for Batch id: &&batch_id 	
select xe.* 	
from gmf.gmf_xla_extract_headers geh, xla.xla_events xe	
where geh.entity_code='PRODUCTION'	
and  xe.event_id = geh.event_id 	
and geh.source_document_id = &&batch_id

17) XLA_AE_HEADERS for batch id: &&batch_id 	

select xe.* 	
from gmf.gmf_xla_extract_headers geh, xla.xla_ae_headers xe	
where geh.entity_code='PRODUCTION'	
and  xe.event_id = geh.event_id 	
and geh.source_document_id = &&batch_id
	
18) XLA_AE_LINES for batch id: &&batch_id 

select xel.* 	
from gmf.gmf_xla_extract_headers geh, xla.xla_ae_headers xe, xla.xla_ae_lines xel	
where geh.entity_code='PRODUCTION'	
and  xe.event_id = geh.event_id 
and xe.ae_header_id = xel.ae_header_id	
and geh.source_document_id = &&batch_id	

19)  Item details for Batch id: &&batch_id 	
select a.*	
    from gl_item_cst a	
    where (inventory_item_id, organization_id,cost_type_id, period_id)	
    IN (select distinct mmt.inventory_item_id, mmt.organization_id,gps.cost_type_id,gps.period_id 	
        from apps.gmf_organization_definitions god,	
             gmf_period_statuses gps,	
             gmf_fiscal_policies gfp,	
             cm_mthd_mst mthd,	
             mtl_material_transactions mmt	
        WHERE mmt.transaction_source_type_id = 5	
              AND god.organization_id      =   mmt.organization_id	
              AND mmt.transaction_source_id =      &&batch_id	
              AND gfp.legal_entity_id    =         god.legal_entity_id	
              AND mthd.cost_type_id       =        gfp.cost_type_id	
              AND gps.legal_entity_id      =       gfp.legal_entity_id	
              AND gps.cost_type_id          =      gfp.cost_type_id	
              AND mmt.transaction_date           > gps.start_date	
              AND mmt.transaction_date           < gps.end_date);	
              

	
	
20)  Item Component Cost details for Batch id: &&batch_id 	
select a.*	
from gl_item_dtl a	
where a.itemcost_id 	
in (select itemcost_id 	
    from gl_item_cst 	
    where (inventory_item_id, organization_id,cost_type_id, period_id)	
    IN (select distinct mmt.inventory_item_id, mmt.organization_id,gps.cost_type_id,gps.period_id 	
        from apps.gmf_organization_definitions god,	
             gmf_period_statuses gps,	
             gmf_fiscal_policies gfp,	
             cm_mthd_mst mthd,	
             mtl_material_transactions mmt	
        WHERE mmt.transaction_source_type_id = 5	
              AND god.organization_id      =   mmt.organization_id	
              AND mmt.transaction_source_id =      &&batch_id	
              AND gfp.legal_entity_id    =         god.legal_entity_id	
              AND mthd.cost_type_id       =        gfp.cost_type_id	
              AND gps.legal_entity_id      =       gfp.legal_entity_id	
              AND gps.cost_type_id          =      gfp.cost_type_id	
              AND mmt.transaction_date           > gps.start_date	
              AND mmt.transaction_date           < gps.end_date));	
              
              
              
21) Material transactins where the Transaction dates are greater than the Yield Transactions dates.
SELECT d.batch_id,
          tran.transaction_id,
          tran.inventory_item_id,
           tran.organization_id,
          f_yield.f_max_yield_DATE,
          tran.transaction_date
   FROM mtl_material_transactions tran,
            gme_material_details d,
           (SELECT
             hdr.batch_id,
             MAX(mmt.transaction_date) f_max_yield_date
        FROM mtl_material_transactions mmt,
            gme_material_details dtl,
            gme_batch_header hdr
        WHERE dtl.batch_id = hdr.batch_id
            AND mmt.trx_source_line_id = dtl.material_detail_id
            AND mmt.transaction_source_type_id = 5
            AND mmt.transaction_action_id IN (1,32,27,31)
            AND hdr.batch_id = mmt.transaction_source_id
            and hdr.batch_id = &p_batch_id
            AND dtl.line_type = 1
       GROUP BY hdr.batch_id) f_yield
WHERE tran.transaction_source_id = f_yield.batch_id
    AND d.batch_id = f_yield.batch_id
    AND tran.trx_source_line_id = d.material_detail_id
    AND tran.transaction_source_type_id = 5
    AND tran.transaction_action_id IN (1,32,27,31)
    AND d.line_type = -1
    AND tran.transaction_date > f_yield.f_max_yield_date; 
              
