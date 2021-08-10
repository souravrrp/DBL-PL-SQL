/* Formatted on 4/11/2021 9:43:21 AM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_cust_update_stg_tbl
(
   cust_upd_id        INTEGER NOT NULL,
   creation_date      DATE,
   created_by         NUMBER,
   unit_name          VARCHAR2 (240),
   operating_unit     NUMBER,
   customer_id        NUMBER,
   customer_number    VARCHAR2 (30),
   cust_site_id       NUMBER,
   location_id        NUMBER,
   location_address   VARCHAR2 (150),
   location_version   NUMBER,
   new_location_id    NUMBER,
   new_address        VARCHAR2 (150),
   postal_code        VARCHAR2 (60),
   salesperson        NUMBER,
   demand_class       VARCHAR2 (30),
   territory          NUMBER,
   status             VARCHAR2 (10),
   CONSTRAINT cust_upd_pk PRIMARY KEY (cust_upd_id)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_cust_update_stg_tbl FOR xxdbl.xxdbl_cust_update_stg_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_cust_update_stg_tbl FOR xxdbl.xxdbl_cust_update_stg_tbl;

DROP TABLE xxdbl.xxdbl_cust_update_stg_tbl;



ALTER TABLE xxdbl.xxdbl_cust_update_stg_tbl
   ADD (status VARCHAR2 (10));

ALTER TABLE xxdbl.xxdbl_cust_update_stg_tbl
   DROP COLUMN unit_name;

ALTER TABLE xxdbl_cust_update_stg_tbl
   MODIFY (organization_id NUMBER);

ALTER TABLE xxdbl.xxdbl_cust_update_stg_tbl
   RENAME COLUMN cusomer_name TO customer_name;