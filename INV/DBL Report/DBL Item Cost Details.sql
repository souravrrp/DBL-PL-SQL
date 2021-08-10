/* Formatted on 2/11/2021 12:20:34 PM (QP5 v5.354) */
  SELECT                                                                    --
         --odd.operating_unit,
         msi.concatenated_segments          AS item_code,
         msi.description,
         msi.primary_uom_code,
         --     mic.segment2 AS Catg,
         --       mic.segment3 AS itm_Type,
         --mic.segment4 AS BRAND,
         -- '' AS ITEM_CATEGORY,
         mic.segment1                       AS ITEM_TYPE,
         mic.segment2                       AS ARTICLE,
         mic.segment3                       AS COLOR_GROUP,
         mic.segment4                       AS BRAND,
         odd.organization_id,
         odd.organization_code,
         clm.legal_entity_id,
         clm.period_id,
         cm.CMPNT_GROUP,
         clm.period_desc,
         cm.cost_cmpntcls_desc,
         ROUND (SUM (cd.cmpnt_cost), 2)     AS item_cost
    --,sum (decode(a.period_id,203,a.cmpnt_cost))
    FROM apps.CM_CMPT_MST                 cm,
         apps.cm_cmpt_dtl                 cd,
         apps.mtl_system_items_kfv        msi,
         apps.cm_cldr_mst_v               clm,
         apps.mtl_item_categories_v       mic,
         apps.org_organization_definitions odd
   WHERE     cd.period_id = clm.period_id
         AND cm.cost_cmpntcls_id = cd.cost_cmpntcls_id
         AND cd.organization_id = odd.organization_id
         AND cd.inventory_item_id = msi.inventory_item_id
         AND cd.organization_id = msi.organization_id
         AND msi.organization_id = mic.organization_id
         AND msi.inventory_item_id = mic.inventory_item_id
         -- AND mic.segment2 ='SEMI FINISH GOODS'
         -- AND msi.concatenated_segments like 'FT%'
         AND mic.category_set_id = 1100000062 -- CCL2 = 1100000062, Ceramic = 1100000061
         AND odd.organization_id IN (150)
         AND clm.period_desc = :p_Period_Name                       --'DEC%17'
         AND clm.legal_entity_id = :p_Legal_Entity
GROUP BY msi.concatenated_segments,
         msi.description,
         msi.primary_uom_code,
         mic.segment1,
         mic.segment2,
         mic.segment3,
         mic.segment4,
         odd.organization_id,
         odd.organization_code,
         clm.legal_entity_id,
         clm.period_id,
         cm.CMPNT_GROUP,
         clm.period_desc,
         cm.cost_cmpntcls_desc;