/* Formatted on 4/12/2021 11:29:23 AM (QP5 v5.354) */
SELECT *
  FROM xxdbl.xxdbl_manual_pi_header mph, xxdbl.xxdbl_manual_pi_line mpl
 WHERE     1 = 1
       AND mph.manual_pi_id = mpl.manual_pi_id
       --AND MANUAL_PI_NUMBER IN ('MPI-1000200')
       AND ( :p_manual_pi_number IS NULL OR (mph.manual_pi_number = :p_manual_pi_number));

 -------------------------------------------------------------------------------

SELECT *
  FROM xxdbl.xxdbl_manual_pi_header mph
 WHERE 1 = 1                         --AND manual_pi_number IN ('MPI-1000200')
             AND ( :p_manual_pi_number IS NULL OR (mph.manual_pi_number = :p_manual_pi_number));

SELECT *
  FROM xxdbl.xxdbl_manual_pi_line mph
 WHERE 1 = 1 AND MANUAL_PI_ID = 10068;

 -------------------------------------------------------------------------------


SELECT *
  FROM xxdbl.xxdbl_manual_pi_header mph, xxdbl.xxdbl_manual_pi_line mpl
 WHERE     1 = 1
       AND mph.manual_pi_id = mpl.manual_pi_id
       --AND MANUAL_PI_NUMBER IN ('MPI-1000200')
       AND ( :p_manual_pi_number IS NULL OR (mph.manual_pi_number = :p_manual_pi_number));


 --truncate table xxdbl.xxdbl_manual_pi_header;