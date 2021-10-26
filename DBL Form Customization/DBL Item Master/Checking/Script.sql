/* Formatted on 10/24/2021 10:34:25 AM (QP5 v5.365) */
DECLARE
BEGIN
    l_organization_id := r2.organization_id;
    l_item_org_hierarchy_id := r2.item_org_hierarchy_id;
    ------- Attributes from Item master ------------
    lt_item_table (1).transaction_type := 'CREATE';
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
    ego_item_pub.process_items (p_api_version     => 1.0,
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
        error_handler.get_message_list (x_message_list => x_message_list);
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
END;