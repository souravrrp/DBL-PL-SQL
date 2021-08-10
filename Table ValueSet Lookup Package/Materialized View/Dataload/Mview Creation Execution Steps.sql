/* Formatted on 6/22/2021 4:55:27 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_INV_CON_RPT_MV#
(
   SET_OF_BOOKS_ID,
   ORGANIZATION_ID,
   ORGANIZATION_NAME,
   TR_TYPE,
   TRANSACTION_ID,
   TRANSACTION_DATE,
   MO_NO,
   ITEM_CODE,
   ITEM_DESCRIPTION,
   UOM,
   ITEM_CATEGORY,
   ITEM_TYPE,
   USE_AREA,
   NATURAL_ACC,
   COMPANY_CODE,
   LOCATION_DESC,
   PRODUCT_LINE_DESC,
   COST_CENTER_DESC,
   NATURAL_ACCOUNT_DESC,
   SUB_ACCCOUNT_DESC,
   INTER_COMPANY,
   EXP_CATEGORY_DESC,
   CODE_COMBINATION,
   QTY,
   UNIT_COST,
   TOTAL_COST,
   BUYER_NAME,
   CUSTOMER_NAME,
   CREATED_BY,
   ASSET,
   ASSET_CATEGORY
)
AS
   SELECT "SET_OF_BOOKS_ID",
       "ORGANIZATION_ID",
       "ORGANIZATION_NAME",
       "TR_TYPE",
       "TRANSACTION_ID",
       "TRANSACTION_DATE",
       "MO_NO",
       "ITEM_CODE",
       "ITEM_DESCRIPTION",
       "UOM",
       "ITEM_CATEGORY",
       "ITEM_TYPE",
       "USE_AREA",
       "NATURAL_ACC",
       "COMPANY" "COMPANY_CODE",
       "LOCATION_DESC",
       "PRODUCT_LINE_DESC",
       "COST_CENTER_DESC",
       "NATURAL_ACCOUNT_DESC",
       "SUB_ACCCOUNT_DESC",
       "INTER_COMPANY",
       "EXP_CATEGORY_DESC",
       "CODE_COMBINATION",
       "TRX_QUANTITY" "QTY",
       ABS ("TOTAL_COST" / "TRX_QUANTITY") "UNIT_COST",
       "TOTAL_COST",
       CAST ("BUYER_NAME" AS VARCHAR2 (240)),
       CAST ("CUSTOMER_NAME" AS VARCHAR2 (240)),
       "CREATED_BY",
       "ASSET",
       "ASSET_CATEGORY"
  FROM (SELECT '1.MOVE_ORDER' AS "TR_SOURCE",
               'Move_Order' "TR_TYPE",
               "A"."TRANSACTION_ID",
               "C"."SEGMENT1" "ITEM_CODE",
               "C"."DESCRIPTION" "ITEM_DESCRIPTION",
               "C"."PRIMARY_UOM_CODE" "UOM",
               "MIC"."SEGMENT2" "ITEM_CATEGORY",
               "MIC"."SEGMENT3" "ITEM_TYPE",
               ("A"."PRIMARY_QUANTITY") "TRX_QUANTITY",
               CASE
                  WHEN "MP"."PROCESS_ENABLED_FLAG" = 'N'
                  THEN
                     "APPS"."XX_INV_TRAN_VAL_T" ("A"."TRANSACTION_ID")
                  ELSE
                     "APPS"."XX_OINV_TRAN_VAL" ("A"."TRANSACTION_ID")
               END
                  AS "TOTAL_COST",
               "CC"."SEGMENT5" "NATURAL_ACC",
               "CC"."SEGMENT1" "COMPANY",
               "CC"."SEGMENT2" "LOCATION_DESC",
               "CC"."SEGMENT3" "PRODUCT_LINE_DESC",
               "CC"."SEGMENT4" "COST_CENTER_DESC",
               "CC"."SEGMENT5" "NATURAL_ACCOUNT_DESC",
               "CC"."SEGMENT6" "SUB_ACCCOUNT_DESC",
               "CC"."SEGMENT7" "INTER_COMPANY",
               "CC"."SEGMENT8" "EXP_CATEGORY_DESC",
               "OOD"."OPERATING_UNIT" "ORG_ID",
               "OOD"."ORGANIZATION_NAME",
               "OOD"."SET_OF_BOOKS_ID",
               "OOD"."ORGANIZATION_ID",
               "B"."REQUEST_NUMBER" "MO_NO",
               TRUNC ("A"."TRANSACTION_DATE") "TRANSACTION_DATE",
               "PRD"."PERIOD_NAME",
               NVL ("MTRL"."ATTRIBUTE7", "MTRL"."ATTRIBUTE13") "USE_AREA",
                  "CC"."SEGMENT1"
               || '.'
               || "CC"."SEGMENT2"
               || '.'
               || "CC"."SEGMENT3"
               || '.'
               || "CC"."SEGMENT4"
               || '.'
               || "CC"."SEGMENT5"
               || '.'
               || "CC"."SEGMENT6"
               || '.'
               || "CC"."SEGMENT7"
               || '.'
               || "CC"."SEGMENT8"
               || '.'
               || "CC"."SEGMENT9"
                  "CODE_COMBINATION",
               NULL "BUYER_NAME",
               NULL "CUSTOMER_NAME",
               "B"."CREATED_BY" "CREATED_BY",
               "MTRL"."ATTRIBUTE1" "ASSET",
               "MTRL"."ATTRIBUTE_CATEGORY" "ASSET_CATEGORY"
          FROM "APPS"."MTL_MATERIAL_TRANSACTIONS" "A",
               "APPS"."MTL_TXN_REQUEST_HEADERS" "B",
               "MTL_TXN_REQUEST_LINES_V" "MTRL",
               "APPS"."MTL_SYSTEM_ITEMS_B_KFV" "C",
               "APPS"."MTL_ITEM_CATEGORIES_V" "MIC",
               "APPS"."GL_CODE_COMBINATIONS" "CC",
               "INV"."MTL_PARAMETERS" "MP",
               "APPS"."ORG_ORGANIZATION_DEFINITIONS" "OOD",
               "APPS"."HR_OPERATING_UNITS" "HOU",
               "INV"."ORG_ACCT_PERIODS" "PRD",
               "APPLSYS"."FND_USER" "FNU"
         WHERE     "A"."ORGANIZATION_ID" = "MP"."ORGANIZATION_ID"
               AND "MP"."ORGANIZATION_ID" = "OOD"."ORGANIZATION_ID"
               AND "OOD"."OPERATING_UNIT" = "HOU"."ORGANIZATION_ID"
               AND "A"."INVENTORY_ITEM_ID" = "C"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
               AND "A"."INVENTORY_ITEM_ID" = "MIC"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "MIC"."ORGANIZATION_ID"
               AND "A"."TRANSACTION_TYPE_ID" IN (63)
               AND "A"."TRANSACTION_SOURCE_ID" = "B"."HEADER_ID"
               AND "B"."HEADER_ID" = "MTRL"."HEADER_ID"
               AND "B"."CREATED_BY" = "FNU"."USER_ID"
               AND "A"."DISTRIBUTION_ACCOUNT_ID" = "CC"."CODE_COMBINATION_ID"
               AND "A"."ACCT_PERIOD_ID" = "PRD"."ACCT_PERIOD_ID"
               AND "A"."TRANSACTION_QUANTITY" < 0
               AND "A"."ORGANIZATION_ID" = "PRD"."ORGANIZATION_ID"
               AND "MTRL"."INVENTORY_ITEM_ID" = "A"."INVENTORY_ITEM_ID"
               AND "MTRL"."ORGANIZATION_ID" = "A"."ORGANIZATION_ID"
               AND "MTRL"."LINE_ID" = "A"."TRX_SOURCE_LINE_ID"
               AND "A"."TRANSACTION_SOURCE_ID" = "B"."HEADER_ID"
               AND "MIC"."CATEGORY_SET_NAME" = 'Inventory'
        UNION ALL
        SELECT '2"."OPM_DIS_ACC_ALS' AS "TR_SOURCE",
               'Move_Order' "TR_TYPE",
               "A"."TRANSACTION_ID",
               "C"."SEGMENT1" "ITEM_CODE",
               "C"."DESCRIPTION" "ITEM_DESCRIPTION",
               "C"."PRIMARY_UOM_CODE" "UOM",
               "MIC"."SEGMENT2" "ITEM_CATEGORY",
               "MIC"."SEGMENT3" "ITEM_TYPE",
               ("A"."PRIMARY_QUANTITY") "TRX_QUANTITY",
               CASE
                  WHEN "MP"."PROCESS_ENABLED_FLAG" = 'N'
                  THEN
                     "APPS"."XX_INV_TRAN_VAL_T" ("A"."TRANSACTION_ID")
                  ELSE
                     "APPS"."XX_OINV_TRAN_VAL" ("A"."TRANSACTION_ID")
               END
                  AS "TOTAL_COST",
               "CC"."SEGMENT5" "NATURAL_ACC",
               "CC"."SEGMENT1" "COMPANY",
               "CC"."SEGMENT2" "LOCATION_DESC",
               "CC"."SEGMENT3" "PRODUCT_LINE_DESC",
               "CC"."SEGMENT4" "COST_CENTER_DESC",
               "CC"."SEGMENT5" "NATURAL_ACCOUNT_DESC",
               "CC"."SEGMENT6" "SUB_ACCCOUNT_DESC",
               "CC"."SEGMENT7" "INTER_COMPANY",
               "CC"."SEGMENT8" "EXP_CATEGORY_DESC",
               "OOD"."OPERATING_UNIT" "ORG_ID",
               "OOD"."ORGANIZATION_NAME",
               "OOD"."SET_OF_BOOKS_ID",
               "OOD"."ORGANIZATION_ID",
               NULL "MO_NO",
               TRUNC ("A"."TRANSACTION_DATE") "TRANSACTION_DATE",
               TO_CHAR ("A"."TRANSACTION_DATE", 'MON-RR') "PERIOD_NAME",
               'Production_Use' AS "Use_Area",
                  "CC"."SEGMENT1"
               || '.'
               || "CC"."SEGMENT2"
               || '.'
               || "CC"."SEGMENT3"
               || '.'
               || "CC"."SEGMENT4"
               || '.'
               || "CC"."SEGMENT5"
               || '.'
               || "CC"."SEGMENT6"
               || '.'
               || "CC"."SEGMENT7"
               || '.'
               || "CC"."SEGMENT8"
               || '.'
               || "CC"."SEGMENT9"
                  "CODE_COMBINATION",
               NULL "BUYER_NAME",
               NULL "CUSTOMER_NAME",
               "A"."CREATED_BY" "CREATED_BY",
               NULL "ASSET",
               NULL "ASSET_CATEGORY"
          FROM "APPS"."MTL_MATERIAL_TRANSACTIONS" "A",
               "APPS"."MTL_GENERIC_DISPOSITIONS" "B",
               "APPS"."MTL_SYSTEM_ITEMS_B_KFV" "C",
               "APPS"."MTL_ITEM_CATEGORIES_V" "MIC",
               "APPS"."GL_CODE_COMBINATIONS" "CC",
               "INV"."MTL_PARAMETERS" "MP",
               "APPS"."ORG_ORGANIZATION_DEFINITIONS" "OOD",
               "APPS"."HR_OPERATING_UNITS" "HOU",
               "APPLSYS"."FND_USER" "FNU"
         WHERE     "A"."ORGANIZATION_ID" = "MP"."ORGANIZATION_ID"
               AND "MP"."ORGANIZATION_ID" = "OOD"."ORGANIZATION_ID"
               AND "OOD"."OPERATING_UNIT" = "HOU"."ORGANIZATION_ID"
               AND "A"."INVENTORY_ITEM_ID" = "C"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
               AND "A"."INVENTORY_ITEM_ID" = "MIC"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "MIC"."ORGANIZATION_ID"
               AND "A"."TRANSACTION_TYPE_ID" IN (31, 41, 100)
               AND "A"."TRANSACTION_SOURCE_ID" = "B"."DISPOSITION_ID"
               AND "A"."CREATED_BY" = "FNU"."USER_ID"
               AND "B"."DISTRIBUTION_ACCOUNT" = "CC"."CODE_COMBINATION_ID"
               AND "B"."ORGANIZATION_ID" = "A"."ORGANIZATION_ID"
               AND "CATEGORY_SET_NAME" = 'Inventory'
        UNION ALL
        SELECT '3.EXP_PO' AS "TR_SOURCE",
               'Expense PO' "TR_TYPE",
               "RT"."TRANSACTION_ID",
               "C"."SEGMENT1" "ITEM_CODE",
               "PLL"."ITEM_DESCRIPTION",
               "PLL"."UNIT_MEAS_LOOKUP_CODE" "UOM",
               "MIC"."SEGMENT2" "ITEM_CATEGORY",
               "MIC"."SEGMENT3" "ITEM_TYPE",
               "RRSL"."SOURCE_DOC_QUANTITY" "TRX_QUANTITY",
                 NVL ("RRSL"."ACCOUNTED_CR", 0)
               - NVL ("RRSL"."ACCOUNTED_DR", 0)
                  "TOTAL_COST",
               "CC"."SEGMENT5" "NATURAL_ACC",
               "CC"."SEGMENT1" "COMPANY",
               "CC"."SEGMENT2" "LOCATION_DESC",
               "CC"."SEGMENT3" "PRODUCT_LINE_DESC",
               "CC"."SEGMENT4" "COST_CENTER_DESC",
               "CC"."SEGMENT5" "NATURAL_ACCOUNT_DESC",
               "CC"."SEGMENT6" "SUB_ACCCOUNT_DESC",
               "CC"."SEGMENT7" "INTER_COMPANY",
               "CC"."SEGMENT8" "EXP_CATEGORY_DESC",
               "OOD"."OPERATING_UNIT" "ORG_ID",
               "OOD"."ORGANIZATION_NAME",
               "OOD"."SET_OF_BOOKS_ID",
               "OOD"."ORGANIZATION_ID",
               NULL "MO_NO",
               "RT"."TRANSACTION_DATE",
               "RRSL"."PERIOD_NAME",
               'EXPENSE_PO' AS "Use_Area",
                  "CC"."SEGMENT1"
               || '.'
               || "CC"."SEGMENT2"
               || '.'
               || "CC"."SEGMENT3"
               || '.'
               || "CC"."SEGMENT4"
               || '.'
               || "CC"."SEGMENT5"
               || '.'
               || "CC"."SEGMENT6"
               || '.'
               || "CC"."SEGMENT7"
               || '.'
               || "CC"."SEGMENT8"
               || '.'
               || "CC"."SEGMENT9"
                  "CODE_COMBINATION",
               NULL "BUYER_NAME",
               NULL "CUSTOMER_NAME",
               "RT"."CREATED_BY" "CREATED_BY",
               NULL "ASSET",
               NULL "ASSET_CATEGORY"
          FROM "APPS"."RCV_RECEIVING_SUB_LEDGER" "RRSL",
               "APPS"."RCV_TRANSACTIONS" "RT",
               "APPS"."PO_DISTRIBUTIONS_ALL" "PD",
               "APPS"."PO_LINES_ALL" "PLL",
               "APPS"."GL_CODE_COMBINATIONS" "CC",
               "APPS"."MTL_SYSTEM_ITEMS_B_KFV" "C",
               "APPS"."MTL_ITEM_CATEGORIES_V" "MIC",
               "APPS"."ORG_ORGANIZATION_DEFINITIONS" "OOD"
         WHERE     "PD"."PO_DISTRIBUTION_ID" = "RT"."PO_DISTRIBUTION_ID"
               AND "RT"."TRANSACTION_ID" = "RRSL"."RCV_TRANSACTION_ID"
               AND "RT"."PO_DISTRIBUTION_ID" = "RRSL"."REFERENCE3"
               AND "PD"."PO_LINE_ID" = "PLL"."PO_LINE_ID"
               AND "PD"."CODE_COMBINATION_ID" = "CC"."CODE_COMBINATION_ID"
               AND "CC"."CODE_COMBINATION_ID" = "RRSL"."CODE_COMBINATION_ID"
               AND "MIC"."INVENTORY_ITEM_ID" = "C"."INVENTORY_ITEM_ID"
               AND "MIC"."ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
               AND "RRSL"."SET_OF_BOOKS_ID" = "OOD"."SET_OF_BOOKS_ID"
               AND "OOD"."ORGANIZATION_ID" = "RT"."ORGANIZATION_ID"
               AND "C"."ORGANIZATION_ID" = "RT"."ORGANIZATION_ID"
               AND "C"."INVENTORY_ITEM_ID" = "PLL"."ITEM_ID"
               AND "PD"."DESTINATION_ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
               AND "ACCOUNTING_LINE_TYPE" = 'Charge'
               AND "RT"."DESTINATION_TYPE_CODE" = 'EXPENSE'
               AND "MIC"."CATEGORY_SET_ID" = 1
        UNION ALL
        SELECT '4.INVENTORY' AS "TR_SOURCE",
               'Miscellaneous Receipt' "TR_TYPE",
               "A"."TRANSACTION_ID",
               "C"."SEGMENT1" "ITEM_CODE",
               "C"."DESCRIPTION" "ITEM_DESCRIPTION",
               "C"."PRIMARY_UOM_CODE" "UOM",
               "MIC"."SEGMENT2" "ITEM_CATEGORY",
               "MIC"."SEGMENT3" "ITEM_TYPE",
               ("A"."PRIMARY_QUANTITY") "TRX_QUANTITY",
               CASE
                  WHEN "MP"."PROCESS_ENABLED_FLAG" = 'N'
                  THEN
                     "APPS"."XX_INV_TRAN_VAL_T" ("A"."TRANSACTION_ID")
                  ELSE
                     "APPS"."XX_OINV_TRAN_VAL" ("A"."TRANSACTION_ID")
               END
                  AS "TOTAL_COST",
               "CC"."SEGMENT5" "NATURAL_ACC",
               "CC"."SEGMENT1" "COMPANY",
               "CC"."SEGMENT2" "LOCATION_DESC",
               "CC"."SEGMENT3" "PRODUCT_LINE_DESC",
               "CC"."SEGMENT4" "COST_CENTER_DESC",
               "CC"."SEGMENT5" "NATURAL_ACCOUNT_DESC",
               "CC"."SEGMENT6" "SUB_ACCCOUNT_DESC",
               "CC"."SEGMENT7" "INTER_COMPANY",
               "CC"."SEGMENT8" "EXP_CATEGORY_DESC",
               "OOD"."OPERATING_UNIT" "ORG_ID",
               "OOD"."ORGANIZATION_NAME",
               "OOD"."SET_OF_BOOKS_ID",
               "OOD"."ORGANIZATION_ID",
               NULL AS "REQUEST_NUMBER",
               TRUNC ("A"."TRANSACTION_DATE") "TRANSACTION_DATE",
               "PRD"."PERIOD_NAME",
               NULL AS "USE_AREA",
                  "CC"."SEGMENT1"
               || '.'
               || "CC"."SEGMENT2"
               || '.'
               || "CC"."SEGMENT3"
               || '.'
               || "CC"."SEGMENT4"
               || '.'
               || "CC"."SEGMENT5"
               || '.'
               || "CC"."SEGMENT6"
               || '.'
               || "CC"."SEGMENT7"
               || '.'
               || "CC"."SEGMENT8"
               || '.'
               || "CC"."SEGMENT9"
                  "CODE_COMBINATION",
               NULL "BUYER_NAME",
               NULL "CUSTOMER_NAME",
               "A"."CREATED_BY" "CREATED_BY",
               NULL "ASSET",
               NULL "ASSET_CATEGORY"
          FROM "APPS"."MTL_MATERIAL_TRANSACTIONS" "A",
               "APPS"."MTL_SYSTEM_ITEMS_B_KFV" "C",
               "APPS"."MTL_ITEM_CATEGORIES_V" "MIC",
               "APPS"."GL_CODE_COMBINATIONS" "CC",
               "INV"."MTL_PARAMETERS" "MP",
               "APPS"."ORG_ORGANIZATION_DEFINITIONS" "OOD",
               "APPS"."HR_OPERATING_UNITS" "HOU",
               "INV"."ORG_ACCT_PERIODS" "PRD",
               "APPLSYS"."FND_USER" "FNU"
         WHERE     1 = 1
               AND "A"."TRANSACTION_TYPE_ID" = 42
               AND "A"."INVENTORY_ITEM_ID" = "C"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "C"."ORGANIZATION_ID"
               AND "A"."INVENTORY_ITEM_ID" = "MIC"."INVENTORY_ITEM_ID"
               AND "A"."ORGANIZATION_ID" = "MIC"."ORGANIZATION_ID"
               AND "A"."DISTRIBUTION_ACCOUNT_ID" = "CC"."CODE_COMBINATION_ID"
               AND "A"."ORGANIZATION_ID" = "MP"."ORGANIZATION_ID"
               AND "MP"."ORGANIZATION_ID" = "OOD"."ORGANIZATION_ID"
               AND "OOD"."OPERATING_UNIT" = "HOU"."ORGANIZATION_ID"
               AND "A"."ACCT_PERIOD_ID" = "PRD"."ACCT_PERIOD_ID"
               AND "A"."ORGANIZATION_ID" = "PRD"."ORGANIZATION_ID"
               AND "A"."CREATED_BY" = "FNU"."USER_ID"
               AND "MIC"."CATEGORY_SET_NAME" = 'Inventory');


--------------------------------------------------------------------------------
EXEC ad_zd_mview.upgrade('APPS','XXDBL_INV_CON_RPT_MV');

SELECT *
  FROM dba_objects
 WHERE object_name LIKE 'XXDBL_INV_CON_RPT_MV%';


--------------------------------------------------------------------------------


EXECUTE dbms_mview.refresh('APPS.XXDBL_INV_CON_RPT_MV',method =>'C',ATOMIC_REFRESH=>FALSE);

BEGIN
   DBMS_MVIEW.refresh ('APPS.XXDBL_INV_CON_RPT_MV',
                       method           => 'C',
                       atomic_refresh   => FALSE);
END;

EXECUTE dbms_mview.refresh('APPS.XXDBL_INV_CON_RPT_MV','C', NULL, TRUE,FALSE,1,0,0,FALSE,FALSE,TRUE);


--------------------------------------------------------------------------------


BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN EXECUTE dbms_mview.refresh(''APPS.XXDBL_INV_CON_RPT_MV'',method => ''C'',ATOMIC_REFRESH=>FALSE) END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=hourly; byminute=0',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/


BEGIN
   SYS.DBMS_SCHEDULER.DROP_JOB (job_name => 'APPS.XXDBL_MVIEW_SCHEDULER');
END;
/


BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'STORED_PROCEDURE',
      job_action        => 'APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=minutely; interval=15; bysecond=0;',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job defined entirely by the CREATE JOB procedure.');
END;
/

BEGIN
   SYS.DBMS_SCHEDULER.create_job (
      job_name          => 'XXDBL_MVIEW_SCHEDULER',
      job_type          => 'PLSQL_BLOCK',
      job_action        => 'BEGIN APPS.XXDBL_MVIEW_DTLD_PKG.RUN_MVIEW_DATALOAD_PROC; END;',
      start_date        => SYSTIMESTAMP,
      repeat_interval   => 'freq=daily; byhour=1; byminute=0; bysecond=0;',
      end_date          => NULL,
      enabled           => TRUE,
      comments          => 'Job Scheduled Created for Update Materialized View.');
END;
/

BEGIN
   DBMS_SCHEDULER.set_attribute (
      name        => 'APPS.XXDBL_MVIEW_SCHEDULER',
      attribute   => 'repeat_interval',
      VALUE       => 'freq=daily; byhour=1,13; byminute=30; bysecond=0;');
END;
/


-- Display job run details.

  SELECT *
    FROM all_scheduler_job_run_details
   WHERE 1 = 1 AND job_name = 'XXDBL_MVIEW_SCHEDULER'
ORDER BY actual_start_date DESC;

--------------------------------------------------------------------------------


SELECT *
  FROM APPS.XXDBL_INV_CON_RPT_MV
 WHERE     1 = 1
       AND TO_CHAR (TRANSACTION_DATE, 'DD-MON-YY') = '01-FEB-21'
       AND ORGANIZATION_ID = 195;

SELECT * FROM inv.mtl_material_transactions;