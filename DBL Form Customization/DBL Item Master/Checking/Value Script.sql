/* Formatted on 10/24/2021 4:18:11 PM (QP5 v5.365) */
DECLARE
    g_exception               EXCEPTION;
    g_sep                     VARCHAR2 (1) := '.';
    g_success        CONSTANT VARCHAR2 (10) := 'SUCCESS';
    g_master_org     CONSTANT VARCHAR2 (3) := 'IMO';
    g_sysadmin       CONSTANT VARCHAR2 (30) := 'SYSADMIN';
    g_gl_resp        CONSTANT VARCHAR2 (100) := 'GENERAL_LEDGER_SUPER_USER';
    g_orig_user_id            NUMBER;
    g_orig_resp_id            NUMBER;
    g_orig_appl_id            NUMBER;
    g_gl_resp_id              NUMBER;
    g_gl_appl_id              NUMBER;
    g_sys_user_id             NUMBER;
    --------------------------------------------
    l_stage                   VARCHAR2 (500);
    l_expense_account         VARCHAR2 (100);
    l_expense_sub_account     VARCHAR2 (100);
    l_product_line            VARCHAR2 (100);
    l_message                 VARCHAR2 (4000);
    l_organization_id         NUMBER;
    l_item_org_hierarchy_id   NUMBER;
    lt_item_table             ego_item_pub.item_tbl_type;
    x_item_table              ego_item_pub.item_tbl_type;
    x_msg_count               NUMBER;
    x_message_list            error_handler.error_tbl_type;
    x_return_status           VARCHAR2 (10);
    lr_item_code              VARCHAR2 (20) := 'SPRECONS000000087791';
    lr_organization_code      VARCHAR2 (10) := '194';
BEGIN
    l_organization_id := 151;                            --r2.organization_id;
    l_item_org_hierarchy_id := 82907;              --r2.item_org_hierarchy_id;
    ------- Attributes from Item master ------------
    lt_item_table (1).transaction_type := 'CREATE';
    lt_item_table (1).item_catalog_group_id := 2006;    --r1.catalog_group_id;
    lt_item_table (1).inventory_item_status_code := 'Active';
    lt_item_table (1).primary_uom_code := 'PCS';        --r1.primary_uom_code;
    lt_item_table (1).item_number := lr_item_code;
    lt_item_table (1).segment1 := lr_item_code;
    lt_item_table (1).description :=
        'COPPER AIR TERMINAL CLASS-1 (12MM, 2’ LENGTH)'; --r1.item_description;
    lt_item_table (1).long_description :=
        'COPPER AIR TERMINAL CLASS-1 (12MM, 2’ LENGTH)'; --r1.long_description;
    lt_item_table (1).secondary_uom_code := NULL;     --r1.secondary_uom_code;
    lt_item_table (1).organization_id := 138;             --l_organization_id;
    lt_item_table (1).list_price_per_unit := 1;

    SELECT DECODE (                                        --r1.dual_uom_flag,
                   'N', 'Y', 4, 1)
      INTO lt_item_table (1).dual_uom_control
      FROM DUAL;

    SELECT DECODE (                                        --r1.dual_uom_flag,
                   'N', 'Y', 'PS', 'P')
      INTO lt_item_table (1).tracking_quantity_ind
      FROM DUAL;

    SELECT DECODE (                                        --r1.dual_uom_flag,
                   'N', 'Y', 'D', '')
      INTO lt_item_table (1).secondary_default_ind
      FROM DUAL;

    ---------- Attributes from Org Hierarchy ----
    lt_item_table (1).template_id := 7082;                   --r2.template_id;
    lt_item_table (1).preprocessing_lead_time := NULL;         --r2.lead_time;
    lt_item_table (1).min_minmax_quantity := NULL;          --r2.min_quantity;
    lt_item_table (1).max_minmax_quantity := NULL;          --r2.max_quantity;
    lt_item_table (1).rfq_required_flag := 'N';                 --r2.rfq_flag;
    lt_item_table (1).receiving_routing_id := NULL;              --r2.routing;
    l_expense_account := '511105';                       --r2.expense_account;
    l_expense_sub_account := '999';                  --r2.expense_sub_account;
    l_product_line := '999';                                --r2.product_line;
    lt_item_table (1).organization_id := 138;             --l_organization_id;
    lt_item_table (1).expense_account := '1223';

    --    gen_expense_ccid (
    --        p_organization_id       => lt_item_table (1).organization_id,
    --        p_expense_acc_code      => l_expense_account,
    --        p_expense_subacc_code   => l_expense_sub_account,
    --        p_product_line          => l_product_line,
    --        x_expense_ccid          => lt_item_table (1).expense_account,
    --        x_message               => l_message);
    --    writedebug ('result from gen_expense_ccid = ' || l_message);

    ---
    IF lt_item_table (1).expense_account = 0
    THEN
        ROLLBACK TO SAVEPOINT x_loop_start;
        RAISE g_exception;
    END IF;

    l_stage :=
        SUBSTRB (
               'API call process_items to org assign item '
            || lr_item_code
            || ' for '
            || lr_organization_code,
            1,
            500);
    DBMS_OUTPUT.PUT_LINE ('Request Phase 1 : ' || l_stage);
    --writedebug (l_stage);
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
            || lr_item_code
            || ' for '
            || lr_organization_code,
            1,
            500);
    DBMS_OUTPUT.PUT_LINE ('Request Phase 2 : ' || l_stage);
    l_message :=
        SUBSTRB (
               l_stage
            || ' - x_return_status = '
            || x_return_status
            || ', x_msg_count = '
            || x_msg_count,
            1,
            4000);
    DBMS_OUTPUT.PUT_LINE ('Request Phase 3 : ' || l_message);

    --writedebug (l_message);

    ---x_inventory_item_id := x_item_table (1).inventory_item_id;
    IF NVL (x_return_status, 'E') != 'S'
    THEN
        ROLLBACK TO SAVEPOINT x_loop_start;
        --writedebug ('Error Messages while item update:');
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
            DBMS_OUTPUT.PUT_LINE ('Request Phase 4 : ' || l_message);
        --writedebug (x_message_list (n).MESSAGE_TEXT);
        END LOOP;

        x_message_list.DELETE;
        RAISE g_exception;
    END IF;
END;