/* Formatted on 1/31/2022 2:43:04 PM (QP5 v5.374) */
CREATE OR REPLACE PROCEDURE APPS.xxdbl_basis_upd (
    x_retcode      OUT NOCOPY NUMBER,
    x_errbuf       OUT NOCOPY VARCHAR2)
IS
    CURSOR c IS
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
               AND msib.inventory_item_id NOT IN
                       (SELECT inventory_item_id
                          FROM gl_aloc_bas
                         WHERE organization_id = 150)
               AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl_gl_aloc_basis_upload_stg
                         WHERE organization_id = 150)
        -- 30256/3782 = 8
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
               AND msib.inventory_item_id NOT IN
                       (SELECT inventory_item_id
                          FROM gl_aloc_bas
                         WHERE organization_id = 150)
               AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl_gl_aloc_basis_upload_stg
                         WHERE organization_id = 150)
        UNION
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
               AND msib.inventory_item_id NOT IN
                       (SELECT inventory_item_id
                          FROM gl_aloc_bas
                         WHERE organization_id = 150)
               AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl_gl_aloc_basis_upload_stg
                         WHERE organization_id = 150);

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
