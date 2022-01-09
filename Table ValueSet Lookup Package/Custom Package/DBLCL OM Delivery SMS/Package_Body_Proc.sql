/* Formatted on 1/5/2022 12:34:10 PM (QP5 v5.374) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_om_sms_delivery_pkg
IS
    -- CREATED BY : SOURAV PAUL
    -- CREATION DATE : 05-AUG-2020
    -- LAST UPDATE DATE :05-JAN-2022
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
            SELECT ORG_ID,
                   CUSTOMER_NUMBER,
                   CUSTOMER_NAME,
                   HEADER_ID,
                   ORDER_NUMBER,
                   BOOKED_DATE,
                   ORDERED_QUANTITY,
                   ORDERED_SEC_QUANTITY,
                   UOM,
                   AMOUNT,
                   XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (BILL_TO_SITE_USE_ID)
                       BILL_TO_ADDRESS,
                   XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (SITE_USE_ID)
                       SHIP_TO_ADDRESS,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (SOLD_TO_ORG_ID,
                                                     'ACCOUNT')
                       BILL_TO_CONTACT,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PARTY_SITE_ID, 'SITE')
                       SHIP_TO_CONTACT,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (ATTRIBUTE3, 'ACCOUNT')
                       CORRESPONDING_DEALER_PHONE,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SR')
                       SR_PHONE_NUMBER,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SRS')
                       SRS_PHONE
              FROM (  SELECT OH.ORG_ID,
                             CUST.CUSTOMER_NUMBER,
                             CUST.CUSTOMER_NAME,
                             OH.HEADER_ID,
                             OH.ORDER_NUMBER,
                             OH.BOOKED_DATE,
                             SUM (OL.ORDERED_QUANTITY)
                                 ORDERED_QUANTITY,
                             SUM (OL.ORDERED_QUANTITY2)
                                 ORDERED_SEC_QUANTITY,
                             OL.ORDER_QUANTITY_UOM
                                 UOM,
                             SUM (
                                   (OL.ORDERED_QUANTITY * OL.UNIT_SELLING_PRICE)
                                 - ABS (NVL (CLV.CHARGE_AMOUNT, 0)))
                                 AMOUNT,
                             OH.SOLD_TO_ORG_ID,
                             HCASA.PARTY_SITE_ID,
                             OH.ATTRIBUTE3,
                             SR.PERSON_ID,
                             HCSUA.BILL_TO_SITE_USE_ID,
                             HCSUA.SITE_USE_ID
                        FROM OE_ORDER_HEADERS_ALL       OH,
                             OE_ORDER_LINES_ALL         OL,
                             APPS.OE_CHARGE_LINES_V     CLV,
                             AR_CUSTOMERS               CUST,
                             APPS.HZ_CUST_ACCT_SITES_ALL HCASA,
                             APPS.HZ_CUST_SITE_USES_ALL HCSUA,
                             RA_SALESREPS_ALL           SR
                       WHERE     OH.HEADER_ID = OL.HEADER_ID
                             AND OL.LINE_ID = CLV.LINE_ID(+)
                             AND OL.FLOW_STATUS_CODE <> 'CANCELLED'
                             AND OH.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
                             AND OL.SHIP_TO_ORG_ID = HCSUA.SITE_USE_ID
                             AND HCSUA.CUST_ACCT_SITE_ID =
                                 HCASA.CUST_ACCT_SITE_ID
                             AND OH.ORG_ID = 126
                             AND OH.SALESREP_ID = SR.SALESREP_ID
                             AND OH.ORG_ID = SR.ORG_ID
                             AND TRUNC (OH.BOOKED_DATE) =
                                 (TRUNC (TO_DATE (SYSDATE)))
                             AND 'BOOKED' = NVL (SMS_TYPE_PM, 'BOOKED')
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM ONT.OE_ORDER_HOLDS_ALL OHH
                                       WHERE     OH.HEADER_ID = OHH.HEADER_ID
                                             AND OHH.RELEASED_FLAG <> 'Y')
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
                                             STG
                                       WHERE OH.HEADER_ID = STG.ORD_HEADER_ID)
                    GROUP BY OH.ORG_ID,
                             CUST.CUSTOMER_NUMBER,
                             CUST.CUSTOMER_NAME,
                             OH.HEADER_ID,
                             OH.ORDER_NUMBER,
                             OH.BOOKED_DATE,
                             OL.ORDER_QUANTITY_UOM,
                             OH.SOLD_TO_ORG_ID,
                             HCASA.PARTY_SITE_ID,
                             OH.ATTRIBUTE3,
                             SR.PERSON_ID,
                             HCSUA.BILL_TO_SITE_USE_ID,
                             HCSUA.SITE_USE_ID);

        CURSOR cur_dlv_stg IS
            SELECT ORG_ID,
                   DELIVERY_ID,
                   DELIVERY_CHALLAN_NUMBER,
                   CUSTOMER_NAME,
                   CUSTOMER_NUMBER,
                   ORDER_NUMBER,
                   SECONDARY_QUANTITY_CTN,
                   PRIMARY_QUANTITY_SFT,
                   DRIVER_NAME,
                   DRIVER_CONTACT_NO,
                   VEHICLE_NO,
                   CONFIRM_DATE,
                   TRANSPORT_CHALLAN_NUMBER
                       TRANSPOTER_CHALLAN_NUMBER,
                   XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (BILL_TO_SITE_USE_ID)
                       BILL_TO_ADDRESS,
                   XXDBL_OM_PKG.GET_PARTY_SITE_ADDRESS (SITE_USE_ID)
                       SHIP_TO_ADDRESS,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (SOLD_TO_ORG_ID,
                                                     'ACCOUNT')
                       BILL_TO_CONTACT,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PARTY_SITE_ID, 'SITE')
                       SHIP_TO_CONTACT,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (ATTRIBUTE3, 'ACCOUNT')
                       CORRESPONDING_DEALER_PHONE,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SR')
                       SR_PHONE_NUMBER,
                   XXDBL_OM_PKG.GET_OM_PHONE_NUMBER (PERSON_ID, 'SRS')
                       SRS_PHONE
              FROM (  SELECT OH.ORG_ID,
                             WND.DELIVERY_ID,
                             OLV.DELIVERY_CHALLAN_NUMBER
                                 DELIVERY_CHALLAN_NUMBER,
                             AC.CUSTOMER_NAME,
                             AC.CUSTOMER_NUMBER,
                             OLV.ORDER_NUMBER,
                             SUM (PICKING_QTY_CRT)
                                 SECONDARY_QUANTITY_CTN,
                             SUM (PICKING_QTY_SFT)
                                 PRIMARY_QUANTITY_SFT,
                             WND.ATTRIBUTE4
                                 DRIVER_NAME,
                             WND.ATTRIBUTE5
                                 DRIVER_CONTACT_NO,
                             WND.ATTRIBUTE2
                                 VEHICLE_NO,
                             WND.CONFIRM_DATE,
                             OLV.TRANSPORT_CHALLAN_NUMBER,
                             OH.SOLD_TO_ORG_ID,
                             HCASA.PARTY_SITE_ID,
                             OH.ATTRIBUTE3,
                             SR.PERSON_ID,
                             HCSUA.BILL_TO_SITE_USE_ID,
                             HCSUA.SITE_USE_ID
                        FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
                             APPS.HZ_CUST_SITE_USES_ALL   HCSUA,
                             APPS.HZ_CUST_ACCT_SITES_ALL  HCASA,
                             APPS.AR_CUSTOMERS            AC,
                             WSH_NEW_DELIVERIES           WND,
                             OE_ORDER_HEADERS_ALL         OH,
                             RA_SALESREPS_ALL             SR
                       WHERE     OLV.ATTRIBUTE10 = HCSUA.SITE_USE_ID
                             AND HCSUA.CUST_ACCT_SITE_ID =
                                 HCASA.CUST_ACCT_SITE_ID
                             AND HCASA.CUST_ACCOUNT_ID = AC.CUSTOMER_ID
                             AND OLV.DELIVERY_ID = WND.DELIVERY_ID
                             AND OLV.ORDER_ID = OH.HEADER_ID
                             AND OH.SALESREP_ID = SR.SALESREP_ID
                             AND OH.ORG_ID = SR.ORG_ID
                             AND OH.ORG_ID = 126
                             AND TRUNC (WND.CONFIRM_DATE) =
                                 (TRUNC (TO_DATE (SYSDATE)))
                             AND 'DELIVERY' = NVL (SMS_TYPE_PM, 'DELIVERY')
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM XXDBL.XXDBL_OM_SMS_DATA_UPLOAD_STG
                                             STG
                                       WHERE     OLV.ORG_ID = STG.ORG_ID
                                             AND STG.DELIVERY_ID =
                                                 WND.DELIVERY_ID)
                    GROUP BY OH.ORG_ID,
                             WND.DELIVERY_ID,
                             OLV.DELIVERY_CHALLAN_NUMBER,
                             AC.CUSTOMER_NAME,
                             AC.CUSTOMER_NUMBER,
                             OLV.ORDER_NUMBER,
                             WND.ATTRIBUTE4,
                             WND.ATTRIBUTE5,
                             WND.ATTRIBUTE2,
                             WND.CONFIRM_DATE,
                             OLV.TRANSPORT_CHALLAN_NUMBER,
                             OH.SOLD_TO_ORG_ID,
                             HCASA.PARTY_SITE_ID,
                             OH.ATTRIBUTE3,
                             SR.PERSON_ID,
                             HCSUA.BILL_TO_SITE_USE_ID,
                             HCSUA.SITE_USE_ID);
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
                                    SR_PHONE_NUMBER, --Add SR Phone Number by Sourav 150121
                                    CORRESPONDING_DEALER_PHONE, --Add CORRESPONDING_DEALER_PHONE by Nurul 050122
                                    SRS_PHONE) --Add SRS_PHONE by Nurul 050122
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
                                 ln_cur_bkd_stg.BILL_TO_CONTACT,
                                 ln_cur_bkd_stg.sr_phone_number,
                                 ln_cur_bkd_stg.CORRESPONDING_DEALER_PHONE,
                                 ln_cur_bkd_stg.SRS_PHONE);


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
                                    SHIP_TO_CONTACT,
                                    PHONE_NUMBER, --Add PHONE_NUMBER by Nurul 050122
                                    SR_PHONE_NUMBER, --Add SR Phone Number by Sourav 150121
                                    CORRESPONDING_DEALER_PHONE, --Add CORRESPONDING_DEALER_PHONE by Nurul 050122
                                    SRS_PHONE) --Add SRS_PHONE by Nurul 050122
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
                                 ln_cur_dlv_stg.SHIP_TO_CONTACT,
                                 ln_cur_dlv_stg.sr_phone_number,
                                 ln_cur_dlv_stg.BILL_TO_CONTACT,
                                 ln_cur_dlv_stg.CORRESPONDING_DEALER_PHONE,
                                 ln_cur_dlv_stg.SRS_PHONE);


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
