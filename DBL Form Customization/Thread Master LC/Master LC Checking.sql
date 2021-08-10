/* Formatted on 4/12/2021 12:21:41 PM (QP5 v5.354) */
SELECT mlh.*
  FROM xxdbl_master_lc_headers  mlh,
       xxdbl_master_lc_line1    mll1,
       xxdbl_master_lc_line2    mll2
 WHERE     1 = 1
       AND ( :p_org_id IS NULL OR (mlh.org_id = :p_org_id))
       AND mlh.master_lc_header_id = mll1.master_lc_header_id(+)
       AND mlh.master_lc_header_id = mll2.master_lc_header_id(+)
       --AND internal_doc_number='lc-66046-000002'
       --AND master_lc_number in ('dpcdak810222')
       AND ( :p_pi_number IS NULL OR (mll1.pi_number = :p_pi_number))
       AND ( :p_lc_number IS NULL OR (mlh.master_lc_number = :p_lc_number))
       AND ( :p_mpi_number IS NULL OR (mlh.mpi_number = :p_mpi_number));

--------------------------------------------------------------------------------

SELECT *
  FROM xxdbl_master_lc_headers mlh
 WHERE     1 = 1
       AND ( :p_org_id IS NULL OR (mlh.org_id = :p_org_id))
       AND ( :p_customer_no IS NULL OR (mlh.customer_number = :p_customer_no))
       --AND INTERNAL_DOC_NUMBER='LC-66046-000002'
       --AND master_lc_number IN ('411011103578-L')
       AND ( :p_lc_number IS NULL OR (mlh.master_lc_number = :p_lc_number));

SELECT *
  FROM xxdbl_master_lc_line1 mll1
 WHERE 1 = 1 AND mll1.master_lc_header_id = '676';

SELECT *
  FROM xxdbl_master_lc_line2 mll2
 WHERE 1 = 1 AND mll1.master_lc_header_id = '676';


--------------------------------------------------------------------------------UPDATE
--SELECT * FROM

UPDATE xxdbl.xxdbl_master_lc_headers mlh
   SET mlh.MPI_NUMBER = 'MPI-1000008'
 WHERE 1 = 1 AND mlh.master_lc_header_id = 1688;

--COMMIT;