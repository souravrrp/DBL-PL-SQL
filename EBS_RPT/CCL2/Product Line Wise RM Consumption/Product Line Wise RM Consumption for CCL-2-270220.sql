/* Formatted on 2/27/2020 4:06:34 PM (QP5 v5.287) */
SELECT
       item_code,
       description,
       major_category,
       minor_category,
       product_line,
       SUM(plan_qty) quantity,
       uom_code
FROM
(SELECT msi.segment1 AS item_code,
       msi.description,
       t.major_category,
       t.minor_category,
       t.group_name product_line,
       d.plan_qty,
       msi.primary_uom_code uom_code
  FROM gme.gme_batch_header h,
       gme.gme_material_details d,
       apps.mtl_system_items_b msi,
       (SELECT t.batch_id,
               t.batch_no AS parent_batch,
               p.batch_no,
               bb.group_name,
               t.major_category,
               t.minor_category,
               t.transaction_date
          FROM (SELECT h.batch_id,
                       h.batch_no,
                       d.phantom_id,
                       cat.segment2 major_category,
                       cat.segment3 minor_category,
                       mmt.transaction_date
                  FROM gme.gme_batch_header h,
                       apps.gme_material_details d,
                       apps.mtl_item_categories_v cat,
                       mtl_material_transactions mmt
                 WHERE     h.batch_id = d.batch_id
                       AND h.batch_id = mmt.transaction_source_id
                       AND d.inventory_item_id = cat.inventory_item_id
                       AND d.organization_id = cat.organization_id
                       AND (cat.segment2 in (  'SEMI FINISH GOODS') and  cat.segment2 not in ( 'NA'))
                       --AND h.batch_no IN (    SELECT REGEXP_SUBSTR (:p_batch, '[^,]+', 1, LEVEL) AS batch_no FROM DUAL CONNECT BY REGEXP_SUBSTR (:p_batch, '[^,]+', 1, LEVEL) IS NOT NULL) 
                                             AND (   :p_date_from IS NULL OR TRUNC (mmt.transaction_date) BETWEEN :p_date_from AND :p_date_to)
                                                         ) t
               LEFT OUTER JOIN gme.gme_batch_header p
                  ON NVL (p.batch_id, 0) = NVL (t.phantom_id, 0)
               INNER JOIN gme_batch_groups_association ga
                  ON t.batch_id = ga.batch_id
               INNER JOIN gme_batch_groups_b bb ON ga.GROUP_ID = bb.GROUP_ID --WHERE bb.group_name = 'SEWING THREAD'
                                                                            )
       t
 WHERE     h.batch_id = d.batch_id
       AND h.batch_no = t.batch_no
       AND msi.inventory_item_id = d.inventory_item_id
       AND msi.organization_id = d.organization_id
       AND line_type = -1
       AND d.plan_qty IS NOT NULL
       AND d.organization_id = 150
UNION
SELECT msi.segment1 AS item_code,
       msi.description,
       cat.segment2 major_category,
       cat.segment3 minor_category,
       bb.group_name,
       d.plan_qty,
       msi.primary_uom_code
  FROM gme.gme_batch_header h,
       gme.gme_material_details d,
       apps.mtl_system_items_b msi,
       apps.mtl_item_categories_v cat,
       gme_batch_groups_association ga,
       gme_batch_groups_b bb,
       mtl_material_transactions mmt
 WHERE     h.batch_id = d.batch_id
       AND msi.inventory_item_id = d.inventory_item_id
       AND msi.organization_id = d.organization_id
       AND msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND h.batch_id = ga.batch_id
       AND ga.GROUP_ID = bb.GROUP_ID
       AND d.organization_id = 150
       AND cat.SEGMENT2 = 'RAW MATERIAL'
       AND line_type = -1
       AND d.plan_qty IS NOT NULL
       AND h.batch_id = mmt.transaction_source_id
       --AND h.batch_no IN (    SELECT REGEXP_SUBSTR (:p_batch, '[^,]+', 1, LEVEL) AS batch_no FROM DUAL CONNECT BY REGEXP_SUBSTR (:p_batch, '[^,]+', 1, LEVEL) IS NOT NULL)
       AND (   :p_date_from IS NULL OR TRUNC (mmt.transaction_date) BETWEEN :p_date_from AND :p_date_to))
       GROUP BY
               item_code,
               description,
               major_category,
               minor_category,
               product_line,
               uom_code
       