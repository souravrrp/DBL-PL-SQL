/* Formatted on 8/25/2021 3:07:34 PM (QP5 v5.287) */
DROP VIEW APPS.XXDBL_AR_LIAB_EXP_BILL_V;


CREATE OR REPLACE FORCE VIEW APPS.XXDBL_AR_LIAB_EXP_BILL_V
(
   LEDGER_ID,
   LEGAL_ENTITY_NAME,
   NAME,
   ORG_ID,
   CUSTOMER_NAME,
   CUSTOMER_ID,
   BR_NUMBER,
   BR_DATE,
   BANK_REF,
   USD_AMOUNT,
   BDT_AMOUNT,
   RECEIPT,
   RECEIPT_NUMBER,
   RECEIPT_DATE,
   ADJUST_USD,
   ADJUSTMENT_BDT,
   TRX_NUMBER,
   ATTRIBUTE1,
   TRX_DATE,
   LOAN_USD,
   LOAN_BDT,
   LOSS_GAIN,
   ACCTD_BALANCE_DUE,
   BAL_DUE_BDT,
   BAL_DUE_STATUS
)
   BEQUEATH DEFINER
AS
   (SELECT CLM.LEDGER_ID,
           CLM.LEGAL_ENTITY_NAME,
           NAME,
           BR.ORG_ID,
           CUSTOMER_NAME,
           CUSTOMER_ID,
           XXDBL.XXDBL_BR_NUMBER (BANK_REF) BR_NUMBER,
           XXDBL.XXDBL_BR_DATE (BANK_REF) BR_DATE,
           BANK_REF,
           USD_AMOUNT,
           BDT_AMOUNT,
           RECEIPT,
           RECEIPT_NUMBER,
           RECEIPT_DATE,
           ADJUST_USD,
           ADJUSTMENT_BDT,
           TRX_NUMBER,
           ATTRIBUTE1,
           TRX_DATE,
           ABS (LOAN_USD) LOAN_USD,
           ABS (LOAN_BDT) LOAN_BDT,
           ADJUSTMENT_BDT - ABS (LOAN_BDT) LOSS_GAIN,
           CASE
              WHEN ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) = 0
              THEN
                 NULL
              ELSE
                 ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0))
           END
              ACCTD_BALANCE_DUE,
           CASE
              WHEN ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) = 0
              THEN
                 NULL
              ELSE
                 (CASE
                     WHEN ABS (
                               NVL (ABS (LOAN_BDT), 0)
                             - NVL (ADJUSTMENT_BDT, 0)) = 0
                     THEN
                        NULL
                     ELSE
                        ABS (
                           NVL (ABS (LOAN_BDT), 0) - NVL (ADJUSTMENT_BDT, 0))
                  END)
           END
              BAL_DUE_BDT,
           CASE
              WHEN (CASE
                       WHEN ABS (
                               NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) =
                               0
                       THEN
                          NULL
                       ELSE
                          ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0))
                    END)
                      IS NOT NULL
              THEN
                 'YES'
              ELSE
                 'NO'
           END
              BAL_DUE_STATUS
      FROM (  SELECT NAME,
                     ORG_ID,
                     CUSTOMER_NAME,
                     CUSTOMER_ID,
                     BANK_REF,
                     SUM (USD_AMOUNT) USD_AMOUNT,
                     SUM (BDT_AMOUNT) BDT_AMOUNT
                FROM (  SELECT HOU.NAME,
                               CT.ORG_ID,
                               AC.CUSTOMER_NAME,
                               AC.CUSTOMER_ID,
                               CT.ATTRIBUTE4 BANK_REF,
                               SUM (CT.BR_AMOUNT) USD_AMOUNT,
                               SUM (
                                    NVL (CT.BR_AMOUNT, 1)
                                  * NVL (CT.EXCHANGE_RATE, 1))
                                  BDT_AMOUNT
                          FROM APPS.RA_CUSTOMER_TRX_ALL CT,
                               APPS.AR_CUSTOMERS AC,
                               APPS.HR_OPERATING_UNITS HOU,
                               AR_TRANSACTION_HISTORY_ALL HIST,
                               AR_TRANSACTION_HISTORY_ALL HISTGL
                         WHERE     CT.BR_AMOUNT IS NOT NULL
                               AND CT.DRAWEE_ID = AC.CUSTOMER_ID
                               AND HOU.ORGANIZATION_ID = CT.ORG_ID
                               AND CT.COMPLETE_FLAG = 'Y'
                               AND CT.CREATED_FROM IN ('OPEN BR', 'ARBRMAIN')
                               AND CT.CUSTOMER_TRX_ID = HIST.CUSTOMER_TRX_ID
                               AND HIST.CURRENT_RECORD_FLAG = 'Y'
                               AND CT.CUSTOMER_TRX_ID = HISTGL.CUSTOMER_TRX_ID
                               AND HISTGL.CURRENT_ACCOUNTED_FLAG = 'Y'
                               AND HIST.STATUS NOT IN ('INCOMPLETE', 'CANCELLED')
                      GROUP BY HOU.NAME,
                               CT.ORG_ID,
                               CT.ATTRIBUTE4,
                               AC.CUSTOMER_NAME,
                               AC.CUSTOMER_ID
                      UNION ALL
                        SELECT HOU.NAME,
                               CT.ORG_ID,
                               AC.CUSTOMER_NAME,
                               AC.CUSTOMER_ID,
                               CT.CUSTOMER_REFERENCE BANK_REF,
                               SUM (CT.BR_AMOUNT) USD_AMOUNT,
                               SUM (
                                    NVL (CT.BR_AMOUNT, 1)
                                  * NVL (CT.EXCHANGE_RATE, 1))
                                  BDT_AMOUNT
                          FROM APPS.RA_CUSTOMER_TRX_ALL CT,
                               APPS.AR_CUSTOMERS AC,
                               APPS.HR_OPERATING_UNITS HOU,
                               AR_TRANSACTION_HISTORY_ALL HIST,
                               AR_TRANSACTION_HISTORY_ALL HISTGL
                         WHERE     CT.BR_AMOUNT IS NOT NULL
                               AND CT.DRAWEE_ID = AC.CUSTOMER_ID
                               AND HOU.ORGANIZATION_ID = CT.ORG_ID
                               AND CT.COMPLETE_FLAG = 'Y'
                               AND CT.CREATED_FROM NOT IN ('OPEN BR', 'ARBRMAIN')
                               AND CT.CUSTOMER_TRX_ID = HIST.CUSTOMER_TRX_ID
                               AND HIST.CURRENT_RECORD_FLAG = 'Y'
                               AND CT.CUSTOMER_TRX_ID = HISTGL.CUSTOMER_TRX_ID
                               AND HISTGL.CURRENT_ACCOUNTED_FLAG = 'Y'
                               AND HIST.STATUS NOT IN ('INCOMPLETE', 'CANCELLED')
                      GROUP BY HOU.NAME,
                               CT.ORG_ID,
                               AC.CUSTOMER_NAME,
                               CT.CUSTOMER_REFERENCE,
                               AC.CUSTOMER_ID) BRM
            GROUP BY NAME,
                     ORG_ID,
                     CUSTOMER_NAME,
                     CUSTOMER_ID,
                     BANK_REF) BR,
           (  SELECT                                                       --*
                    CRA.ORG_ID,
                     TO_CHAR (
                        LISTAGG (CRA.DOC_SEQUENCE_VALUE, ',')
                           WITHIN GROUP (ORDER BY CRA.DOC_SEQUENCE_VALUE))
                        AS RECEIPT,
                     CRA.RECEIPT_NUMBER,
                     MAX (CRA.RECEIPT_DATE) RECEIPT_DATE,
                     SUM (MDIST.AMOUNT) ADJUST_USD,
                     SUM (MDIST.ACCTD_AMOUNT) ADJUSTMENT_BDT
                FROM AR_CASH_RECEIPTS_ALL CRA,
                     APPS.AR_MISC_CASH_DISTRIBUTIONS_ALL MDIST,
                     GL_CODE_COMBINATIONS GCC
               WHERE     CRA.CASH_RECEIPT_ID = MDIST.CASH_RECEIPT_ID
                     AND MDIST.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
                     AND CRA.STATUS <> 'REV'
                     AND GCC.SEGMENT5 = '322103'
                     AND MDIST.AMOUNT > 0
            GROUP BY CRA.ORG_ID, CRA.RECEIPT_NUMBER
            UNION ALL
            SELECT CTR.ORG_ID,                                             --*
                   CTR.CREATED_FROM RECEIPT,
                   CTR.ATTRIBUTE4 RECEIPT_NUMBER,
                   TO_DATE (CTR.ATTRIBUTE3, 'YYYY/MM/DD HH24:MI:SS')
                      RECEIPT_DATE,
                   TO_NUMBER (CTR.ATTRIBUTE2) AMOUNT,
                   CTR.ATTRIBUTE2 * CTR.EXCHANGE_RATE ADJUSTMENT_BDT
              FROM APPS.RA_CUSTOMER_TRX_ALL CTR
             WHERE     CTR.BR_AMOUNT IS NOT NULL
                   AND CTR.CREATED_FROM = 'OPEN BR'
                   AND TRUNC (
                          TO_DATE (CTR.ATTRIBUTE3, 'YYYY/MM/DD HH24:MI:SS')) <=
                          '30-SEP-17') AD,
           (  SELECT ORG_ID,
                     TO_CHAR (
                        LISTAGG (TRX_NUMBER, ',')
                           WITHIN GROUP (ORDER BY TRX_NUMBER))
                        AS TRX_NUMBER,
                     ATTRIBUTE1,
                     MAX (TRX_DATE) TRX_DATE,
                     SUM (LOAN_USD) LOAN_USD,
                     SUM (LOAN_BDT) LOAN_BDT
                FROM (SELECT PP.ORG_ID,
                             PP.TRX_NUMBER,
                             PP.ATTRIBUTE1,
                             PP.TRX_DATE,
                             PP.LOAN_USD,
                             PP.LOAN_BDT
                        FROM (  SELECT ORG_ID,
                                       LISTAGG (TRX_NUMBER, ',')
                                          WITHIN GROUP (ORDER BY TRX_NUMBER)
                                          AS TRX_NUMBER,
                                       ATTRIBUTE1,
                                       MAX (TRX_DATE) TRX_DATE,
                                       SUM (LOAN_USD) LOAN_USD,
                                       SUM (LOAN_BDT) LOAN_BDT
                                  FROM (  SELECT LACT.ORG_ID,              --*
                                                 LACT.TRX_NUMBER,
                                                 LACT.ATTRIBUTE1,
                                                 LACT.TRX_DATE,
                                                 SUM (LADIST.AMOUNT) LOAN_USD,
                                                 SUM (LADIST.ACCTD_AMOUNT) LOAN_BDT
                                            FROM APPS.RA_CUSTOMER_TRX_ALL LACT,
                                                 RA_CUST_TRX_LINE_GL_DIST_ALL
                                                 LADIST,
                                                 GL_CODE_COMBINATIONS LAGCC
                                           WHERE     LACT.CUSTOMER_TRX_ID =
                                                        LADIST.CUSTOMER_TRX_ID
                                                 AND LADIST.ACCOUNT_CLASS = 'REV'
                                                 AND NVL (COMPLETE_FLAG, 'N') = 'Y'
                                                 AND LADIST.CODE_COMBINATION_ID =
                                                        LAGCC.CODE_COMBINATION_ID(+)
                                                 AND LAGCC.SEGMENT5 = '322103'
                                        GROUP BY LACT.ORG_ID,
                                                 LACT.TRX_NUMBER,
                                                 LACT.ATTRIBUTE1,
                                                 LACT.TRX_DATE)
                              GROUP BY ORG_ID, ATTRIBUTE1) PP
                      UNION ALL
                        SELECT CRA.ORG_ID,
                               TO_CHAR (CRA.DOC_SEQUENCE_VALUE) TRX_NUMBER,
                               CRA.RECEIPT_NUMBER ATTRIBUTE1,
                               CRA.RECEIPT_DATE TRX_DATE,
                               SUM (MDIST.AMOUNT) LOAN_USD,
                               SUM (MDIST.ACCTD_AMOUNT) LOAN_BDT
                          FROM AR_CASH_RECEIPTS_ALL CRA,
                               APPS.AR_MISC_CASH_DISTRIBUTIONS_ALL MDIST,
                               GL_CODE_COMBINATIONS GCC
                         WHERE     CRA.CASH_RECEIPT_ID = MDIST.CASH_RECEIPT_ID
                               AND MDIST.CODE_COMBINATION_ID =
                                      GCC.CODE_COMBINATION_ID
                               AND CRA.STATUS <> 'REV'
                               AND GCC.SEGMENT5 = '322103'
                               AND MDIST.AMOUNT < 0
                      GROUP BY CRA.ORG_ID,
                               TO_CHAR (CRA.DOC_SEQUENCE_VALUE),
                               CRA.RECEIPT_NUMBER,
                               CRA.RECEIPT_DATE)
            GROUP BY ORG_ID, ATTRIBUTE1) LOAN,
           XXDBL_COMPANY_LE_MAPPING_V CLM
     WHERE     BR.ORG_ID = AD.ORG_ID
           AND AD.ORG_ID = LOAN.ORG_ID(+)
           AND BANK_REF = RECEIPT_NUMBER
           AND BANK_REF = ATTRIBUTE1(+)
           AND BR.ORG_ID = CLM.ORG_ID
           AND AD.ORG_ID = CLM.ORG_ID
           AND CLM.ORG_ID = LOAN.ORG_ID(+)
    UNION ALL
    SELECT CLMM.LEDGER_ID,
           CLMM.LEGAL_ENTITY_NAME,                                         --*
           ADM.NAME,
           ADM.ORG_ID,
           LOANN.CUSTOMER_NAME,
           LOANN.CUSTOMER_ID,
           NULL BR_NUMBER,
           NULL BR_DATE,
           ADM.BANK_REF,
           NULL USD_AMOUNT,
           NULL BDT_AMOUNT,
           ADM.RECEIPT,
           ADM.RECEIPT_NUMBER,
           ADM.RECEIPT_DATE,
           ADM.ADJUST_USD,
           ADM.ADJUSTMENT_BDT,
           LOANN.TRX_NUMBER,
           LOANN.ATTRIBUTE1,
           LOANN.TRX_DATE,
           ABS (LOANN.LOAN_USD) LOAN_USD,
           ABS (LOANN.LOAN_BDT) LOAN_BDT,
           ADJUSTMENT_BDT - ABS (LOAN_BDT) LOSS_GAIN,
           CASE
              WHEN ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) = 0
              THEN
                 NULL
              ELSE
                 ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0))
           END
              ACCTD_BALANCE_DUE,
           CASE
              WHEN ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) = 0
              THEN
                 NULL
              ELSE
                 (CASE
                     WHEN ABS (
                               NVL (ABS (LOAN_BDT), 0)
                             - NVL (ADJUSTMENT_BDT, 0)) = 0
                     THEN
                        NULL
                     ELSE
                        ABS (
                           NVL (ABS (LOAN_BDT), 0) - NVL (ADJUSTMENT_BDT, 0))
                  END)
           END
              BAL_DUE_BDT,
           CASE
              WHEN (CASE
                       WHEN ABS (
                               NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0)) =
                               0
                       THEN
                          NULL
                       ELSE
                          ABS (NVL (ABS (LOAN_USD), 0) - NVL (ADJUST_USD, 0))
                    END)
                      IS NOT NULL
              THEN
                 'YES'
              ELSE
                 'NO'
           END
              BAL_DUE_STATUS
      FROM (SELECT HOU.NAME,                                               --*
                   CRA.ORG_ID,
                   CRA.RECEIPT_NUMBER BANK_REF,
                   TO_CHAR (CRA.DOC_SEQUENCE_VALUE) RECEIPT,
                   CRA.RECEIPT_NUMBER RECEIPT_NUMBER,
                   CRA.RECEIPT_DATE,
                   MDIST.AMOUNT ADJUST_USD,
                   MDIST.ACCTD_AMOUNT ADJUSTMENT_BDT,
                   MDIST.AMOUNT ACCTD_BALANCE_DUE,
                   MDIST.ACCTD_AMOUNT BAL_DUE_BDT
              FROM AR_CASH_RECEIPTS_ALL CRA,
                   APPS.AR_MISC_CASH_DISTRIBUTIONS_ALL MDIST,
                   GL_CODE_COMBINATIONS GCC,
                   APPS.HR_OPERATING_UNITS HOU
             WHERE     CRA.CASH_RECEIPT_ID = MDIST.CASH_RECEIPT_ID
                   AND MDIST.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
                   AND CRA.STATUS <> 'REV'
                   AND GCC.SEGMENT5 = '322103'
                   AND MDIST.AMOUNT > 0
                   AND CRA.ORG_ID = HOU.ORGANIZATION_ID
                   AND NOT EXISTS
                          (SELECT 1
                             FROM APPS.RA_CUSTOMER_TRX_ALL CT
                            WHERE     CT.CUSTOMER_REFERENCE =
                                         CRA.RECEIPT_NUMBER
                                  AND CT.CREATED_FROM NOT IN
                                         ('OPEN BR', 'ARBRMAIN'))
                   AND NOT EXISTS
                          (SELECT 1
                             FROM APPS.RA_CUSTOMER_TRX_ALL CT
                            WHERE     CT.ATTRIBUTE4 = CRA.RECEIPT_NUMBER
                                  AND CT.CREATED_FROM IN
                                         ('OPEN BR', 'ARBRMAIN'))) ADM,
           (SELECT HOU.NAME,
                   LACT.ORG_ID,
                   AC.CUSTOMER_NAME,
                   AC.CUSTOMER_ID,
                   LACT.ATTRIBUTE1 BANK_REF,
                   LACT.TRX_NUMBER,
                   LACT.ATTRIBUTE1,
                   LACT.TRX_DATE,
                   LADIST.AMOUNT LOAN_USD,
                   LADIST.ACCTD_AMOUNT LOAN_BDT
              FROM APPS.RA_CUSTOMER_TRX_ALL LACT,
                   RA_CUST_TRX_LINE_GL_DIST_ALL LADIST,
                   GL_CODE_COMBINATIONS LAGCC,
                   APPS.AR_CUSTOMERS AC,
                   APPS.HR_OPERATING_UNITS HOU
             WHERE     LACT.CUSTOMER_TRX_ID = LADIST.CUSTOMER_TRX_ID
                   AND LADIST.ACCOUNT_CLASS = 'REV'
                   AND NVL (COMPLETE_FLAG, 'N') = 'Y'
                   AND LADIST.CODE_COMBINATION_ID =
                          LAGCC.CODE_COMBINATION_ID(+)
                   AND LAGCC.SEGMENT5 = '322103'
                   AND BILL_TO_CUSTOMER_ID = AC.CUSTOMER_ID
                   AND LACT.ORG_ID = HOU.ORGANIZATION_ID
                   AND NOT EXISTS
                          (SELECT 1
                             FROM APPS.RA_CUSTOMER_TRX_ALL CT
                            WHERE     CT.CUSTOMER_REFERENCE = LACT.ATTRIBUTE1
                                  AND CT.CREATED_FROM NOT IN
                                         ('OPEN BR', 'ARBRMAIN'))
                   AND NOT EXISTS
                          (SELECT 1
                             FROM APPS.RA_CUSTOMER_TRX_ALL CT
                            WHERE     CT.ATTRIBUTE4 = LACT.ATTRIBUTE1
                                  AND CT.CREATED_FROM IN
                                         ('OPEN BR', 'ARBRMAIN'))
            UNION ALL
              SELECT NULL NAME,
                     CRA.ORG_ID,
                     NULL CUSTOMER_NAME,
                     NULL CUSTOMER_ID,
                     CRA.RECEIPT_NUMBER BANK_REF,
                     LISTAGG (CRA.DOC_SEQUENCE_VALUE, ',')
                        WITHIN GROUP (ORDER BY DOC_SEQUENCE_VALUE)
                        AS TRX_NUMBER,
                     NULL ATTRIBUTE1,
                     MAX (CRA.RECEIPT_DATE) TRX_DATE,
                     SUM (MDIST.AMOUNT) LOAN_USD,
                     SUM (MDIST.ACCTD_AMOUNT) LOAN_BDT
                FROM AR_CASH_RECEIPTS_ALL CRA,
                     APPS.AR_MISC_CASH_DISTRIBUTIONS_ALL MDIST,
                     GL_CODE_COMBINATIONS GCC
               WHERE     CRA.CASH_RECEIPT_ID = MDIST.CASH_RECEIPT_ID
                     AND MDIST.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
                     AND CRA.STATUS <> 'REV'
                     AND GCC.SEGMENT5 = '322103'
                     AND MDIST.AMOUNT < 0
            GROUP BY CRA.ORG_ID, CRA.RECEIPT_NUMBER) LOANN,
           XXDBL_COMPANY_LE_MAPPING_V CLMM
     WHERE     ADM.ORG_ID = LOANN.ORG_ID(+)
           AND ADM.BANK_REF = LOANN.BANK_REF(+)
           AND ADM.ORG_ID = CLMM.ORG_ID
           AND CLMM.ORG_ID = LOANN.ORG_ID(+));


GRANT SELECT ON APPS.XXDBL_AR_LIAB_EXP_BILL_V TO APPSRO;