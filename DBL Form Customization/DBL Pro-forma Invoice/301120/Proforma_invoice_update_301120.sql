/* Formatted on 11/4/2020 12:47:12 PM (QP5 v5.287) */
ALTER TABLE xxdbl.xxdbl_proforma_headers
   ADD (manual_pi_no VARCHAR2(50));

DROP SYNONYM XXDBL_PROFORMA_HEADERS;

CREATE OR REPLACE PUBLIC SYNONYM XXDBL_PROFORMA_HEADERS FOR XXDBL.XXDBL_PROFORMA_HEADERS;

--CREATE OR REPLACE PUBLIC SYNONYM XXDBL_BILL_STAT_HEADERS FOR XXDBL.XXDBL_BILL_STAT_HEADERS;

SELECT
*
FROM
xxdbl.xxdbl_proforma_headers
WHERE 1=1
AND MANUAL_PI_NO='MPI-1000070'

Column Name:


manual_pi_no MANUAL_PI_NO

SELECT * FROM xxdbl.xxdbl_manual_pi_header;

select manual_pi_number from xxdbl.xxdbl_manual_pi_header mpi where mpi.status='CONFIRMED' and mpi.customer_no=:xxdbl_proforma_headers.customer_number;


ALTER TABLE xxdbl.xxdbl_bill_stat_headers DROP COLUMN manual_pi_no;