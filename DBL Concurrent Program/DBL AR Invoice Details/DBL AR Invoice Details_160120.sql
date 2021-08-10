/* Formatted on 06-Jun-18 14:46:13 (QP5 v5.136.908.31019) */
WITH AR_INVOICE
     AS (SELECT DISTINCT CT.ORG_ID,
                CUST_SITE.CUSTOMER_TYPE,
                CUST_SITE.CUSTOMER_CATEGORY_CODE,
                CT.BILL_TO_CUSTOMER_ID CUSTOMER_ID,
                CUST_SITE.CUSTOMER_NUMBER,
                CUST_SITE.CUSTOMER_NAME,
                   CUST_SITE.ADDRESS1
                || ', '
                || CUST_SITE.ADDRESS2
                || ', '
                || CUST_SITE.CITY
                   ADDRESS,
                CT.CUSTOMER_TRX_ID,
                CT.TRX_NUMBER,
                CT.TRX_DATE,
                DIST.GL_DATE,
                DISTCM.GL_DATE CM_GL_DATE,
                CT.ATTRIBUTE7 MAJOR_TYPE,
                DECODE (CT.ATTRIBUTE_CATEGORY,
                        'Export', SHIPMENT_NUMBER,
                        'Bill Invoice', BILL.BILL_NUMBER,
                        ct.ATTRIBUTE9)
                   Bill_number,
                DECODE (CT.ATTRIBUTE_CATEGORY,
                        'Export', CT.ATTRIBUTE3,
                        CT.ATTRIBUTE10)
                   challan_number,
                CASE
                   WHEN CT.ATTRIBUTE_CATEGORY = 'Export'
                   THEN
                      'Export of Garments'
                   WHEN CT.TRX_DATE = '31-DEC-2012'
                   THEN
                      'Opening Balance'
                   ELSE
                      CT.ATTRIBUTE8
                END
                   Sub_type,
                (SELECT DISTINCT B.CUSTOMER_NAME||' - '||B.CUSTOMER_NUMBER FROM XX_AR_CUSTOMER_SITE_V B WHERE CT.ATTRIBUTE11=B.CUSTOMER_ID) BUYER,
                CT.INVOICE_CURRENCY_CODE,
                DIST.AMOUNT ENT_AMOUNT,
                DIST.ACCTD_AMOUNT,
                DISTCM.AMOUNT CM_ENT_AMOUNT,
                DISTCM.ACCTD_AMOUNT CM_ACCTD_AMOUNT,
                CT.PRIMARY_SALESREP_ID,
                QUANTITY_INVOICED,RCTT.ATTRIBUTE1 SUB_UNIT
           FROM RA_CUSTOMER_TRX_ALL CT,
                RA_CUST_TRX_LINE_GL_DIST_ALL DIST,
                XX_AR_CUSTOMER_SITE_V CUST_SITE,
                RA_CUSTOMER_TRX_ALL CTCM,
                RA_CUST_TRX_LINE_GL_DIST_ALL DISTCM,
                RA_CUST_TRX_TYPES_ALL RCTT,
                XX_EXPLC_SHIPMENT_MST SHIP,
                XX_AR_BILLS_HEADERS_ALL BILL,
                FND_LOOKUP_VALUES_VL LOOKUP,
                RA_CUSTOMER_TRX_ALL CTCM2,
                RA_CUST_TRX_LINE_GL_DIST_ALL DISTCM2,
                (  SELECT CUSTOMER_TRX_ID,
                          SUM (QUANTITY_INVOICED) QUANTITY_INVOICED
                     FROM RA_CUSTOMER_TRX_LINES_ALL
                    WHERE ( :P_UOM IS NULL OR UOM_CODE = :P_UOM)
                 GROUP BY CUSTOMER_TRX_ID) CTL
          WHERE     DIST.ACCOUNT_CLASS = 'REC'
                AND DISTCM.ACCOUNT_CLASS(+) = 'REC'
                AND DISTCM2.ACCOUNT_CLASS(+) = 'REC'
                AND CT.cust_trx_type_id NOT IN (1789)
                AND RCTT.TYPE NOT IN ('DM')
                AND UPPER (RCTT.TYPE) = LOOKUP.LOOKUP_CODE
                AND CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
                AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                ---- AND CTL.CUSTOMER_TRX_LINE_ID = DIST.CUSTOMER_TRX_LINE_ID
                AND CT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID
                AND CT.CUSTOMER_TRX_ID = CTCM.PREVIOUS_CUSTOMER_TRX_ID(+)
                AND CTCM.CUSTOMER_TRX_ID = DISTCM.CUSTOMER_TRX_ID(+)
                AND CT.CUSTOMER_TRX_ID = CTCM2.PREVIOUS_CUSTOMER_TRX_ID(+)
                AND CTCM.CUSTOMER_TRX_ID = DISTCM2.CUSTOMER_TRX_ID(+)
                AND CUST_SITE.CUSTOMER_ID = CT.BILL_TO_CUSTOMER_ID
                AND CUST_SITE.ORG_ID = CT.ORG_ID
                AND CUST_SITE.SITE_USE_CODE = 'BILL_TO'
                AND CUST_SITE.PRIMARY_FLAG = 'Y'
                AND CT.ATTRIBUTE1 = SHIP.SHIPMENT_NUMBER(+)
                AND CT.ATTRIBUTE6 = BILL.BILL_HEADER_ID(+)
                AND (  NVL (DIST.ACCTD_AMOUNT, 0)
                     + NVL (DISTCM2.ACCTD_AMOUNT, 0)) <> 0
                AND CT.COMPLETE_FLAG = 'Y'
                AND CTCM.COMPLETE_FLAG(+) = 'Y'
                AND CTCM2.COMPLETE_FLAG(+) = 'Y'
                AND LOOKUP.LOOKUP_TYPE = 'DBL_AR_INVOICE_DETAIL'
                AND LOOKUP.enabled_flag = 'Y'
                AND ( :P_TRX_TYPE IS NULL OR UPPER (RCTT.TYPE) = :P_TRX_TYPE)
                AND ( :P_SUB_UNIT IS NULL OR UPPER (RCTT.ATTRIBUTE1) = UPPER(:P_SUB_UNIT))
                AND (:P_TRX_TYPE_ID IS NULL OR RCTT.CUST_TRX_TYPE_ID= :P_TRX_TYPE_ID)
                AND TRUNC (SYSDATE) BETWEEN TRUNC (LOOKUP.START_DATE_ACTIVE)
                                        AND TRUNC (
                                               NVL (LOOKUP.END_DATE_ACTIVE,
                                                    SYSDATE))
                AND TRUNC (DIST.GL_DATE) <= :P_DATE_TO
                AND TRUNC (DISTCM.GL_DATE(+)) < :P_DATE_FROM ---  AND CT.TRX_NUMBER = 413002552
                AND TRUNC (DISTCM2.GL_DATE(+)) BETWEEN :P_DATE_FROM
                                                   AND :P_DATE_TO---    AND CT.TRX_NUMBER IN ('414010485','414011567')
        ),
     BR_INVOICE
     AS (  SELECT CUSTOMER_TRX_ID,
                  SUM (AMOUNT) BR_ENT_AMOUNT,
                  SUM (ACCTD_AMOUNT) BR_ACCTD_AMOUNT
             FROM AR_ADJUSTMENTS_ALL
            WHERE     UPPER (ADJUSTMENT_TYPE) = 'X'
                  AND STATUS = 'A'
                  AND TRUNC (GL_DATE) < :P_DATE_FROM
         GROUP BY CUSTOMER_TRX_ID),
     ADJUSTMENT
     AS (  SELECT CUSTOMER_TRX_ID,
                  SUM (AMOUNT) ADJUST_ENT_AMOUNT,
                  SUM (ACCTD_AMOUNT) ADJUST_ACCTD_AMOUNT
             FROM AR_ADJUSTMENTS_ALL
            WHERE     UPPER (ADJUSTMENT_TYPE) = 'M'
                  AND STATUS = 'A'
                  AND TRUNC (GL_DATE) < :P_DATE_FROM
         GROUP BY CUSTOMER_TRX_ID),
     Receipt
     AS (  SELECT APPLIED_CUSTOMER_TRX_ID,
                  SUM (AMOUNT_APPLIED) RECEIPT_ENT_AMOUNT,
                  SUM (ACCTD_AMOUNT_APPLIED_TO) RECEIPT_ACCTD_AMOUNT
             FROM APPS.AR_RECEIVABLE_APPLICATIONS_ALL
            WHERE     DISPLAY = 'Y'
                  AND APPLICATION_TYPE <> 'CM'
                  AND TRUNC (GL_DATE) < :P_DATE_FROM
         GROUP BY APPLIED_CUSTOMER_TRX_ID)
  SELECT 0 SL,
         CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         ADDRESS,
         NULL TRX_NUMBER,
         NULL TRX_DATE,
         NULL BILL_NUMBER,
         NULL CHALLAN_NUMBER,
         'Opening Balance' SUB_TYPE,
         NULL BUYER,
         NULL INVOICE_CURRENCY_CODE,
         NULL QUANTITY_INVOICED,
         SUM (ENT_AMOUNT) ENT_AMOUNT,
         SUM (ACCTD_AMOUNT) ACCTD_AMOUNT,
         0 CURRENT_ENT_AMOUNT,
         0 CURRENT_ACCTD_AMOUNT,
         NVL (
            SUM (
               ABS (
                    NVL (CM_ENT_AMOUNT_OA, 0)
                  + LEAST (NVL (ADJUST_ENT_AMOUNT_OA, 0), 0))),
            0)
            CM_ENT_AMOUNT,
         NVL (
            SUM (
               NVL (
                  (  ABS (NVL (BR_ENT_AMOUNT_OA, 0))
                   + NVL (RECEIPT_ENT_AMOUNT_OA, 0)),
                  0)),
            0)
            BR_ENT_AMOUNT,
         NVL (SUM (NVL (GREATEST (NVL (ADJUST_ENT_AMOUNT_OA, 0), 0), 0)), 0)
            ADJUST_ENT_AMOUNT,
         NVL (
            SUM (
               ABS (
                    NVL (CM_ACCTD_AMOUNT_OA, 0)
                  + LEAST (NVL (ADJUST_ACCTD_AMOUNT_OA, 0), 0))),
            0)
            CM_ACCTD_AMOUNT,
         NVL (
            SUM (
               NVL (
                  (  ABS (NVL (BR_ACCTD_AMOUNT_OA, 0))
                   + NVL (RECEIPT_ACCTD_AMOUNT_OA, 0)),
                  0)),
            0)
            BR_ACCTD_AMOUNT,
         NVL (SUM (NVL (GREATEST (ADJUST_ACCTD_AMOUNT_OA, 0), 0)), 0)
            ADJUST_ACCTD_AMOUNT,
         SUM (
            (  ENT_AMOUNT
             + NVL (CM_ENT_AMOUNT_OA, 0)
             + NVL (BR_ENT_AMOUNT_OA, 0)
             + NVL (ADJUST_ENT_AMOUNT_OA, 0)
             - NVL (RECEIPT_ENT_AMOUNT_OA, 0)))
            BAL_ENT_TOTAL,
         SUM (
            (  ACCTD_AMOUNT
             + NVL (CM_ACCTD_AMOUNT_OA, 0)
             + NVL (BR_ACCTD_AMOUNT_OA, 0)
             + NVL (ADJUST_ACCTD_AMOUNT_OA, 0)
             - NVL (RECEIPT_ACCTD_AMOUNT_OA, 0)))
            BAL_ACCTD_TOTAL,
         0 CURRENT_BAL_ENT_TOTAL,
         0 CURRENT_BAL_ACCTD_TOTAL
    FROM (SELECT AR.CUSTOMER_NUMBER,
                 AR.CUSTOMER_NAME,
                 AR.ADDRESS,
                 AR.INVOICE_CURRENCY_CODE,
                 NVL (
                    NVL (
                         (  NVL (AR.ENT_AMOUNT, 0)
                          + NVL (AR.CM_ENT_AMOUNT, 0)
                          + NVL (ADJ.ADJUST_ENT_AMOUNT, 0)
                          + NVL (BR.BR_ENT_AMOUNT, 0))
                       - NVL (RCT.RECEIPT_ENT_AMOUNT, 0),
                       0),
                    0)
                    ENT_AMOUNT,
                 NVL (
                    NVL (                                           ---ROUND (
                         (  NVL (AR.ACCTD_AMOUNT, 0)
                          + NVL (AR.CM_ACCTD_AMOUNT, 0)
                          + NVL (ADJ.ADJUST_ACCTD_AMOUNT, 0)
                          + NVL (BR.BR_ACCTD_AMOUNT, 0))
                       - NVL (RCT.RECEIPT_ACCTD_AMOUNT, 0)              ---,1)
                                                          ,
                       0),
                    0)
                    ACCTD_AMOUNT,
                 APPS.XX_AR_PKG.GET_BR_AMOUNT (AR.ORG_ID,
                                          AR.CUSTOMER_ID,
                                          AR.CUSTOMER_TRX_ID,
                                          'ENTERED',
                                          :P_DATE_FROM,
                                          :P_DATE_TO)
                    BR_ENT_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_ADJ_AMOUNT (AR.ORG_ID,
                                           AR.CUSTOMER_ID,
                                           AR.CUSTOMER_TRX_ID,
                                           'ENTERED',
                                           :P_DATE_FROM,
                                           :P_DATE_TO)
                    ADJUST_ENT_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_RECEIPT_AMOUNT (AR.ORG_ID,
                                               AR.CUSTOMER_ID,
                                               AR.CUSTOMER_TRX_ID,
                                               'ENTERED',
                                               :P_DATE_FROM,
                                               :P_DATE_TO)
                    RECEIPT_ENT_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_CM_AMOUNT (AR.ORG_ID,
                                          AR.CUSTOMER_ID,
                                          AR.CUSTOMER_TRX_ID,
                                          'ENTERED',
                                          :P_DATE_FROM,
                                          :P_DATE_TO)
                    CM_ENT_AMOUNT_OA,
                 ----ACCTD
                 APPS.XX_AR_PKG.GET_BR_AMOUNT (AR.ORG_ID,
                                          AR.CUSTOMER_ID,
                                          AR.CUSTOMER_TRX_ID,
                                          'ACCTD',
                                          :P_DATE_FROM,
                                          :P_DATE_TO)
                    BR_ACCTD_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_ADJ_AMOUNT (AR.ORG_ID,
                                           AR.CUSTOMER_ID,
                                           AR.CUSTOMER_TRX_ID,
                                           'ACCTD',
                                           :P_DATE_FROM,
                                           :P_DATE_TO)
                    ADJUST_ACCTD_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_RECEIPT_AMOUNT (AR.ORG_ID,
                                               AR.CUSTOMER_ID,
                                               AR.CUSTOMER_TRX_ID,
                                               'ACCTD',
                                               :P_DATE_FROM,
                                               :P_DATE_TO)
                    RECEIPT_ACCTD_AMOUNT_OA,
                 APPS.XX_AR_PKG.GET_CM_AMOUNT (AR.ORG_ID,
                                          AR.CUSTOMER_ID,
                                          AR.CUSTOMER_TRX_ID,
                                          'ACCTD',
                                          :P_DATE_FROM,
                                          :P_DATE_TO)
                    CM_ACCTD_AMOUNT_OA
            FROM AR_INVOICE AR,
                 BR_INVOICE BR,
                 ADJUSTMENT ADJ,
                 Receipt RCT
           WHERE     AR.CUSTOMER_TRX_ID = BR.CUSTOMER_TRX_ID(+)
                 AND AR.CUSTOMER_TRX_ID = ADJ.CUSTOMER_TRX_ID(+)
                 AND AR.CUSTOMER_TRX_ID = RCT.APPLIED_CUSTOMER_TRX_ID(+)
                 AND AR.ORG_ID = :P_ORG_ID
                 AND (   :P_CUSTOMER_TYPE IS NULL
                      OR AR.CUSTOMER_TYPE = :P_CUSTOMER_TYPE)
                 AND (   :P_CUSTOMER_CATEGORY_CODE IS NULL
                      OR AR.CUSTOMER_CATEGORY_CODE = :P_CUSTOMER_CATEGORY_CODE)
                 AND (   :P_CUSTOMER_ID IS NULL
                      OR AR.CUSTOMER_ID = :P_CUSTOMER_ID)
                 AND NVL (AR.MAJOR_TYPE, 1) =
                        NVL ( :P_MAJOR_TYPE, NVL (AR.MAJOR_TYPE, 1))
                 AND NVL (AR.SUB_TYPE, 1) =
                        NVL ( :P_SUB_TYPE, NVL (AR.SUB_TYPE, 1))
                 AND (   :P_INVOICE_CURRENCY_CODE IS NULL
                      OR AR.INVOICE_CURRENCY_CODE = :P_INVOICE_CURRENCY_CODE)
                 AND TRUNC (AR.GL_DATE) < :P_DATE_FROM)
