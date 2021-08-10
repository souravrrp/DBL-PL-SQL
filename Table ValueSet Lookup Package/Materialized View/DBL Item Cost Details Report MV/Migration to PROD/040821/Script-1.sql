CREATE OR REPLACE FORCE VIEW APPS.XXDBL_INV_ITEM_CST_RPT_MV#
(
   ITEM_CODE,
   DESCRIPTION,
   PRIMARY_UOM_CODE,
   ITEM_TYPE,
   ARTICLE,
   COLOR_GROUP,
   BRAND,
   ORGANIZATION_ID,
   ORGANIZATION_CODE,
   LEGAL_ENTITY_ID,
   PERIOD_ID,
   CMPNT_GROUP,
   PERIOD_DESC,
   COST_CMPNTCLS_DESC,
   ITEM_COST
)
AS
   SELECT msi.concatenated_segments AS item_code,
         msi.description,
         msi.primary_uom_code,
         mic.segment1 AS item_type,
         mic.segment2 AS article,
         mic.segment3 AS color_group,
         mic.segment4 AS brand,
         odd.organization_id,
         odd.organization_code,
         clm.legal_entity_id,
         clm.period_id,
         cm.cmpnt_group,
         clm.period_desc,
         cm.cost_cmpntcls_desc,
         ROUND (SUM (cd.cmpnt_cost), 2) AS item_cost
    FROM apps.cm_cmpt_mst cm,
         apps.cm_cmpt_dtl cd,
         apps.mtl_system_items_kfv msi,
         apps.cm_cldr_mst_v clm,
         apps.mtl_item_categories_v mic,
         apps.org_organization_definitions odd
   WHERE     cd.period_id = clm.period_id
         AND cm.cost_cmpntcls_id = cd.cost_cmpntcls_id
         AND cd.organization_id = odd.organization_id
         AND cd.inventory_item_id = msi.inventory_item_id
         AND cd.organization_id = msi.organization_id
         AND msi.organization_id = mic.organization_id
         AND msi.inventory_item_id = mic.inventory_item_id
         AND mic.category_set_id = 1100000062
         AND odd.organization_id IN (150)
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
         cm.cmpnt_group,
         clm.period_desc,
         cm.cost_cmpntcls_desc;