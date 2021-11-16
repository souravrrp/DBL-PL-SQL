/* Formatted on 11/15/2021 3:48:45 PM (QP5 v5.365) */
SELECT gbh.batch_no batch_number, gmd.*
  FROM gme.gme_batch_header               gbh,
       gme.gme_material_details           gmd,
       gme.gme_batch_steps                gbs,
       apps.org_organization_definitions  ood
 WHERE     1 = 1
       AND gbh.batch_id = gmd.batch_id
       AND gbh.batch_id = gbs.batch_id
       AND gmd.organization_id = ood.organization_id
       --AND gbh.batch_id = 414587
       AND gmd.line_type = -1
       --AND gbs.batchstep_id = 1490025
       AND ( :p_batch_no IS NULL OR (gbh.batch_no = :p_batch_no))
       AND ( :p_line_no IS NULL OR (gmd.line_no = :p_line_no))
       AND (   :p_organization_code IS NULL
            OR (ood.organization_code = :p_organization_code));