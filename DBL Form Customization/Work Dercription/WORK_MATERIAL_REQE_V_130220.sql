/* Formatted on 2/13/2020 11:50:45 AM (QP5 v5.287) */
SELECT NVL(pbl.ROWID,pbl2.ROWID) row_id,
       NVL(pbl.nature_of_job_id,pbl2.nature_of_job_id) nature_of_job_id,
       NVL(pbl.work_description_id,pbl2.work_description_id) work_description_id,
       NVL(pbl.sub_work_description_id,pbl2.sub_work_description_id) sub_work_description_id,
       nvl(pbl.organization_id,pbl2.organization_id) organization_id,
--       NVL (NVL (pbl.inventory_item_id, material_sepcification_id),
--            ITM.INVENTORY_ITEM_ID)
--          inventory_item_id,
       NULL item_number,
       NVL (
             group_name
          || ' : '
          || mn.material_name
          || ' : '
          || ms.material_specification,
          ITM.DESCRIPTION)
          item_description,
       NVL (mg.group_name, CAT.SEGMENT2) material_group,
       NVL (mn.material_name, ITM.DESCRIPTION) material_name,
       NVL (ms.material_specification,
            ITM.DESCRIPTION || '(' || ITM.SEGMENT1 || ')')
          material_specification,
       nvl(pbl.mtl_specification,pbl2.mtl_specification) mtl_specification,
       nvl(pbl.unit_of_measure,pbl2.unit_of_measure) unit_of_measure,
       nvl(pbl.mtl_origin_lookup_code,pbl2.mtl_origin_lookup_code) mtl_origin_lookup_code,
       nvl(fndlv2.meaning,fndlv4.meaning) m_mtl_origin,
       nvl(pbl.mtl_brand_lookup_code,pbl2.mtl_brand_lookup_code) mtl_brand_lookup_code,
       nvl(fndlv1.meaning,fndlv13.meaning) m_mtl_brand,
       nvl(pbl.required_quantity,pbl2.required_quantity) required_quantity,
       nvl(pbl.mixing_ratio,pbl2.mixing_ratio) mixing_ratio,
       nvl(pbl.ratio_basis,pbl2.ratio_basis) ratio_basis,
       nvl(pbl.creation_date,pbl2.creation_date) creation_date,
       nvl(pbl.created_by,pbl2.created_by) created_by,
       nvl(pbl.last_update_date,pbl2.last_update_date) last_update_date,
       nvl(pbl.last_updated_by,pbl2.last_updated_by) last_updated_by,
       nvl(pbl.last_update_login,pbl2.last_update_login) last_update_login
  FROM work_material_reqe pbl,
       work_material_reqe pbl2,
       (SELECT *
          FROM apps.fnd_lookup_values
         WHERE lookup_type = 'XXCPM_MATERIAL_BRAND') fndlv1,
       (SELECT *
          FROM apps.fnd_lookup_values
         WHERE lookup_type = 'XXCPM_MATERIAL_ORIGIN') fndlv2,
       (SELECT *
          FROM apps.fnd_lookup_values
         WHERE lookup_type = 'XXCPM_MATERIAL_BRAND') fndlv13,
       (SELECT *
          FROM apps.fnd_lookup_values
         WHERE lookup_type = 'XXCPM_MATERIAL_ORIGIN') fndlv4,
       -- APPS.MTL_SYSTEM_ITEMS_KFV ITEM,
       xx_material_spec ms,
       xx_material_name mn,
       material_group mg,
       apps.mtl_system_items_kfv itm,
       apps.mtl_item_categories_v cat
 WHERE     pbl.mtl_brand_lookup_code = fndlv1.lookup_code(+)
       AND pbl.mtl_origin_lookup_code = fndlv2.lookup_code(+)
       and pbl2.mtl_brand_lookup_code = fndlv13.lookup_code(+)
       AND pbl2.mtl_origin_lookup_code = fndlv4.lookup_code(+)
       AND mn.GROUP_ID = mg.material_group_id
       AND mn.name_id = ms.material_name_id
       AND mn.GROUP_ID = ms.GROUP_ID
       AND pbl.inventory_item_id = ms.spec_id(+)
       --AND ITM.ENABLED_FLAG = 'Y'
       AND ITM.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID(+)
       AND ITM.ORGANIZATION_ID = CAT.ORGANIZATION_ID(+)
       --AND CAT.SEGMENT2 (+)= 'CIVIL CONSTRUCTION'
       AND ITM.ORGANIZATION_ID = 147
       AND CAT.CATEGORY_SET_ID = 1
       AND (   INVENTORY_ITEM_STATUS_CODE <> 'Inactive'
            OR PURCHASING_ENABLED_FLAG <> 'N')
       AND pbl2.inventory_item_id = ITM.INVENTORY_ITEM_ID(+)
       AND pbl.SUB_WORK_DESCRIPTION_ID = pbl2.SUB_WORK_DESCRIPTION_ID
       AND pbl.SUB_WORK_DESCRIPTION_ID = :sub_work_id
       --AND pbl2.SUB_WORK_DESCRIPTION_ID = :sub_work_id
       ;
       
       /* Formatted on 2/13/2020 12:42:55 PM (QP5 v5.287) */
