/* Formatted on 10/3/2020 3:59:08 PM (QP5 v5.287) */
--Existing Procedure
--xxdbl_basis_upd
--xxdbl_gl_aloc_basis_upload_prc
--DROP PACKAGE APPS.XXDBL_ITEM_ALLOC_BASIS_PKG;
--DROP PACKAGE BODY APPS.XXDBL_ITEM_ALLOC_BASIS_PKG;
---Existing Query-------------------------------------------------------------------------------------------------

SELECT '193' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 150
       AND msib.item_type IN ('SEWING THREAD')
       AND mst.legal_entity_id = 23277
       AND mst.alloc_code LIKE 'ST%'
       AND msib.inventory_item_id NOT IN (SELECT inventory_item_id
                                            FROM gl_aloc_bas
                                           WHERE organization_id = 150)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl_gl_aloc_basis_upload_stg
                                  WHERE organization_id = 150)
-- 30256/3782 = 8
UNION
SELECT '193' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 150
       AND msib.item_type IN ('DYED YARN')
       AND mst.legal_entity_id = 23277
       AND mst.alloc_code LIKE 'YD%'
       AND msib.inventory_item_id NOT IN (SELECT inventory_item_id
                                            FROM gl_aloc_bas
                                           WHERE organization_id = 150)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl_gl_aloc_basis_upload_stg
                                  WHERE organization_id = 150)
UNION
SELECT '193' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL staus,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 150
       AND msib.item_type IN ('DYED FIBER')
       AND mst.legal_entity_id = 23277
       AND mst.alloc_code LIKE 'FD%'
       AND msib.inventory_item_id NOT IN (SELECT inventory_item_id
                                            FROM gl_aloc_bas
                                           WHERE organization_id = 150)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl_gl_aloc_basis_upload_stg
                                  WHERE organization_id = 150);

---Updated Query-------------------------------------------------------------------------------------------------

/*
SELECT '251' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 152
       AND msib.segment1 LIKE 'FT%'
       AND mst.legal_entity_id = 23282
       AND mst.alloc_code LIKE '%FT%'
       AND NOT EXISTS
              (SELECT 1
                 FROM gl_aloc_bas x
                WHERE     x.organization_id = 152
                      AND msib.inventory_item_id = X.inventory_item_id)
       --AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 152)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                                  WHERE stg.organization_code = 251);
                                  
                                  

SELECT '251'             organization_code,
       msib.segment1     item_code,
       mst.alloc_code,
       'Fixed%'          basis_type,
       'IND'             cost_analysis_code,
       NULL              status,
       NULL              status_id,
       NULL              set_proc_id
  FROM mtl_system_items_b          msib,
       gl_aloc_mst                 mst,
       apps.mtl_item_categories_v  cat
 WHERE     msib.organization_id = 152
       AND msib.inventory_item_id = cat.inventory_item_id
       AND msib.organization_id = cat.organization_id
       AND CAT.SEGMENT2 = 'FINISH GOODS'
       --AND msib.segment1 LIKE 'FG%'
       AND mst.legal_entity_id = 23282
       --AND mst.alloc_code LIKE '%FG%'
       AND mst.alloc_code NOT LIKE '%FT%'
       AND NOT EXISTS
               (SELECT 1
                  FROM gl_aloc_bas x
                 WHERE     x.organization_id = 152
                       AND msib.inventory_item_id = X.inventory_item_id)
--AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 152)
AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                                  WHERE stg.organization_code = 251)
;
*/

SELECT '251' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib,
       gl_aloc_mst mst,
       apps.mtl_item_categories_v cat
 WHERE     msib.organization_id = 152
       AND msib.inventory_item_id = cat.inventory_item_id
       AND msib.organization_id = cat.organization_id
       AND CAT.SEGMENT2 = 'FINISH GOODS'
       --AND msib.segment1 LIKE 'FG%'
       AND mst.legal_entity_id = 23282
       AND cat.category_set_id = 1
       --AND mst.alloc_code LIKE '%FG%'
       --AND mst.alloc_code NOT LIKE '%FT%'
       AND NOT EXISTS
              (SELECT 1
                 FROM gl_aloc_bas x
                WHERE     x.organization_id = 152
                      AND msib.inventory_item_id = X.inventory_item_id)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                                  WHERE stg.organization_code = 251);

SELECT '251' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib,
       gl_aloc_mst mst,
       apps.mtl_item_categories_v cat
 WHERE     msib.organization_id = 152
       --AND msib.segment1 LIKE 'FT%'
       AND cat.segment2 = 'SEMI FINISH GOODS'
       AND cat.category_set_id = 1
       AND msib.inventory_item_id = cat.inventory_item_id
       AND msib.organization_id = cat.organization_id
       AND mst.legal_entity_id = 23282
       --AND mst.alloc_code LIKE '%FT%'
       AND NOT EXISTS
              (SELECT 1
                 FROM gl_aloc_bas x
                WHERE     x.organization_id = 152
                      AND msib.inventory_item_id = X.inventory_item_id)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                                  WHERE stg.organization_code = 251);

/*
-- 30256/3782 = 8
UNION
SELECT '251' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL status,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 152
       --AND msib.item_type IN ('DYED YARN')
       AND mst.legal_entity_id = 23282
       --AND mst.alloc_code LIKE 'YD%'
       AND msib.inventory_item_id NOT IN (SELECT inventory_item_id
                                            FROM gl_aloc_bas
                                           WHERE organization_id = 152)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM XXDBL.XXDBL_ITEM_ALOC_BASIS_STG
                                  WHERE organization_id = 152)
UNION
SELECT '251' organization_code,
       msib.segment1 item_code,
       mst.alloc_code,
       'Fixed%' basis_type,
       'IND' cost_analysis_code,
       NULL staus,
       NULL status_id,
       NULL set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 152
       --AND msib.item_type IN ('DYED FIBER')
       AND mst.legal_entity_id = 23282
       --AND mst.alloc_code LIKE 'FD%'
       AND msib.inventory_item_id NOT IN (SELECT inventory_item_id
                                            FROM gl_aloc_bas
                                           WHERE organization_id = 152)
       AND msib.segment1 NOT IN (SELECT item_code
                                   FROM XXDBL.XXDBL_ITEM_ALOC_BASIS_STG
                                  WHERE organization_id = 152);
*/

SELECT * FROM gl_aloc_mst;

SELECT * FROM gl_aloc_bas;

SELECT * FROM XXDBL.XXDBL_ITEM_ALOC_BASIS_STG;

SELECT * FROM xxdbl_gl_aloc_basis_upload_stg;

SELECT pw.ROWID rx, pw.*
  FROM XXDBL.XXDBL_ITEM_ALOC_BASIS_STG pw
 WHERE 1 = 1 AND NVL (pw.status, 'X') NOT IN ('I', 'E');