SELECT
*
FROM
WORK_MATERIAL_REQE_V
where 1=1
--and ORGANIZATION_ID is not null
and SUB_WORK_DESCRIPTION_ID=:sub_work_id
--order by CREATION_DATE desc

XXCPM_WORK_MAT_REQE_PKG


select
*
from WORK_MATERIAL_REQE pbl 
where 1=1
--and ORGANIZATION_ID is not null
and SUB_WORK_DESCRIPTION_ID=:sub_work_id

SELECT
*
FROM
PROJECT_WISE_MATERIAL_QNT

XXCPM_PROJECT_MATERIAL_UPLOAD



SELECT 138,
             P.PROJECT_ID,
             BUILDING_ID,
             BUILDING_LEVEL_ID,
             APPARTMENT_ID,
             UNIT_LOCATION_ID,
             REVISION_NUM,
             PWQ.NATURE_OF_JOB_ID,
             PWQ.WORK_DESCRIPTION_ID,
             PWQ.SUB_WORK_DESCRIPTION_ID,
             PROJECT_WORK_QTY_ID,                              --SUB_WORK_QTY,
             -- M_SUB_WORK_DESCRIPTION ,
             WMR.INVENTORY_ITEM_ID,
             WMR.UNIT_OF_MEASURE MATERIAL_OUM,
             MTL_ORIGIN_LOOKUP_CODE,
             MTL_BRAND_LOOKUP_CODE,
             (REQUIRED_QUANTITY) * SUB_WORK_QTY REQ_QUNATITY,
             mp.UNIT_PRICE,
             SYSDATE,
             PWQ.CREATED_BY,
             SYSDATE,
             PWQ.LAST_UPDATED_BY,
             PWQ.LAST_UPDATE_LOGIN
        FROM PROJECT_WISE_WORK_QNT PWQ,
             (SELECT WR.NATURE_OF_JOB_ID,
                     WR.WORK_DESCRIPTION_ID,
                     WR.SUB_WORK_DESCRIPTION_ID,
                     WR.ORGANIZATION_ID,
                     WR.INVENTORY_ITEM_ID,
                     WR.MTL_SPECIFICATION,
                     WR.UNIT_OF_MEASURE,
                     WR.MTL_ORIGIN_LOOKUP_CODE,
                     WR.MTL_BRAND_LOOKUP_CODE,
                     (NVL (WR.REQUIRED_QUANTITY, 0) / NVL (EST_WORK_QTY, 1))
                        REQUIRED_QUANTITY,
                     MATERIAL_SEPCIFICATION_ID
                FROM WORK_MATERIAL_REQE wr, SUB_WORK_DESCRIPTION SW
               WHERE SW.SUB_WORK_DESCRIPTION_ID = WR.SUB_WORK_DESCRIPTION_ID)
             WMR,
             ALL_PROJECT_INFO_MASTER P,
             (  SELECT spec_id, MAX (unit_price) unit_price
                  FROM XX_MATERIAL_EST_PRICE
                 WHERE active_to IS NULL
              GROUP BY spec_id) MP
       WHERE     P.PROJECT_ID = PWQ.PROJECT_ID
             AND PWQ.NATURE_OF_JOB_ID = WMR.NATURE_OF_JOB_ID
             AND PWQ.WORK_DESCRIPTION_ID = WMR.WORK_DESCRIPTION_ID
             AND PWQ.SUB_WORK_DESCRIPTION_ID = WMR.SUB_WORK_DESCRIPTION_ID
             AND PWQ.PROJECT_WORK_QTY_ID =
                   NVL (P_PROJECT_WORK_QTY_ID, PWQ.PROJECT_WORK_QTY_ID)
             AND PWQ.PROJECT_ID = P_PROJECT_ID
             AND PWQ.BUILDING_ID = NVL (P_BUILDING_ID, PWQ.BUILDING_ID)
             AND PWQ.REVISION_NUM = NVL (p_revision_num, PWQ.REVISION_NUM)
             AND wmr.MATERIAL_SEPCIFICATION_ID = mp.SPEC_ID(+);
             
             