SELECT *
--CASE
--  WHEN ROW_TYPEN='NEW' THEN YY.ITEM_DESCRIPTION
--  WHEN ROW_TYPEO='OLD' THEN XX.ITEM_DESCRIPTION
--  --ELSE XX.ITEM_DESCRIPTION
--END ITEM_DESCRIPTION
--DECODE(ROW_TYPE, 'NEW', YY.MATERIAL_GROUP,
--                    XX.material_group) material_group                    
--       XX.row_id,
--       XX.nature_of_job_id,
--       XX.work_description_id,
--       XX.sub_work_description_id,
--       XX.organization_id,
--       XX.inventory_item_id,
--       XX.item_number,
--       XX.item_description,
--       DECODE(ITM.ORGANIZATION_ID, 147, CAT.SEGMENT2,
--                    mg.group_name) material_group,
--       XX.material_group,
--       XX.material_name,
--       XX.material_specification,
--       XX.mtl_specification,
--       XX.unit_of_measure,
--       XX.mtl_origin_lookup_code,
--       XX.m_mtl_origin,
--       XX.mtl_brand_lookup_code,
--       XX.m_mtl_brand,
--       XX.required_quantity,
--       XX.mixing_ratio,
--       XX.ratio_basis,
--       XX.creation_date,
--       XX.created_by,
--       XX.last_update_date,
--       XX.last_updated_by,
--       XX.last_update_login
  FROM (SELECT pbl.ROWID row_id,
               'OLD' ROW_TYPEO,
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
               AND pbl.inventory_item_id = ms.spec_id(+)) XX,
       (SELECT pbl.ROWID row_id,
               'NEW' ROW_TYPEN,
               pbl.nature_of_job_id,
               pbl.work_description_id,
               pbl.sub_work_description_id,
               ITM.organization_id,
               NVL (pbl.inventory_item_id, ITM.INVENTORY_ITEM_ID)
                  inventory_item_id,
               NULL item_number,
               ITM.DESCRIPTION item_description,
               CAT.SEGMENT2 material_group,
               ITM.DESCRIPTION material_name,
               ITM.DESCRIPTION || '(' || ITM.SEGMENT1 || ')'
                  material_specification,
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
               apps.mtl_system_items_kfv itm,
               apps.mtl_item_categories_v cat
         WHERE     pbl.mtl_brand_lookup_code = fndlv1.lookup_code(+)
               AND pbl.mtl_origin_lookup_code = fndlv2.lookup_code(+)
               AND ITM.ENABLED_FLAG = 'Y'
               AND ITM.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
               AND ITM.ORGANIZATION_ID = CAT.ORGANIZATION_ID
               AND CAT.SEGMENT2 = 'CIVIL CONSTRUCTION'
               AND ITM.ORGANIZATION_ID = 147
               AND CAT.CATEGORY_SET_ID = 1
               AND (   INVENTORY_ITEM_STATUS_CODE <> 'Inactive'
                    OR PURCHASING_ENABLED_FLAG <> 'N')
               AND pbl.inventory_item_id = ITM.INVENTORY_ITEM_ID(+)) YY
 WHERE     1 = 1
       --AND XX.nature_of_job_id= YY.nature_of_job_id
       --AND XX.work_description_id = YY.work_description_id
       AND XX.sub_work_description_id = YY.sub_work_description_id(+)
       AND XX.SUB_WORK_DESCRIPTION_ID = :sub_work_id;