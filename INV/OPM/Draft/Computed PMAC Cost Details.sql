/* Formatted on 1/12/2020 10:36:05 AM (QP5 v5.287) */
  SELECT msi.segment1 ITEM_CODE,
         msi.description ITEM_DESCRIPTION,
         mp.organization_code ORGANIZATION_CODE,
         TO_CHAR (gps.start_date, 'MON-YY') period,
         'Current ' TYPE,
         ccc.cost_cmpntcls_desc,
         ccc.attribute30 cost_category,
         'Current' doc,
         NVL (AVG (ccdc.total_qty), 0) total_qty,
           NVL (
              (SELECT SUM (primary_quantity)
                 FROM gmf_period_balances gpb
                WHERE     gpb.inventory_item_id = ccdc.inventory_item_id
                      AND gpb.organization_id = ccdc.organization_id
                      AND gpb.acct_period_id =
                             (SELECT oap.acct_period_id
                                FROM org_acct_periods oap
                               WHERE     oap.organization_id =
                                            ccdc.organization_id
                                     AND oap.period_start_date = gps.start_date)),
              0)
         * NVL (SUM (ccdc.cmpnt_cost), 0)
            doc_value,
         NVL (
            (SELECT SUM (primary_quantity)
               FROM gmf_period_balances gpb
              WHERE     gpb.inventory_item_id = ccdc.inventory_item_id
                    AND gpb.organization_id = ccdc.organization_id
                    AND gpb.acct_period_id =
                           (SELECT oap.acct_period_id
                              FROM org_acct_periods oap
                             WHERE     oap.organization_id =
                                          ccdc.organization_id
                                   AND oap.period_start_date = gps.start_date)),
            0)
            doc_qty,
         NVL (SUM (ccdc.cmpnt_cost), 0) component_cost
    FROM cm_cmpt_dtl ccdc,
         cm_cmpt_mst_vl ccc,
         gmf_period_statuses gps,
         mtl_system_items_b msi,
         mtl_parameters mp
   WHERE     1 = 1
         --and gps.legal_entity_id = 23273
         --and gps.calendar_code = 'FY 16-17'
         --and gps.period_code = '0616'
         AND gps.cost_type_id = 1000
         AND GPS.PERIOD_CODE=:P_ACCT_PERIOD
         AND gps.period_id = ccdc.period_id
         --and ccdc.inventory_item_id = :p_inventory_item_id
         --and ccdc.organization_id = :p_organization_id
         AND ccdc.cost_type_id = gps.cost_type_id
         AND ccdc.cost_cmpntcls_id = ccc.cost_cmpntcls_id
         AND msi.organization_id = ccdc.organization_id
         AND msi.inventory_item_id = ccdc.inventory_item_id
         AND mp.organization_id = ccdc.organization_id
         --and msi.item_type like 'FINISH%'
         --and ccdc.cmpnt_cost=:p_cost_component
GROUP BY msi.segment1,
         msi.description,
         mp.organization_code,
         gps.legal_entity_id,
         gps.period_id,
         gps.cost_type_id,
         gps.start_date,
         gps.period_code,
         ccdc.inventory_item_id,
         ccdc.organization_id,
         ccdc.cost_cmpntcls_id,
         ccdc.cost_type_id,
         ccc.cost_cmpntcls_desc,
         ccc.attribute30,
         TO_CHAR (gps.start_date, 'MON-YY')