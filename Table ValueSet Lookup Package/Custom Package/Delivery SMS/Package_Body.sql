CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_om_sms_delivery_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 05-AUG-2020
    -- LAST UPDATE DATE :22-OCT-2020
    -- PURPOSE : INSERT SMS DATA UPLOAD INTO STAGING TABLE
    FUNCTION check_error_log_to_upload_data (SMS_TYPE_PM VARCHAR2)
        RETURN NUMBER
    IS
        L_RETURN_STATUS    VARCHAR2 (1);
        --v_booked_message_text     VARCHAR2 (500);
        --v_delivery_message_text   VARCHAR2 (500);
        v_sms_id           NUMBER;
        L_BOOKED_COUNT     NUMBER := 0;
        L_DELIVERY_COUNT   NUMBER := 0;

        --fnd_file.put_line (fnd_file.LOG, 'Status :' || SMS_TYPE_PM);


        CURSOR cur_bkd_stg IS
              SELECT oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     oha.order_number,
                     oha.booked_date,
                     SUM (ola.ordered_quantity)                 ordered_quantity,
                     SUM (ola.ordered_quantity2)                ordered_sec_quantity,
                     ola.order_quantity_uom                     uom,
                     SUM (
                           (ola.ordered_quantity * ola.unit_selling_price)
                         - ABS (NVL (clv.charge_amount, 0)))    amount,
                     hcp.phone_number,
                     pp.phone_number                            sr_phone_number
                FROM oe_order_headers_all       oha,
                     oe_order_lines_all         ola,
                     apps.oe_charge_lines_v     clv,
                     oe_price_adjustments_v     pav,
                     ar_customers               cus,
                     apps.hz_cust_accounts      hca,
                     apps.hz_party_sites        hps,
                     apps.hz_cust_acct_sites_all hcasa,
                     apps.hz_cust_site_uses_all hcsua,
                     apps.hz_locations          hl,
                     jtf_rs_salesreps           sal,
                     jtf_rs_defresources_v      rsv,
                     (SELECT parent_id, phone_type, phone_number
                        FROM per_phones
                       WHERE phone_type = 'W1') pp,
                     (SELECT owner_table_id, phone_number
                        FROM ar.hz_contact_points
                       WHERE contact_point_type = 'PHONE' AND status = 'A') hcp
               WHERE     oha.header_id = ola.header_id
                     AND oha.header_id = clv.header_id(+)
                     AND ola.line_id = clv.line_id(+)
                     AND oha.header_id = pav.header_id
                     AND ola.line_id = pav.line_id
                     AND oha.org_id = ola.org_id
                     AND oha.flow_status_code != 'CANCELLED'
                     AND ola.flow_status_code <> 'CANCELLED'
                     AND pav.adjustment_name = 'SO Header Adhoc Discount'
                     AND oha.sold_to_org_id = cus.customer_id
                     AND cus.customer_id = hca.cust_account_id
                     AND hca.party_id = hps.party_id
                     AND cus.customer_id = hca.cust_account_id
                     AND hca.status = 'A'
                     AND hca.cust_account_id = hcasa.cust_account_id(+)
                     AND hcasa.status = 'A'
                     AND hcsua.status = 'A'
                     AND hcasa.party_site_id = hps.party_site_id
                     AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id
                     AND hcsua.org_id = 126
                     AND hps.location_id = hl.location_id
                     AND site_use_code = 'BILL_TO'
                     AND hps.party_site_id = hcp.owner_table_id(+)
                     AND hcp.phone_number IS NOT NULL
                     AND oha.org_id = 126
                     AND oha.salesrep_id = sal.salesrep_id(+)
                     AND sal.resource_id = rsv.resource_id
                     AND oha.org_id = sal.org_id(+)
                     AND rsv.source_id = pp.parent_id(+)
                     AND TRUNC (oha.booked_date) = (TRUNC (TO_DATE (SYSDATE)))
                     --AND TO_CHAR (oha.booked_date, 'MON-RRRR') = TO_CHAR ('AUG-2020')
                     AND 'BOOKED' = NVL (SMS_TYPE_PM, 'BOOKED')
                     AND NOT EXISTS
                             (SELECT 1
                                FROM ont.oe_order_holds_all ooha
                               WHERE     oha.header_id = ooha.header_id
                                     AND ooha.released_flag <> 'Y')
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     oha.org_id = stg.org_id
                                     AND oha.header_id = stg.ord_header_id)
            GROUP BY oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     oha.order_number,
                     oha.booked_date,
                     ola.order_quantity_uom,
                     hcp.phone_number,
                     pp.phone_number
            ORDER BY booked_date DESC;

        CURSOR cur_dlv_stg IS
              SELECT DISTINCT
                     TL.ORG_ID,
                     WND.DELIVERY_ID,
                     (TL.DELIVERY_CHALLAN_NUMBER)     DELIVERY_CHALLAN_NUMBER,
                     TL.CUSTOMER_NAME,
                     TL.CUSTOMER_NUMBER,
                     HCP.PHONE_NUMBER,
                     OLV.ORDER_NUMBER,
                     TL.SECONDARY_QUANTITY            SECONDARY_QUANTITY_CTN,
                     TL.PRIMARY_QUANTITY              PRIMARY_QUANTITY_SFT,
                     WND.ATTRIBUTE4                   DRIVER_NAME,
                     WND.ATTRIBUTE5                   DRIVER_CONTACT_NO,
                     WND.ATTRIBUTE2                   VEHICLE_NO,
                     WND.CONFIRM_DATE,
                     TH.TRANSPOTER_CHALLAN_NUMBER,
                     hl.address1                      bill_to_address,
                     hlsh.address1                    ship_to_address,
                     hcp.phone_number                 bill_to_contact,
                     hcph.phone_number                ship_to_contact
                FROM apps.ar_customers            ac,
                     apps.hz_cust_accounts        hca,
                     apps.hz_cust_acct_sites_all  hcasa,
                     apps.hz_cust_acct_sites_all  hcasash,
                     apps.hz_party_sites          hps,
                     apps.hz_party_sites          hpsh,
                     apps.hz_cust_site_uses_all   hcsua,
                     apps.hz_cust_site_uses_all   hcsuash,
                     apps.hz_locations            hl,
                     apps.hz_locations            hlsh,
                     apps.hr_operating_units      hou,
                     oe_order_headers_all         oha,
                     xxdbl.xxdbl_omshipping_line_v olv,
                     wsh_new_deliveries           wnd,
                     xxdbl_transpoter_line        tl,
                     xxdbl_transpoter_headers     th,
                     (SELECT owner_table_id, phone_number
                        FROM ar.hz_contact_points
                       WHERE contact_point_type = 'PHONE' AND status = 'A') hcp,
                     (SELECT owner_table_id, phone_number
                        FROM ar.hz_contact_points
                       WHERE contact_point_type = 'PHONE' AND status = 'A')
                     hcph
               WHERE     hcsua.site_use_id = hcsuash.bill_to_site_use_id(+)
                     AND ac.customer_id = hca.cust_account_id(+)
                     AND hcasa.party_site_id = hps.party_site_id(+)
                     AND hcasash.party_site_id = hpsh.party_site_id(+)
                     AND hcsua.cust_acct_site_id = hcasa.cust_acct_site_id(+)
                     AND hcsuash.cust_acct_site_id =
                         hcasash.cust_acct_site_id(+)
                     AND hps.location_id = hl.location_id(+)
                     AND hpsh.location_id = hlsh.location_id(+)
                     AND hou.organization_id = hcsua.org_id
                     AND hou.organization_id = hcsuash.org_id
                     AND hca.cust_account_id = hcasa.cust_account_id(+)
                     AND hca.cust_account_id = hcasash.cust_account_id(+)
                     AND ac.customer_id = oha.sold_to_org_id
                     AND hcsua.site_use_id = oha.invoice_to_org_id
                     AND hcsuash.site_use_id = oha.ship_to_org_id
                     AND hcasa.status = 'A'
                     AND hcsua.status = 'A'
                     AND hcasash.status = 'A'
                     AND hcsuash.status = 'A'
                     AND hca.status = 'A'
                     AND hca.status = 'A'
                     AND hps.status = 'A'
                     AND hpsh.status = 'A'
                     AND olv.order_number = oha.order_number
                     AND olv.delivery_id = wnd.delivery_id
                     AND olv.delivery_challan_number =
                         tl.delivery_challan_number
                     AND tl.transpoter_header_id = th.transpoter_header_id
                     AND hps.party_site_id = hcp.owner_table_id(+)
                     AND hpsh.party_site_id = hcph.owner_table_id(+)
                     AND tl.customer_number = hca.account_number
                     AND tl.org_id = oha.org_id
                     AND oha.org_id = hcasa.org_id
                     AND hcasa.org_id = hcasash.org_id
                     AND tl.org_id = 126
                     AND hcp.phone_number IS NOT NULL
                     --AND TO_CHAR (WND.CONFIRM_DATE, 'MON-RRRR') = TO_CHAR ('MAY-2020')
                     AND TRUNC (wnd.confirm_date) = (TRUNC (TO_DATE (SYSDATE)))
                     AND 'DELIVERY' = NVL (SMS_TYPE_PM, 'DELIVERY')
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     tl.org_id = stg.org_id
                                     AND STG.DELIVERY_ID = WND.DELIVERY_ID)
            ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;
    BEGIN
        L_RETURN_STATUS := NULL;

        BEGIN
            -------------------------Booked SMS Data Insert------------------------
            FOR ln_cur_bkd_stg IN cur_bkd_stg
            LOOP
                BEGIN
                    v_sms_id :=
                        TRIM (LPAD (XXDBL.XXDBL_OM_SMS_S.NEXTVAL, 5, '0'));

                    L_BOOKED_COUNT := L_BOOKED_COUNT + 1;

                    /*
                    v_booked_message_text :=
                          'Dear Sir, Your order is confirmed. No='
                       || ln_cur_bkd_stg.order_number
                       || ', Qty.= '
                       || ln_cur_bkd_stg.ordered_quantity
                       || ', '
                       || ln_cur_bkd_stg.uom
                       || ', Total= '
                       || ln_cur_bkd_stg.amount
                       || '(BDT), Conf. Date= '
                       || ln_cur_bkd_stg.booked_date
                       || ', Regards, DBL Ceramics';     --MESSAGE_TEXT
                    */



                    INSERT INTO xxdbl.xxdbl_om_sms_data_upload_stg (
                                    SMS_ID,
                                    CREATION_DATE,
                                    SMS_TYPE,
                                    ORG_ID,
                                    CUSTOMER_NUMBER,
                                    CUSTOMER_NAME,
                                    BOOKED_DATE,
                                    ORD_HEADER_ID,
                                    ORDER_NUMBER,
                                    ORDERED_QUANTITY,
                                    ORDERED_SEC_QUANTITY,
                                    UOM_CODE,
                                    AMOUNT,
                                    PHONE_NUMBER,
                                    SR_PHONE_NUMBER)
                         VALUES (v_sms_id,
                                 SYSDATE,
                                 'BOOKED',
                                 ln_cur_bkd_stg.org_id,
                                 ln_cur_bkd_stg.customer_number,
                                 ln_cur_bkd_stg.customer_name,
                                 ln_cur_bkd_stg.booked_date,
                                 ln_cur_bkd_stg.header_id,
                                 ln_cur_bkd_stg.order_number,
                                 ln_cur_bkd_stg.ordered_quantity,
                                 ln_cur_bkd_stg.ordered_sec_quantity,
                                 ln_cur_bkd_stg.uom,
                                 ln_cur_bkd_stg.amount,
                                 ln_cur_bkd_stg.phone_number,
                                 ln_cur_bkd_stg.sr_phone_number);


                    COMMIT;
                END;
            END LOOP;



            -------------------------Delivery SMS Data Insert----------------------

            FOR ln_cur_dlv_stg IN cur_dlv_stg
            LOOP
                BEGIN
                    v_sms_id :=
                        TRIM (LPAD (XXDBL.XXDBL_OM_SMS_S.NEXTVAL, 5, '0'));

                    L_DELIVERY_COUNT := L_DELIVERY_COUNT + 1;

                    /*
                    v_delivery_message_text :=
                          'Dear Sir, Your order is delivered. No='
                       || ln_cur_dlv_stg.ORDER_NUMBER
                       || ', '
                       || ln_cur_dlv_stg.PRIMARY_QUANTITY_SFT
                       || ', Driver Name= '
                       || ln_cur_dlv_stg.DRIVER_NAME
                       || ', No= '
                       || ln_cur_dlv_stg.DRIVER_CONTACT_NO
                       || ', Veh. No= '
                       || ln_cur_dlv_stg.VEHICLE_NO
                       || ', Del. Date= '
                       || ln_cur_dlv_stg.CONFIRM_DATE
                       || ', Regards, DBL Ceramics';     --MESSAGE_TEXT
                    */

                    INSERT INTO xxdbl.xxdbl_om_sms_data_upload_stg (
                                    SMS_ID,
                                    CREATION_DATE,
                                    SMS_TYPE,
                                    ORG_ID,
                                    CUSTOMER_NUMBER,
                                    CUSTOMER_NAME,
                                    ORDER_NUMBER,
                                    --PHONE_NUMBER,
                                    DELIVERY_ID,
                                    DELIVERY_CHALLAN_NO,
                                    PRIMARY_QUANTITY,
                                    SECONDARY_QUANTITY,
                                    DRIVER_NAME,
                                    DRIVER_CONTACT_NO,
                                    VEHICLE_NO,
                                    CONFIRM_DATE,
                                    TRANSPORTER_CHALLAN_NO,
                                    BILL_TO_ADDRESS,
                                    SHIP_TO_ADDRESS,
                                    BILL_TO_CONTACT,
                                    SHIP_TO_CONTACT)
                         VALUES (v_sms_id,
                                 SYSDATE,
                                 'DELIVERY',
                                 ln_cur_dlv_stg.org_id,
                                 ln_cur_dlv_stg.customer_number,
                                 ln_cur_dlv_stg.customer_name,
                                 ln_cur_dlv_stg.order_number,
                                 --ln_cur_dlv_stg.phone_number,
                                 ln_cur_dlv_stg.DELIVERY_ID,
                                 ln_cur_dlv_stg.DELIVERY_CHALLAN_NUMBER,
                                 ln_cur_dlv_stg.PRIMARY_QUANTITY_SFT,
                                 ln_cur_dlv_stg.SECONDARY_QUANTITY_CTN,
                                 ln_cur_dlv_stg.DRIVER_NAME,
                                 ln_cur_dlv_stg.DRIVER_CONTACT_NO,
                                 ln_cur_dlv_stg.VEHICLE_NO,
                                 ln_cur_dlv_stg.CONFIRM_DATE,
                                 ln_cur_dlv_stg.TRANSPOTER_CHALLAN_NUMBER,
                                 ln_cur_dlv_stg.BILL_TO_ADDRESS,
                                 ln_cur_dlv_stg.SHIP_TO_ADDRESS,
                                 ln_cur_dlv_stg.BILL_TO_CONTACT,
                                 ln_cur_dlv_stg.SHIP_TO_CONTACT);


                    COMMIT;
                END;
            END LOOP;



            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                DBMS_OUTPUT.PUT_LINE ('Unexpected errors found!');
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    '--------------Unexpected errors found!--------------------');
            ELSE
                DBMS_OUTPUT.PUT_LINE (
                    'SMS Data Uploaded into Stage In Table!');
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    '--------------SMS Data Uploaded into Stage In Table!--------------------');

                FND_FILE.put_line (
                    FND_FILE.LOG,
                       '--------------No of rows for Booked SMS Data uploaded into Staging Table: '
                    || L_BOOKED_COUNT);

                FND_FILE.put_line (
                    FND_FILE.LOG,
                       '--------------No of rows for Delivery SMS Data uploaded into Staging Table:  '
                    || L_DELIVERY_COUNT);
            /*
            OPEN cur_bkd_stg;

            --FETCH cur_bkd_stg INTO cur_bkd_stg_rec;


            IF SQL%NOTFOUND
            THEN
               DBMS_OUTPUT.PUT_LINE (
                  'No SMS Data found to Upload into Stage In Table!');
               FND_FILE.put_line (
                  FND_FILE.LOG,
                     '--------------No SMS Data found to Upload into Staging Table!!!--------------------');
            ELSIF SQL%FOUND
            THEN
               DBMS_OUTPUT.PUT_LINE (
                  'No of rows in SMS Data found to Upload into Staging Table: '
                  || cur_bkd_stg%ROWCOUNT
                  || '--------------------');
               FND_FILE.put_line (
                  FND_FILE.LOG,
                     '--------------No of rows in SMS Data found to Upload into Staging Table: '
                  || cur_bkd_stg%ROWCOUNT
                  || '--------------------');
            END IF;

            CLOSE cur_bkd_stg;
            */



            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.put_line (
                    FND_FILE.LOG,
                       '--------------Error while inserting records into stagein table !!!  --------------'
                    || CHR (10)
                    || SQLERRM);
        END;

        RETURN 0;
    END;

    PROCEDURE upload_data_to_sms_stg_tbl (ERRBUF          OUT VARCHAR2,
                                          RETCODE         OUT VARCHAR2,
                                          SMS_TYPE_NAME       VARCHAR2)
    IS
        L_Retcode     NUMBER;
        CONC_STATUS   BOOLEAN;
        l_error       VARCHAR2 (100);
    BEGIN
        fnd_file.put_line (
            fnd_file.LOG,
            '---------------Parameter received and Program executed !!!---------');
        FND_FILE.put_line (
            FND_FILE.LOG,
               '--------------SMS Type Name:'
            || NVL (SMS_TYPE_NAME, 'ALL')
            || '!--------------------');


        L_Retcode := check_error_log_to_upload_data (SMS_TYPE_NAME);

        IF L_Retcode = 0
        THEN
            RETCODE := 'Success';
            CONC_STATUS :=
                FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
            fnd_file.put_line (fnd_file.LOG,
                               'Concurrent Status Code :' || L_Retcode);
            fnd_file.put_line (
                fnd_file.LOG,
                'Concurrent Program Completion Status :' || RETCODE);
        ELSIF L_Retcode = 1
        THEN
            RETCODE := 'Warning';
            CONC_STATUS :=
                FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
            fnd_file.put_line (fnd_file.LOG,
                               'Concurrent Status Code :' || L_Retcode);
            fnd_file.put_line (
                fnd_file.LOG,
                'Concurrent Program Completion Status :' || RETCODE);
        ELSIF L_Retcode = 2
        THEN
            RETCODE := 'Error';
            CONC_STATUS :=
                FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
            fnd_file.put_line (fnd_file.LOG,
                               'Concurrent Status Code :' || L_Retcode);
            fnd_file.put_line (
                fnd_file.LOG,
                'Concurrent Program Completion Status :' || RETCODE);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_error := 'Error while executing the procedure !!! ' || SQLERRM;
            errbuf := l_error;
            RETCODE := 1;
            fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
    END upload_data_to_sms_stg_tbl;

    PROCEDURE om_sms_booked_response (sms_text       VARCHAR2,
                                      ord_no         NUMBER,
                                      phone_no       VARCHAR2,
                                      L_RETURN   OUT NUMBER)
    IS
    --v_booked_message_text   VARCHAR2 (500) := sms_text;
    --v_delivery_message_text   VARCHAR2 (500);
    BEGIN
        UPDATE XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
           SET DELIVERED_FLAG = 'Y',
               SENT_FLAG = 'Y',
               MESSAGE_TEXT = sms_text,
               SMS_SENT_DATE = SYSDATE
         WHERE     ORDER_NUMBER = ord_no
               AND PHONE_NUMBER = phone_no
               AND DELIVERED_FLAG IS NULL
               AND SENT_FLAG IS NULL;


        IF SQL%NOTFOUND
        THEN
            L_RETURN := 0;
        ELSIF SQL%FOUND
        THEN
            L_RETURN := 1;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20001,
                   'An error was encountered - '
                || SQLCODE
                || ' -ERROR- '
                || SQLERRM);
    END om_sms_booked_response;

    PROCEDURE om_sms_delivery_response (sms_text          VARCHAR2,
                                        del_chln_no       VARCHAR2,
                                        L_RETURN      OUT NUMBER)
    IS
    --v_booked_message_text   VARCHAR2 (500) := sms_text;
    --v_delivery_message_text   VARCHAR2 (500);
    BEGIN
        UPDATE XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
           SET DELIVERED_FLAG = 'Y',
               SENT_FLAG = 'Y',
               MESSAGE_TEXT = sms_text,
               SMS_SENT_DATE = SYSDATE
         WHERE     DELIVERY_CHALLAN_NO = del_chln_no
               AND DELIVERED_FLAG IS NULL
               AND SENT_FLAG IS NULL;


        IF SQL%NOTFOUND
        THEN
            L_RETURN := 0;
        ELSIF SQL%FOUND
        THEN
            L_RETURN := 1;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20001,
                   'An error was encountered - '
                || SQLCODE
                || ' -ERROR- '
                || SQLERRM);
    END om_sms_delivery_response;
END xxdbl_om_sms_delivery_pkg;
/