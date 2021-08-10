/* Formatted on 10/14/2020 5:08:02 PM (QP5 v5.354) */
  SELECT                                                                    --
         --odd.operating_unit,
         msi.concatenated_segments                             item_code,
         msi.description,
         msi.primary_uom_code,
         --      mic.segment2 AS itm_Catg,
         --   mic.segment3 AS itm_Type,
         mic.segment1                                          AS PL,
         mic.segment2                                          AS ART,
         mic.segment3                                          AS CG,
         mic.segment4                                          AS BRAND,
         odd.organization_id,
         odd.organization_code,
         clm.legal_entity_id,
         clm.period_id,
         cm.CMPNT_GROUP,
         DECODE (cm.USAGE_IND,  1, 'Material',  4, 'Aloc')     usage_ind,
         clm.period_desc,
         cm.cost_cmpntcls_desc,
         SUM (cd.cmpnt_cost)                                   AS item_cost --,sum (decode(a.period_id,203,a.cmpnt_cost)) as "mar-12"
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
         AND clm.legal_entity_id = 23277
         AND mic.category_set_id = 1100000062                --1100000061 CCL2
         AND msi.segment1='26S1COT0100S-60094'
         --   AND mic.segment2 ='SEMI FINISH GOODS'
         --  AND msi.concatenated_segments like 'FT%'
         AND odd.organization_id IN (150)
         AND clm.period_desc IN ('JUL-20')
         AND cm.USAGE_IND IN (1, 4)                                -- 'DEC%17'
GROUP BY msi.concatenated_segments,
         msi.description,
         msi.primary_uom_code,
         mic.segment2,
         mic.segment3,
         mic.segment1,
         mic.segment4,
         odd.organization_id,
         odd.organization_code,
         clm.legal_entity_id,
         clm.period_id,
         cm.CMPNT_GROUP,
         cm.USAGE_IND,
         clm.period_desc,
         cm.cost_cmpntcls_desc;


--------------------------------------------------------------------------------

SELECT *
  FROM (  SELECT                                                            --
                 --odd.operating_unit,
                 msi.concatenated_segments
                     item_code,
                 msi.description,
                 msi.primary_uom_code,
                 --      mic.segment2 AS itm_Catg,
                 --   mic.segment3 AS itm_Type,
                 mic.segment1
                     AS PL,
                 mic.segment2
                     AS ART,
                 mic.segment3
                     AS CG,
                 mic.segment4
                     AS BRAND,
                 odd.organization_id,
                 odd.organization_code,
                 clm.legal_entity_id,
                 clm.period_id,
                 --cm.CMPNT_GROUP,
                 DECODE (cm.USAGE_IND,  1, 'Material',  4, 'Aloc')
                     usage_ind,
                 clm.period_desc,
                 --cm.cost_cmpntcls_desc,
                 SUM (cd.cmpnt_cost)
                     AS item_cost --,sum (decode(a.period_id,203,a.cmpnt_cost)) as "mar-12"
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
                 AND clm.legal_entity_id = 23277
                 AND mic.category_set_id = 1100000062        --1100000061 CCL2
                 --   AND mic.segment2 ='SEMI FINISH GOODS'
                 --  AND msi.concatenated_segments like 'FT%'
                 AND msi.segment1='SYNFPOL0100S-95327'
                 AND odd.organization_id IN (150)
                 AND clm.period_desc IN ('JUL-20')
                 AND cm.USAGE_IND IN (1, 4)
        GROUP BY msi.concatenated_segments,
                 msi.description,
                 msi.primary_uom_code,
                 mic.segment2,
                 mic.segment3,
                 mic.segment1,
                 mic.segment4,
                 odd.organization_id,
                 odd.organization_code,
                 clm.legal_entity_id,
                 clm.period_id,
                 cm.CMPNT_GROUP,
                 cm.USAGE_IND,
                 clm.period_desc,
                 cm.cost_cmpntcls_desc)
       PIVOT (SUM (item_cost) AS total_item_cost
             FOR usage_ind
             IN ('Material' AS usage_Material, 'Aloc' AS usage_Aloc))