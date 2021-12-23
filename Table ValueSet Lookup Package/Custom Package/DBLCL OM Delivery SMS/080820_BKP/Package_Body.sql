/* Formatted on 8/6/2020 10:11:23 AM (QP5 v5.354) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_om_sms_delivery_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 05-AUG-2020
    -- LAST UPDATE DATE :06-AUG-2020
    -- PURPOSE : INSERT SMS DATA UPLOAD INTO STAGING TABLE
    FUNCTION check_error_log_to_upload_data
        RETURN NUMBER
    IS
        L_RETURN_STATUS           VARCHAR2 (1);
        v_booked_message_text     VARCHAR2 (500);
        v_delivery_message_text   VARCHAR2 (500);
        v_sms_id                  NUMBER;

        CURSOR cur_bkd_stg IS
              SELECT oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     ola.line_id,
                     oha.order_number,
                     oha.booked_date,
                     SUM (ola.ordered_quantity)                 ordered_quantity,
                     ola.order_quantity_uom                     uom,
                     SUM (
                           (ola.ordered_quantity * ola.unit_selling_price)
                         - ABS (NVL (clv.charge_amount, 0)))    amount,
                     hcp.phone_number
                FROM oe_order_headers_all       oha,
                     oe_order_lines_all         ola,
                     apps.oe_charge_lines_v     clv,
                     oe_price_adjustments_v     pav,
                     ar_customers               cus,
                     apps.hz_cust_accounts      hca,
                     apps.hz_party_sites        hps,
                     apps.hz_cust_acct_sites_all hcasa,
                     apps.hz_cust_site_uses_all hcsua,
                     ar.hz_contact_points       hcp,
                     apps.hz_locations          hl
               WHERE     oha.header_id = ola.header_id
                     AND oha.header_id = clv.header_id(+)
                     AND ola.line_id = clv.line_id(+)
                     AND oha.header_id = pav.header_id
                     AND ola.line_id = pav.line_id
                     AND oha.org_id = ola.org_id
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
                     AND TRUNC (oha.booked_date) >
                         (TRUNC (TO_DATE (SYSDATE)) - 2)
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     oha.org_id = stg.org_id
                                     AND oha.header_id = stg.ord_header_id
                                     AND ola.line_id = stg.ord_line_id)
            GROUP BY oha.org_id,
                     cus.customer_number,
                     cus.customer_name,
                     oha.header_id,
                     ola.line_id,
                     oha.order_number,
                     oha.booked_date,
                     ola.order_quantity_uom,
                     hcp.phone_number
            ORDER BY BOOKED_DATE DESC;

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
                     TH.TRANSPOTER_CHALLAN_NUMBER
                FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
                     WSH_NEW_DELIVERIES           WND,
                     XXDBL_TRANSPOTER_LINE        TL,
                     XXDBL_TRANSPOTER_HEADERS     TH,
                     APPS.HZ_CUST_ACCOUNTS        HCA,
                     APPS.HZ_PARTY_SITES          HPS,
                     AR.HZ_CONTACT_POINTS         HCP
               WHERE     OLV.DELIVERY_ID = WND.DELIVERY_ID
                     AND OLV.DELIVERY_CHALLAN_NUMBER =
                         TL.DELIVERY_CHALLAN_NUMBER
                     AND TL.TRANSPOTER_HEADER_ID = TH.TRANSPOTER_HEADER_ID
                     AND TL.CUSTOMER_NUMBER = HCA.ACCOUNT_NUMBER
                     AND HCA.PARTY_ID = HPS.PARTY_ID
                     AND HPS.PARTY_SITE_ID = HCP.OWNER_TABLE_ID
                     AND HCP.PHONE_NUMBER IS NOT NULL
                     AND TL.ORG_ID = 126
                     AND TRUNC (WND.CONFIRM_DATE) >
                         (TRUNC (TO_DATE (SYSDATE)) - 2)
                     AND NOT EXISTS
                             (SELECT 1
                                FROM xxdbl.xxdbl_om_sms_data_upload_stg stg
                               WHERE     tl.org_id = stg.org_id
                                     AND STG.DELIVERY_ID = WND.DELIVERY_ID)
            ORDER BY TL.DELIVERY_CHALLAN_NUMBER DESC;
    BEGIN
        L_RETURN_STATUS := NULL;

        BEGIN
            -------------------------Booked SMS Data Insert-------------------------
            FOR ln_cur_bkd_stg IN cur_bkd_stg
            LOOP
                BEGIN
                    v_sms_id :=
                        TRIM (LPAD (XXDBL.XXDBL_OM_SMS_S.NEXTVAL, 5, '0'));
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
                        || ', Regards, DBL Ceramics';


                    INSERT INTO xxdbl.xxdbl_om_sms_data_upload_stg (
                                    SMS_ID,
                                    CREATION_DATE,
                                    SMS_TYPE,
                                    ORG_ID,
                                    CUSTOMER_NUMBER,
                                    CUSTOMER_NAME,
                                    BOOKED_DATE,
                                    ORD_HEADER_ID,
                                    ORD_LINE_ID,
                                    ORDER_NUMBER,
                                    ORDERED_QUANTITY,
                                    UOM_CODE,
                                    AMOUNT,
                                    PHONE_NUMBER,
                                    MESSAGE_TEXT)
                         VALUES (v_sms_id,
                                 SYSDATE,
                                 'BOOKED',
                                 ln_cur_bkd_stg.org_id,
                                 ln_cur_bkd_stg.customer_number,
                                 ln_cur_bkd_stg.customer_name,
                                 ln_cur_bkd_stg.booked_date,
                                 ln_cur_bkd_stg.header_id,
                                 ln_cur_bkd_stg.line_id,
                                 ln_cur_bkd_stg.order_number,
                                 ln_cur_bkd_stg.ordered_quantity,
                                 ln_cur_bkd_stg.uom,
                                 ln_cur_bkd_stg.amount,
                                 ln_cur_bkd_stg.phone_number,
                                 v_booked_message_text);

                    COMMIT;
                END;
            END LOOP;


            FOR ln_cur_dlv_stg IN cur_dlv_stg
            LOOP
                BEGIN
                    v_sms_id :=
                        TRIM (LPAD (XXDBL.XXDBL_OM_SMS_S.NEXTVAL, 5, '0'));
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
                        || ', Regards, DBL Ceramics';


                    INSERT INTO xxdbl.xxdbl_om_sms_data_upload_stg (
                                    SMS_ID,
                                    CREATION_DATE,
                                    SMS_TYPE,
                                    ORG_ID,
                                    CUSTOMER_NUMBER,
                                    CUSTOMER_NAME,
                                    ORDER_NUMBER,
                                    PHONE_NUMBER,
                                    DELIVERY_ID,
                                    DELIVERY_CHALLAN_NO,
                                    PRIMARY_QUANTITY,
                                    SECONDARY_QUANTITY,
                                    DRIVER_NAME,
                                    DRIVER_CONTACT_NO,
                                    VEHICLE_NO,
                                    CONFIRM_DATE,
                                    TRANSPORTER_CHALLAN_NO,
                                    MESSAGE_TEXT)
                         VALUES (v_sms_id,
                                 SYSDATE,
                                 'DELIVERY',
                                 ln_cur_dlv_stg.org_id,
                                 ln_cur_dlv_stg.customer_number,
                                 ln_cur_dlv_stg.customer_name,
                                 ln_cur_dlv_stg.order_number,
                                 ln_cur_dlv_stg.phone_number,
                                 ln_cur_dlv_stg.DELIVERY_ID,
                                 ln_cur_dlv_stg.DELIVERY_CHALLAN_NUMBER,
                                 ln_cur_dlv_stg.PRIMARY_QUANTITY_SFT,
                                 ln_cur_dlv_stg.SECONDARY_QUANTITY_CTN,
                                 ln_cur_dlv_stg.DRIVER_NAME,
                                 ln_cur_dlv_stg.DRIVER_CONTACT_NO,
                                 ln_cur_dlv_stg.VEHICLE_NO,
                                 ln_cur_dlv_stg.CONFIRM_DATE,
                                 ln_cur_dlv_stg.TRANSPOTER_CHALLAN_NUMBER,
                                 v_delivery_message_text);

                    COMMIT;
                END;
            END LOOP;



            IF    L_RETURN_STATUS = FND_API.G_RET_STS_ERROR
               OR L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                DBMS_OUTPUT.PUT_LINE ('unexpected errors found!');
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    '--------------Unexpected errors found!--------------------');
            ELSE
                DBMS_OUTPUT.PUT_LINE (
                    'SMS Data Uploaded into Stage In Table!');
                FND_FILE.put_line (
                    FND_FILE.LOG,
                    '--------------SMS Data Uploaded into Stage In Table!--------------------');
            /*
            UPDATE xxdbl.xxdbl_ra_interface_upload_stg
               SET FLAG = 'Y'
             WHERE     FLAG IS NULL
                   AND SL_NO = ln_cur_stg.SL_NO
                   AND LINE_NUMBER = ln_cur_stg.LINE_NUMBER;
             */
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.put_line (
                    FND_FILE.LOG,
                       'Error while inserting records into stagein table !!!  '
                    || SQLERRM);
        END;

        RETURN 0;
    END;

    PROCEDURE upload_data_to_sms_stg_tbl (ERRBUF    OUT VARCHAR2,
                                          RETCODE   OUT VARCHAR2)
    IS
        L_Retcode     NUMBER;
        CONC_STATUS   BOOLEAN;
        l_error       VARCHAR2 (100);
    BEGIN
        fnd_file.put_line (fnd_file.LOG, 'Parameter received');


        L_Retcode := check_error_log_to_upload_data;

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
    END upload_data_to_sms_stg_tbl;
END xxdbl_om_sms_delivery_pkg;
/