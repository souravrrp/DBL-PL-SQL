SELECT DISTINCT
          pwq.project_id,
          pwq.building_id,
          pwq.building_level_id,
          pwq.appartment_id,
          pwq.UNIT_LOCATION_ID,
          pwq.REVISION_NUM,
          pwq.NATURE_OF_JOB_ID,
          pwq.WORK_DESCRIPTION_ID,
          pwq.SUB_WORK_DESCRIPTION_ID,
          pwq.PROJECT_WORK_QTY_ID,
          NVL (pbl.inventory_item_id, ITM.INVENTORY_ITEM_ID)
             inventory_item_id,
          pbl.nature_of_job_id,
          pbl.work_description_id,
          pbl.sub_work_description_id,
          pbl.organization_id,
          NVL (pbl.inventory_item_id, ITM.INVENTORY_ITEM_ID)
             inventory_item_id,
          ITM.DESCRIPTION || '(' || ITM.SEGMENT1 || ')' MTL_SPECIFICATION,
          pbl.unit_of_measure,
          fndlv2.meaning MTL_ORIGIN_LOOKUP_CODE,
          pbl.mtl_brand_lookup_code MTL_BRAND_LOOKUP_CODE,
          pbl.required_quantity QUANTITY,
          NULL RE_USE,
          mp.UNIT_PRICE,
          pwq.CREATION_DATE,
          pwq.CREATED_BY,
          pwq.LAST_UPDATE_DATE,
          pwq.LAST_UPDATED_BY,	
          pwq.LAST_UPDATE_LOGIN,
          NULL PROJECT_MATERIAL_ID,
          NULL INVENTORY_ID_OLD,
          ---
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
          ,project_wise_work_qnt pwq
          ,(  SELECT spec_id, MAX (unit_price) unit_price
                  FROM XX_MATERIAL_EST_PRICE
                 WHERE active_to IS NULL
              GROUP BY spec_id) MP
    WHERE     pbl.mtl_brand_lookup_code = fndlv1.lookup_code(+)
          AND pbl.mtl_origin_lookup_code = fndlv2.lookup_code(+)
          AND ITM.ENABLED_FLAG = 'Y'
          AND ITM.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
          AND ITM.ORGANIZATION_ID = CAT.ORGANIZATION_ID
          AND CAT.SEGMENT2 = 'CIVIL CONSTRUCTION'
          AND ITM.ORGANIZATION_ID <> 138
          AND CAT.CATEGORY_SET_ID = 1
          AND (   INVENTORY_ITEM_STATUS_CODE <> 'Inactive'
               OR PURCHASING_ENABLED_FLAG <> 'N')
          AND pbl.inventory_item_id = ITM.INVENTORY_ITEM_ID(+)
          AND pwq.nature_of_job_id = pbl.nature_of_job_id
          AND pwq.work_description_id = pbl.work_description_id
          AND pwq.sub_work_description_id = pbl.sub_work_description_id
          AND ITM.INVENTORY_ITEM_ID = mp.SPEC_ID(+)
          --AND pwq.project_id = pbl.project_id
          AND pwq.project_id =182
          AND  pbl.sub_work_description_id= 1204
          ;