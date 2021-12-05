/* Formatted on 12/1/2021 11:57:34 AM (QP5 v5.365) */
  SELECT OPERATING_UNIT,
         SUPPLIER_NUMBER,
         SUPPLIER_NAME,
         GL_DATE,
         VOUCHER,
         ACCOUNT_CODE,
         ACC_DESC,
         SUBACCDESC,
         DESCRIPTION,
         SUM (DR_AMOUNT)     DR_AMOUNT,
         SUM (CR_AMOUNT)     CR_AMOUNT,
         AWT_AMOUNT,
         TDS_AMNT,
         VDS_AMNT,
         CREATED_BY
    FROM (  SELECT APPS.XX_COM_PKG.GET_HR_OPERATING_UNIT (AI.ORG_ID)
                       OPERATING_UNIT,
                   (SELECT SEGMENT1
                      FROM AP_SUPPLIERS AP
                     WHERE AP.VENDOR_ID = AI.VENDOR_ID)
                       SUPPLIER_NUMBER,
                   (SELECT VENDOR_NAME
                      FROM AP_SUPPLIERS AP
                     WHERE AP.VENDOR_ID = AI.VENDOR_ID)
                       SUPPLIER_NAME,
                   AI.GL_DATE,
                   AI.DOC_SEQUENCE_VALUE
                       VOUCHER,
                   APPS.XX_COM_PKG.GET_SEGMENT_VALUE_FROM_CCID (
                       AD.DIST_CODE_COMBINATION_ID,
                       5)
                       ACCOUNT_CODE,
                   APPS.XX_COM_PKG.GET_GL_CODE_DESC_FROM_CCID (
                       AD.DIST_CODE_COMBINATION_ID)
                       ACC_DESC,
                      GC.SEGMENT6
                   || ' - '
                   || (SELECT DESCRIPTION
                         FROM FND_FLEX_VALUES_VL A
                        WHERE     A.FLEX_VALUE_SET_ID = 1017041
                              AND A.FLEX_VALUE = GC.SEGMENT6
                              AND PARENT_FLEX_VALUE_LOW =
                                  (SELECT FLEX_VALUE
                                     FROM FND_FLEX_VALUES_VL B
                                    WHERE     FLEX_VALUE_SET_ID = 1017040
                                          AND B.FLEX_VALUE = GC.SEGMENT5))
                       SUBACCDESC,
                   AD.DESCRIPTION,
                   DECODE (AD.LINE_TYPE_LOOKUP_CODE,
                           'AWT', NULL,
                           GREATEST (NVL (AD.BASE_AMOUNT, AD.AMOUNT), 0))
                       DR_AMOUNT,
                   DECODE (AD.LINE_TYPE_LOOKUP_CODE,
                           'AWT', NULL,
                           (0 - (LEAST (NVL (AD.BASE_AMOUNT, AD.AMOUNT), 0))))
                       CR_AMOUNT,
                   (SELECT SUM (AMOUNT)
                      FROM AP_INVOICE_DISTRIBUTIONS_ALL ADAWT
                     WHERE     ADAWT.INVOICE_ID = AD.INVOICE_ID
                           AND ADAWT.LINE_TYPE_LOOKUP_CODE = 'AWT')
                       AWT_AMOUNT,
                   (SELECT SUM (AMOUNT)
                      FROM AP_INVOICE_DISTRIBUTIONS_ALL ADAWT,
                           APPS.GL_CODE_COMBINATIONS_KFV GCCT
                     WHERE     ADAWT.INVOICE_ID = AD.INVOICE_ID
                           AND ADAWT.LINE_TYPE_LOOKUP_CODE = 'AWT'
                           AND GCCT.SEGMENT5 = '321104'
                           AND ADAWT.DIST_CODE_COMBINATION_ID =
                               GCCT.CODE_COMBINATION_ID)
                       TDS_AMNT,
                   (SELECT SUM (AMOUNT)
                      FROM AP_INVOICE_DISTRIBUTIONS_ALL ADAWT,
                           APPS.GL_CODE_COMBINATIONS_KFV GCCT
                     WHERE     ADAWT.INVOICE_ID = AD.INVOICE_ID
                           AND ADAWT.LINE_TYPE_LOOKUP_CODE = 'AWT'
                           AND GCCT.SEGMENT5 = '321105'
                           AND ADAWT.DIST_CODE_COMBINATION_ID =
                               GCCT.CODE_COMBINATION_ID)
                       VDS_AMNT,
                   APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (AI.CREATED_BY)
                       CREATED_BY
              FROM AP_INVOICES_ALL           AI,
                   AP_INVOICE_DISTRIBUTIONS_ALL AD,
                   GL_CODE_COMBINATIONS      GC
             WHERE     AI.INVOICE_ID = AD.INVOICE_ID
                   AND AD.DIST_CODE_COMBINATION_ID = GC.CODE_COMBINATION_ID
                   AND AD.LINE_TYPE_LOOKUP_CODE IN ('ITEM', 'ACCRUAL')
                   --AND AI.INVOICE_TYPE_LOOKUP_CODE <> 'PREPAYMENT'
                   AND NVL (AD.BASE_AMOUNT, AD.AMOUNT) <> 0
                   AND AD.LINE_TYPE_LOOKUP_CODE <> 'AWT'
                   AND AI.DOC_SEQUENCE_VALUE IN ('222025315')
          ORDER BY AI.DOC_SEQUENCE_VALUE ASC)
GROUP BY OPERATING_UNIT,
         SUPPLIER_NUMBER,
         SUPPLIER_NAME,
         GL_DATE,
         VOUCHER,
         ACCOUNT_CODE,
         ACC_DESC,
         SUBACCDESC,
         DESCRIPTION,
         AWT_AMOUNT,
         TDS_AMNT,
         VDS_AMNT,
         CREATED_BY