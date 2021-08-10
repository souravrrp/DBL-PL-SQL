/* Formatted on 8/27/2020 11:07:20 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_ITEM_ALLOC_BASIS_PKG
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 26-AUG-2020
   -- LAST UPDATE DATE :27-AUG-2020
   -- PURPOSE : Update GL Item Allocation Basis
   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      L_RETURN_STATUS   VARCHAR2 (1);

      CURSOR c
      IS
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
                AND msib.inventory_item_id NOT IN
                       (SELECT inventory_item_id
                          FROM gl_aloc_bas
                         WHERE organization_id = 150)
                AND msib.segment1 NOT IN
                       (SELECT item_code
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
                AND msib.inventory_item_id NOT IN
                       (SELECT inventory_item_id
                          FROM gl_aloc_bas
                         WHERE organization_id = 150)
                AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl_gl_aloc_basis_upload_stg
                         WHERE organization_id = 150);

      r                 c%ROWTYPE;
   BEGIN
      DBMS_OUTPUT.put_line (r.set_proc_id);

      OPEN c;

      LOOP
         FETCH c INTO r;

         EXIT WHEN c%NOTFOUND;

         INSERT INTO XXDBL.XXDBL_ITEM_ALOC_BASIS_STG (organization_code,
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

         IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
            OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
         THEN
            DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
            FND_FILE.put_line (
               FND_FILE.LOG,
               '--------------Unexpected errors found!--------------------');
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         FND_FILE.put_line (
            FND_FILE.LOG,
            'Error while inserting records into Staging table.' || SQLERRM);

         CLOSE c;

         RETURN 0;
   END;

   PROCEDURE item_basis_upd (ERRBUF       OUT NOCOPY NUMBER,
                             RETCODE      OUT NOCOPY VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_import_data;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);

         BEGIN
            gl_aloc_basis_proc;
            COMMIT;
         END;
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END item_basis_upd;

   PROCEDURE gl_aloc_basis_proc
   IS
      CURSOR cur_stg
      IS
         SELECT pw.ROWID rx, pw.*
           FROM xxdbl_gl_aloc_basis_upload_stg pw
          WHERE 1 = 1 AND NVL (pw.status, 'X') NOT IN ('I', 'E');

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
                                    (SELECT MAX (line_no)          --COUNT (*)
                                       FROM gl_aloc_bas
                                      WHERE alloc_id =
                                               (SELECT alloc_id
                                                  FROM gl_aloc_mst
                                                 WHERE UPPER (
                                                          alloc_code) =
                                                          UPPER (
                                                             l_alloc_code))),
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
                                WHERE     concatenated_segments = l_item_code
                                      AND ROWNUM = 1),
                              (SELECT organization_id
                                 FROM mtl_parameters
                                WHERE organization_code = l_organization_code));

            UPDATE XXDBL.XXDBL_ITEM_ALOC_BASIS_STG PW
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
   END gl_aloc_basis_proc;
END XXDBL_ITEM_ALLOC_BASIS_PKG;
/