/* Formatted on 6/29/2020 10:25:55 AM (QP5 v5.287) */
  SELECT ITEM_CODE,
         DESCRIPTION,
         MAJOR_CATEGORY,
         MINOR_CATEGORY,
         PRODUCT_LINE,
         SUM (PLAN_QTY) AS QUANTITY,
         UOM_CODE
    FROM (SELECT MSI.SEGMENT1 AS ITEM_CODE,
                 MSI.DESCRIPTION,
                 T.MAJOR_CATEGORY,
                 T.MINOR_CATEGORY,
                 T.GROUP_NAME AS PRODUCT_LINE,
                 D.PLAN_QTY,
                 MSI.PRIMARY_UOM_CODE AS UOM_CODE
            FROM GME.GME_BATCH_HEADER H,
                 GME.GME_MATERIAL_DETAILS D,
                 APPS.MTL_SYSTEM_ITEMS_B MSI,
                 (SELECT T.BATCH_ID,
                         T.BATCH_NO AS PARENT_BATCH,
                         P.BATCH_NO,
                         BB.GROUP_NAME,
                         T.MAJOR_CATEGORY,
                         T.MINOR_CATEGORY,
                         T.TRANSACTION_DATE
                    FROM (SELECT H.BATCH_ID,
                                 H.BATCH_NO,
                                 D.PHANTOM_ID,
                                 CAT.SEGMENT2 MAJOR_CATEGORY,
                                 CAT.SEGMENT3 MINOR_CATEGORY,
                                 MMT.TRANSACTION_DATE
                            FROM GME.GME_BATCH_HEADER H,
                                 APPS.GME_MATERIAL_DETAILS D,
                                 APPS.MTL_ITEM_CATEGORIES_V CAT,
                                 MTL_MATERIAL_TRANSACTIONS MMT
                           WHERE     H.BATCH_ID = D.BATCH_ID
                                 AND H.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
                                 AND D.INVENTORY_ITEM_ID =
                                        CAT.INVENTORY_ITEM_ID
                                 AND D.ORGANIZATION_ID = CAT.ORGANIZATION_ID
                                 AND (    CAT.SEGMENT2 IN ('SEMI FINISH GOODS')
                                      AND CAT.SEGMENT2 NOT IN ('NA'))
                                 AND TO_DATE (MMT.TRANSACTION_DATE,
                                              'DD/MM/RRRR HH12:MI:SSAM') BETWEEN TO_DATE (
                                                                                    :P_STARTDATE,
                                                                                    'DD/MM/RRRR HH12:MI:SSAM')
                                                                             AND TO_DATE (
                                                                                    :P_ENDDATE,
                                                                                    'DD/MM/RRRR HH12:MI:SSAM'))
                         T
                         LEFT OUTER JOIN GME.GME_BATCH_HEADER P
                            ON NVL (P.BATCH_ID, 0) = NVL (T.PHANTOM_ID, 0)
                         INNER JOIN GME_BATCH_GROUPS_ASSOCIATION GA
                            ON T.BATCH_ID = GA.BATCH_ID
                         INNER JOIN GME_BATCH_GROUPS_B BB
                            ON GA.GROUP_ID = BB.GROUP_ID) T
           WHERE     H.BATCH_ID = D.BATCH_ID
                 AND H.BATCH_NO = T.BATCH_NO
                 AND MSI.INVENTORY_ITEM_ID = D.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = D.ORGANIZATION_ID
                 AND LINE_TYPE = -1
                 AND D.PLAN_QTY IS NOT NULL
                 AND D.ORGANIZATION_ID = 150
          UNION
          SELECT MSI.SEGMENT1 AS ITEM_CODE,
                 MSI.DESCRIPTION,
                 CAT.SEGMENT2 MAJOR_CATEGORY,
                 CAT.SEGMENT3 MINOR_CATEGORY,
                 BB.GROUP_NAME,
                 D.PLAN_QTY,
                 MSI.PRIMARY_UOM_CODE
            FROM GME.GME_BATCH_HEADER H,
                 GME.GME_MATERIAL_DETAILS D,
                 APPS.MTL_SYSTEM_ITEMS_B MSI,
                 APPS.MTL_ITEM_CATEGORIES_V CAT,
                 GME_BATCH_GROUPS_ASSOCIATION GA,
                 GME_BATCH_GROUPS_B BB,
                 MTL_MATERIAL_TRANSACTIONS MMT
           WHERE     H.BATCH_ID = D.BATCH_ID
                 AND MSI.INVENTORY_ITEM_ID = D.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = D.ORGANIZATION_ID
                 AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
                 AND H.BATCH_ID = GA.BATCH_ID
                 AND GA.GROUP_ID = BB.GROUP_ID
                 AND D.ORGANIZATION_ID = 150
                 AND CAT.SEGMENT2 = 'RAW MATERIAL'
                 AND LINE_TYPE = -1
                 AND D.PLAN_QTY IS NOT NULL
                 AND H.BATCH_ID = MMT.TRANSACTION_SOURCE_ID
                 AND TO_DATE (MMT.TRANSACTION_DATE, 'DD/MM/RRRR HH12:MI:SSAM') BETWEEN TO_DATE (
                                                                                          :P_STARTDATE,
                                                                                          'DD/MM/RRRR HH12:MI:SSAM')
                                                                                   AND TO_DATE (
                                                                                          :P_ENDDATE,
                                                                                          'DD/MM/RRRR HH12:MI:SSAM'))
GROUP BY ITEM_CODE,
         DESCRIPTION,
         MAJOR_CATEGORY,
         MINOR_CATEGORY,
         PRODUCT_LINE,
         UOM_CODE;