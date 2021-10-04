/* Formatted on 10/3/2021 10:01:27 AM (QP5 v5.365) */
CREATE TABLE XX_APEX.XXAPEX_PO_GRN_HDR
(
    PO_GRN_TRACK_ID      INTEGER NOT NULL,
    CREATION_DATE        DATE,
    CREATED_BY           NUMBER,
    LAST_UPDATE_DATE     DATE,
    LAST_UPDATED_BY      NUMBER,
    LAST_UPDATE_LOGIN    NUMBER,
    UNIT_NAME            VARCHAR2 (240 BYTE),
    PO_NUMBER            VARCHAR2 (20 BYTE),
    PO_DATE              DATE,
    CONSTRAINT PO_GRN_HDR_PK PRIMARY KEY (PO_GRN_TRACK_ID)
);


CREATE OR REPLACE SYNONYM APPSRO.XXAPEX_PO_GRN_HDR FOR XX_APEX.XXAPEX_PO_GRN_HDR;

CREATE OR REPLACE SYNONYM APPS.XXAPEX_PO_GRN_HDR FOR XX_APEX.XXAPEX_PO_GRN_HDR;

GRANT ALTER, SELECT
    ON XX_APEX.XXAPEX_PO_GRN_HDR
    TO APPS
    WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE, DELETE
    ON XX_APEX.XXAPEX_PO_GRN_HDR
    TO APPSDBL;

DROP TABLE XX_APEX.XXAPEX_PO_GRN_HDR CASCADE CONSTRAINTS;