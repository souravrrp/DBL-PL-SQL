/* Formatted on 5/18/2021 11:37:16 AM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_cust_site_stg_tbl
(
   cust_site_id         INTEGER NOT NULL,
   creation_date        DATE,
   created_by           NUMBER,
   unit_name            VARCHAR2 (240),
   operating_unit       NUMBER,
   customer_id          NUMBER,
   customer_number      VARCHAR2 (30),
   bill_site_id         NUMBER,
   bill_site_use_id     NUMBER,
   new_location_id      NUMBER,
   address1             VARCHAR2 (240),
   address2             VARCHAR2 (240),
   address3             VARCHAR2 (240),
   contact_person       VARCHAR2 (240),
   contact_number       VARCHAR2 (50),
   snd_contact_number   VARCHAR2 (50),
   country              VARCHAR2 (60),
   area                 VARCHAR2 (60),
   zone                 VARCHAR2 (60),
   division             VARCHAR2 (60),
   postal_code          VARCHAR2 (60),
   salesperson_name     VARCHAR2 (240),
   salesperson_id       VARCHAR2 (60),
   salesperson_conact   VARCHAR2 (60),
   salesperson          NUMBER,
   demand_class         VARCHAR2 (30),
   territory            NUMBER,
   status               VARCHAR2 (10),
   CONSTRAINT cust_site_pk PRIMARY KEY (cust_site_id)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_cust_site_stg_tbl FOR xxdbl.xxdbl_cust_site_stg_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_cust_site_stg_tbl FOR xxdbl.xxdbl_cust_site_stg_tbl;

GRANT SELECT ON xxdbl.xxdbl_cust_site_stg_tbl TO appsro;

GRANT INSERT, SELECT, UPDATE ON xxdbl.xxdbl_cust_site_stg_tbl TO appsdbl;

DROP TABLE xxdbl.xxdbl_cust_site_stg_tbl;



ALTER TABLE xxdbl.xxdbl_cust_site_stg_tbl
   ADD (customer_category VARCHAR2 (30));

ALTER TABLE xxdbl.xxdbl_cust_site_stg_tbl
   DROP COLUMN unit_name;

ALTER TABLE xxdbl_cust_site_stg_tbl
   MODIFY (organization_id NUMBER);

ALTER TABLE xxdbl.xxdbl_cust_site_stg_tbl
   RENAME COLUMN cusomer_name TO customer_name;