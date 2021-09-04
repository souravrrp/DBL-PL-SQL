/* Formatted on 9/2/2021 11:53:56 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_item_creation_pkg
AS
   PROCEDURE writedebug (p_text IN VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG, SUBSTRB (p_text, 1, 500));
   END writedebug;

   PROCEDURE set_resp_appl_user_id
   IS
   BEGIN
      g_orig_user_id := apps.fnd_global.user_id;
      g_orig_resp_id := apps.fnd_global.resp_id;
      g_orig_appl_id := apps.fnd_global.resp_appl_id;

      FOR x IN (SELECT r.responsibility_id, r.application_id
                  FROM fnd_responsibility_vl r
                 WHERE r.responsibility_key = g_gl_resp)
      LOOP
         g_gl_resp_id := x.responsibility_id;
         g_gl_appl_id := x.application_id;
      END LOOP;

      FOR y IN (SELECT user_id
                  FROM fnd_user
                 WHERE user_name = g_sysadmin)
      LOOP
         g_sys_user_id := y.user_id;
      END LOOP;
   END set_resp_appl_user_id;

   FUNCTION get_elem_srl_num (p_catalog_group   IN VARCHAR2,
                              p_element         IN VARCHAR2,
                              p_length          IN NUMBER)
      RETURN VARCHAR2
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_serial       VARCHAR2 (100);
      l_serial_num   NUMBER := 1;
   BEGIN
      BEGIN
         SELECT (last_serial + 1)
           INTO l_serial_num
           FROM xxdbl_catalog_elem_serial
          WHERE catalog_group = p_catalog_group AND element_name = p_element
         FOR UPDATE;

         UPDATE xxdbl_catalog_elem_serial
            SET last_serial = l_serial_num,
                last_updated_by = fnd_global.user_id,
                last_update_date = SYSDATE,
                last_update_login = fnd_global.login_id
          WHERE catalog_group = p_catalog_group AND element_name = p_element;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_serial_num := 1;

            INSERT INTO xxdbl_catalog_elem_serial (catalog_group,
                                                   element_name,
                                                   last_serial,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login)
                 VALUES (p_catalog_group,
                         p_element,
                         l_serial_num,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.user_id,
                         SYSDATE,
                         fnd_global.login_id);
      END;

      COMMIT;
      l_serial := TRIM (LPAD (l_serial_num, p_length, '0'));
      RETURN l_serial;
   END get_elem_srl_num;

   FUNCTION submit_item_prog (p_batch_id IN NUMBER)
      RETURN NUMBER
   IS
      l_conc_prog   VARCHAR2 (100) := 'XXDBL_ITEM_CREATION_PROG';
      l_req_id      NUMBER;
   BEGIN
      l_req_id :=
         fnd_request.submit_request (application   => 'XXDBL',
                                     program       => l_conc_prog,
                                     description   => '',
                                     start_time    => SYSDATE,
                                     sub_request   => NULL,
                                     argument1     => p_batch_id);
      RETURN l_req_id;
   END submit_item_prog;

   FUNCTION get_item_uom_conv (p_item_code            IN VARCHAR2,
                               p_primary_uom_code     IN VARCHAR2,
                               p_secondary_uom_code   IN VARCHAR2)
      RETURN NUMBER
   IS
      l_uom_conversion   NUMBER;
   BEGIN
      SELECT conversion_rate
        INTO l_uom_conversion
        FROM mtl_uom_class_conversions ucc
       WHERE     ucc.from_uom_code =
                    (SELECT uomt.uom_code
                       FROM mtl_units_of_measure uom,
                            mtl_units_of_measure uomt
                      WHERE     uom.uom_code = p_secondary_uom_code
                            AND uom.uom_class = uomt.uom_class
                            AND uomt.base_uom_flag = 'Y')
             AND ucc.to_uom_code =
                    (SELECT uomt.uom_code
                       FROM mtl_units_of_measure uom,
                            mtl_units_of_measure uomt
                      WHERE     uom.uom_code = p_primary_uom_code
                            AND uom.uom_class = uomt.uom_class
                            AND uomt.base_uom_flag = 'Y')
             AND ucc.inventory_item_id =
                    (SELECT si.inventory_item_id
                       FROM mtl_system_items si
                      WHERE si.segment1 = p_item_code AND ROWNUM = 1);

      RETURN l_uom_conversion;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         RETURN -1 * ABS (SQLCODE);
   END get_item_uom_conv;

   PROCEDURE gen_expense_ccid (
      p_organization_id       IN     NUMBER DEFAULT NULL,
      p_expense_acc_code      IN     VARCHAR2 DEFAULT NULL,
      p_expense_subacc_code   IN     VARCHAR2 DEFAULT NULL,
      p_product_line          IN     VARCHAR2 DEFAULT NULL,
      x_expense_ccid             OUT NUMBER,
      x_message                  OUT VARCHAR2)
   IS
      l_stage                    VARCHAR2 (500);
      l_item_exp_comb            VARCHAR2 (500);
      l_org_expense_ccid         NUMBER;
      l_n_chart_of_accounts_id   NUMBER;
   BEGIN
      set_resp_appl_user_id;
      fnd_global.apps_initialize (user_id        => g_sys_user_id,
                                  resp_id        => g_gl_resp_id,
                                  resp_appl_id   => g_gl_appl_id);
      l_stage :=
            'Retrieving org accounts for p_organization_id = '
         || p_organization_id;

      SELECT mp.expense_account
        INTO l_org_expense_ccid
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_organization_id;

      l_stage :=
            'Generating cogs concatenated segs for l_org_expense_ccid = '
         || l_org_expense_ccid;

      SELECT gl.chart_of_accounts_id,
                gl.segment1
             || g_sep
             || gl.segment2
             || g_sep
             || p_product_line
             || g_sep
             || gl.segment4
             || g_sep
             || p_expense_acc_code
             || g_sep
             || p_expense_subacc_code
             || g_sep
             || gl.segment7
             || g_sep
             || gl.segment8
             || g_sep
             || gl.segment9
        INTO l_n_chart_of_accounts_id, l_item_exp_comb
        FROM gl_code_combinations_kfv gl
       WHERE gl.code_combination_id = l_org_expense_ccid;

      l_stage := 'call get ccid for ' || l_item_exp_comb;
      x_expense_ccid :=
         fnd_flex_ext.get_ccid (
            application_short_name   => 'SQLGL',
            key_flex_code            => 'GL#',
            structure_number         => l_n_chart_of_accounts_id,
            validation_date          => SYSDATE,
            concatenated_segments    => l_item_exp_comb);
      fnd_global.apps_initialize (user_id        => g_orig_user_id,
                                  resp_id        => g_orig_resp_id,
                                  resp_appl_id   => g_orig_appl_id);

      IF x_expense_ccid = 0
      THEN
         l_stage :=
            SUBSTRB (
                  'Error in get_ccid api - coa id '
               || l_n_chart_of_accounts_id
               || ', account comb '
               || l_item_exp_comb,
               1,
               500);
         RAISE g_exception;
      END IF;
   EXCEPTION
      WHEN g_exception
      THEN
         x_message := l_stage;
         x_expense_ccid := 0;
         writedebug (x_message);
      WHEN OTHERS
      THEN
         x_message :=
            SUBSTRB (
                  'Unexpected Error in gen_expense_ccid - '
               || l_stage
               || ' - '
               || SQLERRM,
               1,
               200);
         x_expense_ccid := 0;
         writedebug (x_message);
   END gen_expense_ccid;

   PROCEDURE assign_category (p_category_id         IN     NUMBER,
                              p_category_set_id     IN     NUMBER,
                              p_inventory_item_id   IN     NUMBER,
                              p_organization_id     IN     NUMBER,
                              x_message                OUT VARCHAR2)
   IS
      l_old_category_id   NUMBER;
      ---- API parameters ----
      x_msg_count         NUMBER;
      x_msg_data          VARCHAR2 (1000);
      x_errorcode         VARCHAR2 (1000);
      x_message_list      error_handler.error_tbl_type;
      x_return_status     VARCHAR2 (10);
      l_proc              VARCHAR2 (100) := 'assign_category: ';
   BEGIN
      l_proc := 'assign_category : ';
      writedebug (l_proc || 'start');

      BEGIN
         SELECT category_id
           INTO l_old_category_id
           FROM mtl_item_categories mic
          WHERE     mic.inventory_item_id = p_inventory_item_id
                AND mic.organization_id = p_organization_id
                AND mic.category_set_id = p_category_set_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_old_category_id := NULL;
      END;

      writedebug (l_proc || ' old categ id = ' || l_old_category_id);

      IF l_old_category_id IS NULL
      THEN
         x_message := 'API call create_category_assignment';
         writedebug (l_proc || x_message);
         inv_item_category_pub.create_category_assignment (
            p_api_version         => 1.0,
            p_init_msg_list       => fnd_api.g_true,
            p_commit              => fnd_api.g_false,
            x_return_status       => x_return_status,
            x_errorcode           => x_errorcode,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_category_id         => p_category_id,
            p_category_set_id     => p_category_set_id,
            p_inventory_item_id   => p_inventory_item_id,
            p_organization_id     => p_organization_id);
      ELSIF l_old_category_id != p_category_id
      THEN
         x_message := 'API call update_category_assignment';
         writedebug (l_proc || x_message);
         inv_item_category_pub.update_category_assignment (
            p_api_version         => 1.0,
            p_init_msg_list       => fnd_api.g_true,
            p_commit              => fnd_api.g_false,
            x_return_status       => x_return_status,
            x_errorcode           => x_errorcode,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_old_category_id     => l_old_category_id,
            p_category_id         => p_category_id,
            p_category_set_id     => p_category_set_id,
            p_inventory_item_id   => p_inventory_item_id,
            p_organization_id     => p_organization_id);
      END IF;

      x_message :=
         SUBSTRB (
               'Post-call inv_item_category_pub - x_return_status = '
            || x_return_status
            || ' x_errorcode = '
            || x_errorcode
            || ' x_msg_count = '
            || x_msg_count
            || ' x_msg_data = '
            || x_msg_data,
            1,
            500);
      writedebug (l_proc || x_message);

      IF x_return_status != fnd_api.g_ret_sts_success
      THEN
         writedebug ('Category API errors: ');

         FOR n IN 1 .. x_msg_count
         LOOP
            x_msg_data := oe_msg_pub.get (p_msg_index => n, p_encoded => 'F');
            x_message :=
               SUBSTRB (x_message || ' ~ ' || n || '. ' || x_msg_data,
                        1,
                        4000);
            writedebug (n || ') ' || x_msg_data);
         END LOOP;
      --RAISE g_exception;
      ELSE
         x_message := g_success;
      END IF;

      writedebug (l_proc || 'end');
   END assign_category;

   PROCEDURE assign_catalog_elements (p_item_master_id      IN     NUMBER,
                                      p_item_number         IN     VARCHAR2,
                                      p_inventory_item_id   IN     NUMBER,
                                      x_message                OUT VARCHAR2)
   IS
      ------------------------------------------------
      lt_item_desc_element_table   apps.inv_item_catalog_elem_pub.item_desc_element_table;
      lx_generated_descr           VARCHAR2 (200);
      lx_return_status             VARCHAR2 (200);
      lx_msg_count                 NUMBER;
      lx_msg_data                  VARCHAR2 (200);
      idx                          INTEGER := 0;
      l_proc                       VARCHAR2 (100)
                                      := 'assign_catalog_elements: ';
      l_exists                     NUMBER := 0;
   BEGIN
      l_proc := 'assign_catalog_elements - ' || p_item_number || ': ';
      writedebug (l_proc || 'start');

      SELECT COUNT (dev.element_name)
        INTO l_exists
        FROM mtl_descr_element_values_v dev,
             mtl_system_items si,
             mtl_parameters mp
       WHERE     si.inventory_item_id = p_inventory_item_id
             AND si.organization_id = mp.organization_id
             AND mp.organization_code = g_master_org
             AND dev.inventory_item_id = si.inventory_item_id
             AND dev.item_catalog_group_id = si.item_catalog_group_id;

      IF l_exists > 0
      THEN
         writedebug (
               l_proc
            || 'Catalog descriptive elements already defined for '
            || p_item_number
            || '. Skipping catalog element assignment.');
         x_message := g_success;
      ELSE
         /*
         SELECT DISTINCT si.segment1, si.inventory_item_id
                    INTO l_item_number, l_inventory_item_id
                    FROM xxdbl_item_master im, mtl_system_items si
                   WHERE im.item_master_id = p_item_master_id
                     AND im.item_code = si.segment1;
                     */
         idx := 0;
         writedebug (l_proc || 'start');

         FOR i
            IN (  SELECT el.element_name, el.element_desc
                    FROM xxdbl_item_code_elements el,
                         xxdbl_catalog_desc_elements cde
                   WHERE     el.item_master_id = p_item_master_id
                         AND el.element_id = cde.element_id
                ORDER BY element_sequence)
         LOOP
            idx := idx + 1;
            writedebug (
                  l_proc
               || ' element '
               || i.element_name
               || ' | '
               || i.element_desc);
            lt_item_desc_element_table (idx).element_name :=
               SUBSTRB (i.element_name, 1, 30);
            lt_item_desc_element_table (idx).element_value :=
               SUBSTRB (i.element_desc, 1, 30);
            lt_item_desc_element_table (idx).description_default := 'Y';
         END LOOP;

         lx_generated_descr := NULL;
         lx_return_status := NULL;
         lx_msg_count := NULL;
         lx_msg_data := NULL;
         -----
         fnd_msg_pub.initialize;
         -----
         x_message :=
            'API call process_item_descr_elements for item ' || p_item_number;
         writedebug (l_proc || 'API call process_item_descr_elements ');
         inv_item_catalog_elem_pub.process_item_descr_elements (
            p_api_version               => 1.0,
            p_init_msg_list             => fnd_api.g_true,
            p_commit_flag               => fnd_api.g_false,
            p_validation_level          => inv_item_catalog_elem_pub.g_validate_level_full,
            p_inventory_item_id         => p_inventory_item_id,
            p_item_number               => p_item_number,
            p_item_desc_element_table   => lt_item_desc_element_table,
            x_generated_descr           => lx_generated_descr,
            x_return_status             => lx_return_status,
            x_msg_count                 => lx_msg_count,
            x_msg_data                  => lx_msg_data);
         writedebug (l_proc || 'API post-call process_item_descr_elements ');
         x_message :=
            SUBSTRB (
                  x_message
               || ' - lx_generated_descr = '
               || lx_generated_descr
               || ' - lx_return_status = '
               || lx_return_status
               || ' - lx_msg_count = '
               || lx_msg_count
               || ' - lx_msg_data = '
               || lx_msg_data,
               1,
               500);
         writedebug (l_proc || x_message);

         IF NVL (lx_return_status, 'E') != fnd_api.g_ret_sts_success
         THEN
            IF NVL (lx_msg_count, 0) > 1
            THEN
               writedebug ('API errrors:');

               FOR n IN 1 .. lx_msg_count
               LOOP
                  lx_msg_data :=
                        n
                     || '> '
                     || fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false);
                  writedebug (lx_msg_data);
                  x_message :=
                     SUBSTRB (x_message || ' ~ ' || lx_msg_data, 1, 2000);
               END LOOP;

               fnd_msg_pub.delete_msg;
            END IF;
         ELSE
            x_message := g_success;
         END IF;
      END IF;

      writedebug (l_proc || 'end');
   END assign_catalog_elements;

   PROCEDURE create_uom_conversions (p_primary_uom_code     IN     VARCHAR2,
                                     p_secondary_uom_code   IN     VARCHAR2,
                                     p_conv_rate            IN     NUMBER,
                                     p_inventory_item_id    IN     NUMBER,
                                     x_message                 OUT VARCHAR2)
   IS
      l_conv_rate_p          NUMBER;
      l_conv_rate_s          NUMBER;
      l_base_prim_uom_code   VARCHAR2 (10);
      l_base_sec_uom_code    VARCHAR2 (10);
      l_base_conv_rate       NUMBER;
      l_return_status        VARCHAR2 (1);
      l_proc                 VARCHAR2 (100) := 'create_uom_conversions: ';
   BEGIN
      writedebug (l_proc || 'start');

      FOR i
         IN (SELECT uomt.uom_code, uc.conversion_rate
               FROM mtl_units_of_measure uom,
                    mtl_units_of_measure uomt,
                    mtl_uom_conversions uc
              WHERE     uom.uom_code = p_primary_uom_code
                    AND uom.uom_code = uc.uom_code
                    AND uc.inventory_item_id = 0
                    AND uom.uom_class = uomt.uom_class
                    AND uomt.base_uom_flag = 'Y')
      LOOP
         l_base_prim_uom_code := i.uom_code;
         l_conv_rate_p := i.conversion_rate;
      END LOOP;

      x_message :=
            'Derived primary uom '
         || l_base_prim_uom_code
         || ' - conv = '
         || l_conv_rate_p;
      writedebug (l_proc || x_message);

      FOR j
         IN (SELECT uomt.uom_code, uc.conversion_rate
               FROM mtl_units_of_measure uom,
                    mtl_units_of_measure uomt,
                    mtl_uom_conversions uc
              WHERE     uom.uom_code = p_secondary_uom_code
                    AND uom.uom_code = uc.uom_code
                    AND uc.inventory_item_id = 0
                    AND uom.uom_class = uomt.uom_class
                    AND uomt.base_uom_flag = 'Y')
      LOOP
         l_base_sec_uom_code := j.uom_code;
         l_conv_rate_s := j.conversion_rate;
      END LOOP;

      x_message :=
         SUBSTRB (
               x_message
            || ' ~ Derived secondary uom '
            || l_base_sec_uom_code
            || ' - conv = '
            || l_conv_rate_s,
            1,
            1000);
      writedebug (l_proc || x_message);

      IF l_base_prim_uom_code = l_base_sec_uom_code
      THEN
         x_message :=
            SUBSTRB (
                  x_message
               || '~ Conversion not required as base UOM are same for both primary and secondary.',
               1,
               1000);
         writedebug (l_proc || x_message);
         x_message := g_success;
      ELSE
         IF NVL (l_conv_rate_s, 0) = 0
         THEN
            l_base_conv_rate := NULL;
         ELSE
            l_base_conv_rate := p_conv_rate * l_conv_rate_p / l_conv_rate_s;
         END IF;

         x_message :=
            SUBSTRB (
                  'API call inv_convert, derived base conv = '
               || l_base_conv_rate,
               1,
               500);
         writedebug (l_proc || x_message);
         inv_convert.create_uom_conversion (
            p_from_uom_code   => l_base_prim_uom_code,
            p_to_uom_code     => l_base_sec_uom_code,
            p_item_id         => p_inventory_item_id,
            p_uom_rate        => l_base_conv_rate,
            x_return_status   => l_return_status);
         writedebug (
            SUBSTRB (
                  'Post-call create_uom_conversion api result '
               || l_return_status,
               1,
               500));
         writedebug (l_proc || x_message);

         IF NVL (l_return_status, 'E') IN ('S', 'W')
         THEN
            x_message := g_success;
         ELSE
            x_message :=
               SUBSTRB (
                  'create_uom_conversion api result ' || l_return_status,
                  1,
                  1000);
         END IF;
      END IF;

      writedebug (l_proc || 'end - ' || x_message);
   END create_uom_conversions;

   PROCEDURE call_item_api (p_errbuff       OUT VARCHAR2,
                            p_retcode       OUT VARCHAR2,
                            p_batch_id   IN     NUMBER)
   IS
      CURSOR cur_item_master
      IS
         SELECT b.batch_name, xim.*
           FROM xxdbl_item_master xim, xxdbl_item_batches b
          WHERE     xim.batch_id = p_batch_id
                AND b.batch_id = xim.batch_id
                AND xim.item_status != 'COMPLETED';

      CURSOR cur_org_items (
         p_item_master_id      IN NUMBER,
         p_inventory_item_id   IN NUMBER)
      IS
         SELECT io.organization_id,
                io.organization_code,
                io.org_name,
                ioh.item_org_hierarchy_id,
                ioh.item_master_id,
                ioh.organization_structure_id,
                ioh.org_hierarchy,
                ioh.template_id,
                ioh.template_name,
                ioh.category_set_id,
                ioh.category_id,
                ioh.category_name,
                ioh.lead_time,
                ioh.min_quantity,
                ioh.max_quantity,
                ioh.rfq_flag,
                ioh.lcm_flag,
                ioh.routing,
                ioh.expense_account,
                ioh.expense_sub_account,
                ioh.product_line
           FROM xxdbl_item_orgs io, xxdbl.xxdbl_item_org_hierarchy ioh
          WHERE     io.item_org_hierarchy_id = ioh.item_org_hierarchy_id
                AND ioh.item_master_id = p_item_master_id
                AND NOT EXISTS
                       (SELECT 1
                          FROM mtl_system_items si
                         WHERE     si.inventory_item_id = p_inventory_item_id
                               AND si.organization_id = io.organization_id);

      l_stage                   VARCHAR2 (500);
      l_master_org_id           NUMBER;
      l_master_assign           NUMBER;
      l_expense_account         VARCHAR2 (100);
      l_expense_sub_account     VARCHAR2 (100);
      l_product_line            VARCHAR2 (100);
      l_message                 VARCHAR2 (4000);
      x_inventory_item_id       NUMBER;
      l_organization_id         NUMBER;
      l_item_org_hierarchy_id   NUMBER;
      l_complete_count          NUMBER;
      l_error_count             NUMBER;
      l_batch_status            VARCHAR2 (20);
      l_category_id             NUMBER;
      l_category_set_id         NUMBER;
      l_category_name           VARCHAR2 (500);
      ------------ API Parameters -------------------
      ln_item_id                mtl_system_items_b.inventory_item_id%TYPE;
      lt_item_table             ego_item_pub.item_tbl_type;
      x_item_table              ego_item_pub.item_tbl_type;
      x_msg_count               NUMBER;
      x_msg_data                VARCHAR2 (1000);
      x_errorcode               VARCHAR2 (1000);
      x_message_list            error_handler.error_tbl_type;
      x_return_status           VARCHAR2 (10);
   BEGIN
      l_stage := 'start - retrieving master org id';
      p_retcode := '0';
      p_errbuff := '';

      DELETE xxdbl_item_errors
       WHERE batch_id = p_batch_id;

      SELECT organization_id
        INTO l_master_org_id
        FROM mtl_parameters mp
       WHERE     master_organization_id = organization_id
             AND organization_id = 138;             --Updated by Sourav 020921

      FOR r1 IN cur_item_master
      LOOP
         BEGIN
            SAVEPOINT x_loop_start;
            l_expense_account := NULL;
            l_product_line := NULL;
            x_inventory_item_id := NULL;
            l_item_org_hierarchy_id := NULL;
            l_stage :=
               SUBSTRB (
                     'checking - item '
                  || r1.item_code
                  || ' exists; master org id = '
                  || l_master_org_id,
                  1,
                  500);

            SELECT COUNT (1)
              INTO l_master_assign
              FROM mtl_system_items
             WHERE     segment1 = r1.item_code
                   AND organization_id = l_master_org_id;

            l_stage :=
               SUBSTRB (
                     'check - item '
                  || r1.item_code
                  || ' master org id = '
                  || l_master_org_id
                  || ' l_master_assign = '
                  || l_master_assign,
                  1,
                  500);
            writedebug (l_stage);

            IF l_master_assign = 0
            THEN
               l_organization_id := l_master_org_id;
               l_message :=
                  'Assigning item attributes for item ' || r1.item_code;
               -- Item definition
               lt_item_table (1).transaction_type := 'CREATE';
               lt_item_table (1).inventory_item_id := NULL;
               lt_item_table (1).item_catalog_group_id := r1.catalog_group_id;
               lt_item_table (1).inventory_item_status_code := 'Active';
               lt_item_table (1).primary_uom_code := r1.primary_uom_code;
               lt_item_table (1).item_number := r1.item_code;
               lt_item_table (1).segment1 := r1.item_code;
               lt_item_table (1).description := r1.item_description;
               lt_item_table (1).long_description := r1.long_description;
               lt_item_table (1).secondary_uom_code := r1.secondary_uom_code;
               lt_item_table (1).organization_id := l_organization_id;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 4, 1)
                 INTO lt_item_table (1).dual_uom_control
                 FROM DUAL;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 'PS', 'P')
                 INTO lt_item_table (1).tracking_quantity_ind
                 FROM DUAL;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 'D', '')
                 INTO lt_item_table (1).secondary_default_ind
                 FROM DUAL;

               l_message :=
                     'Fetching org related item attributes for item '
                  || r1.item_code
                  || ', item_master_id = '
                  || r1.item_master_id;
               writedebug (l_stage);

               BEGIN
                  SELECT template_id,
                         lead_time,
                         min_quantity,
                         max_quantity,
                         rfq_flag,
                         routing,
                         expense_account,
                         expense_sub_account,
                         product_line,
                         category_id,
                         category_set_id,
                         category_name
                    INTO lt_item_table (1).template_id,
                         lt_item_table (1).preprocessing_lead_time,
                         lt_item_table (1).min_minmax_quantity,
                         lt_item_table (1).max_minmax_quantity,
                         lt_item_table (1).rfq_required_flag,
                         lt_item_table (1).receiving_routing_id,
                         l_expense_account,
                         l_expense_sub_account,
                         l_product_line,
                         l_category_id,
                         l_category_set_id,
                         l_category_name
                    FROM xxdbl_item_org_hierarchy
                   WHERE item_master_id = r1.item_master_id AND ROWNUM = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_message :=
                        SUBSTRB (
                              'Unable to retrieve attributes from custom item master for item '
                           || r1.item_code
                           || ', item_master_id = '
                           || r1.item_master_id
                           || ' - '
                           || SQLERRM,
                           1,
                           4000);
                     ROLLBACK TO SAVEPOINT x_loop_start;
                     RAISE g_exception;
               END;

               ----------
               l_stage :=
                     'Fetching expense account for item '
                  || r1.item_code
                  || ' for master org assign ';
               gen_expense_ccid (
                  p_organization_id       => lt_item_table (1).organization_id,
                  p_expense_acc_code      => l_expense_account,
                  p_expense_subacc_code   => l_expense_sub_account,
                  p_product_line          => l_product_line,
                  x_expense_ccid          => lt_item_table (1).expense_account,
                  x_message               => l_message);

               IF lt_item_table (1).expense_account = 0
               THEN
                  ROLLBACK TO SAVEPOINT x_loop_start;
                  RAISE g_exception;
               END IF;

               l_stage :=
                     'API process_items call for item '
                  || r1.item_code
                  || ' for master org assign ';
               ego_item_pub.process_items (
                  --Input Parameters
                  p_api_version     => 1.0,
                  p_init_msg_list   => fnd_api.g_true,
                  p_commit          => fnd_api.g_false,
                  p_item_tbl        => lt_item_table,
                  --Output Parameters
                  x_item_tbl        => x_item_table,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count);
               l_stage :=
                     'API process_items post-call '
                  || r1.item_code
                  || ' org id '
                  || lt_item_table (1).organization_id;
               l_message :=
                  SUBSTRB (
                        l_stage
                     || ' - x_return_status = '
                     || x_return_status
                     || ', x_msg_count = '
                     || x_msg_count,
                     1,
                     4000);
               writedebug (l_message);
               x_inventory_item_id := x_item_table (1).inventory_item_id;
               writedebug ('New item id - ' || x_inventory_item_id);

               IF NVL (x_return_status, 'E') != 'S'
               THEN
                  ROLLBACK TO SAVEPOINT x_loop_start;
                  writedebug (
                        'API Error Messages for item master id '
                     || r1.item_master_id
                     || ', item code '
                     || r1.item_code
                     || ':');
                  error_handler.get_message_list (
                     x_message_list   => x_message_list);
                  l_message := 'API error ' || l_message;

                  FOR n IN 1 .. x_message_list.COUNT
                  LOOP
                     l_message :=
                        SUBSTRB (
                              l_message
                           || '; '
                           || n
                           || '> '
                           || x_message_list (n).MESSAGE_TEXT,
                           1,
                           4000);
                     writedebug (
                        n || '> ' || x_message_list (n).MESSAGE_TEXT);
                  END LOOP;

                  x_message_list.DELETE;
                  RAISE g_exception;
               END IF;

               IF l_category_set_id IS NOT NULL AND l_category_id IS NOT NULL
               THEN
                  l_stage :=
                     SUBSTRB (
                           'Creating master org category '
                        || l_category_name
                        || ' for item '
                        || r1.item_code,
                        1,
                        500);
                  assign_category (
                     p_category_id         => l_category_id,
                     p_category_set_id     => l_category_set_id,
                     p_inventory_item_id   => x_inventory_item_id,
                     p_organization_id     => l_organization_id,
                     x_message             => l_message);
                  l_stage :=
                     SUBSTRB (
                           'Post-call master org assign category '
                        || l_category_name
                        || ' for item '
                        || r1.item_code,
                        1,
                        500);

                  IF l_message != g_success
                  THEN
                     ROLLBACK TO SAVEPOINT x_loop_start;
                     l_message :=
                        SUBSTRB (l_stage || '**' || l_message, 1, 4000);
                     RAISE g_exception;
                  END IF;
               END IF;
            ELSE
               BEGIN
                  l_message :=
                     SUBSTRB (
                           'Fetching inventory item id from master org item '
                        || r1.item_code
                        || ', l_master_org_id = '
                        || l_master_org_id,
                        1,
                        4000);
                  writedebug (l_message);

                  SELECT msib.inventory_item_id
                    INTO x_inventory_item_id
                    FROM mtl_system_items_b msib
                   WHERE     msib.segment1 = r1.item_code
                         AND msib.organization_id = l_master_org_id;

                  writedebug (
                     'Existing x_inventory_item_id = ' || x_inventory_item_id);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_message :=
                        SUBSTRB (
                              'Unable to fetch inventory item id from item '
                           || r1.item_code
                           || ' from master_org_id = '
                           || l_master_org_id
                           || ' - '
                           || SQLERRM,
                           1,
                           4000);
                     RAISE g_exception;
               END;
            END IF;

            l_stage :=
               SUBSTRB (
                     'API assign_catalog_elements '
                  || r1.item_code
                  || ' item_master_id = '
                  || r1.item_master_id,
                  1,
                  500);
            writedebug (l_stage);
            assign_catalog_elements (
               p_item_master_id      => r1.item_master_id,
               p_item_number         => r1.item_code,
               p_inventory_item_id   => x_inventory_item_id,
               x_message             => l_message);
            l_stage :=
               SUBSTRB (
                     'API assign_catalog_elements post-call '
                  || r1.item_code
                  || ' item_master_id = '
                  || r1.item_master_id,
                  1,
                  500);
            writedebug (l_stage);
            writedebug ('message from assign_catalog_elements ' || l_message);

            IF l_message != g_success
            THEN
               ROLLBACK TO SAVEPOINT x_loop_start;
               RAISE g_exception;
            END IF;

            FOR r2 IN cur_org_items (r1.item_master_id, x_inventory_item_id)
            LOOP
               l_stage :=
                  SUBSTRB (
                        'In cur_org_items  '
                     || r1.item_code
                     || ' org id '
                     || r2.organization_id,
                     1,
                     500);
               writedebug (l_stage);
               l_organization_id := r2.organization_id;
               l_item_org_hierarchy_id := r2.item_org_hierarchy_id;
               /*l_stage :=
                     'API call assign_item_to_org for '
                  || r1.item_code
                  || ' , x_inventory_item_id = '
                  || x_inventory_item_id
                  || ' and '
                  || r2.organization_code
                  || ' , x_organization_id = '
                  || r2.organization_id;
               ego_item_pub.assign_item_to_org
                                  (p_api_version            => 1.0,
                                   p_init_msg_list          => fnd_api.g_true,
                                   p_commit                 => fnd_api.g_false,
                                   p_inventory_item_id      => x_inventory_item_id,
                                   p_organization_id        => r2.organization_id,
                                   --p_primary_uom_code       => r1.primary_uom_code,
                                   x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count
                                  );
               l_message :=
                     l_stage
                  || ' - x_return_status = '
                  || x_return_status
                  || ', x_return_status = '
                  || x_return_status
                  || ', x_msg_count = '
                  || x_msg_count;
               writedebug (l_message);

               IF NVL (x_return_status, 'E') != 'S'
               THEN
                  ROLLBACK TO SAVEPOINT x_loop_start;
                  writedebug ('Error Messages from assign_item_to_org :');
                  error_handler.get_message_list
                                            (x_message_list      => x_message_list);
                  l_message := 'API error ' || l_message;

                  FOR n IN 1 .. x_message_list.COUNT
                  LOOP
                     l_message :=
                        SUBSTRB (   l_message
                                || '~'
                                || n
                                || '.'
                                || x_message_list (n).MESSAGE_TEXT,
                                1,
                                4000
                               );
                     writedebug (x_message_list (n).MESSAGE_TEXT);
                  END LOOP;

                  x_message_list.DELETE;
                  RAISE g_exception;
               END IF;*/



               l_message :=
                     'Assigning item attributes for item '
                  || r1.item_code
                  || ' and org code '
                  || r2.organization_code;
               writedebug (l_message);
               ------- Attributes from Item master ------------
               lt_item_table (1).transaction_type := 'CREATE';
               --lt_item_table (1).inventory_item_id := x_inventory_item_id;
               lt_item_table (1).item_catalog_group_id := r1.catalog_group_id;
               lt_item_table (1).inventory_item_status_code := 'Active';
               lt_item_table (1).primary_uom_code := r1.primary_uom_code;
               lt_item_table (1).item_number := r1.item_code;
               lt_item_table (1).segment1 := r1.item_code;
               lt_item_table (1).description := r1.item_description;
               lt_item_table (1).long_description := r1.long_description;
               lt_item_table (1).secondary_uom_code := r1.secondary_uom_code;
               lt_item_table (1).organization_id := l_organization_id;
               lt_item_table (1).list_price_per_unit := 1;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 4, 1)
                 INTO lt_item_table (1).dual_uom_control
                 FROM DUAL;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 'PS', 'P')
                 INTO lt_item_table (1).tracking_quantity_ind
                 FROM DUAL;

               SELECT DECODE (r1.dual_uom_flag, 'Y', 'D', '')
                 INTO lt_item_table (1).secondary_default_ind
                 FROM DUAL;

               ---------- Attributes from Org Hierarchy ----
               lt_item_table (1).template_id := r2.template_id;
               lt_item_table (1).preprocessing_lead_time := r2.lead_time;
               lt_item_table (1).min_minmax_quantity := r2.min_quantity;
               lt_item_table (1).max_minmax_quantity := r2.max_quantity;
               lt_item_table (1).rfq_required_flag := r2.rfq_flag;
               lt_item_table (1).receiving_routing_id := r2.routing;
               l_expense_account := r2.expense_account;
               l_expense_sub_account := r2.expense_sub_account;
               l_product_line := r2.product_line;
               lt_item_table (1).organization_id := l_organization_id;
               ----------
               l_stage :=
                  SUBSTRB (
                        'Fetching expense account for item '
                     || r1.item_code
                     || ' and org code '
                     || r2.organization_code,
                     1,
                     500);
               writedebug (l_stage);
               gen_expense_ccid (
                  p_organization_id       => lt_item_table (1).organization_id,
                  p_expense_acc_code      => l_expense_account,
                  p_expense_subacc_code   => l_expense_sub_account,
                  p_product_line          => l_product_line,
                  x_expense_ccid          => lt_item_table (1).expense_account,
                  x_message               => l_message);
               writedebug ('result from gen_expense_ccid = ' || l_message);

               ---
               IF lt_item_table (1).expense_account = 0
               THEN
                  ROLLBACK TO SAVEPOINT x_loop_start;
                  RAISE g_exception;
               END IF;

               l_stage :=
                  SUBSTRB (
                        'API call process_items to org assign item '
                     || r1.item_code
                     || ' for '
                     || r2.organization_code,
                     1,
                     500);
               writedebug (l_stage);
               ego_item_pub.process_items (
                  p_api_version     => 1.0,
                  p_init_msg_list   => fnd_api.g_true,
                  p_commit          => fnd_api.g_false,
                  p_item_tbl        => lt_item_table,
                  x_item_tbl        => x_item_table,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count);
               l_stage :=
                  SUBSTRB (
                        'API post-call process_items to org assign '
                     || r1.item_code
                     || ' for '
                     || r2.organization_code,
                     1,
                     500);
               l_message :=
                  SUBSTRB (
                        l_stage
                     || ' - x_return_status = '
                     || x_return_status
                     || ', x_msg_count = '
                     || x_msg_count,
                     1,
                     4000);
               writedebug (l_message);

               ---x_inventory_item_id := x_item_table (1).inventory_item_id;
               IF NVL (x_return_status, 'E') != 'S'
               THEN
                  ROLLBACK TO SAVEPOINT x_loop_start;
                  writedebug ('Error Messages while item update:');
                  error_handler.get_message_list (
                     x_message_list   => x_message_list);
                  l_message := 'API error ' || l_message;

                  FOR n IN 1 .. x_message_list.COUNT
                  LOOP
                     l_message :=
                        SUBSTRB (
                              l_message
                           || '~ '
                           || n
                           || '.'
                           || x_message_list (n).MESSAGE_TEXT,
                           1,
                           4000);
                     writedebug (x_message_list (n).MESSAGE_TEXT);
                  END LOOP;

                  x_message_list.DELETE;
                  RAISE g_exception;
               END IF;

               IF r1.dual_uom_flag = 'Y'
               THEN
                  l_stage :=
                     SUBSTRB (
                           'API call create_uom_conversion between primary uom  '
                        || r1.primary_uom_code
                        || ' and secondary uom '
                        || r1.secondary_uom_code
                        || ' for item '
                        || r1.item_code,
                        1,
                        500);
                  create_uom_conversions (
                     p_primary_uom_code     => r1.primary_uom_code,
                     p_secondary_uom_code   => r1.secondary_uom_code,
                     p_conv_rate            => r1.uom_conversion,
                     p_inventory_item_id    => x_inventory_item_id,
                     x_message              => l_message);
                  l_stage :=
                     SUBSTRB (
                           'API post-call create_uom_conversion between primary uom  '
                        || r1.primary_uom_code
                        || ' and secondary uom '
                        || r1.secondary_uom_code
                        || ' for item '
                        || r1.item_code,
                        1,
                        500);

                  IF l_message != g_success
                  THEN
                     l_message :=
                        SUBSTRB (l_stage || ' ~ ' || l_message, 1, 4000);
                     ROLLBACK TO SAVEPOINT x_loop_start;
                     RAISE g_exception;
                  END IF;
               END IF;

               IF     r2.category_set_id IS NOT NULL
                  AND r2.category_id IS NOT NULL
               THEN
                  l_stage :=
                     SUBSTRB (
                           'Creating category '
                        || r2.category_name
                        || ' for item '
                        || r1.item_code
                        || ' for org code '
                        || r2.organization_code,
                        1,
                        500);
                  assign_category (
                     p_category_id         => r2.category_id,
                     p_category_set_id     => r2.category_set_id,
                     p_inventory_item_id   => x_inventory_item_id,
                     p_organization_id     => l_organization_id,
                     x_message             => l_message);
                  l_stage :=
                     SUBSTRB (
                           'Post-call assign category '
                        || r2.category_name
                        || ' for item '
                        || r1.item_code
                        || ' for org code '
                        || r2.organization_code,
                        1,
                        500);

                  IF l_message != g_success
                  THEN
                     ROLLBACK TO SAVEPOINT x_loop_start;
                     l_message :=
                        SUBSTRB (l_stage || '**' || l_message, 1, 4000);
                     RAISE g_exception;
                  END IF;
               END IF;

               IF r2.lcm_flag = 'Y'
               THEN
                  FOR j
                     IN (SELECT mcs.default_category_id, mcs.category_set_id
                           FROM mtl_category_sets mcs
                          WHERE mcs.category_set_id =
                                   fnd_profile.VALUE (
                                      'INL_ITEM_CATEGORY_SET'))
                  LOOP
                     l_stage :=
                        SUBSTRB (
                              'Creating LCM category for item '
                           || r1.item_code
                           || ' for org code '
                           || r2.organization_code,
                           1,
                           500);
                     assign_category (
                        p_category_id         => j.default_category_id,
                        p_category_set_id     => j.category_set_id,
                        p_inventory_item_id   => x_inventory_item_id,
                        p_organization_id     => l_organization_id,
                        x_message             => l_message);
                     l_stage :=
                        SUBSTRB (
                              'Post-call LCM category for item '
                           || r1.item_code
                           || ' for org code '
                           || r2.organization_code,
                           1,
                           500);

                     IF l_message != g_success
                     THEN
                        ROLLBACK TO SAVEPOINT x_loop_start;
                        l_message :=
                           SUBSTRB (l_stage || '**' || l_message, 1, 4000);
                        RAISE g_exception;
                     END IF;
                  END LOOP;
               END IF;

               ----------
               ------------
               UPDATE xxdbl_item_orgs io
                  SET io.item_status = 'COMPLETED', item_assign_flag = 'Y'
                WHERE     io.organization_id = l_organization_id
                      AND io.item_org_hierarchy_id = l_item_org_hierarchy_id;
            END LOOP cur_org_items;

            ----------
            ------------
            UPDATE xxdbl_item_master im
               SET im.item_status = 'COMPLETED'
             WHERE im.item_master_id = r1.item_master_id;

            --------
            UPDATE mtl_system_items_b m
               SET mcc_control_code = 1
             WHERE     inventory_item_id = x_inventory_item_id
                   AND mcc_control_code IS NULL;

            --------
            lt_item_table.DELETE;
            x_item_table.DELETE;
         EXCEPTION
            WHEN g_exception
            THEN
               p_retcode := '1';
               l_message := SUBSTRB (l_stage || ' - ' || l_message, 1, 4000);
               p_errbuff := SUBSTRB (l_message, 1, 100);
               writedebug (l_message);

               INSERT INTO xxdbl_item_errors (batch_id,
                                              item_master_id,
                                              item_org_hierarchy_id,
                                              organization_id,
                                              request_id,
                                              error_message,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login)
                    VALUES (p_batch_id,
                            r1.item_master_id,
                            l_item_org_hierarchy_id,
                            l_organization_id,
                            fnd_global.conc_request_id,
                            l_message,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id);

               UPDATE xxdbl_item_master im
                  SET im.item_status = 'ERROR'
                WHERE im.item_master_id = r1.item_master_id;

               UPDATE xxdbl_item_orgs io
                  SET io.item_status = 'ERROR'
                WHERE     io.item_master_id = r1.item_master_id
                      AND io.item_status != 'EXISTS';

               lt_item_table.DELETE;
               x_item_table.DELETE;
            WHEN OTHERS
            THEN
               ROLLBACK TO SAVEPOINT x_loop_start;
               l_message :=
                  SUBSTRB (
                     'Unexpected Error - ' || l_stage || ' - ' || SQLERRM,
                     1,
                     4000);
               p_retcode := '1';
               p_errbuff := SUBSTRB (l_message, 1, 100);
               writedebug (l_message);

               INSERT INTO xxdbl_item_errors (batch_id,
                                              item_master_id,
                                              item_org_hierarchy_id,
                                              organization_id,
                                              request_id,
                                              error_message,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login)
                    VALUES (p_batch_id,
                            r1.item_master_id,
                            l_item_org_hierarchy_id,
                            l_organization_id,
                            fnd_global.conc_request_id,
                            l_message,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.user_id,
                            SYSDATE,
                            fnd_global.login_id);

               UPDATE xxdbl_item_master im
                  SET im.item_status = 'ERROR'
                WHERE im.item_master_id = r1.item_master_id;

               UPDATE xxdbl_item_orgs io
                  SET io.item_status = 'ERROR'
                WHERE     io.item_master_id = r1.item_master_id
                      AND io.item_status != 'EXISTS';

               lt_item_table.DELETE;
               x_item_table.DELETE;
         END;
      END LOOP cur_item_master;

      SELECT COUNT (1)
        INTO l_complete_count
        FROM xxdbl_item_master
       WHERE batch_id = p_batch_id AND item_status = 'COMPLETED';

      SELECT COUNT (1)
        INTO l_error_count
        FROM xxdbl_item_master
       WHERE batch_id = p_batch_id AND item_status = 'ERROR';

      IF l_error_count = 0 AND l_complete_count > 0
      THEN
         l_batch_status := 'COMPLETED';
      ELSIF l_error_count > 0 AND l_complete_count > 0
      THEN
         l_batch_status := 'PARTIAL';
      ELSIF l_error_count > 0 AND l_complete_count = 0
      THEN
         l_batch_status := 'ERROR';
      END IF;

      UPDATE xxdbl_item_batches
         SET batch_status = l_batch_status
       WHERE batch_id = p_batch_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_message := SUBSTRB ('Unexpected error : ' || SQLERRM, 1, 4000);
         p_retcode := '2';
         p_errbuff := SUBSTRB (l_message, 1, 100);
         writedebug (l_message);
   END call_item_api;

   PROCEDURE copy_items_from_batch (p_batch_id        IN     NUMBER,
                                    x_new_batch_id       OUT NUMBER,
                                    x_return_status      OUT VARCHAR2,
                                    x_message            OUT VARCHAR2)
   IS
      l_user_id          NUMBER := fnd_global.user_id;
      l_sysdate          DATE := SYSDATE;
      l_login_id         NUMBER := fnd_global.login_id;
      l_stage            VARCHAR2 (100);
      l_item_master_id   NUMBER;

      CURSOR cur_item_master (cp_batch_id IN NUMBER)
      IS
           SELECT *
             FROM xxdbl_item_master im
            WHERE im.batch_id = cp_batch_id
         ORDER BY im.item_master_id;

      CURSOR cur_elements (cp_item_master_id IN NUMBER)
      IS
           SELECT *
             FROM xxdbl_item_code_elements ice
            WHERE ice.item_master_id = cp_item_master_id
         ORDER BY ice.element_id;
   BEGIN
      l_stage := 'start';
      x_return_status := 'S';
      x_message := 'SUCCESS';

      SELECT xxdbl_item_batch_id_s.NEXTVAL INTO x_new_batch_id FROM DUAL;

      l_stage := 'batch insert';
      SAVEPOINT x_start;

      INSERT INTO xxdbl_item_batches (batch_id,
                                      batch_name,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      request_id,
                                      batch_status,
                                      from_batch_id)
           VALUES (x_new_batch_id,
                   TO_CHAR (x_new_batch_id),
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate,
                   l_login_id,
                   NULL,
                   'NEW',
                   p_batch_id);

      FOR r1 IN cur_item_master (p_batch_id)
      LOOP
         l_stage := 'master insert - ' || r1.item_code;

         SELECT xxdbl_item_master_id_s.NEXTVAL
           INTO l_item_master_id
           FROM DUAL;

         INSERT INTO xxdbl_item_master (item_master_id,
                                        batch_id,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        catalog_group_id,
                                        catalog_type,
                                        item_code,
                                        item_description,
                                        primary_uom_code,
                                        secondary_uom_code,
                                        dual_uom_flag,
                                        uom_conversion,
                                        long_description,
                                        item_status,
                                        from_master_id,
                                        from_batch_id)
              VALUES (l_item_master_id,
                      x_new_batch_id,
                      l_user_id,
                      l_sysdate,
                      l_user_id,
                      l_sysdate,
                      l_login_id,
                      r1.catalog_group_id,
                      r1.catalog_type,
                      r1.item_code,
                      r1.item_description,
                      r1.primary_uom_code,
                      r1.secondary_uom_code,
                      r1.dual_uom_flag,
                      r1.uom_conversion,
                      r1.long_description,
                      'NEW',
                      r1.item_master_id,
                      p_batch_id);

         FOR r2 IN cur_elements (r1.item_master_id)
         LOOP
            l_stage :=
               SUBSTRB (
                     'element insert - '
                  || r1.item_code
                  || ', '
                  || r2.element_name,
                  1,
                  100);

            INSERT INTO xxdbl_item_code_elements (item_master_id,
                                                  element_id,
                                                  catalog_group_id,
                                                  catalog_group,
                                                  element_name,
                                                  value_set_id,
                                                  value_set_name,
                                                  element_value,
                                                  data_type,
                                                  data_length,
                                                  created_by,
                                                  creation_date,
                                                  last_updated_by,
                                                  last_update_date,
                                                  last_update_login,
                                                  element_desc,
                                                  default_element_flag)
                 VALUES (l_item_master_id,
                         r2.element_id,
                         r2.catalog_group_id,
                         r2.catalog_group,
                         r2.element_name,
                         r2.value_set_id,
                         r2.value_set_name,
                         r2.element_value,
                         r2.data_type,
                         r2.data_length,
                         l_user_id,
                         l_sysdate,
                         l_user_id,
                         l_sysdate,
                         l_login_id,
                         r2.element_desc,
                         r2.default_element_flag);
         END LOOP cur_elements;
      END LOOP cur_item_master;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO SAVEPOINT x_start;
         x_new_batch_id := NULL;
         x_return_status := 'E';
         x_message :=
            SUBSTRB (
               'Error in copying batch - ' || l_stage || ' - ' || SQLERRM,
               1,
               500);
   END copy_items_from_batch;
END xxdbl_item_creation_pkg;
/