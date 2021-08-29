/* Formatted on 1/21/2020 5:04:47 PM (QP5 v5.287) */
  SELECT SL,
         CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         ADDRESS,
         TRX_NUMBER,
         BANK_REF,
         INVOICE_CURRENCY_CODE,
         GL_DATE,
         MATURITY_DATE,
         AMOUNT,
         ACCTD_AMOUNT,
         CURRENT_AMOUNT,
         CURRENT_ACCTD_AMOUNT,
         AMOUNT_APPLIED,
         ACCTD_AMOUNT_APPLIED,
         BAL_ENT_TOTAL,
         BAL_ACCTD_TOTAL,
         CURRENT_BAL_ENT_TOTAL,
         CURRENT_BAL_ACCTD_TOTAL,
         AR_INVOICE,
         CHALLAN_NO
    FROM (WITH BR_INVOICE
               AS (SELECT CT.ORG_ID,
                          CT.SET_OF_BOOKS_ID,
                          CUST.CUSTOMER_TYPE,
                          CUST.CUSTOMER_CATEGORY_CODE,
                          CUST.CUSTOMER_ID,
                          CUST.CUSTOMER_NUMBER,
                          CUST.CUSTOMER_NAME,
                             CUST.ADDRESS1
                          || ', '
                          || CUST.ADDRESS2
                          || ', '
                          || CUST.CITY
                             ADDRESS,
                          CASE
                             WHEN CT.CREATED_FROM = 'OPEN BR'
                             THEN
                                TO_CHAR (CT.TRX_NUMBER)
                             ELSE
                                TO_CHAR (CT.DOC_SEQUENCE_VALUE)
                          END
                             TRX_NUMBER,
                          --NVL (CT.DOC_SEQUENCE_VALUE, 0) ----CT.TRX_NUMBER
                          --TRX_NUMBER,
                          --CT.CUSTOMER_REFERENCE BANk_REF,
                          CASE
                             WHEN CT.CREATED_FROM = 'OPEN BR'
                             THEN
                                CT.ATTRIBUTE4
                             ELSE
                                CT.CUSTOMER_REFERENCE
                          END
                             BANk_REF,
                          CT.TRX_DATE,
                          HISTGL.GL_DATE,
                          HISTGL.MATURITY_DATE,
                          CT.BR_AMOUNT AMOUNT,
                          CT.BR_AMOUNT * NVL (CT.EXCHANGE_RATE, 1) ACCTD_AMOUNT,
                          CT.INVOICE_CURRENCY_CODE,
                          CT.CUSTOMER_TRX_ID
                     FROM RA_CUSTOMER_TRX_ALL CT,
                          RA_CUST_TRX_TYPES_ALL RCTT,
                          XX_AR_CUSTOMER_SITE_V CUST,
                          AR_TRANSACTION_HISTORY_ALL HIST,
                          AR_TRANSACTION_HISTORY_ALL HISTGL
                    WHERE     CUST.ORG_ID = CT.ORG_ID
                          AND CUST.CUSTOMER_ID = CT.DRAWEE_ID
                          AND CT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID
                          --AND CT.LEGAL_ENTITY_ID = :P_LEDGER_ID
                          AND (   :P_SUB_UNIT IS NULL
                               OR UPPER (RCTT.ATTRIBUTE1) =
                                     UPPER ( :P_SUB_UNIT))
                          AND (   :P_TRX_TYPE_ID IS NULL
                               OR CT.CUST_TRX_TYPE_ID = :P_TRX_TYPE_ID)
                          AND CUST.SITE_USE_CODE = 'BILL_TO'
                          AND CUST.PRIMARY_FLAG = 'Y'
                          AND CT.CUSTOMER_TRX_ID = HIST.CUSTOMER_TRX_ID
                          AND HIST.CURRENT_RECORD_FLAG = 'Y'
                          AND CT.CUSTOMER_TRX_ID = HISTGL.CUSTOMER_TRX_ID
                          AND HISTGL.CURRENT_ACCOUNTED_FLAG = 'Y'
                          AND HIST.STATUS NOT IN ('INCOMPLETE', 'CANCELLED')
                          --AND CT.TRX_NUMBER='518000007'
                          AND TRUNC (HISTGL.GL_DATE) <= :P_DATE_TO),
               RECEIPT
               AS (  SELECT APPLIED_CUSTOMER_TRX_ID,
                            ORG_ID,
                            SUM (AMOUNT_APPLIED) RECEIPT_ENT_AMOUNT,
                            SUM (ACCTD_AMOUNT_APPLIED_TO) RECEIPT_ACCTD_AMOUNT
                       FROM APPS.AR_RECEIVABLE_APPLICATIONS_ALL
                      WHERE     DISPLAY = 'Y'
                            AND APPLICATION_TYPE <> 'CM'
                            AND TRUNC (GL_DATE) < :P_DATE_FROM
                   GROUP BY APPLIED_CUSTOMER_TRX_ID, ORG_ID)
            SELECT 0 SL,
                   CUSTOMER_NUMBER,
                   CUSTOMER_NAME,
                   ADDRESS,
                   NULL TRX_NUMBER,
                   'Opening Balance' BANK_REF,
                   NULL INVOICE_CURRENCY_CODE,
                   NULL GL_DATE,
                   NULL MATURITY_DATE,
                   NVL (SUM (AMOUNT), 0) AMOUNT,
                   NVL (SUM (ACCTD_AMOUNT), 0) ACCTD_AMOUNT,
                   0 CURRENT_AMOUNT,
                   0 CURRENT_ACCTD_AMOUNT,
                   NVL (SUM (NVL (AMOUNT_APPLIED, 0)), 0) AMOUNT_APPLIED,
                   NVL (SUM (NVL (ACCTD_AMOUNT_APPLIED, 0)), 0)
                      ACCTD_AMOUNT_APPLIED,
                   NVL (SUM (AMOUNT - NVL (AMOUNT_APPLIED, 0)), 0) BAL_ENT_TOTAL,
                   NVL (SUM (ACCTD_AMOUNT - NVL (ACCTD_AMOUNT_APPLIED, 0)), 0)
                      BAL_ACCTD_TOTAL,
                   0 CURRENT_BAL_ENT_TOTAL,
                   0 CURRENT_BAL_ACCTD_TOTAL,
                   NULL AR_INVOICE,
                   NULL Challan_NO
              FROM (SELECT CUSTOMER_NUMBER,
                           CUSTOMER_NAME,
                           ADDRESS,
                           NVL (AMOUNT, 0) - NVL (RECEIPT_ENT_AMOUNT, 0) AMOUNT,
                           NVL (ACCTD_AMOUNT, 0) - NVL (RECEIPT_ACCTD_AMOUNT, 0)
                              ACCTD_AMOUNT,
                           APPS.XX_AR_PKG.GET_BR_RCT_AMOUNT (BR.ORG_ID,
                                                             BR.CUSTOMER_ID,
                                                             BR.CUSTOMER_TRX_ID,
                                                             'ENTERED',
                                                             :P_DATE_FROM,
                                                             :P_DATE_TO)
                              AMOUNT_APPLIED,
                           APPS.XX_AR_PKG.GET_BR_RCT_AMOUNT (BR.ORG_ID,
                                                             BR.CUSTOMER_ID,
                                                             BR.CUSTOMER_TRX_ID,
                                                             'ACCTD',
                                                             :P_DATE_FROM,
                                                             :P_DATE_TO)
                              ACCTD_AMOUNT_APPLIED
                      FROM BR_INVOICE BR, RECEIPT RCT
                     WHERE     BR.CUSTOMER_TRX_ID =
                                  RCT.APPLIED_CUSTOMER_TRX_ID(+)
                           AND ( :P_ORG_ID IS NULL OR BR.ORG_ID = :P_ORG_ID)
                           AND BR.ORG_ID = RCT.ORG_ID(+)
                           AND BR.SET_OF_BOOKS_ID = :P_LEDGER_ID
                           --AND ORG_ID = :P_ORG_ID
                           AND (   :P_CUSTOMER_TYPE IS NULL
                                OR CUSTOMER_TYPE = :P_CUSTOMER_TYPE)
                           AND (   :P_CUSTOMER_CATEGORY_CODE IS NULL
                                OR CUSTOMER_CATEGORY_CODE =
                                      :P_CUSTOMER_CATEGORY_CODE)
                           AND (   :P_CUSTOMER_ID IS NULL
                                OR BR.CUSTOMER_ID = :P_CUSTOMER_ID)
                           AND TRUNC (BR.GL_DATE) < :P_DATE_FROM)
          GROUP BY CUSTOMER_NUMBER, CUSTOMER_NAME, ADDRESS
          UNION ALL
          SELECT 1 SL,
                 CUSTOMER_NUMBER,
                 CUSTOMER_NAME,
                 ADDRESS,
                 TRX_NUMBER,
                 BANK_REF,
                 INVOICE_CURRENCY_CODE,
                 GL_DATE,
                 MATURITY_DATE,
                 NVL (AMOUNT, 0) AMOUNT,
                 NVL (ACCTD_AMOUNT, 0) ACCTD_AMOUNT,
                 NVL (AMOUNT, 0) CURRENT_AMOUNT,
                 NVL (ACCTD_AMOUNT, 0) CURRENT_ACCTD_AMOUNT,
                 NVL (AMOUNT_APPLIED, 0) AMOUNT_APPLIED,
                 NVL (ACCTD_AMOUNT_APPLIED, 0) ACCTD_AMOUNT_APPLIED,
                 NVL (AMOUNT, 0) - NVL (AMOUNT_APPLIED, 0) BAL_ENT_TOTAL,
                 NVL (ACCTD_AMOUNT, 0) - NVL (ACCTD_AMOUNT_APPLIED, 0)
                    BAL_ACCTD_TOTAL,
                 NVL (AMOUNT, 0) - NVL (AMOUNT_APPLIED, 0)
                    CURRENT_BAL_ENT_TOTAL,
                 NVL (ACCTD_AMOUNT, 0) - NVL (ACCTD_AMOUNT_APPLIED, 0)
                    CURRENT_BAL_ACCTD_TOTAL,
                 APPS.XX_AR_PKG.GET_TRX_NUMBER (CUSTOMER_TRX_ID) AR_INVOICE,
                 APPS.XX_AR_PKG.GET_Challan_NO (CUSTOMER_TRX_ID) Challan_NO
            FROM (SELECT CUSTOMER_TRX_ID,
                         CUSTOMER_NUMBER,
                         CUSTOMER_NAME,
                         ADDRESS,
                         TRX_NUMBER,
                         BANK_REF,
                         INVOICE_CURRENCY_CODE,
                         GL_DATE,
                         MATURITY_DATE,
                         AMOUNT,
                         ACCTD_AMOUNT,
                         APPS.XX_AR_PKG.GET_BR_RCT_AMOUNT (BR.ORG_ID,
                                                           BR.CUSTOMER_ID,
                                                           BR.CUSTOMER_TRX_ID,
                                                           'ENTERED',
                                                           :P_DATE_FROM,
                                                           :P_DATE_TO)
                            AMOUNT_APPLIED,
                         APPS.XX_AR_PKG.GET_BR_RCT_AMOUNT (BR.ORG_ID,
                                                           BR.CUSTOMER_ID,
                                                           BR.CUSTOMER_TRX_ID,
                                                           'ACCTD',
                                                           :P_DATE_FROM,
                                                           :P_DATE_TO)
                            ACCTD_AMOUNT_APPLIED
                    FROM BR_INVOICE BR, XXDBL_COMPANY_LE_MAPPING_V CLM
                   WHERE     BR.ORG_ID = CLM.ORG_ID
                         AND CLM.LEDGER_ID = :P_LEDGER_ID
                         AND ( :P_ORG_ID IS NULL OR BR.ORG_ID = :P_ORG_ID)
                         AND (   :P_CUSTOMER_TYPE IS NULL
                              OR CUSTOMER_TYPE = :P_CUSTOMER_TYPE)
                         AND (   :P_CUSTOMER_CATEGORY_CODE IS NULL
                              OR CUSTOMER_CATEGORY_CODE =
                                    :P_CUSTOMER_CATEGORY_CODE)
                         AND (   :P_CUSTOMER_ID IS NULL
                              OR CUSTOMER_ID = :P_CUSTOMER_ID)
                         AND TRUNC (GL_DATE) BETWEEN :P_DATE_FROM
                                                 AND :P_DATE_TO)) &BAL_DUE
ORDER BY CUSTOMER_NUMBER,
         SL,
         GL_DATE,
         TRX_NUMBER