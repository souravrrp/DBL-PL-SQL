/* Formatted on 5/22/2021 12:33:46 PM (QP5 v5.287) */
CREATE TABLE xxdbl.xxdbl_om_order_upld_stg
(
   om_order_id          INTEGER NOT NULL,
   creation_date        DATE,
   created_by           NUMBER,
   unit_name            VARCHAR2 (240),
   operating_unit       NUMBER,
   order_number         NUMBER,
   order_header_id      NUMBER,
   order_line_id        NUMBER,
   customer_number      VARCHAR2 (30),
   bill_to_site_id      NUMBER,
   ship_to_site_id      NUMBER,
   sold_from_org_id     NUMBER,
   sold_to_org_id       NUMBER,
   price_list_id        NUMBER,
   salesperson          NUMBER,
   order_type_id        NUMBER,
   cust_po_number       VARCHAR2 (50),
   freight_terms_code   VARCHAR2 (30),
   line_type_id         NUMBER,
   ship_from_org_id     NUMBER,
   ship_to_org_id       NUMBER,
   item_code            VARCHAR2 (40),
   inventory_item_id    NUMBER,
   order_qty            NUMBER,
   subinventory         VARCHAR2 (150),
   shipping_method      VARCHAR2 (30),
   status               VARCHAR2 (10),
   CONSTRAINT om_order_pk PRIMARY KEY (om_order_id)
);


CREATE OR REPLACE SYNONYM appsro.xxdbl_om_order_upld_stg FOR xxdbl.xxdbl_om_order_upld_stg;

CREATE OR REPLACE SYNONYM apps.xxdbl_om_order_upld_stg FOR xxdbl.xxdbl_om_order_upld_stg;

DROP TABLE xxdbl.xxdbl_om_order_upld_stg;



ALTER TABLE xxdbl.XXDBL_OM_ORDER_UPLD_STG
   ADD (status VARCHAR2 (10));

ALTER TABLE xxdbl.xxdbl_om_order_upld_stg
   DROP COLUMN unit_name;

ALTER TABLE xxdbl_om_order_upld_stg
   MODIFY (organization_id NUMBER);

ALTER TABLE xxdbl.xxdbl_om_order_upld_stg
   RENAME COLUMN cusomer_name TO customer_name;

CREATE TABLE xxdbl.xxdbl_om_order_upld_stg
(
   om_order_id          INTEGER NOT NULL,
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
   CONSTRAINT om_order_pk PRIMARY KEY (om_order_id)
);