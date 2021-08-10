/* Formatted on 11/18/2020 11:31:41 AM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_manual_pi_header
(
   manual_pi_id        INTEGER NOT NULL,
   created_by           NUMBER,
   creation_date        DATE,
   last_update_login    NUMBER,
   last_updated_by      NUMBER,
   last_update_date     DATE,
   operating_unit      NUMBER,
   legal_entity_id     NUMBER,
   organization_id     VARCHAR2 (50),
   manual_pi_number    VARCHAR2 (50),
   manual_pi_date      DATE,
   status              VARCHAR2 (50),
   customer_no         VARCHAR2 (50),
   customer_name       VARCHAR2 (50),
   po_number           VARCHAR2 (50),
   style               VARCHAR2 (50),
   merchandiser_name   VARCHAR2 (50),
   manual_bs_number    VARCHAR2 (50),
   manual_bs_date      DATE,
   CONSTRAINT manual_pi_pk PRIMARY KEY (manual_pi_id)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_manual_pi_header FOR xxdbl.xxdbl_manual_pi_header;

CREATE OR REPLACE SYNONYM apps.xxdbl_manual_pi_header FOR xxdbl.xxdbl_manual_pi_header;

DROP TABLE xxdbl.xxdbl_manual_pi_header;

CREATE TABLE xxdbl.xxdbl_manual_pi_line
(
   manual_pi_line_id   INTEGER NOT NULL,
   manual_pi_id        INTEGER NOT NULL,
   created_by           NUMBER,
   creation_date        DATE,
   last_update_login    NUMBER,
   last_updated_by      NUMBER,
   last_update_date     DATE,
   article_name        VARCHAR2 (50),
   inventory_item_id   NUMBER,
   item_code           VARCHAR2 (50),
   item_description    VARCHAR2 (500),
   unit_of_measure     VARCHAR2 (50),
   quantity            NUMBER,
   gross_weight        NUMBER,
   net_weight          NUMBER,
   unit_price          NUMBER,
   net_value           NUMBER,
   CONSTRAINT manual_pi_ln_pk PRIMARY KEY (manual_pi_line_id)
);

CREATE OR REPLACE SYNONYM appsro.xxdbl_manual_pi_line FOR xxdbl.xxdbl_manual_pi_line;

CREATE OR REPLACE SYNONYM apps.xxdbl_manual_pi_line FOR xxdbl.xxdbl_manual_pi_line;

DROP TABLE xxdbl.xxdbl_manual_pi_line;


ALTER TABLE XXDBL.XXDBL_MANUAL_PI_LINE
   ADD (TOAL_VALUE NUMBER);

ALTER TABLE XXDBL.XXDBL_MANUAL_PI_LINE DROP COLUMN TOAL_VALUE;

ALTER TABLE XXDBL.XXDBL_MANUAL_PI_HEADER
   ADD (BANK_NAME    VARCHAR2 (500));   
   
   
