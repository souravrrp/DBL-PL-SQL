/* Formatted on 12/23/2019 10:11:45 AM (QP5 v5.287) */
WITH TmpDate
     AS (    SELECT   TO_DATE ( :p_StartDate, 'DD/MM/RRRR hh12:mi:ssAM')
                    + ROWNUM
                    - 1
                       D_DATE
               FROM DUAL
         CONNECT BY LEVEL <=
                         TO_DATE ( :p_EndDate, 'DD/MM/RRRR hh12:mi:ssAM')
                       - TO_DATE ( :p_StartDate, 'DD/MM/RRRR hh12:mi:ssAM')
                       + 1),
     TmpProductionReport01
     AS (  SELECT TRUNC (gbs.ACTUAL_CMPLT_DATE) AS ACTUAL_CMPLT_DATE,
                  DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING YARN') AS activity,
                  COUNT (H.batch_id) no_of_batch
                  --,SUM (Tq.actual_qty) BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  ---------------------------
                  GMD_OPERATIONS OPN,
--                  (SELECT actual_qty, batch_id
--                     FROM gme_material_details
--                    WHERE line_type = -1 AND DTL_UM = 'KG') Tq,
                  (SELECT a.inventory_item_id,
                          a.organization_id,
                          a.segment1 AS item_code,
                          a.description,
                          a.primary_uom_code,
                          b.segment1,
                          b.segment2,
                          b.segment3,
                          b.segment4,
                          c.ARTICLE_TICKET,
                          c.KG_PER_PKG
                     FROM mtl_system_items_kfv a,
                          mtl_item_categories_v b,
                          xxdbl.XXDBL_DYEHOUSE_ROUTING_HDR c
                    WHERE     a.inventory_item_id = b.inventory_item_id
                          AND a.organization_id = b.organization_id
                          AND b.category_set_id = 1100000062
                          AND b.segment2 = c.ARTICLE_TICKET
                          AND a.organization_id = 150) item
            WHERE     H.Batch_ID = D.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  --AND Tq.Batch_ID = H.Batch_ID
                  AND item.organization_id = d.organization_id
                  AND item.inventory_item_id = d.inventory_item_id
                  AND OPN.OPRN_ID = gbs.OPRN_ID
                  AND item.segment1 IN ('DYED YARN')
                  AND line_type = 1
                  --AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS NOT IN (-1, 1, 2)                   -- 3
                  AND d.PHANTOM_TYPE <> 1
                  AND d.DTL_UM = 'KG'
                  AND gbs.BATCHSTEP_NO = 30
                  AND d.line_no = 1
                  AND h.organization_id = 150
                  AND TO_DATE (gbs.ACTUAL_CMPLT_DATE,
                               'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                                     :p_StartDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
                                                              AND TO_DATE (
                                                                     :p_EndDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
         GROUP BY DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING YARN'),
                  TRUNC (gbs.ACTUAL_CMPLT_DATE)),
     TmpProductionReport02
     AS (  SELECT TRUNC (gbs.ACTUAL_CMPLT_DATE) AS ACTUAL_CMPLT_DATE,
                  DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING SEWING THREAD')
                     AS activity,
                  COUNT (H.batch_id) no_of_batch
--                  ,SUM (Tq.actual_qty) BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  ---------------------------
                  GMD_OPERATIONS OPN,
--                  (SELECT actual_qty, batch_id
--                     FROM gme_material_details
--                    WHERE line_type = -1 AND DTL_UM = 'KG') Tq,
                  (SELECT a.inventory_item_id,
                          a.organization_id,
                          a.segment1 AS item_code,
                          a.description,
                          a.primary_uom_code,
                          b.segment1,
                          b.segment2,
                          b.segment3,
                          b.segment4,
                          c.ARTICLE_TICKET,
                          c.KG_PER_PKG
                     FROM mtl_system_items_kfv a,
                          mtl_item_categories_v b,
                          xxdbl.XXDBL_DYEHOUSE_ROUTING_HDR c
                    WHERE     a.inventory_item_id = b.inventory_item_id
                          AND a.organization_id = b.organization_id
                          AND b.category_set_id = 1100000062
                          AND b.segment2 = c.ARTICLE_TICKET
                          AND a.organization_id = 150) item
            WHERE     H.Batch_ID = D.Batch_ID
--                  AND Tq.Batch_ID = H.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  AND item.organization_id = d.organization_id
                  AND item.inventory_item_id = d.inventory_item_id
                  AND OPN.OPRN_ID = gbs.OPRN_ID
                  AND item.segment1 IN ('SEWING THREAD')
                  AND line_type = -1
                  --AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS NOT IN (-1, 1, 2)                   -- 3
                  AND d.PHANTOM_TYPE <> 0
                  AND d.DTL_UM = 'KG'
                  AND gbs.BATCHSTEP_NO = 30
                  AND d.line_no = 1
                  AND h.organization_id = 150
                  AND TO_DATE (gbs.ACTUAL_CMPLT_DATE,
                               'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                                     :p_StartDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
                                                              AND TO_DATE (
                                                                     :p_EndDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
         GROUP BY DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING SEWING THREAD'),
                  TRUNC (gbs.ACTUAL_CMPLT_DATE)),
     TmpProductionReport03
     AS (  SELECT TRUNC (gbs.ACTUAL_CMPLT_DATE) AS ACTUAL_CMPLT_DATE,
                  DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING YARN FIBER')
                     AS activity,
                  COUNT (H.batch_id) no_of_batch
                  --,SUM (Tq.actual_qty) BATCH_QTY
             FROM gme.GME_BATCH_HEADER H,
                  gme.gme_material_details D,
                  apps.gme_batch_steps gbs,
                  ---------------------------
                  GMD_OPERATIONS OPN,
--                  (SELECT actual_qty, batch_id
--                     FROM gme_material_details
--                    WHERE line_type = -1 AND DTL_UM = 'KG') Tq,
                  (SELECT a.inventory_item_id,
                          a.organization_id,
                          a.segment1 AS item_code,
                          a.description,
                          a.primary_uom_code,
                          b.segment1,
                          b.segment2,
                          b.segment3,
                          b.segment4,
                          c.ARTICLE_TICKET,
                          c.KG_PER_PKG
                     FROM mtl_system_items_kfv a,
                          mtl_item_categories_v b,
                          xxdbl.XXDBL_DYEHOUSE_ROUTING_HDR c
                    WHERE     a.inventory_item_id = b.inventory_item_id
                          AND a.organization_id = b.organization_id
                          AND b.category_set_id = 1100000062
                          AND b.segment2 = c.ARTICLE_TICKET
                          AND a.organization_id = 150) item
            WHERE     H.Batch_ID = D.Batch_ID
--                  AND Tq.Batch_ID = H.Batch_ID
                  AND h.batch_id = gbs.batch_id
                  AND item.organization_id = d.organization_id
                  AND item.inventory_item_id = d.inventory_item_id
                  AND OPN.OPRN_ID = gbs.OPRN_ID
                  AND item.segment1 IN ('DYED FIBER')
                  AND line_type = 1
                  --AND h.BATCH_STATUS = 2
                  AND gbs.STEP_STATUS NOT IN (-1, 1, 2)                   -- 3
                  AND d.PHANTOM_TYPE <> 1
                  AND d.DTL_UM = 'KG'
                  AND gbs.BATCHSTEP_NO = 30
                  AND d.line_no = 1
                  AND h.organization_id = 150
                  AND TO_DATE (gbs.ACTUAL_CMPLT_DATE,
                               'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                                     :p_StartDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
                                                              AND TO_DATE (
                                                                     :p_EndDate,
                                                                     'DD/MM/RRRR hh12:mi:ssAM')
         GROUP BY DECODE (gbs.BATCHSTEP_NO, 30, 'DYEING YARN FIBER'),
                  TRUNC (gbs.ACTUAL_CMPLT_DATE))
  SELECT                              --TO_DATE(t.D_DATE, 'DD-MM-YYYY')D_DATE,
        TO_CHAR (t.D_DATE, 'DD-MON-YYYY') D_DATE,
         t1.activity AS DYEING_YARN,
         t1.no_of_batch AS DYEING_YARN_BATCH_CNT,
         --t1.BATCH_QTY AS DYEING_YARN_BATCH_QTY,
         t2.activity AS DYEING_SEWING_THREAD,
         t2.no_of_batch AS DYEING_SEWING_THREAD_BATCH_CNT,
         --T2.BATCH_QTY AS DYEING_SEWING_THREAD_BATCH_QTY,
         t3.activity AS DYEING_YARN_FIBER,
         t3.no_of_batch AS DYEING_YARN_FIBER_BATCH_CNT
         --T3.BATCH_QTY AS DYEING_YARN_FIBER_BATCH_QTY
    FROM TmpDate t
         LEFT OUTER JOIN TmpProductionReport01 t1
            ON TRUNC (t.D_DATE) = TRUNC (t1.ACTUAL_CMPLT_DATE)
         LEFT OUTER JOIN TmpProductionReport02 t2
            ON TRUNC (t.D_DATE) = TRUNC (t2.ACTUAL_CMPLT_DATE)
         LEFT OUTER JOIN TmpProductionReport03 t3
            ON TRUNC (t.D_DATE) = TRUNC (t3.ACTUAL_CMPLT_DATE)
ORDER BY t.D_DATE