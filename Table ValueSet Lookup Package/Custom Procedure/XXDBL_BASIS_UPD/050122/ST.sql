/* Formatted on 1/13/2022 3:03:39 PM (QP5 v5.374) */
SELECT '193'             organization_code,
       msib.segment1     item_code,
       mst.alloc_code,
       'Fixed%'          basis_type,
       'IND'             cost_analysis_code,
       NULL              status,
       NULL              status_id,
       NULL              set_proc_id
  FROM mtl_system_items_b msib, gl_aloc_mst mst
 WHERE     msib.organization_id = 150
       AND msib.item_type IN ('SEWING THREAD')
       AND mst.legal_entity_id = 23277
       AND mst.alloc_code LIKE 'ST%'
       AND EXISTS
               (SELECT 1
                  FROM gl_aloc_bas gab
                 WHERE     gab.organization_id = 150
                       AND msib.inventory_item_id <> gab.inventory_item_id)
       --AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 150)
       --AND msib.segment1 NOT IN (SELECT item_code FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg WHERE organization_id = 150)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg stg
                 WHERE     msib.organization_id = 150
                       AND msib.segment1 <> stg.item_code);


DROP TABLE XXDBL.XXDBL_GL_ALOC_BASIS_9122;

CREATE TABLE XXDBL.XXDBL_GL_ALOC_BASIS_STG_BKP
AS
    SELECT * FROM XXDBL.XXDBL_GL_ALOC_BASIS_UPLOAD_STG;