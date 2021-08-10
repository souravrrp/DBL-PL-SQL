/* Formatted on 1/12/2020 11:08:00 AM (QP5 v5.287) */
  SELECT msib.segment1 item_code,
         msib.description item_desc,
         msib.primary_unit_of_measure uom,
         cal.calendar_code,
         xop.period_code cost_period,
         cmm.cost_mthd_code cost_type,
         ccmv.cost_cmpntcls_code cost_component_class,
         ccd.cost_analysis_code analysis_code,
         SUM (cmpnt_cost) unit_cost
    FROM apps.cm_cmpt_dtl ccd,
         apps.mtl_system_items_b msib,
         apps.mtl_parameters mp,
         apps.cm_mthd_mst cmm,
         apps.gmf_period_statuses xop,
         apps.cm_cldr_dtl cal,
         apps.cm_cmpt_mst_vl ccmv,
         apps.mtl_item_categories_v mic,
         apps.mtl_category_sets_v mcs
   WHERE     1 = 1
         AND msib.inventory_item_id = ccd.inventory_item_id
         AND msib.inventory_item_id = mic.inventory_item_id
         AND msib.organization_id = mic.organization_id
         AND mcs.category_set_id = mic.category_set_id
         --AND mic.segment1           IN ('RM','PKG')
         AND ccmv.cost_cmpntcls_id = ccd.cost_cmpntcls_id
         AND cal.period_code = xop.period_code
         AND msib.organization_id = ccd.organization_id
         AND cmm.cost_type_id = ccd.cost_type_id
         AND mp.organization_id = ccd.organization_id
         AND cmm.cost_mthd_code = 'DBL_PMAC'
         --AND mp.organization_code    =:P_ORG_CODE
         AND ccd.period_id = xop.period_id
         AND ccd.delete_mark = 0
         --AND xop.period_code = TO_CHAR (TO_DATE ( :P_PERIOD, 'MON-YY'), 'MMYY')
GROUP BY msib.segment1,
         msib.description,
         msib.primary_unit_of_measure,
         ccd.cost_analysis_code,
         cmm.cost_mthd_code,
         xop.period_code,
         cal.calendar_code,
         ccmv.cost_cmpntcls_code
ORDER BY msib.segment1;