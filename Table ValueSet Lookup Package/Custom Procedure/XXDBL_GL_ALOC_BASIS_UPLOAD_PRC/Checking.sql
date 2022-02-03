/* Formatted on 2/2/2022 10:03:33 AM (QP5 v5.374) */
SELECT pw.ROWID rx, pw.*
  FROM xxdbl_gl_aloc_basis_upload_stg pw
 WHERE     1 = 1
       AND NOT EXISTS
               (SELECT 1
                  FROM gl_aloc_bas b, mtl_system_items_b msib, gl_aloc_mst m
                 WHERE     b.organization_id = 150
                       AND b.organization_id = msib.organization_id
                       AND b.inventory_item_id = msib.inventory_item_id
                       AND b.alloc_id = m.alloc_id
                       AND m.alloc_code = pw.alloc_code
                       AND msib.segment1 = pw.item_code) --Updated By Sourav 010222
       AND NVL (pw.status, 'X') NOT IN ('I', 'E');