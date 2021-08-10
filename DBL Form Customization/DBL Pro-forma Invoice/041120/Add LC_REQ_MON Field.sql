/* Formatted on 12/23/2020 4:24:16 PM (QP5 v5.287) */
SELECT * FROM xxdbl_proforma_headers;

CREATE OR REPLACE PUBLIC SYNONYM xxdbl_proforma_headers FOR xxdbl.xxdbl_proforma_headers;

ALTER TABLE xxdbl.xxdbl_proforma_headers
   ADD (lc_req_mon VARCHAR2 (100));