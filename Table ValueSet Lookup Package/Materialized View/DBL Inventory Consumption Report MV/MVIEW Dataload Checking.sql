/* Formatted on 6/22/2021 10:16:15 AM (QP5 v5.287) */
SELECT *
  FROM APPS.XXDBL_INV_CON_RPT_MV
 WHERE     1 = 1
       --AND TO_CHAR (TRANSACTION_DATE, 'DD-MON-YY') = '01-FEB-21'
       --AND TO_CHAR (TRANSACTION_DATE, 'MON-YY') = 'FEB-21'
       --AND ASSET IS NOT NULL
       --AND ORGANIZATION_ID = 195
       ;

SELECT * FROM inv.mtl_material_transactions;


EXECUTE APPS.xxdbl_mview_dtld_pkg.run_mview_dataload_proc;

--apps.xxdbl_mview_dtld_pkg.run_mview_dataload_conc;

--------------------------------------------------------------------------------
--EXECUTE APPS.xxdbl_mview_dtld_pkg.run_scheduler_job_proc;

--apps.xxdbl_mview_dtld_pkg.run_scheduler_job_conc;