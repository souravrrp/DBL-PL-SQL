/* Formatted on 9/15/2020 10:55:26 AM (QP5 v5.354) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_sedomast_inbound_pkg
AS
    /***********************************************************************************
    * $Header$
    * Program Name : XXDBL_SEDOMAST_INBOUND_PKG.pkb
    * Language     : PL/SQL
    * Description  : Package for loading data from flatfile to
    *                staging table, validate and insert data into
    *                OPM base table in Oracle EBS using interface.
    * HISTORY
    *===================================================================================
    * Author                      Version                              Date
    *===================================================================================
    * Titas Lahiri-PwC   1.0 - Initial Version                        08/JAN/2019
    * Titas Lahiri-PwC   1.1 - Remove request id so that              28/AUG/2019
    *                          transaction from older
    *                          requests can be processed.
    * Sanjoy Das -PwC    1.2 - Make the material transacction on
    *                          the end_time given in the inbound
    *                          data file
    * Titas Lahiri-PwC   1.3 - Lot common UOM logic related logic     12/DEC/2019
                               commented as primary uom is used.
    * Titas Lahiri-PwC   1.4 - Batch status col is added and          24/JAN/2020
                               process where its value not zero.
    * Titas Lahiri-PwC   1.5 - Record not to be processed when        05/FEB/2020
                               start_time value is '01/01/1990'.
                               process where its value not zero.
    * Titas Lahiri-PwC   1.6 - Record that's errored in transaction   13/SEP/2020
                               creation API is not to be re-processed
                               after the containing batch gets closed.
    ***********************************************************************************/

    --- Pkg Body Global Variables , Record types and Exceptions -------------------------------------------
    g_pkg   VARCHAR2 (31) := 'XXDBL_SEDOMAST_INBOUND_PKG.';
    g_obj   VARCHAR2 (30);                            -- Function or Procedure

    --
    -- Utility PRC to write 'log' or 'dbms_output'. Not defined in Pkg Spec
    PROCEDURE writelog (p_text IN VARCHAR2, p_type IN VARCHAR2 DEFAULT 'LOG')
    IS
    BEGIN
        IF fnd_global.conc_request_id > 0
        THEN
            IF p_type = 'LOG'
            THEN
                fnd_file.put_line (fnd_file.LOG, p_text);
            ELSE
                fnd_file.put_line (fnd_file.output, p_text);
            END IF;
        ELSE
            DBMS_OUTPUT.ENABLE;
            DBMS_OUTPUT.put_line (p_text);
        END IF;
    END writelog;

    --
    -- Called from Conc. Program
    PROCEDURE main_prc (x_errbuff OUT VARCHAR2, x_retcode OUT VARCHAR2)
    IS
        p_request_id     NUMBER;
        l_user_id        NUMBER;
        l_resp_id        NUMBER;
        l_resp_appl_id   NUMBER;
    BEGIN
        g_obj := 'MAIN_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);
        --
        --Initialization for backend program submit
        p_request_id := fnd_global.conc_request_id;

        IF p_request_id <= 0
        THEN
            apps.fnd_global.apps_initialize (1130, 23326, 553);
            p_request_id := test_s.NEXTVAL;
        END IF;

        writelog ('Request Id ' || p_request_id);
        --
        -- Call procedure to get file through FTP
        ftp_prc;
        --
        -- Call procedure to load data
        load_prc (p_request_id);
        --
        --    Call procedure to validate data
        validate_prc (p_request_id);
        --
        -- Call procedure to Create Ingredient Line
        create_line_prc (p_request_id);
        --
        -- Procedure Create Transaction
        create_transaction_prc (p_request_id);
    --    Call program to show errors
    --      show_errors (p_request_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            writelog ('Unexpected Error: ' || SQLERRM);
    END main_prc;

    --
    -- Procedure load data
    PROCEDURE ftp_prc
    IS
        l_ftp_request_id   NUMBER := NULL;
        l_wait             BOOLEAN := TRUE;
        l_phase            VARCHAR2 (30);
        l_status           VARCHAR2 (30);
        l_dev_phase        VARCHAR2 (30);
        l_dev_status       VARCHAR2 (30);
        l_complete         BOOLEAN;
        l_message          VARCHAR2 (1000);
        l_wait_time        NUMBER := 5;
    --
    BEGIN
        g_obj := 'FTP_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);
        --
        -- Submit Conc Req for OPM data load
        writelog ('Submit Request to get Sedo file through FTP');
        --
        --
        l_ftp_request_id :=
            fnd_request.submit_request (
                application   => 'XXDBL',
                program       => 'XXDBL_SEDOMASTER_INBOUND_FTP',
                start_time    => TO_CHAR (SYSDATE, 'DD-MON-RR HH24MISS'));
        COMMIT;
        --
        writelog ('FTP request Id: ' || l_ftp_request_id);

        IF l_ftp_request_id > 0
        THEN
            l_wait := TRUE;
            l_phase := NULL;
            l_status := NULL;
            l_dev_phase := NULL;
            l_dev_status := NULL;
            l_complete := NULL;
            l_message := NULL;
            l_wait_time := 5;

            --
            IF l_wait
            THEN
                WHILE fnd_concurrent.wait_for_request (l_ftp_request_id,
                                                       l_wait_time,
                                                       0,
                                                       l_phase,
                                                       l_status,
                                                       l_dev_phase,
                                                       l_dev_status,
                                                       l_message)
                LOOP
                    EXIT WHEN    UPPER (l_phase) = 'COMPLETED'
                              OR UPPER (l_status) IN
                                     ('CANCELLED', 'ERROR', 'TERMINATED');
                END LOOP;
            END IF;

            COMMIT;
        END IF;
    --
    EXCEPTION
        WHEN OTHERS
        THEN
            writelog (
                   'Error in submitting DBL SedoMaster Inbound FTP Program '
                || TO_CHAR (SQLCODE)
                || ': '
                || SQLERRM);
    END ftp_prc;

    --
    -- Procedure load data
    /*
    PROCEDURE load_prc (p_request_id IN NUMBER)
    IS
        p_opm_dat_file_name     VARCHAR2 (100);
        p_opm_dat_file_path     VARCHAR2 (100);
        p_opm_ctl_file_name     VARCHAR2 (100);
        l_dataload_request_id   NUMBER := NULL;
        l_key_request_id        NUMBER := NULL;
        l_class_request_id      NUMBER := NULL;
        l_task_request_id       NUMBER := NULL;
        l_wait                  BOOLEAN := TRUE;
        l_phase                 VARCHAR2 (30);
        l_status                VARCHAR2 (30);
        l_dev_phase             VARCHAR2 (30);
        l_dev_status            VARCHAR2 (30);
        l_complete              BOOLEAN;
        l_message               VARCHAR2 (1000);
        l_wait_time             NUMBER := 5;
        l_count                 NUMBER;
    --
    BEGIN
        g_obj := 'LOAD_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);
        --
        -- Submit Conc Req for OPM data load
        writelog ('Submit Request for OPM data load');
        --
        --
        l_dataload_request_id :=
            fnd_request.submit_request (
                application   => 'XXDBL',
                program       => 'XXDBL_DATA_LOAD',
                start_time    => TO_CHAR (SYSDATE, 'DD-MON-RR HH24MISS'),
                argument1     => 'XXDBL_OPM_CONV.ctl',
                argument2     => 'SEDO_INPUT',
                argument3     => '*.DAT');
        COMMIT;
        --
        writelog ('Dataload request Id: ' || l_dataload_request_id);

        IF l_dataload_request_id > 0
        THEN
            l_wait := TRUE;
            l_phase := NULL;
            l_status := NULL;
            l_dev_phase := NULL;
            l_dev_status := NULL;
            l_complete := NULL;
            l_message := NULL;
            l_wait_time := 5;

            --
            IF l_wait
            THEN
                WHILE fnd_concurrent.wait_for_request (l_dataload_request_id,
                                                       l_wait_time,
                                                       0,
                                                       l_phase,
                                                       l_status,
                                                       l_dev_phase,
                                                       l_dev_status,
                                                       l_message)
                LOOP
                    EXIT WHEN    UPPER (l_phase) = 'COMPLETED'
                              OR UPPER (l_status) IN
                                     ('CANCELLED', 'ERROR', 'TERMINATED');
                END LOOP;
            END IF;

            COMMIT;
        END IF;

        UPDATE apps.xxdbl_opm_conv_stg
           SET inv_org_code = '193',
               --             subinventory_code = 'DY-SFLR',
               --             lot_number = 'DYSGOL518.',
               step_no = '30',
               validation_status = g_default,
               validation_error_message = NULL,
               creation_date = SYSDATE,
               created_by = fnd_global.user_id,
               last_update_date = SYSDATE,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id,
               request_id = p_request_id,
               record_id = xxdbl_sedomst_in_record_id_s.NEXTVAL
         WHERE request_id IS NULL--       AND NVL (api_status, g_default) <> g_success
                                 ;

        writelog (
               'Total number of records for transaction             :'
            || SQL%ROWCOUNT);

        IF SQL%ROWCOUNT = 0
        THEN
            --          exit program
            NULL;
        END IF;

        COMMIT;
    --
    EXCEPTION
        WHEN OTHERS
        THEN
            writelog (
                   'Error in submitting DBL Data Load Program '
                || TO_CHAR (SQLCODE)
                || ': '
                || SQLERRM);
    END load_prc;
    */

    --
    --   -- Procedure Validate data
    PROCEDURE validate_prc (p_request_id IN NUMBER)
    IS
        l_validation_error            VARCHAR2 (2000);
        l_tot_rec_count               NUMBER;
        l_inv_org_id                  NUMBER;
        l_batch_id                    NUMBER;
        l_inventory_item_id           NUMBER;
        l_subinventory_code           VARCHAR2 (80);
        l_batch_number                VARCHAR2 (80);
        l_uom                         VARCHAR2 (80);
        l_lot_uom_code                VARCHAR2 (80);
        l_rec_cnt                     NUMBER;
        l_count                       NUMBER;
        l_total_available_quantity    NUMBER;
        l_transaction_uom_conv_rate   NUMBER;
        l_lot_uom_conv_rate           NUMBER;
        l_converted_availability      NUMBER;
        l_conversion_rate             NUMBER;
        l_tran_qty                    NUMBER;
    --
    BEGIN
        g_obj := 'VALIDATE_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);

        SELECT COUNT (*)
          INTO l_tot_rec_count
          FROM xxdbl_opm_conv_stg
         WHERE     NVL (validation_status, g_default) <> g_success --added on 28-Aug
               --request_id = p_request_id --commited on 28-Aug
               --AND NVL (api_status, g_default) <> g_success
               AND batch_status <> 0               --added on 24-JAN-2020 V1.4
               AND start_time <> '01/01/1990'      --added on 05/FEB/2020 V1.5
                                             ;

        --
        l_rec_cnt := 0;

        FOR r_opm
            IN (SELECT ROWID h_rowid, xocs.*
                  FROM xxdbl_opm_conv_stg xocs
                 WHERE     1 = 1 --    request_id = p_request_id --commited on 28-Aug
                       AND batch_status <> 0       --added on 24-JAN-2020 V1.4
                       AND start_time <> '01/01/1990' --added on 05/FEB/2020 V1.5
                       AND NVL (validation_status, g_default) <> g_success)
        LOOP
            l_validation_error := NULL;
            l_inv_org_id := NULL;
            l_batch_number := NULL;
            l_batch_id := NULL;
            l_inventory_item_id := NULL;
            l_subinventory_code := NULL;
            l_count := NULL;
            l_lot_uom_code := NULL;
            l_total_available_quantity := NULL;
            l_tran_qty := NULL;
            l_transaction_uom_conv_rate := NULL;
            l_lot_uom_conv_rate := NULL;
            l_converted_availability := NULL;
            l_conversion_rate := NULL;

            --
            --inv org check
            IF r_opm.inv_org_code IS NOT NULL
            THEN
                BEGIN
                    SELECT organization_id
                      INTO l_inv_org_id
                      FROM org_organization_definitions ood
                     WHERE organization_code = r_opm.inv_org_code;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Org: '''
                            || r_opm.inv_org_code
                            || ''' is either inactive or not available in the system.';
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error fetching org id for the Org: '''
                            || r_opm.inv_org_code
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            ELSE
                l_validation_error :=
                    l_validation_error || ' INV_ORG_CODE is null.';
            END IF;

            --
            --batch check
            IF r_opm.batch_number IS NOT NULL
            THEN
                BEGIN
                    SELECT SUBSTR (
                               r_opm.batch_number,
                               1,
                               DECODE (INSTR (r_opm.batch_number, ' '),
                                       0, LENGTH (r_opm.batch_number),
                                       INSTR (r_opm.batch_number, ' ') - 1))
                      INTO l_batch_number
                      FROM DUAL;

                    SELECT batch_id
                      INTO l_batch_id
                      FROM fnd_lookup_values flv, gme_batch_header gbh
                     WHERE     gbh.batch_status = flv.lookup_code
                           AND flv.lookup_type = 'GME_BATCH_STATUS'
                           AND flv.meaning IN ('WIP', 'Completed')
                           AND gbh.batch_no = l_batch_number
                           AND organization_id = l_inv_org_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Batch: '''
                            || l_batch_number
                            || ''' is not available in the system or not in proper status.';
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error fetching batch_id for the Batch: '''
                            || l_batch_number
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            ELSE
                l_validation_error :=
                    l_validation_error || ' BATCH_NUMBER is null.';
            END IF;

            IF r_opm.recipe_qty IS NOT NULL
            THEN
                BEGIN
                    SELECT TO_NUMBER (TRIM (r_opm.recipe_qty))
                      INTO l_tran_qty
                      FROM DUAL;
                EXCEPTION
                    WHEN INVALID_NUMBER
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Quantity : '''
                            || r_opm.recipe_qty
                            || ''' is not a number.';
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error converting quantity: '''
                            || l_batch_number
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            ELSE
                l_validation_error :=
                    l_validation_error || ' RECIPE_QTY is null.';
            END IF;

            --
            --item check
            IF r_opm.item_code IS NOT NULL
            THEN
                BEGIN
                    SELECT inventory_item_id, process_supply_subinventory
                      INTO l_inventory_item_id, l_subinventory_code
                      FROM mtl_system_items_b
                     WHERE     organization_id = l_inv_org_id
                           AND segment1 = r_opm.item_code;

                    IF l_subinventory_code IS NULL
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Process supply subinventory is not defined for Item: '''
                            || r_opm.item_code
                            || ''' is not available in the system.';
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Item: '''
                            || r_opm.item_code
                            || ''' is not available in the system.';
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error fetching item_id for the Item: '''
                            || r_opm.item_code
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            ELSE
                l_validation_error :=
                    l_validation_error || ' ITEM_CODE is null.';
            END IF;

            --
            --UOM check
            IF r_opm.uom IS NOT NULL
            THEN
                BEGIN
                    SELECT uom_code
                      INTO l_uom
                      FROM mtl_units_of_measure muom, fnd_lookup_values flv
                     WHERE     muom.uom_code = flv.lookup_code
                           AND flv.lookup_type = 'XXDBL_SEDOMST_UOM_LKP'
                           AND flv.meaning = r_opm.uom;
                --make exchaustive
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Oracle UOM code for SedoMaster UOM: '''
                            || r_opm.uom
                            || ''' is not not mapped in lookup XXDBL_SEDOMST_UOM_LKP or not available in the system.';
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error fetching Oracle UOM code for the SedoMaster UOM: '''
                            || r_opm.uom
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            ELSE
                l_validation_error := l_validation_error || ' UOM is null.';
            END IF;

            --         --determine common uom for availability
            --
            --         IF     l_inv_org_id IS NOT NULL
            --            AND l_inventory_item_id IS NOT NULL
            --            AND l_subinventory_code IS NOT NULL
            --            AND l_uom IS NOT NULL
            --         THEN
            --            BEGIN
            --               SELECT DISTINCT transaction_uom_code
            --                 INTO l_lot_uom_code
            --                 FROM mtl_onhand_quantities_detail
            --                WHERE     organization_id = l_inv_org_id
            --                      AND subinventory_code = l_subinventory_code
            --                      AND inventory_item_id = l_inventory_item_id;
            --            EXCEPTION
            --               WHEN NO_DATA_FOUND
            --               THEN
            --                  l_validation_error :=
            --                        l_validation_error
            --                     || ' Availability not found in subinventory '''
            --                     || l_subinventory_code
            --                     || ''' for item '''
            --                     || r_opm.item_code
            --                     || '''.';
            --               WHEN TOO_MANY_ROWS
            --               THEN
            --                  l_validation_error :=
            --                        l_validation_error
            --                     || ' Multiple UOM code found for different lot in subinventory '''
            --                     || l_subinventory_code
            --                     || ''' for item '''
            --                     || r_opm.item_code
            --                     || '''.';
            --               WHEN OTHERS
            --               THEN
            --                  l_validation_error :=
            --                        l_validation_error
            --                     || ' Error fetching common UOM code for availability. error message: '
            --                     || SQLERRM
            --                     || '.';
            --            END;
            --         END IF;

            --
            -- determine total on hand availability
            --
            IF     l_inv_org_id IS NOT NULL
               AND l_inventory_item_id IS NOT NULL
               AND l_subinventory_code IS NOT NULL
            THEN
                BEGIN
                    SELECT xxdbl_mto_workbench_pkg.available_to_transact (
                               l_inv_org_id,
                               l_inventory_item_id,
                               l_subinventory_code)
                      INTO l_total_available_quantity
                      FROM DUAL;

                    /*SELECT SUM (primary_transaction_quantity)
                      INTO l_total_available_quantity
                      FROM mtl_onhand_quantities_detail
                     WHERE organization_id = l_inv_org_id
                       AND subinventory_code = l_subinventory_code
                       AND inventory_item_id = l_inventory_item_id;*/
                    IF    (l_total_available_quantity IS NULL)
                       OR (l_total_available_quantity = 0)
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Availability not found for Item: '''
                            || r_opm.item_code
                            || ''' in inventory organization: '''
                            || r_opm.inv_org_code
                            || ''' and subinventory: '''
                            || l_subinventory_code
                            || '''.';
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error getting availability for Item: '''
                            || r_opm.item_code
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            END IF;

            IF NVL (l_total_available_quantity, 0) > 0 AND l_uom IS NOT NULL
            THEN
                BEGIN
                    -- get conversion rate for transaction uom
                    SELECT conversion_rate
                      INTO l_transaction_uom_conv_rate
                      FROM mtl_uom_conversions
                     WHERE uom_code = l_uom;

                    --               -- get conversion rate for  commong lot uom
                    --
                    --               SELECT conversion_rate
                    --                 INTO l_lot_uom_conv_rate
                    --                 FROM mtl_uom_conversions
                    --                WHERE uom_code = l_lot_uom_code;

                    -- calculate conversion_rate from primary uom into transaction uom
                    l_conversion_rate := 1 / l_transaction_uom_conv_rate;

                    --    compare availability
                    IF l_total_available_quantity * l_conversion_rate <
                       r_opm.tran_qty
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' On Hand Availability in subinventory '''
                            || l_subinventory_code
                            || ''' for item '''
                            || r_opm.item_code
                            || '''is less than transaction quantity.';
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_validation_error :=
                               l_validation_error
                            || ' Error comparing availability for Item: '''
                            || r_opm.item_code
                            || ''' error message: '
                            || SQLERRM
                            || '.';
                END;
            END IF;

            IF l_validation_error IS NULL
            THEN
                UPDATE xxdbl_opm_conv_stg
                   SET inv_org_id = l_inv_org_id,
                       ora_batch_number = l_batch_number,
                       batch_id = l_batch_id,
                       inventory_item_id = l_inventory_item_id,
                       subinventory_code = l_subinventory_code,
                       uom_code = l_uom,
                       conversion_rate = l_conversion_rate,
                       tran_qty = l_tran_qty,
                       validation_error_message = l_validation_error,
                       validation_status = g_success
                 WHERE ROWID = r_opm.h_rowid;
            ELSE
                UPDATE xxdbl_opm_conv_stg xpd
                   SET inv_org_id = l_inv_org_id,
                       ora_batch_number = l_batch_number,
                       batch_id = l_batch_id,
                       inventory_item_id = l_inventory_item_id,
                       subinventory_code = l_subinventory_code,
                       uom_code = l_uom,
                       conversion_rate = l_conversion_rate,
                       tran_qty = l_tran_qty,
                       validation_error_message = l_validation_error,
                       validation_status = g_fail
                 WHERE ROWID = r_opm.h_rowid;
            END IF;

            l_rec_cnt := l_rec_cnt + 1;

            IF MOD (l_rec_cnt, 1000) = 0
            THEN
                COMMIT;
            END IF;
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            fnd_file.put_line (
                fnd_file.LOG,
                   ' Unexpected error '
                || SQLERRM
                || ' --'
                || DBMS_UTILITY.format_error_backtrace);
    END validate_prc;

    --
    -- Procedure Create Ingredient line
    PROCEDURE create_line_prc (p_request_id IN NUMBER)
    IS
        e_validation_err               EXCEPTION;
        l_validation_fail_count        NUMBER;
        l_conc_req_id                  NUMBER;
        l_po_header_id                 NUMBER;
        l_po_line_id                   NUMBER;
        l_po_line_location_id          NUMBER;
        l_po_dist_id                   NUMBER;
        l_api_error                    VARCHAR2 (2000);
        l_error_msg                    VARCHAR2 (4000) := NULL;
        x_error_message                VARCHAR2 (4100) := NULL;
        x_batch_header                 gme_batch_header%ROWTYPE := NULL;
        e_batch_error                  EXCEPTION;
        e_batch_release_error          EXCEPTION;
        e_mat_transact_error           EXCEPTION;
        l_batch_id                     NUMBER := NULL;
        l_batch_no                     gme_batch_header.batch_no%TYPE := NULL;
        p_api_version                  NUMBER DEFAULT 1;
        p_validation_level             NUMBER DEFAULT gme_common_pvt.g_max_errors;
        p_init_msg_list                BOOLEAN DEFAULT FALSE;
        p_batch_type                   NUMBER DEFAULT 0;
        l_batch_header                 gme_batch_header%ROWTYPE := NULL;
        l_msg_index_out                NUMBER;
        xx_exception_material_tbl      gme_common_pvt.exceptions_tab;
        x_out_batch_header             gme_batch_header%ROWTYPE := NULL;
        l_line_type                    NUMBER := NULL;
        l_line_no                      NUMBER := NULL;
        l_material_detail_id           NUMBER;
        x_mmt_rec                      mtl_material_transactions%ROWTYPE;
        l_mmti_rec                     mtl_transactions_interface%ROWTYPE;
        l_mmli_tbl                     gme_common_pvt.mtl_trans_lots_inter_tbl;
        x_mmln_tbl                     gme_common_pvt.mtl_trans_lots_num_tbl;
        l_transaction_interface_id     NUMBER;
        l_process_yield_subinventory   VARCHAR2 (100);
        l_process_yield_locator_id     NUMBER;
        l_organization_id              NUMBER;
        l_production_date              VARCHAR2 (60);
        l_shift                        VARCHAR2 (100);
        l_mill_no                      VARCHAR2 (100);
        l_routing_no                   VARCHAR2 (100);
        x_message_count                NUMBER;
        l_message_list                 VARCHAR2 (4000) := NULL;
        l_return_status                VARCHAR2 (10) := NULL;
        l_user_id                      fnd_user.user_id%TYPE
                                           := fnd_global.user_id;
        l_resp_id                      NUMBER := fnd_global.resp_id;
        l_resp_appl_id                 NUMBER := fnd_global.resp_appl_id;
        l_organization_code            VARCHAR2 (240) := NULL;
        l_formula_line_id              NUMBER;
        l_uom                          VARCHAR2 (10);
        l_release_type                 NUMBER;
        l_material_detail_rec          gme_material_details%ROWTYPE;
        l_batch_header_rec             gme_batch_header%ROWTYPE;
        x_message_count1               NUMBER;
        x_message_list1                VARCHAR2 (2000);
        x_return_status1               VARCHAR2 (1) := 'T';
        x_material_detail_rec          gme_material_details%ROWTYPE;
        l_validation_level             NUMBER DEFAULT 100;
        l_api_version                  NUMBER := 2.0;
        l_init_msg_list                VARCHAR2 (100) := 'F';
        l_locator_code                 VARCHAR2 (100);
        l_batchstep_no                 NUMBER := NULL;
        l_validate_flexfields          VARCHAR2 (100) := 'F';
        l_commit                       VARCHAR2 (100) := 'F';
        l_start_time                   VARCHAR2 (100);
        l_end_time                     VARCHAR2 (100);
        l_production_date1             DATE;
        l_production_start_date        DATE;
        l_production_end_date          DATE;
        l_rest_quantity_used           NUMBER := 0;
        l_last_day                     DATE;
        l_count                        NUMBER;
    BEGIN
        g_obj := 'CREATE_LINE_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);

        --      --
        --      -- Initialize Staging Table
        --      --
        --
        UPDATE xxdbl_opm_conv_stg
           SET line_api_status = g_default, line_api_error_message = NULL
         WHERE     1 = 1   --   request_id = p_request_id --commited on 28-Aug
               AND batch_status <> 0               --added on 24-JAN-2020 V1.4
               AND validation_status = g_success
               AND NVL (line_api_status, g_default) <> g_success;

        --
        IF SQL%ROWCOUNT = 0
        THEN
            RAISE e_validation_err;
        END IF;

        --
        --
        COMMIT;

        --
        FOR r_opm_line
            IN (  SELECT ROWID h_rowid, h.*
                    FROM xxdbl_opm_conv_stg h
                   WHERE     1 = 1 --request_id = p_request_id --commited on 28-Aug
                         AND batch_status <> 0     --added on 24-JAN-2020 V1.4
                         AND line_api_status = g_default
                ORDER BY record_id)
        LOOP
            BEGIN
                l_material_detail_id := NULL;
                l_line_no := NULL;
                x_error_message := NULL;
                l_error_msg := NULL;
                l_api_error := NULL;

                BEGIN
                    SELECT MIN (material_detail_id)
                      INTO l_material_detail_id
                      FROM gme_batch_header gbh, gme_material_details gmd
                     WHERE     gbh.batch_id = gmd.batch_id
                           AND gbh.organization_id = r_opm_line.inv_org_id
                           AND gmd.batch_id = r_opm_line.batch_id
                           AND gmd.inventory_item_id =
                               r_opm_line.inventory_item_id;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_api_error :=
                               'Unexpected Error to find batch line - '
                            || TO_CHAR (SQLCODE)
                            || ': '
                            || SQLERRM;

                        UPDATE xxdbl_opm_conv_stg
                           SET line_api_status = g_fail,
                               line_api_error_message = l_api_error
                         WHERE ROWID = r_opm_line.h_rowid;

                        CONTINUE;
                END;

                IF l_material_detail_id IS NOT NULL
                THEN
                    UPDATE xxdbl_opm_conv_stg
                       SET line_api_status = g_success,
                           material_detail_id = l_material_detail_id,
                           line_no =
                               (SELECT gmd.line_no
                                  FROM gme_material_details gmd
                                 WHERE gmd.material_detail_id =
                                       l_material_detail_id)
                     WHERE ROWID = r_opm_line.h_rowid;

                    UPDATE gme_material_details
                       SET plan_qty =
                                 NVL (plan_qty, 0)
                               + NVL (r_opm_line.recipe_qty, 0),
                           wip_plan_qty =
                                 NVL (wip_plan_qty, 0)
                               + NVL (r_opm_line.recipe_qty, 0),
                           original_qty =
                                 NVL (original_qty, 0)
                               + NVL (r_opm_line.recipe_qty, 0),
                           original_primary_qty =
                                 NVL (original_primary_qty, 0)
                               + NVL (r_opm_line.recipe_qty, 0)
                     WHERE material_detail_id = l_material_detail_id;
                ELSE
                    x_message_count := NULL;
                    l_message_list := NULL;
                    l_return_status := NULL;
                    l_batch_header_rec.batch_id := r_opm_line.batch_id;
                    l_material_detail_rec.organization_id :=
                        r_opm_line.inv_org_id;
                    l_material_detail_rec.line_type := -1;
                    --   l_material_detail_rec.line_no := 7;
                    l_material_detail_rec.plan_qty := r_opm_line.recipe_qty; --0;
                    l_material_detail_rec.wip_plan_qty :=
                        r_opm_line.recipe_qty;
                    --0;
                    l_material_detail_rec.original_qty :=
                        r_opm_line.recipe_qty;
                    --0;
                    l_material_detail_rec.inventory_item_id :=
                        r_opm_line.inventory_item_id;
                    l_material_detail_rec.original_primary_qty :=
                        r_opm_line.recipe_qty;
                    --0;
                    l_material_detail_rec.dtl_um := r_opm_line.uom_code;
                    l_material_detail_rec.scale_type := 1;
                    l_material_detail_rec.phantom_type := 0;
                    l_material_detail_rec.release_type := 1;
                    l_material_detail_rec.contribute_yield_ind := 'N';
                    l_material_detail_rec.contribute_step_qty_ind := 'N';
                    l_material_detail_rec.cost_alloc := NULL;
                    --
                    -- api code
                    gme_api_pub.insert_material_line (
                        p_api_version           => l_api_version,
                        p_validation_level      => l_validation_level,
                        p_init_msg_list         => l_init_msg_list,
                        p_commit                => l_commit,
                        p_batch_header_rec      => l_batch_header_rec,
                        p_material_detail_rec   => l_material_detail_rec,
                        p_locator_code          => l_locator_code,
                        p_org_code              => '193',
                        p_batchstep_no          => 30,
                        p_validate_flexfields   => l_validate_flexfields,
                        x_material_detail_rec   => x_material_detail_rec,
                        x_message_count         => x_message_count1,
                        x_message_list          => x_message_list1,
                        x_return_status         => x_return_status1);

                    IF TRIM (NVL (x_return_status1, 'E')) <> 'S'
                    THEN
                        l_error_msg :=
                            SUBSTR (
                                   'Material Line Creation Error - '
                                || x_message_list1,
                                1,
                                4000);

                        IF x_error_message IS NULL
                        THEN
                            x_error_message := l_error_msg;
                        ELSE
                            x_error_message :=
                                x_error_message || CHR (10) || l_error_msg;
                        END IF;

                        UPDATE xxdbl_opm_conv_stg
                           SET line_api_status = g_fail,
                               line_api_error_message = x_error_message
                         WHERE ROWID = r_opm_line.h_rowid;
                    ELSE
                        UPDATE gme_material_details
                           SET plan_qty =
                                     NVL (plan_qty, 0)
                                   + NVL (r_opm_line.recipe_qty, 0),
                               wip_plan_qty =
                                     NVL (wip_plan_qty, 0)
                                   + NVL (r_opm_line.recipe_qty, 0),
                               original_qty =
                                     NVL (original_qty, 0)
                                   + NVL (r_opm_line.recipe_qty, 0),
                               original_primary_qty =
                                     NVL (original_primary_qty, 0)
                                   + NVL (r_opm_line.recipe_qty, 0)
                         WHERE material_detail_id =
                               x_material_detail_rec.material_detail_id;

                        UPDATE xxdbl_opm_conv_stg
                           SET line_api_status = g_success,
                               material_detail_id =
                                   x_material_detail_rec.material_detail_id,
                               line_no =
                                   (SELECT gmd.line_no
                                      FROM gme_material_details gmd
                                     WHERE gmd.material_detail_id =
                                           x_material_detail_rec.material_detail_id)
                         WHERE ROWID = r_opm_line.h_rowid;
                    END IF;
                END IF;

                COMMIT;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    l_api_error := l_api_error || ':' || SQLERRM;
                    writelog (l_api_error);

                    UPDATE xxdbl_opm_conv_stg
                       SET line_api_status = g_fail,
                           line_api_error_message = l_api_error
                     WHERE ROWID = r_opm_line.h_rowid;

                    COMMIT;
            END;
        END LOOP;
    EXCEPTION
        WHEN e_validation_err
        THEN
            writelog (
                'No record is validated for batch ingredient line creation!!!');
        WHEN OTHERS
        THEN
            writelog (
                   'Unexpected Error to create batch line - '
                || TO_CHAR (SQLCODE)
                || ': '
                || SQLERRM);
    END create_line_prc;

    --
    -- Procedure Create Transaction
    PROCEDURE create_transaction_prc (p_request_id IN NUMBER)
    IS
        e_validation_err               EXCEPTION;
        l_validation_fail_count        NUMBER;
        l_conc_req_id                  NUMBER;
        l_po_header_id                 NUMBER;
        l_po_line_id                   NUMBER;
        l_po_line_location_id          NUMBER;
        l_po_dist_id                   NUMBER;
        l_api_error                    VARCHAR2 (2000);
        l_error_msg                    VARCHAR2 (4000) := NULL;
        x_error_message                VARCHAR2 (4100) := NULL;
        x_batch_header                 gme_batch_header%ROWTYPE := NULL;
        e_batch_error                  EXCEPTION;
        e_batch_release_error          EXCEPTION;
        e_mat_transact_error           EXCEPTION;
        l_batch_id                     NUMBER := NULL;
        l_batch_no                     gme_batch_header.batch_no%TYPE := NULL;
        p_api_version                  NUMBER DEFAULT 1;
        p_validation_level             NUMBER DEFAULT gme_common_pvt.g_max_errors;
        p_init_msg_list                BOOLEAN DEFAULT FALSE;
        p_batch_type                   NUMBER DEFAULT 0;
        l_batch_header                 gme_batch_header%ROWTYPE := NULL;
        l_msg_index_out                NUMBER;
        xx_exception_material_tbl      gme_common_pvt.exceptions_tab;
        x_out_batch_header             gme_batch_header%ROWTYPE := NULL;
        l_line_type                    NUMBER := NULL;
        l_line_no                      NUMBER := NULL;
        l_material_detail_id           NUMBER;
        x_mmt_rec                      mtl_material_transactions%ROWTYPE;
        l_mmti_rec                     mtl_transactions_interface%ROWTYPE;
        l_mmli_tbl                     gme_common_pvt.mtl_trans_lots_inter_tbl;
        x_mmln_tbl                     gme_common_pvt.mtl_trans_lots_num_tbl;
        l_transaction_interface_id     NUMBER;
        l_process_yield_subinventory   VARCHAR2 (100);
        l_process_yield_locator_id     NUMBER;
        l_organization_id              NUMBER;
        l_production_date              VARCHAR2 (60);
        l_shift                        VARCHAR2 (100);
        l_mill_no                      VARCHAR2 (100);
        l_routing_no                   VARCHAR2 (100);
        x_message_count                NUMBER;
        l_message_list                 VARCHAR2 (4000) := NULL;
        l_return_status                VARCHAR2 (10) := NULL;
        l_user_id                      fnd_user.user_id%TYPE
                                           := fnd_global.user_id;
        l_resp_id                      NUMBER := fnd_global.resp_id;
        l_resp_appl_id                 NUMBER := fnd_global.resp_appl_id;
        l_organization_code            VARCHAR2 (240) := NULL;
        l_formula_line_id              NUMBER;
        l_uom                          VARCHAR2 (10);
        l_release_type                 NUMBER;
        l_material_detail_rec          gme_material_details%ROWTYPE;
        l_batch_header_rec             gme_batch_header%ROWTYPE;
        x_message_count1               NUMBER;
        x_message_list1                VARCHAR2 (2000);
        x_return_status1               VARCHAR2 (1) := 'T';
        x_material_detail_rec          gme_material_details%ROWTYPE;
        l_validation_level             NUMBER DEFAULT 100;
        l_api_version                  NUMBER := 2.0;
        l_init_msg_list                VARCHAR2 (100) := 'F';
        l_locator_code                 VARCHAR2 (100);
        l_batchstep_no                 NUMBER := NULL;
        l_validate_flexfields          VARCHAR2 (100) := 'F';
        l_commit                       VARCHAR2 (100) := 'F';
        l_start_time                   VARCHAR2 (100);
        l_end_time                     VARCHAR2 (100);
        l_production_date1             DATE;
        l_production_start_date        DATE;
        l_production_end_date          DATE;
        l_rest_quantity_used           NUMBER := 0;
        l_last_day                     DATE;
        l_rest_quantity                NUMBER;
        l_counter                      NUMBER;
        l_prev_onhand_quantities_id    NUMBER;
        l_lot_quantity                 NUMBER;
        l_onhand_quantities_id         NUMBER;
    BEGIN
        g_obj := 'CREATE_TRANSACTION_PRC';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);

        --
        --      -- Initialize Staging Table
        --
        UPDATE xxdbl_opm_conv_stg h
           SET transaction_api_status = g_default,
               transaction_api_error_message = NULL
         WHERE     1 = 1     -- request_id = p_request_id --commited on 28-Aug
               AND batch_status <> 0               --added on 24-JAN-2020 V1.4
               AND validation_status = g_success
               AND line_api_status = g_success
               AND NVL (transaction_api_status, g_default) <> g_success
               AND EXISTS                          --added on 13-SEP-2020 V1.6
                       (SELECT 1
                          FROM fnd_lookup_values flv, gme_batch_header gbh
                         WHERE     gbh.batch_status = flv.lookup_code
                               AND flv.lookup_type = 'GME_BATCH_STATUS'
                               AND flv.meaning IN ('WIP', 'Completed')
                               AND gbh.batch_id = h.batch_id);

        --
        IF SQL%ROWCOUNT = 0
        THEN
            RAISE e_validation_err;
        END IF;

        --
        COMMIT;

        --
        FOR r_opm_transaction
            IN (  SELECT ROWID h_rowid, h.*
                    FROM xxdbl_opm_conv_stg h
                   WHERE     1 = 1 --    request_id = p_request_id --commited on 28-Aug
                         AND batch_status <> 0     --added on 24-JAN-2020 V1.4
                         AND transaction_api_status = g_default
                         AND EXISTS                --added on 13-SEP-2020 V1.6
                                 (SELECT 1
                                    FROM fnd_lookup_values flv,
                                         gme_batch_header gbh
                                   WHERE     gbh.batch_status = flv.lookup_code
                                         AND flv.lookup_type =
                                             'GME_BATCH_STATUS'
                                         AND flv.meaning IN
                                                 ('WIP', 'Completed')
                                         AND gbh.batch_id = h.batch_id)
                ORDER BY record_id)
        LOOP
            l_transaction_interface_id := NULL;
            l_rest_quantity := NULL;
            l_counter := NULL;
            l_prev_onhand_quantities_id := NULL;
            l_onhand_quantities_id := NULL;
            l_lot_quantity := NULL;
            l_mmti_rec := NULL;
            l_message_list := NULL;
            l_return_status := NULL;
            l_api_error := NULL;
            x_error_message := NULL;
            x_mmt_rec := NULL;
            x_message_count := NULL;
            --
            x_mmln_tbl.DELETE;
            l_mmli_tbl.DELETE;

            BEGIN
                SELECT mtl_material_transactions_s.NEXTVAL
                  INTO l_transaction_interface_id
                  FROM DUAL;

                -- api code
                l_rest_quantity := r_opm_transaction.tran_qty;
                l_counter := 0;
                l_prev_onhand_quantities_id := 0;

                BEGIN
                    WHILE l_rest_quantity > 0
                    LOOP
                        l_lot_quantity := 0;
                        l_counter := l_counter + 1;
                        l_mmli_tbl (l_counter).transaction_interface_id :=
                            l_transaction_interface_id;

                        SELECT moqd.onhand_quantities_id,
                               moqd.lot_number,
                                 moqd.primary_transaction_quantity
                               * r_opm_transaction.conversion_rate
                          INTO l_onhand_quantities_id,
                               l_mmli_tbl (l_counter).lot_number,
                               l_lot_quantity
                          FROM mtl_onhand_quantities_detail moqd
                         WHERE     moqd.organization_id =
                                   r_opm_transaction.inv_org_id
                               AND moqd.subinventory_code =
                                   r_opm_transaction.subinventory_code
                               AND moqd.inventory_item_id =
                                   r_opm_transaction.inventory_item_id
                               AND moqd.onhand_quantities_id =
                                   (SELECT MIN (moqd1.onhand_quantities_id)
                                      FROM mtl_onhand_quantities_detail moqd1
                                     WHERE     moqd1.organization_id =
                                               r_opm_transaction.inv_org_id
                                           AND moqd1.subinventory_code =
                                               r_opm_transaction.subinventory_code
                                           AND moqd1.inventory_item_id =
                                               r_opm_transaction.inventory_item_id
                                           AND moqd1.onhand_quantities_id >
                                               l_prev_onhand_quantities_id)
                               -- Added By Manas
                               AND xxdbl_mto_workbench_pkg.available_to_transact (
                                       r_opm_transaction.inv_org_id,
                                       r_opm_transaction.inventory_item_id,
                                       r_opm_transaction.subinventory_code,
                                       NULL,
                                       moqd.lot_number) > 0;

                        l_prev_onhand_quantities_id := l_onhand_quantities_id;

                        IF l_lot_quantity > l_rest_quantity
                        THEN
                            l_mmli_tbl (l_counter).transaction_quantity :=
                                l_rest_quantity;
                        ELSE
                            l_mmli_tbl (l_counter).transaction_quantity :=
                                l_lot_quantity;
                        END IF;

                        l_rest_quantity :=
                              l_rest_quantity
                            - l_mmli_tbl (l_counter).transaction_quantity;

                        IF l_mmli_tbl (l_counter).lot_number IS NULL
                        THEN
                            l_mmli_tbl.DELETE;
                        END IF;
                    END LOOP;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        UPDATE xxdbl_opm_conv_stg
                           SET transaction_api_status = g_fail,
                               transaction_api_error_message =
                                   'Error while defining lot quantity.'
                         WHERE ROWID = r_opm_transaction.h_rowid;

                        CONTINUE;
                END;

                l_mmti_rec.subinventory_code :=
                    r_opm_transaction.subinventory_code;
                -- 'DY-SFLR';
                l_mmti_rec.locator_id := NULL;
                l_mmti_rec.transaction_interface_id :=
                    l_transaction_interface_id;
                l_mmti_rec.transaction_header_id :=
                    l_transaction_interface_id;
                l_mmti_rec.process_flag := 1;
                l_mmti_rec.validation_required := 1;
                l_mmti_rec.transaction_mode := 3;
                l_mmti_rec.lock_flag := 2;
                l_mmti_rec.last_update_date := SYSDATE;
                -- r_opm_transaction.end_time;
                l_mmti_rec.last_updated_by := fnd_global.user_id;
                l_mmti_rec.creation_date := SYSDATE;
                -- r_opm_transaction.end_time;
                l_mmti_rec.created_by := fnd_global.user_id;
                l_mmti_rec.last_update_login := fnd_global.login_id;
                l_mmti_rec.transaction_date :=
                    TO_DATE (r_opm_transaction.end_time,
                             'dd/mm/yyyy hh24:mi:ss');
                -- end_time is passed as transaction date as per discussion on 31-Aug-19 with DBL --SYSDATE; --r_opm_transaction.end_time;
                l_mmti_rec.transaction_source_type_id := 5;
                l_mmti_rec.transaction_action_id := 1;
                l_mmti_rec.transaction_type_id := 35;
                --
                l_mmti_rec.transaction_quantity := r_opm_transaction.tran_qty;
                --.03;  --check this
                l_mmti_rec.organization_id := r_opm_transaction.inv_org_id;
                -- 150;
                l_mmti_rec.inventory_item_id :=
                    r_opm_transaction.inventory_item_id;
                --4912;
                --
                l_mmti_rec.transaction_source_id :=
                    r_opm_transaction.batch_id;
                --92039;                   --c1.batch_id;
                l_mmti_rec.transaction_uom := r_opm_transaction.uom_code;
                --'GM';                  --c1.primary_uom_code;
                --
                l_mmti_rec.trx_source_line_id :=
                    r_opm_transaction.material_detail_id;
                -- 3217;              --l_material_detail_id;
                gme_api_pub.create_material_txn (
                    p_api_version           => 2.0,
                    p_validation_level      => p_validation_level,
                    p_init_msg_list         => 'F',
                    p_commit                => fnd_api.g_false,
                    --'F',
                    x_message_count         => x_message_count,
                    x_message_list          => l_message_list,
                    x_return_status         => l_return_status,
                    p_org_code              => r_opm_transaction.inv_org_code,
                    --'193',
                    p_mmti_rec              => l_mmti_rec,
                    p_mmli_tbl              => l_mmli_tbl,
                    p_batch_no              => r_opm_transaction.ora_batch_number,
                    --'728',
                    p_line_no               => r_opm_transaction.line_no,
                    p_line_type             => -1,
                    p_create_lot            => 'F',
                    p_generate_lot          => 'F',
                    p_generate_parent_lot   => 'F',
                    x_mmt_rec               => x_mmt_rec,
                    x_mmln_tbl              => x_mmln_tbl);
                gme_debug.display_messages (x_message_count);
                l_error_msg := l_message_list;

                --
                --
                IF TRIM (NVL (l_return_status, 'E')) <> 'S'
                THEN
                    l_error_msg :=
                        SUBSTR ('Material error -> ' || l_error_msg, 1, 4000);

                    IF x_error_message IS NULL
                    THEN
                        x_error_message := l_error_msg;
                    ELSE
                        x_error_message :=
                            x_error_message || CHR (10) || l_error_msg;
                    END IF;

                    UPDATE xxdbl_opm_conv_stg
                       SET transaction_api_status = g_fail,
                           transaction_api_error_message = x_error_message
                     WHERE ROWID = r_opm_transaction.h_rowid;
                ELSE
                    UPDATE xxdbl_opm_conv_stg
                       SET transaction_api_status = g_success
                     WHERE ROWID = r_opm_transaction.h_rowid;
                END IF;

                --
                --
                COMMIT;
            --
            --
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    l_api_error := l_api_error || ':' || SQLERRM;
                    writelog (l_api_error);

                    UPDATE xxdbl_opm_conv_stg
                       SET transaction_api_status = g_fail,
                           transaction_api_error_message = l_api_error
                     WHERE ROWID = r_opm_transaction.h_rowid;

                    COMMIT;
            END;
        END LOOP;
    EXCEPTION
        WHEN e_validation_err
        THEN
            writelog ('No valid records is found for Transaction!!!');
        WHEN OTHERS
        THEN
            writelog (
                   'Unexpected Error to create transaction - '
                || TO_CHAR (SQLCODE)
                || ': '
                || SQLERRM);
    END create_transaction_prc;

    --
    -- Procedure show error records
    PROCEDURE show_errors (p_request_id IN NUMBER)
    IS
        l_tot_rec_count           NUMBER;
        l_success_count           NUMBER;
        l_validation_fail_count   NUMBER;
        l_line_fail_count         NUMBER;
        l_tran_fail_count         NUMBER;
    BEGIN
        g_obj := 'SHOW_ERRORS';
        writelog ('---------------------------------------');
        writelog ('Initiating .. ' || g_pkg || g_obj);

        --
        --       Get total Record
        SELECT COUNT (*)
          INTO l_tot_rec_count
          FROM xxdbl_opm_conv_stg
         WHERE request_id = p_request_id;

        --
        -- Get Total Success Count
        SELECT COUNT (*)
          INTO l_success_count
          FROM xxdbl_opm_conv_stg
         WHERE     request_id = p_request_id
               AND NVL (transaction_api_status, g_default) = g_success;

        --
        -- Get Total validation fail Count
        SELECT COUNT (*)
          INTO l_validation_fail_count
          FROM xxdbl_opm_conv_stg
         WHERE     request_id = p_request_id
               AND NVL (validation_status, g_default) = g_fail;

        --
        -- Get Total line creation fail Count
        SELECT COUNT (*)
          INTO l_line_fail_count
          FROM xxdbl_opm_conv_stg
         WHERE     request_id = p_request_id
               AND NVL (line_api_status, g_default) = g_fail;

        --
        -- Get Total transaction fail Count
        SELECT COUNT (*)
          INTO l_tran_fail_count
          FROM xxdbl_opm_conv_stg
         WHERE     request_id = p_request_id
               AND NVL (transaction_api_status, g_default) = g_fail;

        --
        writelog (
            '                DBL OPM INBOUND TRANSACTION                     ',
            'OUTPUT');
        writelog (' ', 'OUTPUT');
        writelog (
               'Total number of new records for transaction             :'
            || l_tot_rec_count,
            'OUTPUT');
        writelog (
               'Total Number of new records successfully transacted     :'
            || l_success_count,
            'OUTPUT');
        writelog (
               'Total Number of new records failed during validation    :'
            || l_validation_fail_count,
            'OUTPUT');
        writelog (
               'Total Number of new records failed during line creation :'
            || l_line_fail_count,
            'OUTPUT');
        writelog (
               'Total Number of new records failed during transaction   :'
            || l_tran_fail_count,
            'OUTPUT');
    END show_errors;
--
END xxdbl_sedomast_inbound_pkg;
/