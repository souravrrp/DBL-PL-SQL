/* Formatted on 5/6/2021 11:41:52 AM (QP5 v5.354) */
--Technical Summary-------------------------------------------------------------
--DBL MOVE/PO ORDER Correction PROCESS
--MO
--xxdbl_inv_pkg.Load_acc_cor

--STAGING TABLE-----------------------------------------------------------------

SELECT *
  FROM xxdbl.xxdbl_rcv_po_account_cor_stg stg
 WHERE     1 = 1
       --AND ROWNUM < 2
       --AND status IS NULL
       AND EXISTS
               (SELECT 1
                  FROM rcv_transactions rt
                 WHERE     1 = 1
                       --AND transaction_id = 930974
                       AND transaction_id = NVL ( :p_transaction_id, transaction_id)
                       AND rt.po_header_id = stg.po_header_id
                       AND rt.po_line_id = stg.po_line_id
                       AND rt.po_distribution_id = stg.po_distribution_id);

;

SELECT rt.po_header_id,
       rt.organization_id,
       rt.transaction_date,
       rt.po_line_id,
       rt.po_distribution_id,
       --rt.*
       stg.*
  FROM rcv_transactions rt, xxdbl.xxdbl_rcv_po_account_cor_stg stg
 WHERE     1 = 1
       AND transaction_id = 1193881
       AND rt.po_header_id = stg.po_header_id
       AND rt.po_line_id = stg.po_line_id
       AND rt.po_distribution_id = stg.po_distribution_id;


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
         AND OOD.ORGANIZATION_NAME = 'COLOR CITY LTD 2 GENERAL- IO'
ORDER BY HOU.DEFAULT_LEGAL_CONTEXT_ID,
         OOD.OPERATING_UNIT,
         OOD.ORGANIZATION_CODE;


--CCID CHECKING-----------------------------------------------------------------

SELECT DISTINCT CONCATENATED_SEGMENTS, CODE_COMBINATION_ID
  FROM APPS.GL_CODE_COMBINATIONS_KFV GCCV
 WHERE 1 = 1
AND CONCATENATED_SEGMENTS='211.105.601.16103.511105.999.999.201.999'
;

--Transaction CHECKING-----------------------------------------------------------------

SELECT rt.po_header_id,
       rt.organization_id,
       rt.transaction_date,
       rt.po_line_id,
       rt.po_distribution_id,
       pd.code_combination_id,
       cc.concatenated_segments,
       poh.segment1,
       rt.*
  FROM rcv_transactions               rt,
       po_distributions_all           pd,
       apps.gl_code_combinations_kfv  cc,
       po_headers_all                 poh
 WHERE     1 = 1
       AND pd.po_distribution_id = rt.po_distribution_id
       AND pd.code_combination_id = cc.code_combination_id(+)
       AND rt.po_header_id = poh.po_header_id
       AND transaction_id = 1193881;

SELECT po_header_id,
       organization_id,
       transaction_date,
       po_line_id,
       po_distribution_id,
       rt.*
  FROM rcv_transactions rt
 WHERE 1 = 1 AND transaction_id = 1193881;