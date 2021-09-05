/* Formatted on 5/6/2021 2:44:45 PM (QP5 v5.354) */
--Technical Summary-------------------------------------------------------------
--DBL MOVE/PO ORDER Correction PROCESS
--MO
--xxdbl_inv_pkg.Load_acc_cor

--STAGING TABLE-----------------------------------------------------------------

  SELECT *
    FROM xxdbl.xxdbl_mo_account_cor_stg
   WHERE 1 = 1                                                --AND ROWNUM < 2
               --AND status IS NULL
               -- AND organization_id=165
               --AND TO_CHAR (transaction_date, ' MON-YY ')='MAR-21'
               --AND TRANSACTION_ID = 35984257
               --AND MO_NUMBER='1467057'
               AND transaction_id = NVL ( :p_transaction_id, transaction_id)
ORDER BY transaction_date DESC;

--TRANSACTION CHECKING----------------------------------------------------------

  SELECT mmt.organization_id,
         mmt.transaction_id,
         mmt.transaction_source_id,
         mmt.transaction_date,
         TO_CHAR (mmt.transaction_date, ' MON-YY ')     AS acct_period,
         mmt.organization_id,
         mmt.distribution_account_id,
         mmt.transaction_quantity,
         mmt.*
    FROM inv.mtl_material_transactions mmt
   WHERE 1 = 1
   AND transaction_id = NVL ( :p_transaction_id, transaction_id)
--AND TRANSACTION_ID = 27776075
--AND mmt.organization_id=165
--AND TO_CHAR (mmt.transaction_date, ' MON-YY ')='MAR-21'
ORDER BY mmt.transaction_date DESC;


--ORG CHECKING------------------------------------------------------------------

  SELECT OOD.OPERATING_UNIT               ORG_ID,
         HOU.NAME                         OPERATING_UNIT_NAME,
         HOU.SHORT_CODE                   OPERATING_UNIT_CODE,
         OOD.ORGANIZATION_NAME            WAREHOUSE_NAME,
         OOD.ORGANIZATION_CODE            WAREHOUSE_ORG_CODE,
         OOD.ORGANIZATION_ID              WAREHOUSE_ID,
         HOU.DEFAULT_LEGAL_CONTEXT_ID     LEGAL_ENTITY,
         OU.LEGAL_ENTITY_NAME,
         OOD.SET_OF_BOOKS_ID              LEDGER_ID,
         OU.LEDGER_NAME,
         OOD.BUSINESS_GROUP_ID,
         OOD.CHART_OF_ACCOUNTS_ID,
         OU.COMPANY_CODE
    FROM HR_OPERATING_UNITS          HOU,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V  OU
   WHERE     1 = 1
         AND HOU.ORGANIZATION_ID = OOD.OPERATING_UNIT
         AND OOD.OPERATING_UNIT = OU.ORG_ID
         AND OOD.ORGANIZATION_ID=153
         --AND OOD.ORGANIZATION_NAME = 'COLOR CITY LTD 2 GENERAL- IO'
ORDER BY HOU.DEFAULT_LEGAL_CONTEXT_ID,
         OOD.OPERATING_UNIT,
         OOD.ORGANIZATION_CODE;


--CCID CHECKING-----------------------------------------------------------------

SELECT DISTINCT CONCATENATED_SEGMENTS, CODE_COMBINATION_ID
  FROM APPS.GL_CODE_COMBINATIONS_KFV GCCV
 WHERE     1 = 1
       AND CONCATENATED_SEGMENTS = '153.102.999.99999.511102.999.999.999.999';


--------------------------------------------------------------------------------

SELECT *
  FROM APPS.XXDBL_INV_CON_RPT_MV
 WHERE 1 = 1
 AND TRANSACTION_ID=42129946
--AND TO_CHAR (TRANSACTION_DATE, 'DD-MON-YY') = '01-FEB-21'


--------------------------------------------------------------------------------

--DELETE
--FROM xxdbl.xxdbl_mo_account_cor_stg
-- WHERE  status IS NULL;