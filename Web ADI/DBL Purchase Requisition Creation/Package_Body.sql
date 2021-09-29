/* Formatted on 9/29/2021 9:38:15 AM (QP5 v5.354) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_pr_creation_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 28-SEP-2021
    -- LAST UPDATE DATE :29-SEP-2021
    -- PURPOSE : DBL Purchase Requisition Creation
    PROCEDURE create_pr_from_interface (ERRBUF    OUT VARCHAR2,
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
                fnd_request.submit_request (APPLICATION   => 'PO', --Application,
                                            PROGRAM       => 'REQIMPORT', --Program,
                                            ARGUMENT1     => '', --Interface Source code,
                                            ARGUMENT2     => '',   --Batch ID,
                                            ARGUMENT3     => 'ALL', --Group By,
                                            ARGUMENT4     => '', --Last Req Number,
                                            ARGUMENT5     => 'N', --Multi Distributions,
                                            ARGUMENT6     => 'Y' --Initiate Approval after ReqImport
                                                                );
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
                            --L_Retcode := check_error_log_to_assign_data;
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
    END create_pr_from_interface;

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
        --------------------------------------------------
        ----------Validate Item UOM-----------------
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

                IF ((len_item_code > 20) OR (len_item_desc > 240))
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



        --------------------------------------------------------------------------------------------------------------
        --------Condition to show error if any of the above validation picks up a data entry error--------------------
        --------Condition to insert data into custom staging table if the data passes all above validations-----------
        --------------------------------------------------------------------------------------------------------------


        IF l_error_code = 'E'
        THEN
            raise_application_error (-20101, l_error_message);
        ELSIF NVL (l_error_code, 'A') <> 'E'
        THEN
            INSERT INTO apps.po_requisitions_interface_all (
                            interface_source_code,
                            org_id,
                            destination_type_code,
                            authorization_status,
                            preparer_id,
                            charge_account_id,
                            source_type_code,
                            unit_of_measure,
                            line_type_id,
                            quantity,
                            destination_organization_id,
                            deliver_to_location_id,
                            deliver_to_requestor_id,
                            item_id,
                            need_by_date,
                            suggested_vendor_name,
                            unit_price)
                 VALUES ('IMPORT_INV',
                         p_org_id, --org_id--(Validate against apps.org_organization_definitions table)
                         'INVENTORY',
                         'INCOMPLETE',
                         p_user_id, --preparer_id--(Validate against apps.per_all_people_f tabel)
                         13185, --charge_account_id--(Vlidate against apps.mtl_system_items_b corresponding to item and inv org),
                         'VENDOR',                         --SOURCE_TYPE_CODE,
                         'METRICTON',                        --UNIT_OF_MEASURE
                         1,                 --(Validate against PO_LINE_TYPES)
                         100,                                       --QUANTITY
                         204,                   --DESTINATION_ORGANIZATION_ID,
                         27108,                      --DELIVER_TO_LOCATION_ID,
                         25,                         --DELIVER_TO_REQUESTOR_ID
                         208955,       --(Validate against mtl_system_items_b)
                         SYSDATE,                               --NEED_BY_DATE
                         'Staples',                    --SUGGESTED_VENDOR_NAME
                         1                                        --UNIT_PRICE
                          );

            COMMIT;
        ----------------------------------------------------------------------------------------------------
        -----------Insert data into MTL_SYSTEM_ITEMS_INTERFACE after loading into staging table-------------
        ----------------------------------------------------------------------------------------------------

        --BEGIN
        --APPS.xxdbl_item_conv_prc;
        --COMMIT;
        --l_return_status := cust_import_data_to_interface (P_ITEM_CODE);
        --COMMIT;
        --END;
        END IF;
    END cust_upload_data_to_staging;
END xxdbl_pr_creation_pkg;