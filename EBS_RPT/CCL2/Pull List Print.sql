SELECT item_code,
       description,
       primary_uom_code uom,
       REQUIRED_QTY,
       SF_Qty,
       main_Qty,
       CASE SIGN (REQUIRED_QTY - SF_Qty)
          WHEN 1 THEN REQUIRED_QTY - SF_Qty
          ELSE 0
       END
          TSFR_QTY
  FROM (  SELECT inventory_item_id,
                 item_code,
                 description,
                 primary_uom_code,
                 SUM (SF_Qty) SF_QTY,
                 SUM (main_Qty) main_qty
            FROM (  SELECT a.inventory_item_id,
                           b.segment1 item_code,
                           b.description,
                           b.primary_uom_code,
                           CASE
                              WHEN SUBINVENTORY_CODE NOT IN
                                         ('CCL2-DC-FL',
                                          'CCL2-RM-FL',
                                          'CCL2-SF FL',
                                          'CCL2-YF-FL',
                                          'PACK-SFLR')
                              THEN
                                 SUM (transaction_quantity)
                              ELSE
                                 0
                           END
                              main_Qty,
                           CASE
                              WHEN SUBINVENTORY_CODE = 'CCL2-DC-FL'
                              THEN
                                 SUM (transaction_quantity)
                              WHEN SUBINVENTORY_CODE = 'CCL2-RM-FL'
                              THEN
                                 SUM (transaction_quantity)
                              WHEN SUBINVENTORY_CODE = 'CCL2-SF FL'
                              THEN
                                 SUM (transaction_quantity)
                              WHEN SUBINVENTORY_CODE = 'CCL2-YF-FL'
                              THEN
                                 SUM (transaction_quantity)
                              WHEN SUBINVENTORY_CODE = 'PACK-SFLR'
                              THEN
                                 SUM (transaction_quantity)
                              ELSE
                                 0
                           END
                              SF_Qty
                      FROM mtl_onhand_quantities A,
                           mtl_system_items_kfv b,
                           mtl_item_categories_v mic
                     WHERE     a.inventory_item_id = b.inventory_item_id
                           AND a.organization_id = b.organization_id
                           AND mic.inventory_item_id = b.inventory_item_id
                           AND mic.organization_id = b.organization_id
                           AND a.ORGANIZATION_ID = 150
                           AND mic.category_set_id = 1
                           AND mic.segment2 IN
                                    ('RAW MATERIAL', 'PACKING MATERIAL')
                                    AND  mic.segment3 NOT IN ('DYES','CHEMICAL')
                  -- AND b.segment1 = 'GT001SSPA025-GGGGGGG'
                  GROUP BY a.inventory_item_id,
                           b.segment1,
                           SUBINVENTORY_CODE,
                           b.description,
                           b.primary_uom_code)
        GROUP BY inventory_item_id,
                 item_code,
                 description,
                 primary_uom_code) itm,
       (  SELECT d.inventory_item_id,
                 SUM (NVL (d.WIP_PLAN_QTY, d.plan_qty))
                 - NVL (SUM (d.ACTUAL_QTY), 0)
                    AS REQUIRED_QTY
            FROM gme.GME_BATCH_HEADER H, gme.gme_material_details D
           WHERE     h.batch_id = d.batch_id
                 AND line_type = -1
                 AND h.organization_id = 150
                 AND BATCH_STATUS IN (1, 2)
                 AND d.plan_qty IS NOT NULL
                 AND batch_no IN
                          (SELECT Batch_no
                             FROM gme.GME_BATCH_HEADER
                            WHERE batch_id IN
                                        (SELECT PHANTOM_ID
                                           FROM gme.GME_BATCH_HEADER h,
                                                apps.gme_material_details d
                                          WHERE H.Batch_ID = D.Batch_ID
                                                AND batch_no IN
                                                         (SELECT batch_no
                                                            FROM gme.GME_BATCH_HEADER))
                           UNION
                           SELECT Batch_no
                             FROM gme.GME_BATCH_HEADER a,
                                  gme.gme_material_details b,
                                  mtl_item_categories_v mic
                            WHERE a.batch_id = b.batch_id
                                  AND B.inventory_item_id =
                                        mic.inventory_item_id
                                  AND B.organization_id = mic.organization_id
                                  AND a.organization_id = mic.organization_id
                                  AND BATCH_STATUS IN (1, 2)
                                  AND mic.category_set_id = 1
                                  AND SEGMENT3 IN ('DYED YARN', 'DYED FIBER'))
        GROUP BY d.inventory_item_id) b
 WHERE b.inventory_item_id = itm.inventory_item_id
 AND item_code='GT001SSPA030-GGGGGGG'