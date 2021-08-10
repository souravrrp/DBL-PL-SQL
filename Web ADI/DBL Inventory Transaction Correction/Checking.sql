/* Formatted on 10/31/2020 11:19:05 AM (QP5 v5.287) */
--Technical Summary-------------------------------------------------------------
--DBL MOVE/PO ORDER Correction PROCESS
--MO
--xxdbl_inv_pkg.Load_acc_cor

--STAGING TABLE-----------------------------------------------------------------

  SELECT *
    FROM xxdbl.xxdbl_mo_account_cor_stg
   WHERE     1 = 1
         --AND REGEXP_SUBSTR (PRIOR_ACCOUNT, '[^.]*', 1, 1) = '105'
--AND ROWNUM < 2
AND status IS NULL
--AND TRANSACTION_ID=17222608
ORDER BY TRANSACTION_ID DESC;

--ORG CHECKING------------------------------------------------------------------

  SELECT OOD.OPERATING_UNIT ORG_ID,
         HOU.NAME OPERATING_UNIT_NAME,
         HOU.SHORT_CODE OPERATING_UNIT_CODE,
         OOD.ORGANIZATION_NAME WAREHOUSE_NAME,
         OOD.ORGANIZATION_CODE WAREHOUSE_ORG_CODE,
         OOD.ORGANIZATION_ID WAREHOUSE_ID,
         HOU.DEFAULT_LEGAL_CONTEXT_ID LEGAL_ENTITY,
         OU.LEGAL_ENTITY_NAME,
         OOD.SET_OF_BOOKS_ID LEDGER_ID,
         OU.LEDGER_NAME,
         OOD.BUSINESS_GROUP_ID,
         OOD.CHART_OF_ACCOUNTS_ID,
         OU.COMPANY_CODE
    FROM HR_OPERATING_UNITS HOU,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         XXDBL_COMPANY_LE_MAPPING_V OU
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
 WHERE     1 = 1
       AND CONCATENATED_SEGMENTS = '155.102.212.10201.114102.999.999.101.999';

SELECT transaction_id,
       mmt.transaction_source_id,
       mmt.organization_id,
       mmt.transaction_date,
       mmt.distribution_account_id,
       mmt.*
  FROM mtl_material_transactions mmt
 WHERE 1 = 1 AND transaction_id = '32935074';

SELECT transaction_id, gcc.*
  FROM mtl_material_transactions mmt, apps.gl_code_combinations_kfv gcc
 WHERE     1 = 1
       AND mmt.distribution_account_id = gcc.code_combination_id(+)
       AND transaction_id = '20860171'
       AND gcc.concatenated_segments =
              '102.102.402.10204.512118.101.102.101.999'
       AND mmt.transaction_source_id = '765240'
--and TRANSACTION_DATE=
--and mmt.ORGANIZATION_ID=
;
SELECT RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             1),
              '.')
          AS part_1,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             2),
              '.')
          AS part_2,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             3),
              '.')
          AS part_3,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             4),
              '.')
          AS part_4,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             5),
              '.')
          AS part_5,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             6),
              '.')
          AS part_6,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             7),
              '.')
          AS part_7,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             8),
              '.')
          AS part_8,
       RTRIM (REGEXP_SUBSTR ('102.102.402.10204.512118.101.102.101.999',
                             '[^.]*.',
                             1,
                             9),
              '.')
          AS part_9
  FROM DUAL;


SELECT *
  FROM xxdbl.xxdbl_mo_account_correction
 WHERE 1 = 1 AND TRANSACTION_ID = 17222608
--AND ORGANIZATION_CODE='101'
--AND FLAG IS NULL
--AND TO_CHAR(TRANSACTION_DATE,'MON-RR') = 'JUN-20'
--AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
;
--TRUNCATE TABLE xxdbl.xxdbl_ra_interface_upload_stg;
--

DELETE xxdbl.xxdbl_mo_account_cor_stg
   WHERE 1=1
--   AND transaction_id=17222608
--   AND new_account is null
    AND status IS NULL
;
COMMIT;

  SELECT *
    FROM xxdbl.xxdbl_mo_account_cor_stg
   WHERE     1 = 1
         --AND ORGANIZATION_CODE='101'
         --AND FLAG IS NULL
         --AND REGEXP_SUBSTR (PRIOR_ACCOUNT, '[^.]*', 1, 1) = '105'
         --AND ROWNUM < 2
         --AND status IS NULL
         AND TRANSACTION_ID=4746192
         --AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
         --AND TO_CHAR (TRANSACTION_DATE, 'MON-RR') = 'JUN-20'
ORDER BY TRANSACTION_ID DESC;

--   update xxdbl_ra_interface_upload_stg set flag=null
--   WHERE 1=1
--   AND FLAG='Y';


UPDATE 
INV.MTL_MATERIAL_TRANSACTIONS
SET DISTRIBUTION_ACCOUNT_ID='87987'
WHERE TRANSACTION_ID='34616148';
COMMIT;

--EXECUTE apps.xxdbl_mo_acct_cor_pkg.import_data_from_web_adi('17222608','105.102.401.10205.512144.106.999.101.999');
EXECUTE apps.xxdbl_mo_acct_cor_pkg.import_data_from_web_adi('17222608','105.102.401.10205.512144.106.999.101.999');


SELECT MTRL.TO_ACCOUNT_ID
  FROM INV.MTL_MATERIAL_TRANSACTIONS MMT, INV.MTL_TXN_REQUEST_LINES MTRL
 WHERE MMT.TRANSACTION_ID = 36707674 AND MTRL.LINE_ID = MMT.MOVE_ORDER_LINE_ID;
 
 /* Formatted on 5/5/2021 3:13:49 PM (QP5 v5.287) */
SELECT mtrl.to_account_id
  FROM inv.mtl_material_transactions mmt, inv.mtl_txn_request_lines mtrl
 WHERE     mmt.transaction_id = :P_transaction_id
       AND mtrl.line_id = mmt.move_order_line_id;