GROUP BY CUSTOMER_NUMBER, CUSTOMER_NAME, ADDRESS
UNION ALL
SELECT 1 SL,
       CUSTOMER_NUMBER,
       CUSTOMER_NAME,
       ADDRESS,
       TRX_NUMBER,
       TRX_DATE,
       BILL_NUMBER,
       CHALLAN_NUMBER,
       SUB_TYPE,
       BUYER,
       INVOICE_CURRENCY_CODE,
       QUANTITY_INVOICED,
       ENT_AMOUNT,
       ACCTD_AMOUNT,
       ENT_AMOUNT CURRENT_ENT_AMOUNT,
       ACCTD_AMOUNT CURRENT_ACCTD_AMOUNT,
       ABS (NVL (CM_ENT_AMOUNT, 0) + LEAST (NVL (ADJUST_ENT_AMOUNT, 0), 0))
          CM_ENT_AMOUNT,
       NVL ( (ABS (NVL (BR_ENT_AMOUNT, 0)) + NVL (RECEIPT_ENT_AMOUNT, 0)), 0)
          BR_ENT_AMOUNT,
       NVL (GREATEST (NVL (ADJUST_ENT_AMOUNT, 0), 0), 0) ADJUST_ENT_AMOUNT,
       ABS (
          NVL (CM_ACCTD_AMOUNT, 0) + LEAST (NVL (ADJUST_ACCTD_AMOUNT, 0), 0))
          CM_ACCTD_AMOUNT,
       NVL (
          (ABS (NVL (BR_ACCTD_AMOUNT, 0)) + NVL (RECEIPT_ACCTD_AMOUNT, 0)),
          0)
          BR_ACCTD_AMOUNT,
       NVL (GREATEST (ADJUST_ACCTD_AMOUNT, 0), 0) ADJUST_ACCTD_AMOUNT,
       NVL (
            (  NVL (ENT_AMOUNT, 0)
             + NVL (CM_ENT_AMOUNT, 0)
             + NVL (ADJUST_ENT_AMOUNT, 0)
             + NVL (BR_ENT_AMOUNT, 0))
          - NVL (RECEIPT_ENT_AMOUNT, 0),
          0)
          BAL_ENT_TOTAL,
       NVL (                                                        ---ROUND (
            (  NVL (ACCTD_AMOUNT, 0)
             + NVL (CM_ACCTD_AMOUNT, 0)
             + NVL (ADJUST_ACCTD_AMOUNT, 0)
             + NVL (BR_ACCTD_AMOUNT, 0))
          - NVL (RECEIPT_ACCTD_AMOUNT, 0)                               ---,1)
                                         ,
          0)
          BAL_ACCTD_TOTAL,
       NVL (
            (  NVL (ENT_AMOUNT, 0)
             + NVL (CM_ENT_AMOUNT, 0)
             + NVL (ADJUST_ENT_AMOUNT, 0)
             + NVL (BR_ENT_AMOUNT, 0))
          - NVL (RECEIPT_ENT_AMOUNT, 0),
          0)
          CURRENT_BAL_ENT_TOTAL,
       NVL (                                                        ---ROUND (
            (  NVL (ACCTD_AMOUNT, 0)
             + NVL (CM_ACCTD_AMOUNT, 0)
             + NVL (ADJUST_ACCTD_AMOUNT, 0)
             + NVL (BR_ACCTD_AMOUNT, 0))
          - NVL (RECEIPT_ACCTD_AMOUNT, 0)                               ---,1)
                                         ,
          0)
          CURRENT_BAL_ACCTD_TOTAL
  FROM (SELECT CUSTOMER_NUMBER,
               CUSTOMER_NAME,
               ADDRESS,
               TRX_NUMBER,
               AR.GL_DATE TRX_DATE,
               BILL_NUMBER,
               CHALLAN_NUMBER,
               SUB_TYPE,
               BUYER,
               INVOICE_CURRENCY_CODE,
               QUANTITY_INVOICED,
               ENT_AMOUNT,
               ACCTD_AMOUNT,
               APPS.XX_AR_PKG.GET_BR_AMOUNT (AR.ORG_ID,
                                        AR.CUSTOMER_ID,
                                        AR.CUSTOMER_TRX_ID,
                                        'ENTERED',
                                        :P_DATE_FROM,
                                        :P_DATE_TO)
                  BR_ENT_AMOUNT,
               APPS.XX_AR_PKG.GET_ADJ_AMOUNT (AR.ORG_ID,
                                         AR.CUSTOMER_ID,
                                         AR.CUSTOMER_TRX_ID,
                                         'ENTERED',
                                         :P_DATE_FROM,
                                         :P_DATE_TO)
                  ADJUST_ENT_AMOUNT,
               APPS.XX_AR_PKG.GET_RECEIPT_AMOUNT (AR.ORG_ID,
                                             AR.CUSTOMER_ID,
                                             AR.CUSTOMER_TRX_ID,
                                             'ENTERED',
                                             :P_DATE_FROM,
                                             :P_DATE_TO)
                  RECEIPT_ENT_AMOUNT,
               APPS.XX_AR_PKG.GET_CM_AMOUNT (AR.ORG_ID,
                                        AR.CUSTOMER_ID,
                                        AR.CUSTOMER_TRX_ID,
                                        'ENTERED',
                                        :P_DATE_FROM,
                                        :P_DATE_TO)
                  CM_ENT_AMOUNT,
               ----ACCTD
               APPS.XX_AR_PKG.GET_BR_AMOUNT (AR.ORG_ID,
                                        AR.CUSTOMER_ID,
                                        AR.CUSTOMER_TRX_ID,
                                        'ACCTD',
                                        :P_DATE_FROM,
                                        :P_DATE_TO)
                  BR_ACCTD_AMOUNT,
               APPS.XX_AR_PKG.GET_ADJ_AMOUNT (AR.ORG_ID,
                                         AR.CUSTOMER_ID,
                                         AR.CUSTOMER_TRX_ID,
                                         'ACCTD',
                                         :P_DATE_FROM,
                                         :P_DATE_TO)
                  ADJUST_ACCTD_AMOUNT,
               APPS.XX_AR_PKG.GET_RECEIPT_AMOUNT (AR.ORG_ID,
                                             AR.CUSTOMER_ID,
                                             AR.CUSTOMER_TRX_ID,
                                             'ACCTD',
                                             :P_DATE_FROM,
                                             :P_DATE_TO)
                  RECEIPT_ACCTD_AMOUNT,
               APPS.XX_AR_PKG.GET_CM_AMOUNT (AR.ORG_ID,
                                        AR.CUSTOMER_ID,
                                        AR.CUSTOMER_TRX_ID,
                                        'ACCTD',
                                        :P_DATE_FROM,
                                        :P_DATE_TO)
                  CM_ACCTD_AMOUNT
          FROM AR_INVOICE AR
         WHERE     AR.ORG_ID = :P_ORG_ID
               AND (   :P_CUSTOMER_TYPE IS NULL
                    OR CUSTOMER_TYPE = :P_CUSTOMER_TYPE)
               AND (   :P_CUSTOMER_CATEGORY_CODE IS NULL
                    OR CUSTOMER_CATEGORY_CODE = :P_CUSTOMER_CATEGORY_CODE)
               AND (   :P_CUSTOMER_ID IS NULL
                    OR AR.CUSTOMER_ID = :P_CUSTOMER_ID)
               AND NVL (MAJOR_TYPE, 1) =
                      NVL ( :P_MAJOR_TYPE, NVL (MAJOR_TYPE, 1))
               AND NVL (SUB_TYPE, 1) = NVL ( :P_SUB_TYPE, NVL (SUB_TYPE, 1))
               AND (   :P_INVOICE_CURRENCY_CODE IS NULL
                    OR INVOICE_CURRENCY_CODE = :P_INVOICE_CURRENCY_CODE)
               AND TRUNC (AR.GL_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO)
       &BAL_DUE
ORDER BY CUSTOMER_NUMBER,
         SL,
         6,
         TRX_NUMBER