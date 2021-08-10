/* Formatted on 12/2/2020 11:47:36 AM (QP5 v5.287) */
  SELECT meaning payment_terms
    FROM fnd_lookup_values_vl
   WHERE     1 = 1
         AND lookup_type LIKE 'XXDBL_OM_PI_PAYMENT_TERMS'
         AND NVL (enabled_flag, 'N') = 'Y'
         AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                        NVL (start_date_active, SYSDATE - 1))
                                 AND TRUNC (NVL (end_date_active, SYSDATE + 1))
ORDER BY 1;


/* Formatted on 11/4/2020 12:47:12 PM (QP5 v5.287) */
ALTER TABLE xxdbl.xxdbl_manual_pi_header
   ADD (payment_terms VARCHAR2(240));

DROP SYNONYM xxdbl.xxdbl_manual_pi_header;

CREATE OR REPLACE SYNONYM appsro.xxdbl_manual_pi_line FOR xxdbl.xxdbl_manual_pi_line;

CREATE OR REPLACE SYNONYM apps.xxdbl_manual_pi_line FOR xxdbl.xxdbl_manual_pi_line;

--SELECT
--*
--FROM
--xxdbl.xxdbl_proforma_headers
--WHERE 1=1
--AND MANUAL_PI_NO='MPI-1000070'

Column Name:


payment_terms PAYMENT_TERMS

SELECT * FROM xxdbl.xxdbl_manual_pi_header;
