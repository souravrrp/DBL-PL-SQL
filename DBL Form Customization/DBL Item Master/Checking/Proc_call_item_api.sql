/* Formatted on 10/24/2021 10:30:30 AM (QP5 v5.365) */
PROCEDURE call_item_api (p_errbuff       OUT VARCHAR2,
                         p_retcode       OUT VARCHAR2,
                         p_batch_id   IN     NUMBER)
IS
    CURSOR cur_item_master IS
        SELECT b.batch_name, xim.*
          FROM xxdbl_item_master xim, xxdbl_item_batches b
         WHERE     xim.batch_id = p_batch_id
               AND b.batch_id = xim.batch_id
               AND xim.item_status != 'COMPLETED';

    CURSOR cur_org_items (p_item_master_id      IN NUMBER,
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
     WHERE master_organization_id = organization_id;

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
                lt_item_table (1).item_catalog_group_id :=
                    r1.catalog_group_id;
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
                    x_expense_ccid          =>
                        lt_item_table (1).expense_account,
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

                IF     l_category_set_id IS NOT NULL
                   AND l_category_id IS NOT NULL
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
                           'Existing x_inventory_item_id = '
                        || x_inventory_item_id);
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
                lt_item_table (1).item_catalog_group_id :=
                    r1.catalog_group_id;
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
                    x_expense_ccid          =>
                        lt_item_table (1).expense_account,
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
                        IN (SELECT mcs.default_category_id,
                                   mcs.category_set_id
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
                                SUBSTRB (l_stage || '**' || l_message,
                                         1,
                                         4000);
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