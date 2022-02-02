/* Formatted on 2/1/2022 12:08:37 PM (QP5 v5.374) */
CREATE OR REPLACE PROCEDURE APPS.xxdbl_basis_upd (
    x_retcode      OUT NOCOPY NUMBER,
    x_errbuf       OUT NOCOPY VARCHAR2)
IS
    CURSOR c IS
        --------------------------------SEWING THREAD---------------------------
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
               AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas gab
                         WHERE     gab.organization_id = msib.organization_id
                               AND gab.alloc_id = mst.alloc_id
                               AND msib.inventory_item_id =
                                   gab.inventory_item_id) --Updated By Sourav 010222
               --AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 150)
               --AND msib.segment1 NOT IN (SELECT item_code FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg WHERE organization_id = 150)
               AND NOT EXISTS
                       (SELECT 1
                          FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg stg
                         WHERE     1 = 1
                               AND mst.alloc_code = stg.alloc_code
                               AND stg.organization_code = '193'
                               AND msib.segment1 = stg.item_code) --Updated By Sourav 010222
        --------------------------------DYED YARN-------------------------------
        UNION
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
               AND msib.item_type IN ('DYED YARN')
               AND mst.legal_entity_id = 23277
               AND mst.alloc_code LIKE 'YD%'
               AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas gab
                         WHERE     gab.organization_id = msib.organization_id
                               AND gab.alloc_id = mst.alloc_id
                               AND msib.inventory_item_id =
                                   gab.inventory_item_id) --Updated By Sourav 010222
               --AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 150)
               --AND msib.segment1 NOT IN (SELECT item_code FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg WHERE organization_id = 150)
               AND NOT EXISTS
                       (SELECT 1
                          FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg stg
                         WHERE     1 = 1
                               AND mst.alloc_code = stg.alloc_code
                               AND stg.organization_code = '193'
                               AND msib.segment1 = stg.item_code) --Updated By Sourav 010222
        UNION
        --------------------------------DYED FIBER------------------------------
        SELECT '193'             organization_code,
               msib.segment1     item_code,
               mst.alloc_code,
               'Fixed%'          basis_type,
               'IND'             cost_analysis_code,
               NULL              staus,
               NULL              status_id,
               NULL              set_proc_id
          FROM mtl_system_items_b msib, gl_aloc_mst mst
         WHERE     msib.organization_id = 150
               AND msib.item_type IN ('DYED FIBER')
               AND mst.legal_entity_id = 23277
               AND mst.alloc_code LIKE 'FD%'
               AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas gab
                         WHERE     gab.organization_id = msib.organization_id
                               AND gab.alloc_id = mst.alloc_id
                               AND msib.inventory_item_id =
                                   gab.inventory_item_id) --Updated By Sourav 010222
               --AND msib.inventory_item_id NOT IN (SELECT inventory_item_id FROM gl_aloc_bas WHERE organization_id = 150)
               --AND msib.segment1 NOT IN (SELECT item_code FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg WHERE organization_id = 150)
               AND NOT EXISTS
                       (SELECT 1
                          FROM xxdbl.xxdbl_gl_aloc_basis_upload_stg stg
                         WHERE     1 = 1
                               AND mst.alloc_code = stg.alloc_code
                               AND stg.organization_code = '193'
                               AND msib.segment1 = stg.item_code) --Updated By Sourav 010222
                                                                 ;


    r   c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put_line (r.set_proc_id);

    OPEN c;

    LOOP
        FETCH c INTO r;

        EXIT WHEN c%NOTFOUND;

        INSERT INTO xxdbl_gl_aloc_basis_upload_stg (organization_code,
                                                    item_code,
                                                    alloc_code,
                                                    basis_type,
                                                    cost_analysis_code,
                                                    set_proc_id)
             VALUES (r.organization_code,
                     r.item_code,
                     r.alloc_code,
                     r.basis_type,
                     r.cost_analysis_code,
                     r.set_proc_id);
    END LOOP;

    CLOSE c;
END;
/
