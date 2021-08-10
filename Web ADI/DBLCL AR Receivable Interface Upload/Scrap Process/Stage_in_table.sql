/* Formatted on 3/31/2021 4:34:02 PM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_cer_ra_interface_stg
(
   SL_NO                  NUMBER,
   CREATION_DATE          DATE,
   CREATED_BY             NUMBER,
   ORGANIZATION_CODE      VARCHAR2 (10 BYTE),
   TRX_TYPE               VARCHAR2 (500 BYTE),
   CUST_TRX_TYPE_ID       NUMBER,
   BATCH_SOURCE_NAME      VARCHAR2 (500 BYTE),
   LINE_NUMBER            NUMBER,
   TRX_DATE               DATE,
   GL_DATE                DATE,
   CURRENCY_CODE          VARCHAR2 (3 BYTE),
   CUSTOMER_NUMBER        VARCHAR2 (10 BYTE),
   SALES_ORDER            NUMBER,
   ITEM_CODE              VARCHAR2 (50 BYTE),
   QUANTITY               NUMBER,
   UNIT_SELLING_PRICE     NUMBER,
   OPERATING_UNIT         NUMBER,
   ORGANIZATION_ID        NUMBER,
   SET_OF_BOOKS           NUMBER,
   LEGAL_ENTITY_ID        NUMBER,
   ITEM_ID                NUMBER,
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
   ACTUAL_SHIP_DATE       DATE,
   TERRITORY_ID           NUMBER,
   T_SEGMENT1             VARCHAR2 (500 BYTE),
   T_SEGMENT2             VARCHAR2 (500 BYTE),
   T_SEGMENT3             VARCHAR2 (500 BYTE),
   T_SEGMENT4             VARCHAR2 (500 BYTE),
   EXCHANGE_RATE_TYPE     VARCHAR2 (30 BYTE),
   EXCHANGE_DATE          DATE,
   EXCHANGE_RATE          NUMBER,
   FLAG                   VARCHAR2 (3 BYTE)
);

CREATE OR REPLACE SYNONYM appsro.xxdbl_cer_ra_interface_stg FOR xxdbl.xxdbl_cer_ra_interface_stg;

CREATE OR REPLACE SYNONYM apps.xxdbl_cer_ra_interface_stg FOR xxdbl.xxdbl_cer_ra_interface_stg;

DROP TABLE xxdbl.xxdbl_cer_ra_interface_stg;

TRUNCATE TABLE ra_interface_table_stg;

DELETE FROM ra_interface_table_stg;

SELECT                                                                --SL_NO,
       --       ORGANIZATION_CODE,
       --       BATCH_SOURCE_NAME,
       --       LINE_NUMBER,
       --       TRX_DATE,
       --       GL_DATE,
       --       CURRENCY_CODE,
       --       CUSTOMER_NUMBER,
       --       SALES_ORDER,
       --       ITEM_CODE,
       --       QUANTITY,
       --       UNIT_SELLING_PRICE,
       --       FLAG,
       --       OPERATING_UNIT,
       --       ORGANIZATION_ID,
       --       SET_OF_BOOKS,
       --       LEGAL_ENTITY_ID,
       --       --
       --       ITEM_ID,
       --       UOM_CODE,
       --       AMOUNT,
       --       --
       --       CUSTOMER_ID,
       --       BILL_TO_SITE_ID,
       --       SHIP_TO_SITE_ID,
       --       TERM_ID,
       --       ---
       --       ORD_HEADER_ID,
       --       TRANSACTIONAL_CURR_CODE,
       --       FREIGHT_TERMS_CODE,
       --       FREIGHT_CARRIER_CODE,
       --       SALESREP_ID,
       --       ORD_LINE_ID,
       --       ORDERED_QUANTITY
       STG.*
  FROM apps.ra_interface_table_stg STG;


DROP TABLE APPS.ra_interface_table_stg CASCADE CONSTRAINTS;



BEGIN
   INSERT INTO ra_interface_lines_all (interface_line_context,
                                       interface_line_attribute1,
                                       interface_line_attribute2,
                                       amount,
                                       batch_source_name,
                                       conversion_rate,
                                       conversion_type,
                                       currency_code,
                                       cust_trx_type_id,
                                       description,
                                       gl_date,
                                       line_type,
                                       orig_system_bill_address_id,
                                       orig_system_bill_customer_id,
                                       quantity,
                                       unit_selling_price,
                                       term_id,
                                       taxable_flag,
                                       amount_includes_tax_flag,
                                       set_of_books_id,
                                       org_id,
                                       invoicing_rule_id,
                                       accounting_rule_id,
                                       accounting_rule_duration)
        VALUES ('TIP',
                'TIP RULE INVOICE 1',
                'TIP RULE INVOICE SAMPLE',
                1000.00,
                'TIP BATCH SOURCE',
                1,
                'User',
                'USD',
                3627,
                'TIP DESCRIPTION 1 - ITEM #1',
                '10-AUG-2010',
                'LINE',
                11145,
                117751,
                10,
                100.00,
                1514,
                'Y',
                'N',
                1,
                204,
                -2,
                12086,
                NULL);
END;

ALTER TABLE xxdbl.xxdbl_cer_ra_interface_stg
   RENAME COLUMN organization_code TO organization_id;