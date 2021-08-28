/* Formatted on 8/26/2021 3:07:18 PM (QP5 v5.354) */
  SELECT BR_NUMBER,
         BR_DATE,
         BANK_REF,
         USD_AMOUNT,
         BDT_AMOUNT,
         RECEIPT,
         RECEIPT_DATE,
         ADJUST_USD,
         ADJUSTMENT_BDT,
         (CASE WHEN TRX_DATE > :P_AS_ON_DATE THEN NULL ELSE TRX_NUMBER END)
             AS TRX_NUMBER,
         (CASE WHEN TRX_DATE > :P_AS_ON_DATE THEN NULL ELSE TRX_DATE END)
             AS TRX_DATE,
         (CASE WHEN TRX_DATE > :P_AS_ON_DATE THEN NULL ELSE LOAN_USD END)
             AS LOAN_USD,
         (CASE WHEN TRX_DATE > :P_AS_ON_DATE THEN NULL ELSE LOAN_BDT END)
             AS LOAN_BDT,
         (CASE WHEN TRX_DATE > :P_AS_ON_DATE THEN NULL ELSE LOSS_GAIN END)
             AS LOSS_GAIN,
         (CASE
              WHEN TRX_DATE > :P_AS_ON_DATE THEN ADJUST_USD
              ELSE ACCTD_BALANCE_DUE
          END)
             AS ACCTD_BALANCE_DUE,
         (CASE
              WHEN TRX_DATE > :P_AS_ON_DATE THEN ADJUSTMENT_BDT
              ELSE BAL_DUE_BDT
          END)
             BAL_DUE_BDT,
         (CASE
              WHEN (CASE
                        WHEN TRX_DATE > :P_AS_ON_DATE THEN ADJUSTMENT_BDT
                        ELSE BAL_DUE_BDT
                    END) >
                   0
              THEN
                  'YES'
              ELSE
                  'NO'
          END)
             AS BAL_DUE_STATUS
    FROM APPS.XXDBL_AR_LIAB_EXP_BILL_MV
   WHERE     LEDGER_ID = :P_LEDGER_ID
         AND ( :P_ORG_ID IS NULL OR ORG_ID = :P_ORG_ID)
         AND ( :P_CUSTOMER_ID IS NULL OR CUSTOMER_ID = :P_CUSTOMER_ID)
         AND TRUNC (RECEIPT_DATE) <= :P_AS_ON_DATE
         AND (CASE
                  WHEN (CASE
                            WHEN TRX_DATE > :P_AS_ON_DATE THEN ADJUSTMENT_BDT
                            ELSE BAL_DUE_BDT
                        END) >
                       0
                  THEN
                      'YES'
                  ELSE
                      'NO'
              END) =
             NVL (
                 :BAL_DUE,
                 (CASE
                      WHEN (CASE
                                WHEN TRX_DATE > :P_AS_ON_DATE
                                THEN
                                    ADJUSTMENT_BDT
                                ELSE
                                    BAL_DUE_BDT
                            END) >
                           0
                      THEN
                          'YES'
                      ELSE
                          'NO'
                  END))
ORDER BY RECEIPT_DATE