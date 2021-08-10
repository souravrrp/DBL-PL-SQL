SELECT TO_CHAR (GL_DATE, 'DD-Mon-RRRR') GL_DATE,
         INVOICE_NUM,
         VENDOR_TYPE,
         VENDOR_NAME,
         INVOICE_TYPE,
         VOUCHER,
         CURRENCY,
         --LEDGER_NAME,
         LEGAL_ENTITY_ID,
         UNIT_NAME,
         SUM (NVL (INVOICE_AMOUNT, 0)) INVOICE_AMOUNT,
         SUM (NVL (AMOUNT_PAID, 0)) AMOUNT_PAID,
         SUM (NVL (INVOICE_AMOUNT, 0)) - SUM (NVL (AMOUNT_PAID, 0))
            TOTAL_PENDING,
         SUM (P_1_30) P_1_30,
         SUM (P_31_60) P_31_60,
         SUM (P_61_90) P_61_90,
         SUM (P_91_120) P_91_120,
         SUM (P_121_150) P_121_150,
         SUM (P_151_180) P_151_180,
         SUM (P_181_360) P_181_360,
         SUM (OVER_ONE_YEAR) OVER_ONE_YEAR,
           SUM (P_1_30)
         + SUM (P_31_60)
         + SUM (P_61_90)
         + SUM (P_91_120)
         + SUM (P_121_150)
         + SUM (P_151_180)
         + SUM (P_181_360)
         + SUM (OVER_ONE_YEAR)
            TOTAL
    FROM (SELECT TRUNC (GL_DATE) GL_DATE,
                 INVOICE_NUM,
                 VENDOR_TYPE,
                 ORG_ID,
                 VENDOR_ID,
                 --LEDGER_NAME,
                 LEGAL_ENTITY_ID,
                 UNIT_NAME,
                 VENDOR_NAME,
                 INVOICE_TYPE,
                 VOUCHER,                                        --7,287 7,817
                 CURRENCY,
                 NVL (INVOICE_AMOUNT, 0) - NVL (AMOUNT_PAID, 0) TOTAL_PENDING,
                 NVL (INVOICE_AMOUNT, 0) INVOICE_AMOUNT,
                 NVL (AMOUNT_PAID, 0) AMOUNT_PAID,
                 CASE
                    WHEN AGING_DAYS BETWEEN -9999 AND 30 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_1_30,
                 CASE
                    WHEN AGING_DAYS BETWEEN 31 AND 60 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_31_60,
                 CASE
                    WHEN AGING_DAYS BETWEEN 61 AND 90 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_61_90,
                 CASE
                    WHEN AGING_DAYS BETWEEN 91 AND 120 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_91_120,
                 CASE
                    WHEN AGING_DAYS BETWEEN 121 AND 150 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_121_150,
                 CASE
                    WHEN AGING_DAYS BETWEEN 151 AND 180 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_151_180,
                 CASE
                    WHEN AGING_DAYS BETWEEN 181 AND 360 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    P_181_360,
                 CASE
                    WHEN AGING_DAYS BETWEEN 361 AND 9999 THEN UNPAID_AMOUNT
                    ELSE 0
                 END
                    OVER_ONE_YEAR
            FROM (SELECT AIA.ORG_ID,
                         APPS.XX_COM_PKG.GET_HR_OPERATING_UNIT (AIA.ORG_ID)
                            UNIT_NAME,
                         POV.VENDOR_TYPE_LOOKUP_CODE VENDOR_TYPE,
                         POV.VENDOR_ID,
                         POV.VENDOR_NAME,
                         AIA.LEGAL_ENTITY_ID,
                         AIA.INVOICE_ID,
                         AIA.DOC_SEQUENCE_VALUE VOUCHER,
                         AIA.INVOICE_TYPE_LOOKUP_CODE INVOICE_TYPE,
                         AIA.INVOICE_NUM,
                         AIA.INVOICE_DATE,
                         AIA.GL_DATE,
                         ( :P_DATE_TO - AIA.GL_DATE) AGING_DAYS,
                         AIA.INVOICE_AMOUNT,
                         AIA.INVOICE_CURRENCY_CODE CURRENCY,
                         NVL (APS.AMOUNT_REMAINING, 0) UNPAID_AMOUNT,
                         NVL (AIA.AMOUNT_PAID, 0) AMOUNT_PAID
                    FROM AP_INVOICES_ALL AIA,
                         AP_PAYMENT_SCHEDULES_ALL APS,
                         AP_SUPPLIERS POV
                   WHERE     AIA.INVOICE_ID = APS.INVOICE_ID
                         AND AIA.VENDOR_ID = POV.VENDOR_ID
                         AND NVL (APS.AMOUNT_REMAINING, 0) <> 0
                         AND ( :P_ORG_ID IS NULL OR AIA.ORG_ID = :P_ORG_ID)
                         AND LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID
                         AND (   :P_VENDOR_ID IS NULL
                              OR POV.VENDOR_ID = :P_VENDOR_ID)
                         AND (   :P_VENDOR_TYPE IS NULL
                              OR VENDOR_TYPE_LOOKUP_CODE = :P_VENDOR_TYPE)
                         AND (   :P_DATE_FROM IS NULL
                              OR AIA.GL_DATE >= :P_DATE_FROM)
                         AND ( :P_DATE_TO IS NULL OR AIA.GL_DATE <= :P_DATE_TO)
                         AND (   :P_INVOICE_TYPE IS NULL
                              OR AIA.INVOICE_TYPE_LOOKUP_CODE = :P_INVOICE_TYPE)
                  UNION ALL
                  SELECT AIA.ORG_ID,
                         APPS.XX_COM_PKG.GET_HR_OPERATING_UNIT (AIA.ORG_ID)
                            UNIT_NAME,
                         POV.VENDOR_TYPE_LOOKUP_CODE VENDOR_TYPE,
                         POV.VENDOR_ID,
                         POV.VENDOR_NAME,
                         AIA.LEGAL_ENTITY_ID,
                         AIA.INVOICE_ID,
                         AIA.DOC_SEQUENCE_VALUE VOUCHER,
                         AIA.INVOICE_TYPE_LOOKUP_CODE INVOICE_TYPE,
                         AIA.INVOICE_NUM,
                         AIA.INVOICE_DATE,
                         AIA.GL_DATE,
                         ( :P_DATE_TO - AIA.GL_DATE) AGING_DAYS,
                         AIA.INVOICE_AMOUNT,
                         AIA.INVOICE_CURRENCY_CODE CURRENCY,
                         NVL (
                            APPS.XX_AP_PKG.GET_PREPAY_AMOUNT_REMAINING (
                               AIA.INVOICE_ID),
                            0)
                            UNAPPLIED_AMOUNT,
                         (  AIA.INVOICE_AMOUNT
                          - NVL (
                               APPS.XX_AP_PKG.GET_PREPAY_AMOUNT_REMAINING (
                                  AIA.INVOICE_ID),
                               0))
                            APPLIED_AMOUNT
                    FROM AP_INVOICES_ALL AIA, AP_SUPPLIERS POV
                   WHERE     AIA.VENDOR_ID = POV.VENDOR_ID
                         AND NVL (
                                APPS.XX_AP_PKG.GET_PREPAY_AMOUNT_REMAINING (
                                   AIA.INVOICE_ID),
                                0) <> 0
                         AND ( :P_ORG_ID IS NULL OR ORG_ID = :P_ORG_ID)
                         AND LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID
                         AND (   :P_VENDOR_ID IS NULL
                              OR POV.VENDOR_ID = :P_VENDOR_ID)
                         AND (   :P_VENDOR_TYPE IS NULL
                              OR VENDOR_TYPE_LOOKUP_CODE = :P_VENDOR_TYPE)
                         AND (   :P_DATE_FROM IS NULL
                              OR AIA.GL_DATE >= :P_DATE_FROM)
                         AND ( :P_DATE_TO IS NULL OR AIA.GL_DATE <= :P_DATE_TO)
                         AND (   :P_INVOICE_TYPE IS NULL
                              OR INVOICE_TYPE_LOOKUP_CODE = :P_INVOICE_TYPE)))
GROUP BY GL_DATE,
         VENDOR_TYPE,
         INVOICE_NUM,
         VENDOR_NAME,
         INVOICE_TYPE,
         CURRENCY,
         VOUCHER,
         --LEDGER_NAME,
         LEGAL_ENTITY_ID,
         UNIT_NAME
ORDER BY 6 ASC