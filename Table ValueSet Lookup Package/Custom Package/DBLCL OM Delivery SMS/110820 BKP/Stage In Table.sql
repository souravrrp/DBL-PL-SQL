/* Formatted on 8/6/2020 10:02:49 AM (QP5 v5.354) */
CREATE TABLE xxdbl.xxdbl_om_sms_data_upload_stg
(
    SMS_ID                    NUMBER NOT NULL,
    CREATION_DATE             DATE,
    ORG_ID                    NUMBER,
    SMS_TYPE                  VARCHAR2 (20 BYTE),
    ---------------------------------------BOOKED
    CUSTOMER_NUMBER           VARCHAR2 (10 BYTE),
    CUSTOMER_NAME             VARCHAR2 (50 BYTE),
    BOOKED_DATE               DATE,
    ORD_HEADER_ID             NUMBER,
    ORD_LINE_ID               NUMBER,
    ORDER_NUMBER              NUMBER,
    ORDERED_QUANTITY          NUMBER,
    UOM_CODE                  VARCHAR2 (10 BYTE),
    AMOUNT                    NUMBER,
    PHONE_NUMBER              VARCHAR2 (40 BYTE),
    ---------------------------------------DELIVERY
    DELIVERY_ID               NUMBER,
    DELIVERY_CHALLAN_NO       VARCHAR2 (240 BYTE),
    PRIMARY_QUANTITY          NUMBER,
    SECONDARY_QUANTITY        NUMBER,
    DRIVER_NAME               VARCHAR2 (150 BYTE),
    DRIVER_CONTACT_NO         VARCHAR2 (150 BYTE),
    VEHICLE_NO                VARCHAR2 (150 BYTE),
    CONFIRM_DATE              DATE,
    TRANSPORTER_CHALLAN_NO    VARCHAR2 (240 BYTE),
    ---------------------------------------
    MESSAGE_TEXT              VARCHAR2 (240 BYTE),
    SENT_FLAG                 VARCHAR2 (3 BYTE),
    DELIVERED_FLAG            VARCHAR2 (3 BYTE)
);

DELETE FROM xxdbl.xxdbl_om_sms_data_upload_stg;

SELECT STG.*
  FROM xxdbl.xxdbl_om_sms_data_upload_stg STG;

ALTER TABLE xxdbl.xxdbl_om_sms_data_upload_stg
   ADD (SMS_RESPONSE VARCHAR2 (100 BYTE));
   
ALTER TABLE xxdbl.xxdbl_om_sms_data_upload_stg
   ADD CONSTRAINT OM_SMS_PK PRIMARY KEY (SMS_ID);

DROP TABLE xxdbl.xxdbl_om_sms_data_upload_stg CASCADE CONSTRAINTS;

