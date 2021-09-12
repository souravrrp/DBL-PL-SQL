/* Formatted on 8/12/2021 11:28:33 AM (QP5 v5.354) */
SELECT ic.item_code,
       ic.description,
       ic.primary_uom_code,
       ic.item_type,
       ic.article,
       ic.color_group,
       ic.brand,
       ic.organization_id,
       ic.organization_code,
       odd.organization_name,
       ic.legal_entity_id,
       ic.period_id,
       ic.cmpnt_group,
       ic.period_desc,
       ic.cost_cmpntcls_desc,
       ic.item_cost
  FROM apps.xxdbl_inv_item_cst_rpt_mv ic, org_organization_definitions odd
 WHERE     1 = 1
       AND ic.organization_id = odd.organization_id
       AND ic.period_desc = :p_period_name
       AND ic.legal_entity_id = 23277