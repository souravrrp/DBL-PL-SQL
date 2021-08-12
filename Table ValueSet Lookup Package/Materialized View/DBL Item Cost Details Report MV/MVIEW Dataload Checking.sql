/* Formatted on 8/12/2021 11:32:17 AM (QP5 v5.354) */
SELECT *
  FROM APPS.XXDBL_INV_ITEM_CST_RPT_MV#
 WHERE 1 = 1 AND PERIOD_DESC = 'JUL-21' AND legal_entity_id = 23277;

SELECT *
  FROM APPS.XXDBL_INV_ITEM_CST_RPT_MV
 WHERE 1 = 1 AND PERIOD_DESC = 'JUL-21' AND legal_entity_id = 23277;

SELECT * FROM inv.mtl_material_transactions;


EXECUTE APPS.xxdbl_mview_dtld_pkg.run_mview_dataload_proc;

--apps.xxdbl_mview_dtld_pkg.run_mview_dataload_conc;

--------------------------------------------------------------------------------
--EXECUTE APPS.xxdbl_mview_dtld_pkg.run_scheduler_job_proc;

--apps.xxdbl_mview_dtld_pkg.run_scheduler_job_conc;