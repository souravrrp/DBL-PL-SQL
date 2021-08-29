SELECT ACCTD_AMOUNT OPENING_AMOUNT
  FROM (WITH AR_INVOICE
             AS (SELECT DISTINCT
                        CT.ORG_ID,
                        CT.LEGAL_ENTITY_ID,
                        RCTT.SET_OF_BOOKS_ID,
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
                        (SELECT DISTINCT
                                B.CUSTOMER_NAME || ' - ' || B.CUSTOMER_NUMBER
                           FROM XX_AR_CUSTOMER_SITE_V B
                          WHERE CT.ATTRIBUTE11 = B.CUSTOMER_ID)
                           BUYER,
                        CT.INVOICE_CURRENCY_CODE,
                        DECODE (CT.INVOICE_CURRENCY_CODE,
                                'BDT', DIST.AMOUNT * 0,
                                'USD', DIST.AMOUNT * 1)
                           ENT_AMOUNT,
                        --DIST.AMOUNT ENT_AMOUNT,
                        DIST.ACCTD_AMOUNT,
                        DISTCM.AMOUNT CM_ENT_AMOUNT,
                        DISTCM.ACCTD_AMOUNT CM_ACCTD_AMOUNT,
                        CT.PRIMARY_SALESREP_ID,
                        QUANTITY_INVOICED,
                        RCTT.ATTRIBUTE1 SUB_UNIT
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
                         GROUP BY CUSTOMER_TRX_ID) CTL
                  WHERE     DIST.ACCOUNT_CLASS = 'REC'
                        AND DISTCM.ACCOUNT_CLASS(+) = 'REC'
                        AND DISTCM2.ACCOUNT_CLASS(+) = 'REC'
                        AND CT.cust_trx_type_id NOT IN (1789)
                        AND RCTT.TYPE NOT IN ('DM')
                        AND CT.SOLD_TO_CUSTOMER_ID IS NOT NULL
                        AND UPPER (RCTT.TYPE) = LOOKUP.LOOKUP_CODE
                        AND CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
                        AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                        AND CT.CUST_TRX_TYPE_ID = RCTT.CUST_TRX_TYPE_ID
                        AND CT.CUSTOMER_TRX_ID =
                               CTCM.PREVIOUS_CUSTOMER_TRX_ID(+)
                        AND CTCM.CUSTOMER_TRX_ID = DISTCM.CUSTOMER_TRX_ID(+)
                        AND CT.CUSTOMER_TRX_ID =
                               CTCM2.PREVIOUS_CUSTOMER_TRX_ID(+)
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
                        AND RCTT.NAME NOT IN ('Access. Sale CM',
                                              'Allover Printing CM',
                                              'Buying Comm. CM',
                                              'Cartoon Sales CM',
                                              'CCTV Income CM',
                                              'DHL Local Sales CM',
                                              'Diesel Income CM',
                                              'Dredging Income CM',
                                              'Dye & Finish Inc CM',
                                              'Dyeing Income CM',
                                              'Embroidery CM',
                                              'Embroidery Income CM',
                                              'Enecon Income CM',
                                              'Export Lingerie CM',
                                              'Fabrics Export CM',
                                              'Fabrics Export CM.',
                                              'Fibre Dyeing CM',
                                              'Finishing Income CM',
                                              'Fire S.S Income CM',
                                              'Garments Export CM',
                                              'Garments Export CM.',
                                              'Gmts. Printing CM',
                                              'InkCups Income CM',
                                              'Insurance Claim CM',
                                              'Insurance Claim CM.',
                                              'Int Incoming RSP C',
                                              'Int Incoming VSP C',
                                              'Int Incoming-FC CM',
                                              'Knitting Income CM',
                                              'Knitting Income CM.',
                                              'Life Stye CM',
                                              'Lift Income CM',
                                              'Local Sales FG CM',
                                              'Open Invoice CM',
                                              'Others Income CM',
                                              'Out Going Call CM',
                                              'Out Going RSP CM',
                                              'Raw Cotton Sales CM',
                                              'Realization Adj.',
                                              'Rental Income CM',
                                              'Rental Income CM.',
                                              'Return Credit Memo',
                                              'Sales of Ticket CM',
                                              'Scraps Sales CM',
                                              'Scraps Sales CM.',
                                              'Screen Print CM.',
                                              'Sewing Thread CM',
                                              'Sponsor Income CM',
                                              'Sub-Contract CM',
                                              'Sub-Contract CM.',
                                              'Textiles Testing CM',
                                              'Tiles Export CM',
                                              'Tiles Sale -Dealer',
                                              'Trading Income CM',
                                              'Twisting Income CM',
                                              'Visa Processing CM',
                                              'Washing Income CM',
                                              'Washing Income- CM',
                                              'Yarn Dyeing CM',
                                              'Yarn Sales CM',
                                              'Yarn Sales CM-(Mel)',
                                              'Yarn Sales CM-(Syn)')
                        AND LOOKUP.LOOKUP_TYPE = 'DBL_AR_INVOICE_DETAIL'
                        AND LOOKUP.enabled_flag = 'Y'
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                       LOOKUP.START_DATE_ACTIVE)
                                                AND TRUNC (
                                                       NVL (
                                                          LOOKUP.END_DATE_ACTIVE,
                                                          SYSDATE))
                        AND TRUNC (DISTCM.GL_DATE(+)) < :P_DATE_FROM
                        AND TRUNC (DISTCM2.GL_DATE(+)) < :P_DATE_FROM),
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
        SELECT SUM (ACCTD_AMOUNT) ACCTD_AMOUNT               --OPENING_BANLACE
          FROM (SELECT AR.CUSTOMER_NUMBER,
                       AR.CUSTOMER_NAME,
                       AR.ADDRESS,
                       AR.INVOICE_CURRENCY_CODE,
                       NVL (
                          NVL (
                               (  NVL (AR.ACCTD_AMOUNT, 0)
                                + NVL (AR.CM_ACCTD_AMOUNT, 0)
                                + NVL (ADJ.ADJUST_ACCTD_AMOUNT, 0)
                                + NVL (BR.BR_ACCTD_AMOUNT, 0))
                             - NVL (RCT.RECEIPT_ACCTD_AMOUNT, 0),
                             0),
                          0)
                          ACCTD_AMOUNT
                  FROM AR_INVOICE AR,
                       BR_INVOICE BR,
                       ADJUSTMENT ADJ,
                       Receipt RCT
                 WHERE     AR.CUSTOMER_TRX_ID = BR.CUSTOMER_TRX_ID(+)
                       AND AR.CUSTOMER_TRX_ID = ADJ.CUSTOMER_TRX_ID(+)
                       AND AR.CUSTOMER_TRX_ID =
                              RCT.APPLIED_CUSTOMER_TRX_ID(+)
                       --AND AR.LEGAL_ENTITY_ID = :P_LEGAL_ENTITY_ID
                       AND AR.SET_OF_BOOKS_ID = :P_LEDGER_ID
                       AND ( :P_ORG_ID IS NULL OR AR.ORG_ID = :P_ORG_ID)
                       AND (   :P_CUSTOMER_ID IS NULL
                            OR AR.CUSTOMER_ID = :P_CUSTOMER_ID)
                       AND TRUNC (AR.GL_DATE) < :P_DATE_FROM));