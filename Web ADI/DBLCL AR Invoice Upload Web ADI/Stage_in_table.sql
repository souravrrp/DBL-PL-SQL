/* Formatted on 2/8/2022 10:34:38 AM (QP5 v5.374) */
CREATE TABLE xxdbl.xxdbl_cer_ar_intrf_stg
(
    SL_NO                   NUMBER NOT NULL,
    CREATION_DATE           DATE,
    CREATED_BY              NUMBER,
    ORGANIZATION_CODE       VARCHAR2 (10 BYTE),
    TRX_TYPE                VARCHAR2 (500 BYTE),
    CUST_TRX_TYPE_ID        NUMBER,
    BATCH_SOURCE_NAME       VARCHAR2 (500 BYTE),
    LINE_NUMBER             NUMBER,
    TRX_DATE                DATE,
    GL_DATE                 DATE,
    CURRENCY_CODE           VARCHAR2 (3 BYTE),
    CUSTOMER_NUMBER         VARCHAR2 (10 BYTE),
    SALES_ORDER             NUMBER,
    ITEM_CODE               VARCHAR2 (50 BYTE),
    QUANTITY                NUMBER,
    UNIT_SELLING_PRICE      NUMBER,
    OPERATING_UNIT          NUMBER,
    ORGANIZATION_ID         NUMBER,
    SET_OF_BOOKS            NUMBER,
    LEGAL_ENTITY_ID         NUMBER,
    ITEM_ID                 NUMBER,
    UOM_CODE                VARCHAR2 (10 BYTE),
    AMOUNT                  NUMBER,
    CUSTOMER_ID             NUMBER,
    BILL_TO_SITE_ID         NUMBER,
    SHIP_TO_SITE_ID         NUMBER,
    TERM_ID                 NUMBER,
    ORD_HEADER_ID           NUMBER,
    FREIGHT_TERMS_CODE      VARCHAR2 (50 BYTE),
    FREIGHT_CARRIER_CODE    VARCHAR2 (50 BYTE),
    SALESREP_ID             NUMBER,
    ORD_LINE_ID             NUMBER,
    ORDER_DATE              DATE,
    ORD_LINE_NUMBER         NUMBER,
    UNIT_LIST_PRICE         FLOAT,
    ACTUAL_SHIP_DATE        DATE,
    TERRITORY_ID            NUMBER,
    T_SEGMENT1              VARCHAR2 (500 BYTE),
    T_SEGMENT2              VARCHAR2 (500 BYTE),
    T_SEGMENT3              VARCHAR2 (500 BYTE),
    T_SEGMENT4              VARCHAR2 (500 BYTE),
    EXCHANGE_RATE_TYPE      VARCHAR2 (30 BYTE),
    EXCHANGE_DATE           DATE,
    EXCHANGE_RATE           NUMBER,
    CODE_COMBINATION_ID     NUMBER,
    FLAG                    VARCHAR2 (3 BYTE)
);

CREATE OR REPLACE SYNONYM appsro.xxdbl_cer_ar_intrf_stg FOR xxdbl.xxdbl_cer_ar_intrf_stg;

CREATE OR REPLACE SYNONYM apps.xxdbl_cer_ar_intrf_stg FOR xxdbl.xxdbl_cer_ar_intrf_stg;

DROP TABLE xxdbl.xxdbl_cer_ar_intrf_stg;

TRUNCATE TABLE xxdbl_cer_ar_intrf_stg;

DELETE FROM xxdbl_cer_ar_intrf_stg;



DROP TABLE APPS.xxdbl_cer_ar_intrf_stg CASCADE CONSTRAINTS;

ALTER TABLE xxdbl.xxdbl_cer_ar_intrf_stg
    RENAME COLUMN organization_code TO organization_id;