SELECT 138,
             P.PROJECT_ID,
             BUILDING_ID,
             BUILDING_LEVEL_ID,
             APPARTMENT_ID,
             UNIT_LOCATION_ID,
             REVISION_NUM,
             PWQ.NATURE_OF_JOB_ID,
             PWQ.WORK_DESCRIPTION_ID,
             PWQ.SUB_WORK_DESCRIPTION_ID,
             PROJECT_WORK_QTY_ID,                              --SUB_WORK_QTY,
             -- M_SUB_WORK_DESCRIPTION ,
             WMR.INVENTORY_ITEM_ID,
             WMR.UNIT_OF_MEASURE MATERIAL_OUM,
             MTL_ORIGIN_LOOKUP_CODE,
             MTL_BRAND_LOOKUP_CODE,
             (REQUIRED_QUANTITY) * SUB_WORK_QTY REQ_QUNATITY,
             mp.UNIT_PRICE,
             SYSDATE,
             PWQ.CREATED_BY,
             SYSDATE,
             PWQ.LAST_UPDATED_BY,
             PWQ.LAST_UPDATE_LOGIN
        FROM PROJECT_WISE_WORK_QNT PWQ,
             (SELECT WR.NATURE_OF_JOB_ID,
                     WR.WORK_DESCRIPTION_ID,
                     WR.SUB_WORK_DESCRIPTION_ID,
                     WR.ORGANIZATION_ID,
                     WR.INVENTORY_ITEM_ID,
                     WR.MTL_SPECIFICATION,
                     WR.UNIT_OF_MEASURE,
                     WR.MTL_ORIGIN_LOOKUP_CODE,
                     WR.MTL_BRAND_LOOKUP_CODE,
                     (NVL (WR.REQUIRED_QUANTITY, 0) / NVL (EST_WORK_QTY, 1))
                        REQUIRED_QUANTITY,
                     MATERIAL_SEPCIFICATION_ID
                FROM WORK_MATERIAL_REQE wr, SUB_WORK_DESCRIPTION SW
               WHERE SW.SUB_WORK_DESCRIPTION_ID = WR.SUB_WORK_DESCRIPTION_ID)
             WMR,
             ALL_PROJECT_INFO_MASTER P,
             (  SELECT spec_id, MAX (unit_price) unit_price
                  FROM XX_MATERIAL_EST_PRICE
                 WHERE active_to IS NULL
              GROUP BY spec_id) MP
       WHERE     P.PROJECT_ID = PWQ.PROJECT_ID
             AND PWQ.NATURE_OF_JOB_ID = WMR.NATURE_OF_JOB_ID
             AND PWQ.WORK_DESCRIPTION_ID = WMR.WORK_DESCRIPTION_ID
             AND PWQ.SUB_WORK_DESCRIPTION_ID = WMR.SUB_WORK_DESCRIPTION_ID
             AND PWQ.PROJECT_WORK_QTY_ID =PWQ.PROJECT_WORK_QTY_ID
             AND PWQ.PROJECT_ID = :P_PROJECT_ID
             AND PWQ.BUILDING_ID = PWQ.BUILDING_ID
             AND PWQ.REVISION_NUM = PWQ.REVISION_NUM
             AND wmr.MATERIAL_SEPCIFICATION_ID = mp.SPEC_ID(+)
             AND PWQ.SUB_WORK_DESCRIPTION_ID=1201;
             
