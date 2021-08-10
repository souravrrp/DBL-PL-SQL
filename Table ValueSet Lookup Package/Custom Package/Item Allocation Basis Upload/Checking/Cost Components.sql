SELECT c.segment1 item, description, COST_CMPNTCLS_CODE
  FROM CM_CMPT_MTL a, CM_CMPT_MST_VL b, mtl_system_items_kfv c
 WHERE     A.MTL_CMPNTCLS_ID = B.COST_CMPNTCLS_ID
       AND a.inventory_item_id = c.inventory_item_id
       AND a.organization_id = c.organization_id
       AND c.organization_id = 152
--and USAGE_IND=1
--and MTL_ANALYSIS_CODE='DIR'