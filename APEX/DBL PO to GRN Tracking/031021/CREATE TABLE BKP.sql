/* Formatted on 9/18/2021 10:16:51 AM (QP5 v5.354) */
CREATE TABLE XX_APEX.XXAPEX_ORD_GRN_TRACK
(
    OM_GRN_TRACK_ID           INTEGER
                                 GENERATED ALWAYS AS IDENTITY
                                     (               START WITH 1 INCREMENT BY 1)
                                 NOT NULL,
    CREATION_DATE             DATE,
    CREATED_BY                NUMBER,
    LAST_UPDATE_DATE          DATE,
    LAST_UPDATED_BY           NUMBER,
    LAST_UPDATE_LOGIN         NUMBER,
    ORGANIZATION_ID           NUMBER,
    UNIT_NAME                 VARCHAR2 (240 BYTE),
    PO_NUMBER                 VARCHAR2 (20 BYTE),
    PO_DATE                   DATE,
    LC_OPN_REQ_DT             DATE,
    PI_NUMBER                 NUMBER,
    BANK_NAME                 VARCHAR2 (500 BYTE),
    SUPPLIER_NUMBER           VARCHAR2 (30 BYTE),
    PRODUCT_NAME              VARCHAR2 (40 BYTE),
    LC_OPN_DT                 DATE,
    LC_NUMBER                 VARCHAR2 (30 BYTE),
    SND_MAIL_DT_COM_PI        DATE,
    BILL_NUMBER               VARCHAR2 (240 BYTE),
    BILL_DATE                 DATE,
    ON_BOARD_DATE             DATE,
    NOTF_BANK_DATE            DATE,
    COM_DOC_RCV_DATE          DATE,
    CNF_DOC_SEND_DATE         DATE,
    DOC_RCV_DATE              DATE,
    IGM_CREATION_DATE         DATE,
    IGM_APPROVAL_DATE         DATE,
    VESSEL_ARRIVAL_DATE       DATE,
    EAT_DATE                  DATE,
    EBT_DATE                  DATE,
    RECEIVED_DATE             DATE,
    BILL_ENTRY_DATE           DATE,
    CUSTOMS_NUMBER            NUMBER,
    DOC_SUB_DATE              DATE,
    BILL_SEND_DATE            DATE,
    REQ_BILL_ENT_DATE         DATE,
    REQ_BILL_ENT_TIME         DATE,
    REQ_SHIP_AGENT_DATE       DATE,
    REQ_SHIP_AGENT_TIME       DATE,
    REQ_DEPOT_DATE            DATE,
    REQ_DEPOT_TIME            DATE,
    COM_TRNSF_DATE            DATE,
    COM_DEPOSIT_DATE          DATE,
    DEPORT_NAME               VARCHAR2 (240 BYTE),
    CONS_DEL_DATE             DATE,
    QUANTITY                  NUMBER,
    PORT_TEST_START_DATE      DATE,
    PORT_TEST_RESULT_DATE     DATE,
    DEPOT_TEST_START_DATE     DATE,
    DEPOT_TEST_RESULT_DATE    DATE,
    PORT_CUST_DATE            DATE,
    DEPORT_CUST_DATE          DATE,
    SHIPPING_AGENT_NAME       VARCHAR2 (500 BYTE),
    ADVANCE_PAYMENT_DATE      DATE,
    DO_COLLECT_DATE           DATE,
    TRANS_PROVIDER_DATE       DATE,
    REQUISITION_DATE          DATE,
    NO_OF_VECH_REQ            NUMBER,
    CONT_IDENT_NO             VARCHAR2 (240 BYTE),
    VEHICLE_NUMBER            VARCHAR2 (240 BYTE),
    VECH_RCV_DATE             DATE,
    VECH_LEFT_DATE            DATE,
    RCVER_UNIT_NAME           VARCHAR2 (240 BYTE),
    VECH_GATE_IN_DATE         DATE,
    VECH_GATE_OUT_DATE        DATE,
    HANDOVER_DATE             DATE,
    BG_RELEASE_DATE           DATE,
    CNF_BG_RTN_DATE           DATE,
    COM_BG_RTN_DATE           DATE,
    SHIP_AGENT_BILL_DATE      DATE,
    CONSTRAINT MTL_ITEMS_PK PRIMARY KEY (OM_GRN_TRACK_ID)
);


CREATE OR REPLACE SYNONYM APPSRO.XXAPEX_ORD_GRN_TRACK FOR XX_APEX.XXAPEX_ORD_GRN_TRACK;

CREATE OR REPLACE SYNONYM APPS.XXAPEX_ORD_GRN_TRACK FOR XX_APEX.XXAPEX_ORD_GRN_TRACK;

GRANT SELECT ON XX_APEX.XXAPEX_ORD_GRN_TRACK TO APPS WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE, DELETE ON XX_APEX.XXAPEX_ORD_GRN_TRACK TO APPSDBL;