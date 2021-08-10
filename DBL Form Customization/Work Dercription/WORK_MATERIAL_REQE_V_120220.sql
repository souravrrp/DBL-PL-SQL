/* Formatted on 2/12/2020 11:39:05 AM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW XXDBL.WORK_MATERIAL_REQE_V
(
   ROW_ID,
   NATURE_OF_JOB_ID,
   WORK_DESCRIPTION_ID,
   SUB_WORK_DESCRIPTION_ID,
   ORGANIZATION_ID,
   INVENTORY_ITEM_ID,
   ITEM_NUMBER,
   ITEM_DESCRIPTION,
   MATERIAL_GROUP,
   MATERIAL_NAME,
   MATERIAL_SPECIFICATION,
   MTL_SPECIFICATION,
   UNIT_OF_MEASURE,
   MTL_ORIGIN_LOOKUP_CODE,
   M_MTL_ORIGIN,
   MTL_BRAND_LOOKUP_CODE,
   M_MTL_BRAND,
   REQUIRED_QUANTITY,
   MIXING_RATIO,
   RATIO_BASIS,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN
)
   BEQUEATH DEFINER
AS
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
          AND pbl.inventory_item_id = ms.spec_id(+)
   UNION ALL
   SELECT pbl.ROWID row_id,
          pbl.nature_of_job_id,
          pbl.work_description_id,
          pbl.sub_work_description_id,
          pbl.organization_id,
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
          AND pbl.inventory_item_id = ITM.INVENTORY_ITEM_ID(+);


CREATE OR REPLACE SYNONYM APPS.WORK_MATERIAL_REQE_V FOR XXDBL.WORK_MATERIAL_REQE_V;


CREATE OR REPLACE SYNONYM APPSRO.WORK_MATERIAL_REQE_V FOR XXDBL.WORK_MATERIAL_REQE_V;


GRANT SELECT ON XXDBL.WORK_MATERIAL_REQE_V TO APPSRO;