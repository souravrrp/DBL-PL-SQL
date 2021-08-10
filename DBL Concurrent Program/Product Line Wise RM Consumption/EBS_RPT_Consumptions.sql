/* Formatted on 2/27/2020 10:16:34 AM (QP5 v5.287) */
SELECT 3 AS type_id,
       t.batch_id,
       t.parent_batch,
       d.line_no,
       msi.segment1 AS item_code,
       msi.description,
       d.plan_qty,
       msi.primary_uom_code,
       'Block_5_Material',
       i_printflag
  FROM gme.gme_batch_header h,
       gme.gme_material_details d,
       apps.mtl_system_items_b msi,
       (SELECT t.batch_id, t.batch_no AS parent_batch, p.batch_no
          FROM (SELECT h.batch_id, h.batch_no, d.phantom_id
                  FROM gme.gme_batch_header h, apps.gme_material_details d
                 WHERE     h.batch_id = d.batch_id
                       AND h.batch_no IN (    SELECT REGEXP_SUBSTR (p_batch,
                                                                    '[^,]+',
                                                                    1,
                                                                    LEVEL)
                                                        AS batch_no
                                                FROM DUAL
                                          CONNECT BY REGEXP_SUBSTR (p_batch,
                                                                    '[^,]+',
                                                                    1,
                                                                    LEVEL)
                                                        IS NOT NULL)) t
               LEFT OUTER JOIN gme.gme_batch_header p
                  ON NVL (p.batch_id, 0) = NVL (t.phantom_id, 0)
               INNER JOIN gme_batch_groups_association ga
                  ON t.batch_id = ga.batch_id
               INNER JOIN gme_batch_groups_b bb ON ga.GROUP_ID = bb.GROUP_ID
         WHERE bb.group_name = 'SEWING THREAD') t
 WHERE     h.batch_id = d.batch_id
       AND h.batch_no = t.batch_no
       AND msi.inventory_item_id = d.inventory_item_id
       AND msi.organization_id = d.organization_id
       AND line_type = -1
       AND d.plan_qty IS NOT NULL
       AND d.organization_id = 150
UNION
SELECT 3 AS type_id,
       h.batch_id,
       h.batch_no,
       d.line_no,
       msi.segment1 AS item_code,
       msi.description,
       d.plan_qty,
       msi.primary_uom_code,
       'Block_5_Material',
       i_printflag
  FROM gme.gme_batch_header h,
       gme.gme_material_details d,
       apps.mtl_system_items_b msi,
       gme_batch_groups_association ga,
       gme_batch_groups_b bb
 WHERE     h.batch_id = d.batch_id
       AND msi.inventory_item_id = d.inventory_item_id
       AND msi.organization_id = d.organization_id
       AND h.batch_id = ga.batch_id
       AND ga.GROUP_ID = bb.GROUP_ID
       AND d.organization_id = 150
       AND line_type = -1
       AND d.plan_qty IS NOT NULL
       AND bb.group_name IN ('YARN',
                             'SY',
                             'FIBER',
                             'FD')
       --AND h.batch_no IN (    SELECT REGEXP_SUBSTR (p_batch,'[^,]+', 1, LEVEL) AS batch_no FROM DUAL CONNECT BY REGEXP_SUBSTR (p_batch, '[^,]+', 1, LEVEL) IS NOT NULL);
       AND h.batch_no IN (    SELECT REGEXP_SUBSTR (p_batch,
                                                    '[^,]+',
                                                    1,
                                                    LEVEL)
                                        AS batch_no
                                FROM DUAL
                          CONNECT BY REGEXP_SUBSTR (p_batch,
                                                    '[^,]+',
                                                    1,
                                                    LEVEL)
                                        IS NOT NULL);