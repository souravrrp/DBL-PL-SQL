/* Formatted on 8/28/2021 3:43:02 PM (QP5 v5.287) */
SELECT                                           --DISTINCT --CUSTOMER_NUMBER,
                                                              --CUSTOMER_NAME,
                                                                     --AMOUNT,
     ACCTD_AMOUNT OPENING_AMOUNT
FROM (WITH BR_INVOICE
           AS (SELECT DISTINCT
                      CT.ORG_ID,
                      RCTT.SET_OF_BOOKS_ID,
                      CUST.CUSTOMER_ID,
                      CUST.CUSTOMER_NUMBER,
                      CUST.CUSTOMER_NAME,
                         CUST.ADDRESS1
                      || ', '
                      || CUST.ADDRESS2
                      || ', '
                      || CUST.CITY
                         ADDRESS,
                      HISTGL.GL_DATE,
                      CT.BR_AMOUNT AMOUNT,
                      CT.BR_AMOUNT * NVL (CT.EXCHANGE_RATE, 1) ACCTD_AMOUNT,
                      CT.CUSTOMER_TRX_ID
                 FROM RA_CUSTOMER_TRX_ALL CT,
                      RA_CUST_TRX_TYPES_ALL RCTT,
                      XX_AR_CUSTOMER_SITE_V CUST,
                      AR_TRANSACTION_HISTORY_ALL HIST,
                      AR_TRANSACTION_HISTORY_ALL HISTGL,
                      XXDBL_BILL_REC_HEADER CBR
                WHERE     CUST.ORG_ID = CT.ORG_ID
                      AND CUST.CUSTOMER_ID = CT.DRAWEE_ID
                      AND CT.CUSTOMER_REFERENCE = CBR.BR_BANK_REFERENCE(+)
                      AND CT.ATTRIBUTE4 = CBR.BR_BANK_REFERENCE(+)
                      AND CT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID
                      AND CUST.SITE_USE_CODE = 'BILL_TO'
                      AND CUST.PRIMARY_FLAG = 'Y'
                      AND CT.CUSTOMER_TRX_ID = HIST.CUSTOMER_TRX_ID
                      AND HIST.CURRENT_RECORD_FLAG = 'Y'
                      AND CT.CUSTOMER_TRX_ID = HISTGL.CUSTOMER_TRX_ID
                      AND HISTGL.CURRENT_ACCOUNTED_FLAG = 'Y'
                      AND HIST.STATUS NOT IN ('INCOMPLETE', 'CANCELLED')),
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
               NULL LC_NUMBER,
               NULL INVOICE_CURRENCY_CODE,
               NULL GL_DATE,
               NULL MATURITY_DATE,
               NVL (SUM (AMOUNT), 0) AMOUNT,
               NVL (SUM (ACCTD_AMOUNT), 0) ACCTD_AMOUNT
          FROM (SELECT CUSTOMER_NUMBER,
                       CUSTOMER_NAME,
                       ADDRESS,
                       NVL (AMOUNT, 0) - NVL (RECEIPT_ENT_AMOUNT, 0) AMOUNT,
                       NVL (ACCTD_AMOUNT, 0) - NVL (RECEIPT_ACCTD_AMOUNT, 0)
                          ACCTD_AMOUNT
                  FROM BR_INVOICE BR, RECEIPT RCT
                 WHERE     BR.CUSTOMER_TRX_ID = RCT.APPLIED_CUSTOMER_TRX_ID(+)
                       AND ( :P_ORG_ID IS NULL OR BR.ORG_ID = :P_ORG_ID)
                       AND BR.ORG_ID = RCT.ORG_ID(+)
                       AND BR.SET_OF_BOOKS_ID = :P_LEDGER_ID
                       AND (   :P_CUSTOMER_ID IS NULL
                            OR BR.CUSTOMER_ID = :P_CUSTOMER_ID)
                       AND TRUNC (BR.GL_DATE) < :P_DATE_FROM)
      GROUP BY CUSTOMER_NUMBER, CUSTOMER_NAME, ADDRESS)
--ORDER BY CUSTOMER_NUMBER