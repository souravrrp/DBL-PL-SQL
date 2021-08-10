WITH TmpNotRelease
     AS (  SELECT H.BATCH_NO,
                  H.ACTUAL_START_DATE AS PRODUCTION_START_DATE,
                  H.ATTRIBUTE1 COUNT,
                  H.ATTRIBUTE5 AS CUSTOMER_NAME,
                  H.ATTRIBUTE7 AS COLOR,
                  H.ATTRIBUTE6 AS COLOR_REF,
                  msi.Segment1 AS ITEM,
                  H.ATTRIBUTE8 AS STYLE,
                  H.ATTRIBUTE11 AS CUSTOMR_LOT,
                  H.ATTRIBUTE12 AS ORDER_PO_NO,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING') AS activity,
                  COUNT (H.Batch_NO) no_of_batch,
                  ROUND (SUM (d.WIP_PLAN_QTY), 2) AS BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  mtl_system_items_kfv msi,
                  mtl_item_categories_v mic
            WHERE     H.Batch_ID = D.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  AND msi.inventory_item_id = mic.inventory_item_id
                  AND msi.organization_id = mic.organization_id
                  AND msi.inventory_item_id = d.inventory_item_id
                  AND msi.organization_id = d.organization_id
                  AND mic.SEGMENT2 IN ('SEMI FINISH GOODS')
                  AND category_set_id = 1
                  AND line_type = -1
                  AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS = 1
                  AND d.PHANTOM_TYPE <> 0
                  AND d.DTL_UM = 'KG'
                  AND gbs.BATCHSTEP_NO = 10
                  AND d.line_no = 1
         GROUP BY H.BATCH_NO,
                  H.ACTUAL_START_DATE,
                  H.ATTRIBUTE1,
                  H.ATTRIBUTE5,
                  H.ATTRIBUTE7,
                  H.ATTRIBUTE6,
                  msi.Segment1,
                  H.ATTRIBUTE8,
                  H.ATTRIBUTE11,
                  H.ATTRIBUTE12,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING')
         UNION
           SELECT H.BATCH_NO,
                  H.ACTUAL_START_DATE AS PRODUCTION_START_DATE,
                  H.ATTRIBUTE1 COUNT,
                  H.ATTRIBUTE5 AS CUSTOMER_NAME,
                  H.ATTRIBUTE7 AS COLOR,
                  H.ATTRIBUTE6 AS COLOR_REF,
                  msi.Segment1 AS ITEM,
                  H.ATTRIBUTE8 AS STYLE,
                  H.ATTRIBUTE11 AS CUSTOMR_LOT,
                  H.ATTRIBUTE12 AS ORDER_PO_NO,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING') AS activity,
                  COUNT (H.Batch_NO) no_of_batch,
                  ROUND (SUM (d.WIP_PLAN_QTY), 2) AS BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  mtl_system_items_kfv msi,
                  mtl_item_categories_v mic
            WHERE     H.Batch_ID = D.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  AND msi.inventory_item_id = mic.inventory_item_id
                  AND msi.organization_id = mic.organization_id
                  AND msi.inventory_item_id = d.inventory_item_id
                  AND msi.organization_id = d.organization_id
                  AND mic.SEGMENT2 IN ('SEMI FINISH GOODS')
                  AND mic.SEGMENT3 IN ('DYED YARN')
                  AND category_set_id = 1
                  AND line_type = -1
                  AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS = 1
                  AND d.PHANTOM_TYPE <> 1
                  AND d.DTL_UM = 'KG'
                  AND gbs.BATCHSTEP_NO = 10
                  AND d.line_no = 1
         GROUP BY H.BATCH_NO,
                  H.ACTUAL_START_DATE,
                  H.ATTRIBUTE1,
                  H.ATTRIBUTE5,
                  H.ATTRIBUTE7,
                  H.ATTRIBUTE6,
                  msi.Segment1,
                  H.ATTRIBUTE8,
                  H.ATTRIBUTE11,
                  H.ATTRIBUTE12,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING')
         UNION
           SELECT H.BATCH_NO,
                  H.ACTUAL_START_DATE AS PRODUCTION_START_DATE,
                  H.ATTRIBUTE1 COUNT,
                  H.ATTRIBUTE5 AS CUSTOMER_NAME,
                  H.ATTRIBUTE7 AS COLOR,
                  H.ATTRIBUTE6 AS COLOR_REF,
                  msi.Segment1 AS ITEM,
                  H.ATTRIBUTE8 AS STYLE,
                  H.ATTRIBUTE11 AS CUSTOMR_LOT,
                  H.ATTRIBUTE12 AS ORDER_PO_NO,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING') AS activity,
                  COUNT (H.Batch_NO) no_of_batch,
                  ROUND (SUM (d.WIP_PLAN_QTY), 2) AS BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  mtl_system_items_kfv msi,
                  mtl_item_categories_v mic
            WHERE     H.Batch_ID = D.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  AND msi.inventory_item_id = mic.inventory_item_id
                  AND msi.organization_id = mic.organization_id
                  AND msi.inventory_item_id = d.inventory_item_id
                  AND msi.organization_id = d.organization_id
                  AND mic.SEGMENT2 IN ('RAW MATERIAL')
                  AND mic.SEGMENT3 IN ('DYED FIBER')
                  AND category_set_id = 1
                  AND line_type = -1
                  AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS = 1
                  AND d.PHANTOM_TYPE <> 1
                  AND d.DTL_UM = 'KG'
                  -- AND gbs.STEP_STATUS = 2
                  AND gbs.BATCHSTEP_NO = 10
                  AND d.line_no = 1
         GROUP BY H.BATCH_NO,
                  H.ACTUAL_START_DATE,
                  H.ATTRIBUTE1,
                  H.ATTRIBUTE5,
                  H.ATTRIBUTE7,
                  H.ATTRIBUTE6,
                  msi.Segment1,
                  H.ATTRIBUTE8,
                  H.ATTRIBUTE11,
                  H.ATTRIBUTE12,
                  DECODE (gbs.BATCHSTEP_NO, 10, 'STAGING')
         ORDER BY PRODUCTION_START_DATE)
SELECT *
  FROM TmpNotRelease
 WHERE TO_DATE (PRODUCTION_START_DATE, 'DD/MM/RRRR hh12:mi:ssAM') 
 BETWEEN TO_DATE (:p_StartDate, 'DD/MM/RRRR hh12:mi:ssAM')
 AND TO_DATE (:p_EndDate, 'DD/MM/RRRR hh12:mi:ssAM')