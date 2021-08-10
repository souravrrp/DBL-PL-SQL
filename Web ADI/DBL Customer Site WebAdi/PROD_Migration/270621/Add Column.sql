ALTER TABLE xxdbl.xxdbl_cust_site_stg_tbl
   ADD (customer_category VARCHAR2 (30));


CREATE OR REPLACE SYNONYM appsro.xxdbl_cust_site_stg_tbl FOR xxdbl.xxdbl_cust_site_stg_tbl;

CREATE OR REPLACE SYNONYM apps.xxdbl_cust_site_stg_tbl FOR xxdbl.xxdbl_cust_site_stg_tbl;