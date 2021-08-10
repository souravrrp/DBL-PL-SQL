/* Formatted on 6/16/2020 11:20:58 AM (QP5 v5.287) */
CREATE TABLE apps.ar_bill_upload_stg
(
   SL_NO                NUMBER (35),
   --------------BILL HEADER----------------------------------------------------
   BILL_HEADER_ID       NUMBER (35),
   OPERATING_UNIT       VARCHAR2 (100 BYTE),
   ORG_ID               NUMBER (35),
   CUSTOMER_NUMBER      NUMBER (35),
   CUSTOMER_ID          NUMBER (35),
   CUSTOMER_NAME        VARCHAR2 (1000 BYTE),
   CUSTOMER_TYPE        VARCHAR2 (10 BYTE),
   BILL_DATE            DATE,
   BILL_CURRENCY        VARCHAR2 (3 BYTE),
   BILL_CATEGORY        VARCHAR2 (50 BYTE),
   EXCHANCE_RATE        NUMBER (35),
   LAST_UPDATE_DATE     DATE,
   LAST_UPDATED_BY      NUMBER (35),
   LAST_UPDATE_LOGIN    NUMBER (35),
   CREATED_BY           NUMBER (35),
   CREATION_DATE        DATE,
   BILL_TYPE            VARCHAR2 (50 BYTE),
   --------------BILL LINE------------------------------------------------------
   BILL_LINE_ID         NUMBER (35),
   CHALLAN_NUMBER       VARCHAR2 (50 BYTE),
   CHALLAN_QTY          NUMBER (35),
   CHALLAN_DATE         DATE,
   --------------BILL LINE DETAILS----------------------------------------------
   ITEM_CODE            VARCHAR2 (50 BYTE),
   ITEM_NAME            VARCHAR2 (500 BYTE),
   UOM                  VARCHAR2 (500 BYTE),
   FINISHING_WEIGHT     NUMBER (35),
   UNIT_SELLING_PRICE   NUMBER (35),
   STATUS               VARCHAR2 (3 BYTE),
   PO_NUMBER            VARCHAR2 (50 BYTE),
   PI_NUMBER            VARCHAR2 (50 BYTE),
   FLAG                 VARCHAR2 (3 BYTE)
);

SELECT SL_NO,
       OPERATING_UNIT,
       --ORG_ID,
       CUSTOMER_NUMBER,
       --CUSTOMER_ID,
       --CUSTOMER_NAME,
       --CUSTOMER_TYPE,
       BILL_CURRENCY,
       BILL_CATEGORY,
       EXCHANCE_RATE,
       BILL_DATE,
       --LAST_UPDATE_DATE,
       --LAST_UPDATED_BY,
       --LAST_UPDATE_LOGIN,
       --CREATED_BY,
       --CREATION_DATE,
       BILL_TYPE,
       CHALLAN_DATE,
       CHALLAN_QTY,
       ITEM_CODE,
       --ITEM_NAME,
       --UOM,
       FINISHING_WEIGHT,
       PO_NUMBER,
       PI_NUMBER,
       UNIT_SELLING_PRICE
       --STATUS,
       --flag,
  --,STG.*
  FROM apps.ar_bill_upload_stg;


DROP TABLE APPS.AR_BILL_UPLOAD_STG CASCADE CONSTRAINTS;