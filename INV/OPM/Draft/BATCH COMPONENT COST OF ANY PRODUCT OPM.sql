/* Formatted on 1/12/2020 10:49:37 AM (QP5 v5.287) */
SELECT o.organization_code,
       o.organization_name,
       i.segment1,
       i.description,
       bh.batch_no,
       line_type,
       plan_qty,
       wip_plan_qty,
       original_qty,
       actual_qty,
       c.cost_cmpntcls_id,
       cc.cost_cmpntcls_code,
       c.cost_analysis_code,
       cost_amt amount,
       cd.CMPNT_COST acc_cost,
       p.PERIOD_CODE
  FROM gme_batch_header bh,
       gme_material_details bd,
       mtl_system_items_b i,
       org_organization_definitions o,
       cm_acst_led c,
       cm_cmpt_dtl cd,
       cm_cmpt_mst_b cc,
       GMF_PERIOD_STATUSES P
 WHERE     1 = 1
       --AND o.organization_code = :p_org_code
       AND bh.organization_id = o.organization_id
       AND bh.batch_id = bd.batch_id
       AND bd.inventory_item_id = i.inventory_item_id
       AND bd.organization_id = i.organization_id
       --AND line_type = 1
       AND c.cost_cmpntcls_id = cc.cost_cmpntcls_id
       AND bd.material_detail_id = c.transline_id
       AND bd.inventory_item_id = c.inventory_item_id(+)
       AND bd.organization_id = c.organization_id(+)
       --AND c.period_id(+) = :p_period_id
       --AND i.inventory_item_id = :p_inv_item_id
       AND c.INVENTORY_ITEM_ID = cd.INVENTORY_ITEM_ID
       AND c.ORGANIZATION_ID = cd.ORGANIZATION_ID
       AND c.PERIOD_ID = cd.PERIOD_ID
       AND c.CMPNTCOST_ID = cd.CMPNTCOST_ID
       AND c.PERIOD_ID = p.PERIOD_ID;