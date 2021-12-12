/* Formatted on 12/12/2021 2:36:29 PM (QP5 v5.374) */
CREATE TABLE XX_APEX.XX_APEX_CNF_EXPENSE_LIST
(
    EXPENSE_LIST_ID        NUMBER
                              GENERATED ALWAYS AS IDENTITY
(
                START WITH 1
    MAXVALUE 9999999999999999999999999999
    MINVALUE 1
    NOCYCLE
    CACHE 20
    NOORDER
    NOKEEP
    NOSCALE
    )
                              NOT NULL,
    EXPENSE_LIST           VARCHAR2 (200 BYTE),
    RECEIPTABLE            VARCHAR2 (10 BYTE),
    NON_RECEIPTABLE        VARCHAR2 (10 BYTE),
    PORT_SIDE              VARCHAR2 (10 BYTE),
    DEPOT_SIDE             VARCHAR2 (10 BYTE),
    CUSTOMS_SIDE           VARCHAR2 (10 BYTE),
    EXPENSE_LIST_STATUS    NUMBER,
    CREATED_BY             NUMBER,
    CREATION_DATE          DATE,
    LAST_UPDATED_BY        NUMBER,
    LAST_UPDATE_DATE       DATE,
    ATTRIBUTE1             VARCHAR2 (255 BYTE),
    ATTRIBUTE2             VARCHAR2 (255 BYTE),
    ATTRIBUTE3             VARCHAR2 (255 BYTE),
    ATTRIBUTE4             VARCHAR2 (255 BYTE),
    SL                     NUMBER (4)
);


CREATE UNIQUE INDEX XX_APEX.XX_APEX_CNF_EXPENSE_L_PK
    ON XX_APEX.XX_APEX_CNF_EXPENSE_LIST (EXPENSE_LIST_ID);

ALTER TABLE XX_APEX.XX_APEX_CNF_EXPENSE_LIST
    ADD (
        CONSTRAINT XX_APEX_CNF_EXPENSE_L_PK PRIMARY KEY (EXPENSE_LIST_ID)
            USING INDEX XX_APEX.XX_APEX_CNF_EXPENSE_L_PK ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM XX_APEX_CNF_EXPENSE_LIST FOR XX_APEX.XX_APEX_CNF_EXPENSE_LIST;


GRANT DELETE, INSERT, SELECT, UPDATE
    ON XX_APEX.XX_APEX_CNF_EXPENSE_LIST
    TO APPSRO;