SELECT pbl.ROWID row_id,
          pbl.nature_of_job_id,
          pbl.work_description_id,
          pbl.sub_work_description_id,
          pbl.organization_id,
          NVL (pbl.inventory_item_id, material_sepcification_id)
             inventory_item_id,
          NULL item_number,
             group_name
          || ' : '
          || mn.material_name
          || ' : '
          || ms.material_specification
             item_description,
          mg.group_name material_group,
          mn.material_name,
          ms.material_specification,
          pbl.mtl_specification,
          pbl.unit_of_measure,
          pbl.mtl_origin_lookup_code,
          fndlv2.meaning m_mtl_origin,
          pbl.mtl_brand_lookup_code,
          fndlv1.meaning m_mtl_brand,
          pbl.required_quantity,
          pbl.mixing_ratio,
          pbl.ratio_basis,
          pbl.creation_date,
          pbl.created_by,
          pbl.last_update_date,
          pbl.last_updated_by,
          pbl.last_update_login
     FROM work_material_reqe pbl,
          (SELECT *
             FROM apps.fnd_lookup_values
            WHERE lookup_type = 'XXCPM_MATERIAL_BRAND') fndlv1,
          (SELECT *
             FROM apps.fnd_lookup_values
            WHERE lookup_type = 'XXCPM_MATERIAL_ORIGIN') fndlv2,
          -- APPS.MTL_SYSTEM_ITEMS_KFV ITEM,
          xx_material_spec ms,
          xx_material_name mn,
          material_group mg
    WHERE     pbl.mtl_brand_lookup_code = fndlv1.lookup_code(+)
          AND pbl.mtl_origin_lookup_code = fndlv2.lookup_code(+)
          AND mn.GROUP_ID = mg.material_group_id
          AND mn.name_id = ms.material_name_id
          AND mn.GROUP_ID = ms.GROUP_ID
          --AND PBL.ORGANIZATION_ID = ITEM.ORGANIZATION_ID(+)
          --     AND PBL.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID(+)
          AND pbl.inventory_item_id = ms.spec_id(+);
          
          
          select
          *
          FROM work_material_reqe
          WHERE 1=1
          --AND SUB_WORK_DESCRIPTION_ID=:P_ID
          --AND WORK_DESCRIPTION_ID=:WD_ID
          
          
          SELECT
          *
          FROM
          SUB_WORK_DESCRIPTION SW
          WHERE 1=1
        AND SUB_WORK_DESCRIPTION=:P_NAME
--          AND SUB_WORK_DESCRIPTION_ID=:P_ID
          

/*select group_name||' : '||n.material_name||' : '||MATERIAL_SPECIFICATION item_description, d.spec_id, MATERIAL_UOM,unit_price
from XX_MATERIAL_SPEC d  ,xx_material_name n,material_group g    ,(select SPEC_ID,max(unit_price)unit_price from XX_MATERIAL_EST_PRICE group by spec_id) p
where d.spec_id=p.spec_id (+)
and n.group_id=g.material_group_id
and n.NAME_ID =d.MATERIAL_NAME_ID
*/
SELECT   distinct msik.description ||' ( '||msik.concatenated_segments||' )' item_description,           msik.inventory_item_id spec_id,
msik.PRIMARY_UOM_CODE MATERIAL_UOM, null unit_price
                  FROM   org_organization_definitions ood,
                    mtl_system_items_b_kfv msik,
                    mtl_item_categories mic,
                    mtl_categories_b mcb
            WHERE       msik.organization_id = mic.organization_id
                    AND msik.organization_id = ood.organization_id
                    AND ood.organization_id = mic.organization_id
                    AND msik.inventory_item_id = mic.inventory_item_id
                    AND mcb.segment2 LIKE '%CONSTRUCTION%'
                    AND mic.category_id = mcb.category_id
                    AND msik.organization_id in (select company_id from all_project_info_master where project_id=182)
                    order by 1
                    
                    
                    select * from all_project_info_master where project_id=182
                    
