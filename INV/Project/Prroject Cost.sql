/* Formatted on 10/19/2020 5:43:41 PM (QP5 v5.354) */
  SELECT XXDBL.COM.GET_PROJECT ( :P_PROJECT_ID)    PROJECT_NAME,
         (  SELECT XXDBL.COM.GET_PROJECT_BUILDING_LEVEL (AD.ATTRIBUTE2)
              FROM AP_INVOICE_DISTRIBUTIONS_ALL ad
             WHERE     ck.ORG_ID = ad.ORG_ID
                   AND ad.INVOICE_ID = ap.INVOICE_ID
                   AND ad.ATTRIBUTE_CATEGORY = 'Construction Details'
                   AND AD.ATTRIBUTE1 = NVL ( :P_PROJECT_ID, AD.ATTRIBUTE1)
          GROUP BY ad.INVOICE_ID,
                   AD.ATTRIBUTE2,
                   ad.ORG_ID,
                   ad.ATTRIBUTE_CATEGORY)          BUILDING_LEVEL_NAME,
         NULL                                      MATERIAL_BUDGET,
         NULL                                      LABOR_BUDGET,
         NULL                                      MATERIAL_CONSUMPTION,
         NULL                                      LABOR_CONSUMPTION,
         NULL                                      MATERIAL_PAYABLE,
         ck.DOC_SEQUENCE_VALUE,
         SUM (CK.AMOUNT)                           MATERIAL_PAYMENT
    FROM AP_INVOICE_PAYMENTS_ALL ap, AP_CHECKS_ALL CK
   WHERE     1 = 1
         AND ck.CHECK_ID = ap.CHECK_ID
         AND ck.DOC_SEQUENCE_VALUE = 320013615
         AND (   :P_FROM_DATE IS NULL
              OR CK.CHECK_DATE BETWEEN :P_FROM_DATE AND :P_TO_DATE)
         AND ck.ORG_ID = NVL ( :P_ORG_ID, ck.ORG_ID)
         AND EXISTS
                 (SELECT 1
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL ad
                   WHERE     ck.ORG_ID = ad.ORG_ID
                         AND ad.INVOICE_ID = ap.INVOICE_ID
                         AND ad.ATTRIBUTE_CATEGORY = 'Construction Details'
                         AND AD.ATTRIBUTE1 =
                             NVL ( :P_PROJECT_ID, AD.ATTRIBUTE1))
GROUP BY XXDBL.COM.GET_PROJECT ( :P_PROJECT_ID),
         ck.ORG_ID,
         ap.INVOICE_ID,
         ck.DOC_SEQUENCE_VALUE;