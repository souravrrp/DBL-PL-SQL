/* Formatted on 1/31/2022 5:00:34 PM (QP5 v5.374) */
CREATE OR REPLACE PROCEDURE APPS.xxdbl_gl_aloc_basis_upload_prc (
    x_retcode      OUT NOCOPY NUMBER,
    x_errbuf       OUT NOCOPY VARCHAR2)
IS
    CURSOR cur_stg IS
        SELECT pw.ROWID rx, pw.*
          FROM xxdbl_gl_aloc_basis_upload_stg pw
         WHERE     1 = 1
               AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas         b,
                               mtl_system_items_b  msib,
                               gl_aloc_mst         m
                         WHERE     b.organization_id = 150
                               AND b.organization_id = msib.organization_id
                               AND b.inventory_item_id =
                                   msib.inventory_item_id
                               AND b.alloc_id = m.alloc_id
                               AND m.alloc_code = pw.alloc_code
                               AND msib.segment1 = pw.item_code)
               AND NVL (pw.status, 'X') NOT IN ('I', 'E');

    l_organization_code    VARCHAR2 (10 BYTE);
    l_item_code            VARCHAR2 (100 BYTE);
    l_alloc_code           VARCHAR2 (100 BYTE);
    l_basis_type           VARCHAR2 (100 BYTE);
    l_cost_analysis_code   VARCHAR2 (10 BYTE);
    l_status               VARCHAR2 (10 BYTE);
    l_status_message       VARCHAR2 (240 BYTE);
    l_error                VARCHAR2 (240 BYTE);
BEGIN
    FOR r IN cur_stg
    LOOP
        BEGIN
            l_organization_code := r.organization_code;
            l_item_code := r.item_code;
            l_alloc_code := r.alloc_code;
            l_basis_type := r.basis_type;
            l_cost_analysis_code := r.cost_analysis_code;
            l_status := r.status;
            l_status_message := r.status_message;

            INSERT INTO gl_aloc_bas (alloc_id,
                                     line_no,
                                     alloc_method,
                                     fixed_percent,
                                     cmpntcls_id,
                                     analysis_code,
                                     whse_code,
                                     creation_date,
                                     created_by,
                                     last_update_date,
                                     last_updated_by,
                                     last_update_login,
                                     trans_cnt,
                                     text_code,
                                     delete_mark,
                                     basis_account_id,
                                     basis_type,
                                     inventory_item_id,
                                     organization_id)
                     VALUES (
                                (SELECT alloc_id
                                   FROM gl_aloc_mst
                                  WHERE UPPER (alloc_code) =
                                        UPPER (l_alloc_code)),
                                (  NVL (
                                       (SELECT MAX (line_no)       --COUNT (*)
                                          FROM gl_aloc_bas
                                         WHERE alloc_id =
                                               (SELECT alloc_id
                                                  FROM gl_aloc_mst
                                                 WHERE UPPER (alloc_code) =
                                                       UPPER (l_alloc_code))),
                                       0)
                                 + 1),
                                1,
                                0,
                                (SELECT cost_cmpntcls_id
                                   FROM cm_cmpt_mst
                                  WHERE     delete_mark = 0
                                        AND usage_ind = 4
                                        AND UPPER (cost_cmpntcls_desc) =
                                            UPPER (l_alloc_code)),
                                (SELECT cost_analysis_code
                                   FROM cm_alys_mst
                                  WHERE     delete_mark = 0
                                        AND cost_analysis_code =
                                            l_cost_analysis_code),
                                NULL,
                                SYSDATE,
                                1130,
                                SYSDATE,
                                1130,
                                3904211,
                                0,
                                NULL,
                                0,
                                NULL,
                                1,
                                (SELECT inventory_item_id
                                   FROM mtl_system_items_kfv
                                  WHERE     concatenated_segments =
                                            l_item_code
                                        AND ROWNUM = 1),
                                (SELECT organization_id
                                   FROM mtl_parameters
                                  WHERE organization_code =
                                        l_organization_code));

            UPDATE xxdbl_gl_aloc_basis_upload_stg pw
               SET pw.status = 'I'
             WHERE     1 = 1
                   AND pw.alloc_code = l_alloc_code
                   AND pw.organization_code = l_organization_code
                   AND pw.item_code = l_item_code
                   AND pw.status IS NULL;
        EXCEPTION
            WHEN OTHERS
            THEN
                -- ROLLBACK TO SAVEPOINT xx_item;
                l_error := SUBSTRB ('ERROR: ' || SQLERRM, 1, 4000);

                UPDATE xxdbl_gl_aloc_basis_upload_stg pw
                   SET pw.status = 'E', pw.status_message = l_error
                 WHERE     1 = 1
                       AND pw.alloc_code = l_alloc_code
                       AND pw.organization_code = l_organization_code
                       AND pw.item_code = l_item_code
                       AND pw.status IS NULL;
        END;

        COMMIT;
    END LOOP;
END xxdbl_gl_aloc_basis_upload_prc;
/
