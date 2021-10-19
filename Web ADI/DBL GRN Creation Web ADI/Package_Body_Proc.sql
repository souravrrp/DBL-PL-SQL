/* Formatted on 9/15/2021 9:53:45 AM (QP5 v5.354) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_item_upload_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 10-AUG-2021
    -- LAST UPDATE DATE :11-OCT-2021
    -- PURPOSE : CUSTOM ITEM UPLOAD INTO STAGING TABLE
    FUNCTION check_error_log_to_assign_data
        RETURN NUMBER
    IS
        -------**Check to find only for Org Code-IMO that not Exists**------------
        CURSOR cur_stg IS
            SELECT *
              FROM XXDBL.xxdbl_item_master_conv xxdbl
             WHERE     1 = 1
                   AND xxdbl.status = 'I'
                   AND xxdbl.organization_code = 'IMO'
                   AND EXISTS
                           (SELECT 1
                              FROM mtl_system_items_b msi
                             WHERE     xxdbl.item_code = msi.segment1
                                   AND msi.organization_id = 138
                                   AND TRUNC (msi.creation_date) =
                                       TRUNC (SYSDATE));

        -------**Check the Org Hirearchy to find organization_id**----------------
        CURSOR cur_org_hierarchy (p_org_hierarchy VARCHAR2)
        IS
                       SELECT org.organization_id
                         FROM ORG_ORGANIZATION_DEFINITIONS org,
                              per_org_structure_elements_v pose,
                              per_organization_structures_v os
                        WHERE     1 = 1
                              AND org.organization_id = pose.organization_id_child
                              AND os.organization_structure_id =
                                  pose.org_structure_version_id
                              AND os.name = p_org_hierarchy
                   START WITH pose.organization_id_parent = 138
                   CONNECT BY PRIOR pose.organization_id_child =
                              pose.organization_id_parent
            ORDER SIBLINGS BY pose.organization_id_child;
    BEGIN
        FOR ln_cur_stg IN cur_stg
        LOOP
            BEGIN
                FOR ln_org_hierarchy
                    IN cur_org_hierarchy (ln_cur_stg.org_hierarchy)
                LOOP
                    BEGIN
                        item_assign_template (
                            ln_cur_stg.item_code,
                            ln_org_hierarchy.organization_id,
                            ln_cur_stg.template);

                        IF ln_cur_stg.lcm_enabled = 'Y'
                        THEN
                            create_lcm_item_category (
                                ln_cur_stg.item_code,
                                ln_org_hierarchy.organization_id);
                        END IF;
                    END;
                END LOOP;
            END;

            COMMIT;
        END LOOP;

        RETURN 0;
    END;

    FUNCTION cust_import_data_to_interface (p_item_code VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR cur_intf IS
            SELECT *
              FROM xxdbl.xxdbl_item_master_conv pw
             WHERE     NVL (pw.status, 'X') NOT IN ('I', 'S', 'D')
                   AND pw.item_code = p_item_code;
    BEGIN
        FOR ln_cur_intf IN cur_intf
        LOOP
            BEGIN
                APPS.xxdbl_item_conv_prc;
            END;
        END LOOP;

        RETURN 0;
    END cust_import_data_to_interface;

    PROCEDURE cust_upload_data_to_staging (
        P_ITEM_CODE                VARCHAR2,
        P_ITEM_DESCRIPTION         VARCHAR2,
        P_PRIMARY_UOM              VARCHAR2,
        P_SECONDARY_UOM            VARCHAR2,
        P_ITEM_CONVERSION_FACTOR   NUMBER,
        P_ORGANIZATION_CODE        VARCHAR2,
        P_LOT_CONTROLLED           VARCHAR2,
        P_LOT_DIVISIBLE            VARCHAR2,
        P_DUAL_SINGLE_UOM          VARCHAR2,
        P_DISCRETE_OR_PROCESS      VARCHAR2,
        P_ORG_HIERARCHY            VARCHAR2,
        P_TEMPLATE                 VARCHAR2,
        P_ITEM_TYPE                VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT1   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT2   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT3   VARCHAR2,
        P_ITEM_CATEGORY_SEGMENT4   VARCHAR2,
        P_LCM_ENABLED              VARCHAR2,
        P_LIST_PRICE               NUMBER,
        P_EXPENSE_ACCOUNT          VARCHAR2,
        P_COGS_ACCOUNT             VARCHAR2,
        P_SALES_ACCOUNT            VARCHAR2,
        P_SERIAL_CONTROLLED        VARCHAR2,
        P_SHELF_LIFE               VARCHAR2,
        P_SHELF_LIFE_DAY           VARCHAR2,
        P_MIN_MAX_PLANNING         VARCHAR2,
        P_PLANNER                  VARCHAR2,
        P_MIN_ORDER_QTY            VARCHAR2,
        P_MAX_ORDER_QTY            VARCHAR2,
        P_SAFETY_STOCK             VARCHAR2,
        P_LEAD_TIME                NUMBER,
        P_STATUS                   VARCHAR2,
        P_STATUS_MESSAGE           VARCHAR2,
        P_LEGACY_ITEM_CODE         VARCHAR2,
        P_INVENTORY_ITEM_ID        NUMBER,
        P_ORGANIZATION_ID          NUMBER)
    IS
        len_item_code     NUMBER;
        len_item_desc     NUMBER;
        l_existing_orgh   NUMBER;
        l_category_id     NUMBER;
        l_primary_uom     VARCHAR2 (3);
        l_return_status   NUMBER;
        --------------------------------------------------------------------------

        l_error_message   VARCHAR2 (3000);
        l_error_code      VARCHAR2 (3000);
    BEGIN
        ----------------------------------------
        ----Validate Existing Items code--------
        ----------------------------------------
        BEGIN
            SELECT NVL (COUNT (*), 0)
              INTO l_existing_orgh
              FROM xxdbl.xxdbl_item_master_conv imc
             WHERE     1 = 1
                   AND imc.item_code = p_item_code
                   AND UPPER (imc.item_description) =
                       UPPER (p_item_description);

            IF (l_existing_orgh <> 0)
            THEN
                BEGIN
                    SELECT LENGTH (TRIM (p_item_code))
                      INTO len_item_code
                      FROM DUAL
                     WHERE NOT EXISTS
                               (SELECT 1
                                  FROM xxdbl.xxdbl_item_master_conv imc
                                 WHERE     imc.item_code = p_item_code
                                       AND UPPER (imc.item_description) =
                                           UPPER (p_item_description)
                                       AND (   UPPER (imc.org_hierarchy) =
                                               UPPER (p_org_hierarchy)
                                            OR imc.status IS NULL));
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_error_message :=
                               l_error_message
                            || ','
                            || 'Item Code already exists in the staging table.';
                        l_error_code := 'E';
                END;
            ELSE
                BEGIN
                    SELECT LENGTH (TRIM (p_item_code)),
                           LENGTH (TRIM (p_item_description))
                      INTO len_item_code, len_item_desc
                      FROM DUAL
                     WHERE NOT EXISTS
                               (SELECT 1
                                  FROM mtl_system_items_b msi
                                 WHERE     (   msi.segment1 = p_item_code
                                            OR UPPER (msi.description) =
                                               UPPER (p_item_description))
                                       AND msi.organization_id = 138);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_error_message :=
                               l_error_message
                            || ','
                            || 'Item Code/Description is already exists in Item Master.';
                        l_error_code := 'E';
                END;

                IF ((len_item_code <> 20) OR (len_item_desc > 240))
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please ensure the length of item code is 20 and item description is 240 characters';
                    l_error_code := 'E';
                END IF;
            END IF;
        END;


        --------------------------------------------------
        ----------Validate Item Category-----------------
        --------------------------------------------------
        IF    p_item_category_segment1 IS NOT NULL
           OR p_item_category_segment2 IS NOT NULL
           OR p_item_category_segment3 IS NOT NULL
           OR p_item_category_segment4 IS NOT NULL
        THEN
            BEGIN
                SELECT category_id
                  INTO l_category_id
                  FROM mtl_categories_b mc
                 WHERE     UPPER (mc.segment1) =
                           UPPER (p_item_category_segment1)
                       AND UPPER (mc.segment2) =
                           UPPER (p_item_category_segment2)
                       AND UPPER (mc.segment3) =
                           UPPER (p_item_category_segment3)
                       AND UPPER (mc.segment4) =
                           UPPER (p_item_category_segment4);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct Territory combination.';
                    l_error_code := 'E';
            END;
        ELSE
            SELECT NULL INTO l_category_id FROM DUAL;
        END IF;

        --------------------------------------------------
        ----------Validate Item Category-----------------
        --------------------------------------------------
        IF P_PRIMARY_UOM IS NOT NULL
        THEN
            BEGIN
                SELECT uom_code
                  INTO l_primary_uom
                  FROM mtl_units_of_measure_tl
                 WHERE uom_code = p_primary_uom;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct UOM Code.';
                    l_error_code := 'E';
            END;
        ELSE
            SELECT NULL INTO l_primary_uom FROM DUAL;
        END IF;


        --------------------------------------------------------------------------------------------------------------
        --------Condition to show error if any of the above validation picks up a data entry error--------------------
        --------Condition to insert data into custom staging table if the data passes all above validations-----------
        --------------------------------------------------------------------------------------------------------------


        IF l_error_code = 'E'
        THEN
            raise_application_error (-20101, l_error_message);
        ELSIF NVL (l_error_code, 'A') <> 'E'
        THEN
            INSERT INTO XXDBL.XXDBL_ITEM_MASTER_CONV (COGS_ACCOUNT,
                                                      DISCRETE_OR_PROCESS,
                                                      DUAL_SINGLE_UOM,
                                                      EXPENSE_ACCOUNT,
                                                      INVENTORY_ITEM_ID,
                                                      ITEM_CATEGORY_SEGMENT1,
                                                      ITEM_CATEGORY_SEGMENT2,
                                                      ITEM_CATEGORY_SEGMENT3,
                                                      ITEM_CATEGORY_SEGMENT4,
                                                      ITEM_CODE,
                                                      ITEM_CONVERSION_FACTOR,
                                                      ITEM_DESCRIPTION,
                                                      ITEM_TYPE,
                                                      LCM_ENABLED,
                                                      LEAD_TIME,
                                                      LEGACY_ITEM_CODE,
                                                      LIST_PRICE,
                                                      LOT_CONTROLLED,
                                                      LOT_DIVISIBLE,
                                                      MAX_ORDER_QTY,
                                                      MIN_MAX_PLANNING,
                                                      MIN_ORDER_QTY,
                                                      ORGANIZATION_CODE,
                                                      ORGANIZATION_ID,
                                                      ORG_HIERARCHY,
                                                      PLANNER,
                                                      PRIMARY_UOM,
                                                      SAFETY_STOCK,
                                                      SALES_ACCOUNT,
                                                      SECONDARY_UOM,
                                                      SERIAL_CONTROLLED,
                                                      SHELF_LIFE,
                                                      SHELF_LIFE_DAY,
                                                      STATUS,
                                                      STATUS_MESSAGE,
                                                      TEMPLATE)
                 VALUES (P_COGS_ACCOUNT,
                         P_DISCRETE_OR_PROCESS,
                         P_DUAL_SINGLE_UOM,
                         P_EXPENSE_ACCOUNT,
                         P_INVENTORY_ITEM_ID,
                         P_ITEM_CATEGORY_SEGMENT1,
                         P_ITEM_CATEGORY_SEGMENT2,
                         P_ITEM_CATEGORY_SEGMENT3,
                         P_ITEM_CATEGORY_SEGMENT4,
                         P_ITEM_CODE,
                         P_ITEM_CONVERSION_FACTOR,
                         P_ITEM_DESCRIPTION,
                         P_ITEM_TYPE,
                         P_LCM_ENABLED,
                         P_LEAD_TIME,
                         P_LEGACY_ITEM_CODE,
                         P_LIST_PRICE,
                         P_LOT_CONTROLLED,
                         P_LOT_DIVISIBLE,
                         P_MAX_ORDER_QTY,
                         P_MIN_MAX_PLANNING,
                         P_MIN_ORDER_QTY,
                         P_ORGANIZATION_CODE,
                         P_ORGANIZATION_ID,
                         P_ORG_HIERARCHY,
                         P_PLANNER,
                         P_PRIMARY_UOM,
                         P_SAFETY_STOCK,
                         P_SALES_ACCOUNT,
                         P_SECONDARY_UOM,
                         P_SERIAL_CONTROLLED,
                         P_SHELF_LIFE,
                         P_SHELF_LIFE_DAY,
                         P_STATUS,
                         P_STATUS_MESSAGE,
                         P_TEMPLATE);

            COMMIT;

            ----------------------------------------------------------------------------------------------------
            -----------Insert data into MTL_SYSTEM_ITEMS_INTERFACE after loading into staging table-------------
            ----------------------------------------------------------------------------------------------------

            BEGIN
                --APPS.xxdbl_item_conv_prc;
                --COMMIT;

                l_return_status :=
                    cust_import_data_to_interface (P_ITEM_CODE);
                COMMIT;
            END;
        END IF;
    END cust_upload_data_to_staging;

    PROCEDURE assign_item_org_and_category (ERRBUF    OUT VARCHAR2,
                                            RETCODE   OUT VARCHAR2)
    IS
        L_Retcode              NUMBER;
        CONC_STATUS            BOOLEAN;
        l_error                VARCHAR2 (100);

        ln_req_id              NUMBER;
        lv_req_phase           VARCHAR2 (240);
        lv_req_status          VARCHAR2 (240);
        lv_req_dev_phase       VARCHAR2 (240);
        lv_req_dev_status      VARCHAR2 (240);
        lv_req_message         VARCHAR2 (240);
        lv_req_return_status   BOOLEAN;
    BEGIN
        fnd_file.put_line (fnd_file.LOG, 'Parameter received');


        BEGIN
            fnd_file.put_line (fnd_file.output,
                               '*** Call The Item Import Program  ***');
            FND_GLOBAL.APPS_INITIALIZE (0, 20634, 401);
            MO_GLOBAL.SET_POLICY_CONTEXT ('S', '138');
            FND_GLOBAL.SET_NLS_CONTEXT ('AMERICAN');
            MO_GLOBAL.INIT ('INV');
            ln_req_id :=
                fnd_request.submit_request (application   => 'INV',
                                            Program       => 'INCOIN',
                                            description   => NULL,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => 138,
                                            argument2     => 1,
                                            argument3     => 1,
                                            argument4     => 1,
                                            argument5     => 1,
                                            argument6     => 1000,
                                            argument7     => 1);
            COMMIT;

            IF ln_req_id = 0
            THEN
                fnd_file.put_line (
                    fnd_file.LOG,
                       'Request Not Submitted due to "'
                    || fnd_message.get
                    || '".');
            ELSE
                fnd_file.put_line (
                    fnd_file.LOG,
                       'The Item Import Program submitted - Request id :'
                    || ln_req_id);
            END IF;

            IF ln_req_id > 0
            THEN
                LOOP
                    lv_req_return_status :=
                        fnd_concurrent.wait_for_request (ln_req_id,
                                                         60,
                                                         0,
                                                         lv_req_phase,
                                                         lv_req_status,
                                                         lv_req_dev_phase,
                                                         lv_req_dev_status,
                                                         lv_req_message);
                    EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                              OR UPPER (lv_req_status) IN
                                     ('CANCELLED', 'ERROR', 'TERMINATED');
                END LOOP;

                DBMS_OUTPUT.PUT_LINE (
                    'Request Phase  : ' || lv_req_dev_phase);
                DBMS_OUTPUT.PUT_LINE (
                    'Request Status : ' || lv_req_dev_status);
                DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
                Fnd_File.PUT_LINE (
                    Fnd_File.LOG,
                       'The Item Import Program Completion Phase: '
                    || lv_req_dev_phase);
                Fnd_File.PUT_LINE (
                    Fnd_File.LOG,
                       'The Item Import Program Completion Status: '
                    || lv_req_dev_status);

                CASE
                    WHEN     UPPER (lv_req_phase) = 'COMPLETED'
                         AND UPPER (lv_req_status) = 'ERROR'
                    THEN
                        fnd_file.put_line (
                            fnd_file.LOG,
                            'The Item Import prog completed in error. See log for request id');
                        fnd_file.put_line (fnd_file.LOG, SQLERRM);
                    WHEN    (    UPPER (lv_req_phase) = 'COMPLETED'
                             AND UPPER (lv_req_status) = 'NORMAL')
                         OR (    UPPER (lv_req_phase) = 'COMPLETED'
                             AND UPPER (lv_req_status) = 'WARNING')
                    THEN
                        BEGIN
                            L_Retcode := check_error_log_to_assign_data;
                            Fnd_File.PUT_LINE (
                                Fnd_File.LOG,
                                   'The Item successfully Assigned to the respected Organization for request id: '
                                || ln_req_id);
                        END;

                        Fnd_File.PUT_LINE (
                            Fnd_File.LOG,
                               'The Item Import successfully completed for request id: '
                            || ln_req_id);
                    ELSE
                        Fnd_File.PUT_LINE (
                            Fnd_File.LOG,
                            'The Item Import request failed.Review log for Oracle request id ');
                        Fnd_File.PUT_LINE (Fnd_File.LOG, SQLERRM);
                END CASE;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                fnd_file.put_line (
                    fnd_file.LOG,
                       'OTHERS exception while submitting The Item  Import Program: '
                    || SQLERRM);
        END;

        --L_Retcode := check_error_log_to_assign_data;



        IF L_Retcode = 0
        THEN
            RETCODE := 'Success';
            CONC_STATUS :=
                FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
            fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
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
    END assign_item_org_and_category;

    PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                    tm_org_id          IN NUMBER,
                                    tm_template_name   IN VARCHAR2)
    IS
        l_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
        x_item_tbl             EGO_Item_PUB.Item_Tbl_Type;
        l_msg_data             VARCHAR2 (2000);
        v_context              VARCHAR2 (100);
        tm_Inventory_Item_Id   NUMBER;
        tm_Item_description    VARCHAR2 (100);
        x_return_status        VARCHAR2 (1);
        x_msg_count            NUMBER (10);


        FUNCTION set_context (i_user_name   IN VARCHAR2,
                              i_resp_name   IN VARCHAR2,
                              i_org_id      IN NUMBER)
            RETURN VARCHAR2
        IS
            v_user_id        NUMBER;
            v_resp_id        NUMBER;
            v_resp_appl_id   NUMBER;
            v_lang           VARCHAR2 (100);
            v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
            v_return         VARCHAR2 (10) := 'T';
            v_nls_lang       VARCHAR2 (100);
            v_org_id         NUMBER := i_org_id;

            CURSOR cur_user IS
                SELECT user_id
                  FROM fnd_user
                 WHERE user_name = i_user_name;

            CURSOR cur_resp IS
                SELECT responsibility_id, application_id, language
                  FROM fnd_responsibility_tl
                 WHERE responsibility_name = i_resp_name;

            CURSOR cur_lang (p_lang_code VARCHAR2)
            IS
                SELECT nls_language
                  FROM fnd_languages
                 WHERE language_code = p_lang_code;
        BEGIN
            OPEN cur_user;

            FETCH cur_user INTO v_user_id;

            IF cur_user%NOTFOUND
            THEN
                v_return := 'F';
            END IF;

            CLOSE cur_user;


            OPEN cur_resp;

            FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

            IF cur_resp%NOTFOUND
            THEN
                v_return := 'F';
            END IF;

            CLOSE cur_resp;


            fnd_global.apps_initialize (user_id        => v_user_id,
                                        resp_id        => v_resp_id,
                                        resp_appl_id   => v_resp_appl_id);


            mo_global.set_policy_context ('S', v_org_id);


            IF v_session_lang != v_lang
            THEN
                OPEN cur_lang (v_lang);

                FETCH cur_lang INTO v_nls_lang;

                CLOSE cur_lang;

                fnd_global.set_nls_context (v_nls_lang);
            END IF;

            RETURN v_return;
        EXCEPTION
            WHEN OTHERS
            THEN
                RETURN 'F';
        END set_context;
    BEGIN
        BEGIN
            v_context := set_context ('SYSADMIN', 'Inventory', 131);

            IF v_context = 'F'
            THEN
                DBMS_OUTPUT.PUT_LINE (
                    'Error while setting the context' || SQLERRM (SQLCODE));
            END IF;
        END;

        SELECT inventory_item_id, description
          INTO tm_Inventory_Item_Id, tm_Item_description
          FROM mtl_system_items_b
         WHERE segment1 = tm_item_code AND organization_id = 138;


        l_item_tbl (1).Transaction_Type := 'CREATE';
        l_item_tbl (1).Inventory_Item_Status_Code := 'Active';
        l_item_tbl (1).Organization_ID := tm_org_id;
        l_item_tbl (1).Description := tm_Item_description;
        l_item_tbl (1).Segment1 := tm_item_code;
        l_item_tbl (1).Template_Name := tm_template_name;



        DBMS_OUTPUT.PUT_LINE ('=====================================');
        DBMS_OUTPUT.PUT_LINE ('Calling EGO_ITEM_PUB.Process_Items API');
        ego_item_pub.process_items (p_api_version     => 1.0,
                                    p_init_msg_list   => fnd_api.g_true,
                                    p_commit          => fnd_api.g_true,
                                    p_item_tbl        => l_item_tbl,
                                    x_item_tbl        => x_item_tbl,
                                    x_return_status   => x_return_status,
                                    x_msg_count       => x_msg_count);

        DBMS_OUTPUT.PUT_LINE ('=====================================');


        COMMIT;

        IF x_return_status = 'S'
        THEN
            DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
        ELSIF x_return_status = 'W'
        THEN
            DBMS_OUTPUT.put_line (' Conversion Already Exists ');
        ELSIF x_return_status = 'U'
        THEN
            DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
        ELSIF x_return_status = 'E'
        THEN
            LOOP
                l_msg_data :=
                    FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

                IF l_msg_data IS NULL
                THEN
                    EXIT;
                END IF;

                DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
            END LOOP;
        END IF;
    END item_assign_template;

    PROCEDURE create_lcm_item_category (LCM_ITEM_CODE         VARCHAR2,
                                        Lcm_organization_id   NUMBER)
    IS
        v_return_status       VARCHAR2 (1) := NULL;
        v_msg_count           NUMBER := 0;
        v_msg_data            VARCHAR2 (2000);
        v_errorcode           VARCHAR2 (1000);
        v_category_id         NUMBER;
        v_category_set_id     NUMBER;
        v_inventory_item_id   NUMBER;
        vl_ITEM_ID            NUMBER;
        v_organization_id     NUMBER := Lcm_organization_id;
        v_context             VARCHAR2 (2);



        FUNCTION set_context (i_user_name   IN VARCHAR2,
                              i_resp_name   IN VARCHAR2,
                              i_org_id      IN NUMBER)
            RETURN VARCHAR2
        IS
            v_user_id        NUMBER;
            v_resp_id        NUMBER;
            v_resp_appl_id   NUMBER;
            v_lang           VARCHAR2 (100);
            v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
            v_return         VARCHAR2 (10) := 'T';
            v_nls_lang       VARCHAR2 (100);
            v_org_id         NUMBER := i_org_id;

            CURSOR cur_user IS
                SELECT user_id
                  FROM fnd_user
                 WHERE user_name = i_user_name;

            CURSOR cur_resp IS
                SELECT responsibility_id, application_id, language
                  FROM fnd_responsibility_tl
                 WHERE responsibility_name = i_resp_name;

            CURSOR cur_lang (p_lang_code VARCHAR2)
            IS
                SELECT nls_language
                  FROM fnd_languages
                 WHERE language_code = p_lang_code;
        BEGIN
            SELECT MSI.INVENTORY_ITEM_ID
              INTO vl_ITEM_ID
              FROM APPS.MTL_SYSTEM_ITEMS_B MSI
             WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

            INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE (INVENTORY_ITEM_ID,
                                                       CATEGORY_SET_ID,
                                                       CATEGORY_ID,
                                                       PROCESS_FLAG,
                                                       ORGANIZATION_ID,
                                                       SET_PROCESS_ID,
                                                       TRANSACTION_TYPE)
                 VALUES (vl_ITEM_ID,
                         1,
                         2124,
                         1,
                         v_organization_id,
                         1,
                         'INSERT');

            COMMIT;

            OPEN cur_user;

            FETCH cur_user INTO v_user_id;

            IF cur_user%NOTFOUND
            THEN
                v_return := 'F';
            END IF;

            CLOSE cur_user;

            OPEN cur_resp;

            FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

            IF cur_resp%NOTFOUND
            THEN
                v_return := 'F';
            END IF;

            CLOSE cur_resp;

            fnd_global.apps_initialize (user_id        => v_user_id,
                                        resp_id        => v_resp_id,
                                        resp_appl_id   => v_resp_appl_id);

            mo_global.set_policy_context ('S', v_org_id);


            IF v_session_lang != v_lang
            THEN
                OPEN cur_lang (v_lang);

                FETCH cur_lang INTO v_nls_lang;

                CLOSE cur_lang;

                fnd_global.set_nls_context (v_nls_lang);
            END IF;

            RETURN v_return;
        EXCEPTION
            WHEN OTHERS
            THEN
                RETURN 'F';
        END set_context;
    BEGIN
        v_context := set_context ('SYSADMIN', 'Inventory', 131);

        IF v_context = 'F'
        THEN
            DBMS_OUTPUT.put_line ('Error while setting the context');
        END IF;

        SELECT MSI.INVENTORY_ITEM_ID
          INTO vl_ITEM_ID
          FROM APPS.MTL_SYSTEM_ITEMS_B MSI
         WHERE MSI.SEGMENT1 = LCM_ITEM_CODE AND MSI.ORGANIZATION_ID = 138;

        --- context done ------------
        v_category_id := 2124;
        v_category_set_id := 1100000041;
        v_inventory_item_id := vl_ITEM_ID;
        v_organization_id := v_organization_id;

        INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY_ASSIGNMENT (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_TRUE,
            p_commit              => FND_API.G_FALSE,
            x_return_status       => v_return_status,
            x_errorcode           => v_errorcode,
            x_msg_count           => v_msg_count,
            x_msg_data            => v_msg_data,
            p_category_id         => v_category_id,
            p_category_set_id     => v_category_set_id,
            p_inventory_item_id   => v_inventory_item_id,
            p_organization_id     => v_organization_id);
        COMMIT;

        IF v_return_status = fnd_api.g_ret_sts_success
        THEN
            COMMIT;
            DBMS_OUTPUT.put_line (
                   'The Item assignment to category is Successful : '
                || v_category_id);
        ELSE
            DBMS_OUTPUT.put_line (
                'The Item assignment to category failed:' || v_msg_data);
            ROLLBACK;

            FOR i IN 1 .. v_msg_count
            LOOP
                v_msg_data :=
                    oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
                DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
            END LOOP;
        END IF;
    END create_lcm_item_category;
END xxdbl_item_upload_pkg;
/