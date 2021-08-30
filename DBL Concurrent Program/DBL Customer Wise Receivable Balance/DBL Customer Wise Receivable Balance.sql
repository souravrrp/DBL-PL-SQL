/* Formatted on 8/29/2021 10:18:34 AM (QP5 v5.354) */
  SELECT CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         APPS.xx_ar_pkg.GET_AR_OPEN_BAL ( CT.SET_OF_BOOKS_ID,
                                         CT.ORG_ID,
                                         CUST_SITE.CUSTOMER_ID,
                                         TO_DATE (TO_CHAR ( :P_DATE_FROM)))
             AR_OPEN_BAL,
         APPS.xx_ar_pkg.GET_BR_OPEN_BAL (CT.SET_OF_BOOKS_ID,
                                         CT.ORG_ID,
                                         CUST_SITE.CUSTOMER_ID,
                                         TO_DATE (TO_CHAR ( :P_DATE_FROM)))
             BR_OPEN_BAL,
         SUM (CTL.QUANTITY_INVOICED)
             QUANTITY,
         SUM (
               CTL.QUANTITY_INVOICED
             * NVL (CT.EXCHANGE_RATE, 1)
             * UNIT_SELLING_PRICE)
             INVOICE_AMOUNT
    FROM RA_CUSTOMER_TRX_ALL         CT,
         RA_CUST_TRX_LINE_GL_DIST_ALL DIST,
         XX_AR_CUSTOMER_SITE_V       CUST_SITE,
         RA_CUST_TRX_TYPES_ALL       CTT,
         RA_CUSTOMER_TRX_LINES_ALL   CTL
   WHERE     CT.CUSTOMER_TRX_ID = DIST.CUSTOMER_TRX_ID
         AND CT.CUSTOMER_TRX_ID(+) = CTL.CUSTOMER_TRX_ID
         AND CUST_SITE.CUSTOMER_ID = CT.BILL_TO_CUSTOMER_ID
         AND CUST_SITE.ORG_ID = CT.ORG_ID
         AND CT.CUST_TRX_TYPE_ID = CTT.CUST_TRX_TYPE_ID
         AND CT.SET_OF_BOOKS_ID = :P_LEDGER_ID
         AND ( :P_ORG_ID IS NULL OR CT.ORG_ID = :P_ORG_ID)
         AND ( :P_CUSTOMER_ID IS NULL OR CUST_SITE.CUSTOMER_ID = :P_CUSTOMER_ID)
         AND DIST.GL_DATE BETWEEN :P_DATE_FROM AND :P_DATE_TO
         -- AND CUSTOMER_NUMBER = '2359'
         AND CTT.TYPE <> 'BR'
         AND CTT.TYPE = 'INV'
         AND CTT.ORG_ID = CT.ORG_ID
         AND CUST_SITE.SITE_USE_CODE = 'BILL_TO'
         AND CUST_SITE.PRIMARY_FLAG = 'Y'
         AND DIST.ACCOUNT_CLASS = 'REC'
         AND CT.COMPLETE_FLAG = 'Y'
GROUP BY CT.SET_OF_BOOKS_ID,
         CT.ORG_ID,
         CUST_SITE.CUSTOMER_ID,
         CUSTOMER_NUMBER,
         CUSTOMER_NAME
ORDER BY CUSTOMER_NAME