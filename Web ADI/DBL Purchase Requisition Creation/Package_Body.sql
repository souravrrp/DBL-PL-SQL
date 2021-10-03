/* Formatted on 10/2/2021 11:53:46 AM (QP5 v5.365) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_pr_creation_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 28-SEP-2021
    -- LAST UPDATE DATE :02-OCT-2021
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

    PROCEDURE cust_upload_data_to_staging (p_organization_code   VARCHAR2,
                                           p_line_type           VARCHAR2,
                                           p_item_code           VARCHAR2,
                                           p_item_category       VARCHAR2,
                                           p_quantity            NUMBER,
                                           p_unit_price          NUMBER,
                                           p_specification       VARCHAR2)
    IS
        ------------------------------------------------------------------------
        l_org_id                        NUMBER;
        l_destination_organization_id   NUMBER;
        l_deliver_to_location_id        NUMBER;
        ------------------------------------------------------------------------
        l_line_type_id                  NUMBER;
        ------------------------------------------------------------------------
        l_inventory_item_id             NUMBER;
        l_primary_uom_code              VARCHAR2 (3);
        l_primary_unit_of_measure       VARCHAR2 (25);
        l_expense_account               NUMBER;
        l_item_category_id              NUMBER;
        l_category_id                   NUMBER;
        l_person_id                     NUMBER;
        ------------------------------------------------------------------------

        l_error_message                 VARCHAR2 (3000);
        l_error_code                    VARCHAR2 (3000);
    BEGIN
        --------------------------------------------------
        ----------Validate Organization-------------------
        --------------------------------------------------
        BEGIN
            SELECT ood.operating_unit, ood.organization_id, aou.location_id
              INTO l_org_id,
                   l_destination_organization_id,
                   l_deliver_to_location_id
              FROM apps.org_organization_definitions  ood,
                   hr.hr_all_organization_units       aou
             WHERE     ood.organization_code = p_organization_code
                   AND ood.organization_id = aou.organization_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_error_message :=
                       l_error_message
                    || ','
                    || 'Please enter correct Organization Code.';
                l_error_code := 'E';
        END;

        --------------------------------------------------
        ----------Validate Item Code----------------------
        --------------------------------------------------
        IF p_item_code IS NOT NULL
        THEN
            BEGIN
                SELECT msi.inventory_item_id,
                       msi.primary_uom_code,
                       msi.primary_unit_of_measure,
                       msi.expense_account,
                       cat.category_id
                  INTO l_inventory_item_id,
                       l_primary_uom_code,
                       l_primary_unit_of_measure,
                       l_expense_account,
                       l_item_category_id
                  FROM apps.mtl_system_items_b     msi,
                       apps.mtl_item_categories_v  cat
                 WHERE     msi.inventory_item_id = cat.inventory_item_id
                       AND msi.organization_id = cat.organization_id
                       AND msi.segment1 = p_item_code
                       AND msi.organization_id =
                           l_destination_organization_id;
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
            SELECT NULL,
                   NULL,
                   NULL,
                   NULL
              INTO l_inventory_item_id,
                   l_primary_uom_code,
                   l_expense_account,
                   l_item_category_id
              FROM DUAL;
        END IF;

        --------------------------------------------------
        ----------Validate Item Category-----------------
        --------------------------------------------------
        IF p_item_category IS NOT NULL
        THEN
            BEGIN
                SELECT category_id
                  INTO l_category_id
                  FROM mtl_categories_b mc
                 WHERE     UPPER (
                                  mc.segment1
                               || '.'
                               || mc.segment2
                               || '.'
                               || mc.segment3
                               || '.'
                               || mc.segment4) <>
                           UPPER ('NA.NA.NA.NA')
                       AND UPPER (
                                  mc.segment1
                               || '.'
                               || mc.segment2
                               || '.'
                               || mc.segment3
                               || '.'
                               || mc.segment4) =
                           UPPER (p_item_category);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_message :=
                           l_error_message
                        || ','
                        || 'Please enter correct category combination.'
                        || p_item_category
                        || ' is not available';
                    l_error_code := 'E';
            END;
        ELSE
            SELECT NULL INTO l_category_id FROM DUAL;
        END IF;



        --------------------------------------------------
        ----------Validate PO Line Type-------------------
        --------------------------------------------------

        BEGIN
            SELECT plt.line_type_id
              INTO l_line_type_id
              FROM apps.po_line_types plt
             WHERE 1 = 1 AND plt.line_type = p_line_type;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_error_message :=
                       l_error_message
                    || ','
                    || 'Please enter correct PO Line Type.';
                l_error_code := 'E';
        END;

        --------------------------------------------------
        ----------Validate PO Line Type-------------------
        --------------------------------------------------

        BEGIN
            SELECT employee_id
              INTO l_person_id
              FROM applsys.fnd_user
             WHERE user_id = p_user_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_error_message :=
                       l_error_message
                    || ','
                    || 'Please enter correct PO Line Type.';
                l_error_code := 'E';
        END;


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
                            INTERFACE_SOURCE_CODE,
                            ORG_ID,
                            DESTINATION_TYPE_CODE,
                            AUTHORIZATION_STATUS,
                            PREPARER_ID,
                            CHARGE_ACCOUNT_ID,
                            SOURCE_TYPE_CODE,
                            UNIT_OF_MEASURE,
                            LINE_TYPE_ID,
                            QUANTITY,
                            DESTINATION_ORGANIZATION_ID,
                            DELIVER_TO_LOCATION_ID,
                            DELIVER_TO_REQUESTOR_ID,
                            ITEM_ID,
                            NEED_BY_DATE,
                            UNIT_PRICE,
                            LINE_ATTRIBUTE6)
                 VALUES ('IMPORT_INV',                 --interface_source_code
                         NVL (l_org_id, p_org_id),                    --org_id
                         'INVENTORY',                  --destination_type_code
                         'INCOMPLETE',                  --authorization_status
                         NVL (l_person_id, 2030),                --preparer_id
                         l_expense_account,                --charge_account_id
                         'VENDOR',                          --source_type_code
                         l_primary_unit_of_measure,          --unit_of_measure
                         l_line_type_id,                        --line_type_id
                         NVL (p_quantity, 1),                       --quantity
                         l_destination_organization_id, --destination_organization_id
                         l_deliver_to_location_id,   --deliver_to_location_id,
                         NVL (l_person_id, 2030),    --deliver_to_requestor_id
                         l_inventory_item_id,                        --item_id
                         SYSDATE + 2,                           --need_by_date
                         NVL (p_unit_price, 1),                   --unit_price
                         p_specification       --line_attribute6 --specication
                                        );

            COMMIT;
        END IF;
    END cust_upload_data_to_staging;
END xxdbl_pr_creation_pkg;