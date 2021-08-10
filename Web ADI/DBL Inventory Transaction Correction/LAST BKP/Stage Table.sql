/* Formatted on 10/15/2020 3:24:57 PM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_mo_account_correction
(
   SL_NO              NUMBER NOT NULL,
   CREATION_DATE      DATE,
   CREATED_BY         NUMBER,
   TRANSACTION_ID     NUMBER,
   PRIOR_ACCOUNT      VARCHAR2 (40 BYTE),
   NEW_ACCOUNT        VARCHAR2 (40 BYTE),
   CC_ID              NUMBER,
   MO_NUMBER          VARCHAR2 (50 BYTE),
   ORGANIZATION_ID    NUMBER,
   TRANSACTION_DATE   DATE,
   FLAG               VARCHAR2 (3 BYTE),
   STATUS             VARCHAR2 (20 BYTE),
   CONSTRAINT MO_ACCT_PK PRIMARY KEY (SL_NO)
);


GRANT ALTER,
      DELETE,
      INDEX,
      INSERT,
      REFERENCES,
      SELECT,
      UPDATE,
      ON COMMIT REFRESH,
      QUERY REWRITE,
      READ,
      DEBUG,
      FLASHBACK
   ON XXDBL.xxdbl_mo_account_correction
   TO APPS
   WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON XXDBL.xxdbl_mo_account_correction TO APPSDBL;

GRANT SELECT ON XXDBL.xxdbl_mo_account_correction TO APPSRO;

GRANT INSERT, SELECT, UPDATE ON XXDBL.xxdbl_mo_account_correction TO INV;

DROP TABLE XXDBL.xxdbl_mo_account_correction CASCADE CONSTRAINTS;