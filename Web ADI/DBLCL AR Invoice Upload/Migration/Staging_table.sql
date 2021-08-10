/* Formatted on 5/2/2021 2:06:17 PM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_cer_ar_inv_upld_stg
(
   SL_NO                  NUMBER NOT NULL,
   CREATION_DATE          DATE,
   CREATED_BY             NUMBER,
   ORGANIZATION_CODE      VARCHAR2 (10 BYTE),
   OPERATING_UNIT         NUMBER,
   ORGANIZATION_ID        NUMBER,
   SET_OF_BOOKS           NUMBER,
   LEGAL_ENTITY_ID        NUMBER,
   TRX_TYPE               VARCHAR2 (500 BYTE),
   CUST_TRX_TYPE_ID       NUMBER,
   GL_ID_REV              NUMBER,
   BATCH_SOURCE_NAME      VARCHAR2 (500 BYTE),
   BATCH_SOURCE_ID        NUMBER,
   LINE_NUMBER            NUMBER,
   TRX_DATE               DATE,
   GL_DATE                DATE,
   CURRENCY_CODE          VARCHAR2 (3 BYTE),
   CUSTOMER_NUMBER        VARCHAR2 (10 BYTE),
   SALES_ORDER            NUMBER,
   ITEM_CODE              VARCHAR2 (50 BYTE),
   QUANTITY               NUMBER,
   UNIT_SELLING_PRICE     NUMBER,
   LINE_DESCRIPTION       VARCHAR2 (500 BYTE),
   ITEM_ID                NUMBER,
   ITEM_DESCRIPTION       VARCHAR2 (500 BYTE),
   UOM_CODE               VARCHAR2 (10 BYTE),
   AMOUNT                 NUMBER,
   CUSTOMER_ID            NUMBER,
   BILL_TO_SITE_ID        NUMBER,
   SHIP_TO_SITE_ID        NUMBER,
   TERM_ID                NUMBER,
   ORD_HEADER_ID          NUMBER,
   FREIGHT_TERMS_CODE     VARCHAR2 (50 BYTE),
   FREIGHT_CARRIER_CODE   VARCHAR2 (50 BYTE),
   SALESREP_ID            NUMBER,
   ORD_LINE_ID            NUMBER,
   ORDER_DATE             DATE,
   ORD_LINE_NUMBER        NUMBER,
   UNIT_LIST_PRICE        FLOAT,
   EXCHANGE_RATE_TYPE     VARCHAR2 (30 BYTE),
   EXCHANGE_DATE          DATE,
   EXCHANGE_RATE          NUMBER,
   ACTUAL_SHIP_DATE       DATE,
   TERRITORY_ID           NUMBER,
   T_SEGMENT1             VARCHAR2 (500 BYTE),
   T_SEGMENT2             VARCHAR2 (500 BYTE),
   T_SEGMENT3             VARCHAR2 (500 BYTE),
   T_SEGMENT4             VARCHAR2 (500 BYTE),
   FLAG                   VARCHAR2 (3 BYTE)
);

CREATE OR REPLACE SYNONYM appsro.xxdbl_cer_ar_inv_upld_stg FOR xxdbl.xxdbl_cer_ar_inv_upld_stg;

CREATE OR REPLACE SYNONYM apps.xxdbl_cer_ar_inv_upld_stg FOR xxdbl.xxdbl_cer_ar_inv_upld_stg;

GRANT SELECT ON xxdbl.xxdbl_bill_rec_header TO appsro;