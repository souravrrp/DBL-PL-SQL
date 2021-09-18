/* Formatted on 11/8/2020 9:56:46 AM (QP5 v5.287) */
-----------------------------CREATE_TABLE---------------------------------------

CREATE TABLE w_mtl_system_items_b
(
   inventory_item_id   INTEGER
                          GENERATED ALWAYS AS IDENTITY
                             (          START WITH 1 INCREMENT BY 1)
                          NOT NULL,
   organization_id     VARCHAR2 (50) NOT NULL,
   item_code           VARCHAR2 (50),
   description         VARCHAR2 (100),
   CONSTRAINT mtl_items_pk PRIMARY KEY (inventory_item_id)
);

-----------------------------ADD_COLUMN_INTO_TABLE---------------------------------------

ALTER TABLE table_name
   ADD (lot_number NUMBER,
        attribute1 VARCHAR2 (100),
        origination_date DATE);


-----------------------------CREATE_TABLE_FROM_TABLE----------------------------
CREATE TABLE APPS.XXDBL_PR_TO_PAY_MAT_BKP AS
   SELECT *
   FROM XXDBL.XXDBL_PR_TO_PAY;
   
-----------------------------CREATE_TABLE_FROM_TABLE----------------------------
   ALTER TABLE table_name DROP COLUMN column_name;

-----------------------------CREATE_TABLE---------------------------------------

ALTER TABLE w_mtl_system_items_b
   DROP CONSTRAINT mtl_items_pk;

-----------------------------CREATE_TABLE---------------------------------------

ALTER TABLE w_mtl_system_items_b
   MODIFY (organization_id NUMBER);

-----------------------------CREATE_TABLE---------------------------------------

ALTER TABLE table_name RENAME COLUMN old_column_name  TO new_column_name;

-----------------------------CREATE_TABLE---------------------------------------

ALTER TABLE w_org_organization_definitions
   ADD CONSTRAINT org_def_pk PRIMARY KEY (organization_id);



-----------------------------CREATE_TABLE---------------------------------------

ALTER TABLE table_name
   DROP COLUMN column_name;

-----------------------------DROP_TABLE---------------------------------------
DROP TABLE table_name;

-----------------------------DROP_TABLE_WITH_CONSTRAINTS------------------------
DROP TABLE xxdbl.table_name CASCADE CONSTRAINTS;

-----------------------------CREATE_TABLE---------------------------------------
TRUNCATE TABLE table_name;


-----------------------------DELETE_TABLE---------------------------------------

DELETE FROM xxdbl.table_name;

-----------------------------SELECT_TABLE---------------------------------------

SELECT stg.*
  FROM xxdbl.table_name stg;


-----------------------------SELECT_TABLE---------------------------------------

ALTER TABLE table_name
   RENAME COLUMN old_name TO new_name;

-----------------------------RENAME_TABLE---------------------------------------

ALTER TABLE table_name
   RENAME TO
   new_table_name;

-----------------------------GRANT_TABLE----------------------------------------

CREATE OR REPLACE SYNONYM appsro.xxdbl_cust_creation_tbl FOR xxdbl.xxdbl_cust_creation_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_cust_creation_tbl FOR xxdbl.xxdbl_cust_creation_tbl;

GRANT SELECT ON xxdbl.xxdbl_gate_pass_detail TO apps WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE, DELETE ON xxdbl.xxdbl_gate_pass_detail TO appsdbl;

GRANT SELECT ON xxdbl.xxdbl_gate_pass_detail TO appsro;

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
   ON xxdbl.xxdbl_bill_rec_header
   TO apps
   WITH GRANT OPTION;


GRANT SELECT ON xxdbl.xxdbl_bill_rec_header TO appsro;

CREATE UNIQUE INDEX xxdbl.idx_om_sms_data
   ON xxdbl.xxdbl_om_sms_data_upload_stg (sms_id)
   LOGGING
   TABLESPACE xxdbl_ts_tx_data
   PCTFREE 10
   INITRANS 2
   MAXTRANS 255
   STORAGE (INITIAL 64 K
            NEXT 1 M
            MAXSIZE UNLIMITED
            MINEXTENTS 1
            MAXEXTENTS UNLIMITED
            PCTINCREASE 0
            BUFFER_POOL DEFAULT);



ALTER TABLE xxdbl.xxdbl_om_sms_data_upload_stg ADD (
  CONSTRAINT idx_om_sms_data
  PRIMARY KEY
  (sms_id)
  USING INDEX xxdbl.idx_om_sms_data
  ENABLE VALIDATE);
-----------------------------CREATE_SYNONYM-------------------------------------
CREATE OR REPLACE SYNONYM appsro.xxdbl_bill_rec_header FOR xxdbl.xxdbl_bill_rec_header;

CREATE OR REPLACE SYNONYM apps.xxdbl_bill_rec_header FOR xxdbl.xxdbl_bill_rec_header;