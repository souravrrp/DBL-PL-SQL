/* Formatted on 5/30/2021 11:13:17 AM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_cust_creation_tbl
(
   cust_id                    INTEGER NOT NULL,
   creation_date              DATE,
   created_by                 NUMBER,
   unit_name                  VARCHAR2 (240),
   operating_unit             NUMBER,
   cust_account_id            NUMBER,
   customer_number            VARCHAR2 (30),
   customer_name              VARCHAR2 (240),
   customer_type              VARCHAR2 (30),
   customer_category          VARCHAR2 (30),
   salesperson                NUMBER,
   buyer                      VARCHAR2 (30),
   payment_term               NUMBER,
   demand_class               VARCHAR2 (30),
   territory                  NUMBER,
   attribute_category         VARCHAR2 (30),
   attribute1                 VARCHAR2 (150),
   attribute2                 VARCHAR2 (150),
   attribute3                 VARCHAR2 (150),
   attribute4                 VARCHAR2 (150),
   address1                   VARCHAR2 (150),
   address2                   VARCHAR2 (150),
   address3                   VARCHAR2 (150),
   address4                   VARCHAR2 (150),
   postal_code                VARCHAR2 (60),
   gl_id_rec                  NUMBER,
   party_id                   NUMBER,
   party_site_id              NUMBER,
   location_id                NUMBER,
   cust_acct_site_id          NUMBER,
   bill_site_use_id           NUMBER,
   ship_site_use_id           NUMBER,
   cust_account_profile_id    NUMBER,
   cust_acct_profile_amt_id   NUMBER,
   status                     VARCHAR2 (10),
   CONSTRAINT cust_creation_pk PRIMARY KEY (cust_id)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_cust_creation_tbl FOR xxdbl.xxdbl_cust_creation_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_cust_creation_tbl FOR xxdbl.xxdbl_cust_creation_tbl;

DROP TABLE xxdbl.xxdbl_cust_creation_tbl;



ALTER TABLE xxdbl.xxdbl_cust_creation_tbl
   ADD (status VARCHAR2 (10));

ALTER TABLE xxdbl.xxdbl_cust_creation_tbl
   DROP COLUMN unit_name;

ALTER TABLE xxdbl_cust_creation_tbl
   MODIFY (payment_term NUMBER);

ALTER TABLE xxdbl.xxdbl_cust_creation_tbl
   RENAME COLUMN cusomer_name TO customer_name;