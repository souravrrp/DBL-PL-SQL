/* Formatted on 10/14/2020 9:51:42 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.XXDBL_CER_ITEM_UPLD_PKG
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 26-AUG-2020
   -- LAST UPDATE DATE :27-AUG-2020
   -- PURPOSE : Update GL Item Allocation Basis
   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
      L_RETURN_STATUS   VARCHAR2 (1);
      l_sl_no           NUMBER;

      CURSOR cur_stg
      IS
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
                AND mst.alloc_code LIKE '%FG%'
                AND mst.alloc_code NOT LIKE '%FT%'
                AND msib.segment1 = 'FT-GP6060-044P'
                AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas x
                         WHERE     x.organization_id = 152
                               AND msib.inventory_item_id =
                                      X.inventory_item_id)
                AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                         WHERE stg.organization_code = 251)
         UNION
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
                AND mst.alloc_code LIKE '%FT%'
                AND msib.segment1 = 'FT-GP6060-044P'
                AND NOT EXISTS
                       (SELECT 1
                          FROM gl_aloc_bas x
                         WHERE     x.organization_id = 152
                               AND msib.inventory_item_id =
                                      X.inventory_item_id)
                AND msib.segment1 NOT IN
                       (SELECT item_code
                          FROM xxdbl.xxdbl_item_aloc_basis_stg stg
                         WHERE stg.organization_code = 251);
   BEGIN
      FOR ln_cur_stg IN cur_stg
      LOOP
         BEGIN
            L_RETURN_STATUS := NULL;
            --SELECT ra_customer_trx_lines_s.CURRVAL INTO vl_interface_line_id FROM DUAL;
            l_sl_no := XXDBL.XXDBL_ITM_ALOC_BS_S.NEXTVAL;


            INSERT INTO XXDBL.XXDBL_ITEM_ALOC_BASIS_STG (organization_code,
                                                         item_code,
                                                         alloc_code,
                                                         basis_type,
                                                         cost_analysis_code,
                                                         set_proc_id,
                                                         sl_no,
                                                         creation_date,
                                                         created_by)
                 VALUES (ln_cur_stg.organization_code,
                         ln_cur_stg.item_code,
                         ln_cur_stg.alloc_code,
                         ln_cur_stg.basis_type,
                         ln_cur_stg.cost_analysis_code,
                         ln_cur_stg.set_proc_id,
                         l_sl_no,
                         SYSDATE,
                         p_user_id);

            COMMIT;

            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
               DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
               FND_FILE.put_line (
                  FND_FILE.LOG,
                  '--------------Unexpected errors found!--------------------');
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.put_line (
                  FND_FILE.LOG,
                     'Error while inserting records into Interface lines table.'
                  || SQLERRM);
         END;
      END LOOP;

      RETURN 0;
   END;

   PROCEDURE ITEM_BASIS_UPD (ERRBUF       OUT NOCOPY NUMBER,
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
           FROM XXDBL.XXDBL_ITEM_ALOC_BASIS_STG pw
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

               UPDATE XXDBL.XXDBL_ITEM_ALOC_BASIS_STG pw
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

   PROCEDURE formula_upload_prc (errbuf              OUT VARCHAR2,
                                 retcode             OUT NUMBER,
                                 p_batch_number   IN     NUMBER)
   IS
      xxdbl_fml_tabtype         gmd_formula_pub.formula_insert_hdr_tbl_type;
      owner_id                  NUMBER;

      CURSOR c1_main
      IS
         SELECT DISTINCT formula_no
           FROM XXDBL_CER_FORMULA_UPD_STG
          WHERE     1 = 1
                AND NVL (verify_flag, 'N') = 'N'
                AND NVL (batch_number, -1) =
                       NVL (p_batch_number, NVL (batch_number, -1));

      CURSOR c1 (
         p_formula_no   IN VARCHAR2)
      IS
         SELECT xxdbl.formula_no,
                xxdbl.formula_vers,
                xxdbl.formula_desc1,
                xxdbl.formula_class,
                NVL (xxdbl.inactive_ind, 0) inactive_ind,
                ood.organization_id,
                DECODE (xxdbl.formula_type, 'Yes', 1, 0) formula_type,
                DECODE (xxdbl.formula_status,
                        'Approved for General Use', 700,
                        700)
                   formula_status,
                xxdbl.owner_code,
                DECODE (UPPER (xxdbl.line_type),
                        'PRODUCT', 1,
                        'INGREDIENT', -1,
                        2)
                   line_type,
                xxdbl.line_no,
                xxdbl.item_no,
                xxdbl.qty,
                xxdbl.detail_uom,
                (TO_NUMBER (NVL (xxdbl.scrap_factor, 0)) / 100) scrap_factor,
                TO_NUMBER (
                   DECODE (UPPER (xxdbl.scale_type_hdr), 'YES', 1, 0))
                   scale_type_hdr,
                TO_NUMBER (
                   DECODE (UPPER (xxdbl.scale_type_hdr), 'YES', 1, 0))
                   scale_type_dtl,
                xxdbl.cost_alloc,
                DECODE (UPPER (xxdbl.by_product_type),
                        'SAMPLE', 'S',
                        'REWORK', 'R',
                        'WASTE', 'W',
                        'YIELD', 'Y')
                   by_product_type,
                DECODE (UPPER (xxdbl.contribute_yield_ind), 'YES', 'Y', 'N')
                   contribute_yield_ind,
                DECODE (UPPER (xxdbl.contribute_step_qty_ind),
                        'YES', 'Y',
                        'N')
                   contribute_step_qty_ind,
                DECODE (
                   UPPER (xxdbl.line_type),
                   'PRODUCT', 1,
                   DECODE (UPPER (xxdbl.prod_or_ingr_scale_type),
                           'PROPORTIONAL', 1,
                           'FIXED', 0,
                           'INTEGER', 2,
                           1))
                   prod_or_ingr_scale_type,
                DECODE (
                   UPPER (
                      (SUBSTR (xxdbl.yield_or_consumption_type,
                               1,
                               (LENGTH (xxdbl.yield_or_consumption_type))))),
                   'AUTOMATIC', 0,
                   'MANUAL', 1,
                   'INCREMENTAL', 2,
                   'AUTOMATIC BY STEP', 3)
                   yield_or_consumption_type,
                xxdbl.attribute3,
                xxdbl.attribute1 comments,
                xxdbl.dtl_attribute1,
                xxdbl.scale_multiple,
                xxdbl.rounding_direction,
                xxdbl.scale_rounding_variance,
                NVL (xxdbl.phantom_type, 0) phantom_type
           FROM XXDBL_CER_FORMULA_UPD_STG xxdbl,
                org_organization_definitions ood
          WHERE     xxdbl.owner_organization_code = ood.organization_code
                AND xxdbl.formula_no = p_formula_no
                AND NVL (xxdbl.verify_flag, 'N') != 'Y'
                AND NVL (batch_number, -1) =
                       NVL (p_batch_number, NVL (batch_number, -1));

      CURSOR c2 (
         p_formula_no   IN VARCHAR2)
      IS
         SELECT DISTINCT formula_no, formula_vers, attribute3
           FROM XXDBL_CER_FORMULA_UPD_STG
          WHERE     attribute3 IS NOT NULL
                AND formula_no = p_formula_no
                AND NVL (batch_number, -1) =
                       NVL (p_batch_number, NVL (batch_number, -1));

      CURSOR c3 (
         p_formula_no   IN VARCHAR2)
      IS
         SELECT formula_no,
                formula_vers,
                line_no,
                by_product_type
           FROM XXDBL_CER_FORMULA_UPD_STG
          WHERE     1 = 1
                AND formula_no = p_formula_no
                AND line_type LIKE '%By%'
                AND NVL (batch_number, -1) =
                       NVL (p_batch_number, NVL (batch_number, -1));


      CURSOR c4 (
         p_formula_no   IN VARCHAR2)
      IS
           SELECT formula_no,
                  formula_vers,
                  line_no,
                  by_product_type,
                  dtl_attribute1,
                  dtl_attribute2,
                  item_no
             FROM XXDBL_CER_FORMULA_UPD_STG
            WHERE     1 = 1
                  AND formula_no = p_formula_no
                  AND line_type = 'INGREDIENT'
                  AND NVL (batch_number, -1) =
                         NVL (p_batch_number, NVL (batch_number, -1))
         ORDER BY line_no;


      cnt                       NUMBER;
      l_return_status           VARCHAR2 (1);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (1000);
      l_out_index               NUMBER := 0;
      l_user_id                 NUMBER;
      l_responsibility_id       NUMBER;
      l_responsibility_app_id   NUMBER;
      x_routing_upd_msg         VARCHAR2 (4000) := NULL;
      l_recipe_id_count         NUMBER := 0;
   BEGIN
      l_user_id := fnd_profile.VALUE ('USER_ID');
      l_responsibility_id := fnd_profile.VALUE ('RESP_ID');
      l_responsibility_app_id := fnd_profile.VALUE ('RESP_APPL_ID');
      fnd_file.put_line (fnd_file.LOG, 'Initializing......');
      fnd_file.put_line (fnd_file.LOG, 'User Id : ' || l_user_id);
      fnd_file.put_line (fnd_file.LOG,
                         'Responsibility Id : ' || l_responsibility_id);
      fnd_file.put_line (
         fnd_file.LOG,
         'Responsibility Appl Id : ' || l_responsibility_app_id);

      fnd_global.apps_initialize (l_user_id, 22882, 552);

      FOR x1 IN c1_main
      LOOP
         BEGIN
            fnd_file.put_line (
               fnd_file.LOG,
               '---------------------------------------------------------------------------------------------------- ');
            fnd_file.put_line (fnd_file.LOG,
                               'Processing for formula: ' || x1.formula_no);
            fnd_file.put_line (
               fnd_file.LOG,
               '---------------------------------------------------------------------------------------------------- ');
            cnt := 0;
            xxdbl_fml_tabtype.DELETE;

            FOR i IN c1 (x1.formula_no)
            LOOP
               BEGIN
                  SELECT user_id
                    INTO owner_id
                    FROM fnd_user
                   WHERE UPPER (TRIM (user_name)) =
                            UPPER (TRIM (i.owner_code));
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     fnd_file.put_line (fnd_file.LOG, 'Invalid Owner.... ');
               END;

               DBMS_OUTPUT.put_line (
                  'Owner ID is - ' || owner_id || '-' || i.owner_code); /*NEW LINE FOR TEST*/
               fnd_file.put_line (
                  fnd_file.LOG,
                     'yield_or_consumption_type->'
                  || i.yield_or_consumption_type);
               cnt := cnt + 1;
               xxdbl_fml_tabtype (cnt).formula_no := TRIM (i.formula_no);
               xxdbl_fml_tabtype (cnt).formula_vers := i.formula_vers;
               xxdbl_fml_tabtype (cnt).formula_class := i.formula_class;
               xxdbl_fml_tabtype (cnt).formula_desc1 := i.formula_desc1;
               xxdbl_fml_tabtype (cnt).owner_id := owner_id;
               xxdbl_fml_tabtype (cnt).inactive_ind := i.inactive_ind;
               xxdbl_fml_tabtype (cnt).owner_organization_id :=
                  i.organization_id;
               xxdbl_fml_tabtype (cnt).formula_type := i.formula_type;
               xxdbl_fml_tabtype (cnt).formula_desc2 := i.comments;
               xxdbl_fml_tabtype (cnt).formula_status := i.formula_status;
               xxdbl_fml_tabtype (cnt).line_no := i.line_no;
               xxdbl_fml_tabtype (cnt).line_type := i.line_type;
               xxdbl_fml_tabtype (cnt).item_no := i.item_no;
               xxdbl_fml_tabtype (cnt).qty := i.qty;
               xxdbl_fml_tabtype (cnt).detail_uom := i.detail_uom;
               xxdbl_fml_tabtype (cnt).release_type :=
                  i.yield_or_consumption_type;
               xxdbl_fml_tabtype (cnt).scrap_factor := i.scrap_factor;
               xxdbl_fml_tabtype (cnt).scale_type_hdr := i.scale_type_hdr;
               fnd_file.put_line (fnd_file.LOG,
                                  'scale_type_hdr.....' || i.scale_type_hdr);
               xxdbl_fml_tabtype (cnt).scale_type_dtl :=
                  i.prod_or_ingr_scale_type;
               xxdbl_fml_tabtype (cnt).cost_alloc := i.cost_alloc;
               fnd_file.put_line (fnd_file.LOG,
                                  'cost_alloc....' || i.cost_alloc);
               --Added for test
               xxdbl_fml_tabtype (cnt).phantom_type := i.phantom_type;
               xxdbl_fml_tabtype (cnt).contribute_yield_ind :=
                  i.contribute_yield_ind;
               xxdbl_fml_tabtype (cnt).contribute_step_qty_ind :=
                  i.contribute_step_qty_ind;
               xxdbl_fml_tabtype (cnt).attribute_category := NULL;
               xxdbl_fml_tabtype (cnt).attribute1 := i.dtl_attribute1;
               fnd_file.put_line (fnd_file.LOG, 'attribute1');
               xxdbl_fml_tabtype (cnt).scale_multiple := i.scale_multiple;
               xxdbl_fml_tabtype (cnt).rounding_direction :=
                  i.rounding_direction;
               xxdbl_fml_tabtype (cnt).scale_rounding_variance :=
                  i.scale_rounding_variance;
            END LOOP;

            l_return_status := NULL;
            fnd_file.put_line (fnd_file.LOG, 'Starting API....');
            gmd_formula_pub.insert_formula (
               p_api_version          => 1,
               p_init_msg_list        => apps.fnd_api.g_true,
               p_commit               => apps.fnd_api.g_true,
               p_called_from_forms    => 'YES',
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data,
               p_formula_header_tbl   => xxdbl_fml_tabtype);
            fnd_file.put_line (fnd_file.LOG, '1.Ending API....');
            fnd_file.put_line (fnd_file.LOG,
                               '1.Return status - ' || l_return_status);
            fnd_file.put_line (fnd_file.LOG,
                               '1.Message count - ' || l_msg_count);
            DBMS_OUTPUT.put_line ('Return status - ' || l_return_status);
            DBMS_OUTPUT.put_line ('Message count - ' || l_msg_count);

            IF l_return_status IN ('S', 'Q')
            THEN
               fnd_file.put_line (
                  fnd_file.LOG,
                  '---------------------------------------------------------------------------------------------------- ');
               fnd_file.put_line (
                  fnd_file.LOG,
                  '100. Success  for Formula  - ' || x1.formula_no);
               fnd_file.put_line (
                  fnd_file.LOG,
                  '---------------------------------------------------------------------------------------------------- ');
               fnd_file.put_line (fnd_file.LOG, '10a - I am here  ');

               DECLARE
                  l_formula_id_new       NUMBER := -1;
                  l_exists               NUMBER := 0;
                  l_return_status_new    VARCHAR2 (1) := 'E';
                  x_recipe_no_new        VARCHAR2 (4000);
                  x_recipe_version_new   VARCHAR2 (4000);
               BEGIN
                  BEGIN
                     SELECT 1
                       INTO l_exists
                       FROM gmd_recipe_generation
                      WHERE organization_id = 152 AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_exists := 0;
                  END;

                  IF l_exists > 0
                  THEN
                     fnd_file.put_line (
                        fnd_file.LOG,
                           'Autometic Receipt generation set found '
                        || x1.formula_no);

                     BEGIN
                        SELECT formula_id
                          INTO l_formula_id_new
                          FROM fm_form_mst
                         WHERE     formula_no = x1.formula_no
                               AND owner_organization_id = 152;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_formula_id_new := -1;
                     END;

                     IF l_formula_id_new > 0
                     THEN
                        fnd_file.put_line (
                           fnd_file.LOG,
                              'Newly Created Formula ID for '
                           || x1.formula_no
                           || ' is '
                           || l_formula_id_new);

                        BEGIN
                           SELECT COUNT (recipe_id)
                             INTO l_recipe_id_count
                             FROM gmd_recipes
                            WHERE     formula_id = l_formula_id_new
                                  AND owner_organization_id = 152;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              l_recipe_id_count := 0;
                        END;

                        IF l_recipe_id_count = 0
                        THEN
                           gmd_recipe_generate.recipe_generate (
                              150,
                              l_formula_id_new,
                              l_return_status_new,
                              x_recipe_no_new,
                              x_recipe_version_new,
                              FALSE);
                        ELSE
                           fnd_file.put_line (
                              fnd_file.LOG,
                                 'Recipes Exists for the given Formula'
                              || x1.formula_no
                              || ' is '
                              || l_formula_id_new);
                        END IF;
                     ELSE
                        fnd_file.put_line (
                           fnd_file.LOG,
                              'Newly Created Formula ID not found for '
                           || x1.formula_no
                           || ' is '
                           || l_formula_id_new);
                        l_return_status_new := 'E';
                     END IF;
                  ELSE
                     fnd_file.put_line (
                        fnd_file.LOG,
                           'Autometic Receipt generation set not found '
                        || x1.formula_no);
                     l_return_status_new := 'S';
                  END IF;

                  IF l_return_status NOT IN ('S', 'Q')
                  THEN
                     fnd_file.put_line (
                        fnd_file.LOG,
                           'A recipe not created through the use of the configuration rules '
                        || x1.formula_no);

                     UPDATE XXDBL_CER_FORMULA_UPD_STG
                        SET error_msg =
                               'A recipe not created through the use of the configuration rules.'
                      WHERE     formula_no = x1.formula_no
                            AND NVL (batch_number, -1) =
                                   NVL (p_batch_number,
                                        NVL (batch_number, -1));
                  ELSE
                     UPDATE XXDBL_CER_FORMULA_UPD_STG
                        SET verify_flag = 'Y', error_msg = NULL
                      WHERE     formula_no = x1.formula_no
                            AND NVL (batch_number, -1) =
                                   NVL (p_batch_number,
                                        NVL (batch_number, -1));

                     fnd_file.put_line (fnd_file.LOG, '10b - I am here  ');
                     xxdbl_recp_rout_thread_assign (x1.formula_no,
                                                    x_routing_upd_msg);

                     DECLARE
                        l_recipe_no            VARCHAR2 (4000) := x1.formula_no;
                        l_recipe_version_new   VARCHAR2 (4000)
                           := NVL (x_recipe_version_new, 1);
                     --'ET01160-20716';
                     BEGIN
                        fnd_global.apps_initialize (l_user_id, 22882, 552);

                        DELETE gmd_recipe_step_materials
                         WHERE (recipe_id, formulaline_id, routingstep_id) IN
                                  (SELECT grstm.recipe_id,
                                          grstm.formulaline_id,
                                          grstm.routingstep_id
                                     FROM gmd_recipes gr,
                                          gmd_recipe_step_materials grstm
                                    WHERE     gr.recipe_id = grstm.recipe_id
                                          AND gr.owner_organization_id = 150
                                          AND gr.recipe_no =
                                                 NVL (l_recipe_no,
                                                      gr.recipe_no));

                        INSERT INTO gmd_recipe_step_materials
                           SELECT rcp.recipe_id,
                                  fmd.formulaline_id,
                                  frd.routingstep_id,
                                  NULL,
                                  SYSDATE,
                                  fnd_global.user_id,
                                  fnd_global.user_id,
                                  SYSDATE,
                                  fnd_global.login_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL
                             FROM gmd_recipes rcp,
                                  fm_form_mst mst,
                                  fm_rout_hdr rt,
                                  fm_matl_dtl fmd,
                                  fm_rout_dtl frd
                            WHERE     rcp.formula_id = mst.formula_id
                                  AND mst.formula_id = fmd.formula_id
                                  AND fmd.line_type = -1
                                  AND fmd.line_no = 1
                                  AND rcp.owner_organization_id = 150
                                  AND rcp.routing_id = rt.routing_id
                                  AND rt.owner_organization_id = 150
                                  AND rt.routing_id = frd.routing_id
                                  AND frd.routingstep_no = '10'
                                  AND mst.formula_class = 'ST'
                                  AND mst.owner_organization_id = 150
                                  AND rcp.recipe_no =
                                         NVL (l_recipe_no, rcp.recipe_no)
                                  AND rcp.recipe_id NOT IN
                                         (SELECT recipe_id
                                            FROM gmd_recipe_step_materials)
                           UNION ALL
                           SELECT rcp.recipe_id,
                                  fmd.formulaline_id,
                                  frd.routingstep_id,
                                  NULL,
                                  SYSDATE,
                                  fnd_global.user_id,
                                  fnd_global.user_id,
                                  SYSDATE,
                                  fnd_global.login_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL
                             FROM gmd_recipes rcp,
                                  fm_form_mst mst,
                                  fm_rout_hdr rt,
                                  fm_matl_dtl fmd,
                                  fm_rout_dtl frd
                            WHERE     rcp.formula_id = mst.formula_id
                                  AND mst.formula_id = fmd.formula_id
                                  AND fmd.line_type = -1
                                  AND fmd.line_no = 1
                                  AND rcp.owner_organization_id = 152
                                  AND rcp.routing_id = rt.routing_id
                                  AND rt.owner_organization_id = 152
                                  AND rt.routing_id = frd.routing_id
                                  AND frd.routingstep_no = '20'
                                  AND mst.formula_class IN ('FD', 'YD')
                                  AND mst.owner_organization_id = 152
                                  AND rcp.recipe_no =
                                         NVL (l_recipe_no, rcp.recipe_no)
                                  AND rcp.recipe_id NOT IN
                                         (SELECT recipe_id
                                            FROM gmd_recipe_step_materials);
                     END;

                     IF x_routing_upd_msg IS NOT NULL
                     THEN
                        fnd_file.put_line (
                           fnd_file.LOG,
                              'Receipe Updation for Routing is failed:   '
                           || x_routing_upd_msg);
                        DBMS_OUTPUT.put_line (
                              'Receipe Updation for Routing is failed:   '
                           || x_routing_upd_msg);
                     END IF;

                     FOR x IN c2 (x1.formula_no)
                     LOOP
                        fnd_file.put_line (fnd_file.LOG, '11a - I am here  ');

                        UPDATE fm_form_mst
                           SET attribute1 = x.attribute3,
                               attribute_category = 'Net Weight'
                         WHERE     formula_no = x.formula_no
                               AND formula_vers = x.formula_vers;

                        fnd_file.put_line (fnd_file.LOG, '11b - I am here  ');
                     END LOOP;

                     FOR y IN c3 (x1.formula_no)
                     LOOP
                        fnd_file.put_line (fnd_file.LOG, '12a - I am here  ');

                        UPDATE fm_matl_dtl
                           SET by_product_type =
                                  DECODE (y.by_product_type,
                                          'Sample', 'S',
                                          'Rework', 'R',
                                          'Waste', 'W',
                                          'Yield', 'Y')
                         WHERE     formula_id =
                                      (SELECT formula_id
                                         FROM fm_form_mst
                                        WHERE     formula_no = y.formula_no
                                              AND formula_vers =
                                                     y.formula_vers)
                               AND line_no = y.line_no
                               AND line_type = 2;

                        fnd_file.put_line (fnd_file.LOG, '12b - I am here  ');
                     END LOOP;

                     fnd_file.put_line (
                        fnd_file.LOG,
                        '12c - I am here  x1.formula_no:' || x1.formula_no);

                     FOR z IN c4 (x1.formula_no)
                     LOOP
                        fnd_file.put_line (
                           fnd_file.LOG,
                              'z.formula_no:'
                           || z.formula_no
                           || '    z.formula_vers:'
                           || z.formula_vers
                           || '  z.line_no:'
                           || z.line_no
                           || '   z.dtl_attribute2:'
                           || z.dtl_attribute2);

                        UPDATE fm_matl_dtl
                           SET attribute1 =
                                  (SELECT b.attribute1
                                     FROM fm_form_mst a, fm_matl_dtl b
                                    WHERE     a.formula_id = b.formula_id
                                          AND a.formula_no = z.dtl_attribute2
                                          AND a.formula_vers = z.formula_vers
                                          AND b.line_no = z.line_no
                                          AND b.line_type = -1)
                         WHERE     formula_id =
                                      (SELECT formula_id
                                         FROM fm_form_mst
                                        WHERE     formula_no = z.formula_no
                                              AND formula_vers =
                                                     z.formula_vers)
                               AND line_no = z.line_no
                               AND line_type = -1;

                        fnd_file.put_line (
                           fnd_file.LOG,
                              'ITEM_NO:'
                           || z.item_no
                           || '      Count:'
                           || SQL%ROWCOUNT);
                        COMMIT;
                     END LOOP;

                     FOR rec
                        IN (SELECT line_no,
                                   formula_no,
                                   formula_vers,
                                   scale_rounding_variance
                              FROM XXDBL_CER_FORMULA_UPD_STG
                             WHERE     line_type = 'INGREDIENT'
                                   AND scale_rounding_variance IS NOT NULL
                                   AND NVL (batch_number, -1) =
                                          NVL (p_batch_number,
                                               NVL (batch_number, -1)))
                     LOOP
                        UPDATE fm_matl_dtl
                           SET scale_rounding_variance =
                                  rec.scale_rounding_variance
                         WHERE     formula_id =
                                      (SELECT formula_id
                                         FROM fm_form_mst ffm
                                        WHERE     ffm.formula_no =
                                                     rec.formula_no
                                              AND ffm.formula_vers =
                                                     rec.formula_vers)
                               AND line_no = rec.line_no;

                        COMMIT;
                     END LOOP;
                  END IF;
               END;
            ELSE
               fnd_file.put_line (
                  fnd_file.LOG,
                  '---------------------------------------------------------------------------------------------------- ');
               fnd_file.put_line (
                  fnd_file.LOG,
                  '100. Error  for Formula  - ' || x1.formula_no);
               fnd_file.put_line (
                  fnd_file.LOG,
                  '---------------------------------------------------------------------------------------------------- ');

               FOR j IN 1 .. l_msg_count
               LOOP
                  apps.fnd_msg_pub.get (p_msg_index       => j,
                                        p_encoded         => 'F',
                                        p_data            => l_msg_data,
                                        p_msg_index_out   => l_out_index);
                  fnd_file.put_line (
                     fnd_file.LOG,
                     '(' || j || ')' || ' -  Message Text ' || l_msg_data);
                  DBMS_OUTPUT.put_line ('Message data - ' || l_msg_data);
               END LOOP;

               fnd_file.put_line (fnd_file.LOG, '14a - I am here  ');

               UPDATE XXDBL_CER_FORMULA_UPD_STG
                  SET error_msg = l_msg_data
                WHERE     formula_no = x1.formula_no
                      AND NVL (batch_number, -1) =
                             NVL (p_batch_number, NVL (batch_number, -1));


               fnd_file.put_line (fnd_file.LOG, '15 - I am here  ');
            END IF;

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_file.put_line (fnd_file.LOG, '16 - I am here  ');
               fnd_file.put_line (fnd_file.LOG,
                                  'Error for Formula  - ' || x1.formula_no);
         END;
      END LOOP;

      fnd_file.put_line (fnd_file.LOG, '17 - I am here  ');
      COMMIT;
   END formula_upload_prc;
END XXDBL_CER_ITEM_UPLD_PKG;
/