/*select group_name||' : '||n.material_name||' : '||MATERIAL_SPECIFICATION item_description, d.spec_id, MATERIAL_UOM,unit_price
from XX_MATERIAL_SPEC d  ,xx_material_name n,material_group g    ,(select SPEC_ID,max(unit_price)unit_price from XX_MATERIAL_EST_PRICE group by spec_id) p
where d.spec_id=p.spec_id (+)
and n.group_id=g.material_group_id
and n.NAME_ID =d.MATERIAL_NAME_ID
*/
SELECT   distinct msik.description ||' ( '||msik.concatenated_segments||' )' item_description,           msik.inventory_item_id spec_id,
msik.PRIMARY_UOM_CODE MATERIAL_UOM, null unit_price
                  FROM   org_organization_definitions ood,
                    mtl_system_items_b_kfv msik,
                    mtl_item_categories mic,
                    mtl_categories_b mcb
            WHERE       msik.organization_id = mic.organization_id
                    AND msik.organization_id = ood.organization_id
                    AND ood.organization_id = mic.organization_id
                    AND msik.inventory_item_id = mic.inventory_item_id
                    AND mcb.segment2 LIKE '%CONSTRUCTION%'
                    AND mic.category_id = mcb.category_id
                    AND msik.organization_id=835
                    
                    

SELECT DISTINCT CAT.SEGMENT2 MATERIAL_GROUP,
       ITM.DESCRIPTION MATERIAL_NAME,
       ITM.DESCRIPTION || '(' || ITM.SEGMENT1 || ')' MATERIAL_SPECIFICATION,
       ITM.PRIMARY_UOM_CODE MATERIAL_UOM,
       ITM.INVENTORY_ITEM_ID SPEC_ID
  FROM MTL_SYSTEM_ITEMS_KFV ITM, MTL_ITEM_CATEGORIES_V CAT
 WHERE     ITM.ENABLED_FLAG = 'Y'
       AND ITM.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND ITM.ORGANIZATION_ID = CAT.ORGANIZATION_ID
       AND CAT.SEGMENT2 = 'CIVIL CONSTRUCTION'
       AND ITM.ORGANIZATION_ID <> 138
       AND CAT.CATEGORY_SET_ID = 1
       AND (INVENTORY_ITEM_STATUS_CODE <>'Inactive'
       OR PURCHASING_ENABLED_FLAG <>'N')
       UNION ALL
SELECT GROUP_NAME MATERIAL_GROUP,
       N.MATERIAL_NAME,
       MATERIAL_SPECIFICATION,
       MATERIAL_UOM,
       SPEC_ID
  FROM XX_MATERIAL_SPEC S, XX_MATERIAL_NAME N, MATERIAL_GROUP G
 WHERE G.MATERIAL_GROUP_ID = N.GROUP_ID AND N.NAME_ID = S.MATERIAL_NAME_ID


SELECT DISTINCT
         msik.description || ' ( ' || msik.concatenated_segments || ' )'
            item_description,
         msik.inventory_item_id spec_id,
         msik.primary_uom_code material_uom,
         NULL unit_price
    FROM org_organization_definitions ood,
         mtl_system_items_b_kfv msik,
         mtl_item_categories_v mic
   WHERE     msik.organization_id = mic.organization_id
         AND msik.organization_id = ood.organization_id
         AND ood.organization_id = mic.organization_id
         AND msik.inventory_item_id = mic.inventory_item_id
         AND msik.organization_id = mic.organization_id
         AND mic.segment2 LIKE '%CONSTRUCTION%'
         AND mic.category_set_id = 1
         and ood.organization_id=157
--         AND ood.operating_unit=157
         AND msik.inventory_item_id=69913
ORDER BY 1



SELECT distinct msik.description ||' ( '||msik.concatenated_segments||' )' item
--into :PROJECT_WISE_MATERIAL_QNT.ITEM_DESCRIPTION
                  FROM   org_organization_definitions ood,
         mtl_system_items_b_kfv msik,
         mtl_item_categories_v mic
            WHERE       msik.organization_id = mic.organization_id
         AND msik.organization_id = ood.organization_id
         AND ood.organization_id = mic.organization_id
         AND msik.inventory_item_id = mic.inventory_item_id
         AND msik.organization_id = mic.organization_id
         AND mic.segment2 LIKE '%CONSTRUCTION%'
         AND mic.category_set_id = 1
         AND ood.organization_id IN
                (SELECT company_id
                   FROM all_project_info_master
                  WHERE project_id = 157)
                    AND msik.inventory_item_id = 69913;
                    
                    SELECT company_id
                   FROM all_project_info_master
                  WHERE project_id = :project_id