/* Formatted on 3/31/2021 2:23:26 PM (QP5 v5.354) */
WITH
    MAINS
    AS
        (SELECT MSIK.ORGANIZATION_ID,
                OOD.ORGANIZATION_NAME,
                MSIK.INVENTORY_ITEM_ID,
                MSIK.CONCATENATED_SEGMENTS     ITEM_CODE,
                MSIK.DESCRIPTION               ITEM_NAME,
                MSIK.PRIMARY_UOM_CODE          UOM,
                MIC.SEGMENT2                   ITEM_MJR_CAT,
                MIC.SEGMENT3                   ITEM_MNR_CAT
           FROM ORG_ORGANIZATION_DEFINITIONS  OOD,
                MTL_SYSTEM_ITEMS_B_KFV        MSIK,
                MTL_ITEM_CATEGORIES_V         MIC
          WHERE     MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                AND MIC.CATEGORY_SET_ID = 1
                -- AND INVENTORY_ITEM_STATUS_CODE<>'Inactive'
                AND ( :P_ORG_ID IS NULL OR MSIK.ORGANIZATION_ID = :P_ORG_ID)
                AND (   :P_ITEM_ID IS NULL
                     OR MSIK.INVENTORY_ITEM_ID = :P_ITEM_ID)
                AND ( :P_MJR_CAT IS NULL OR MIC.SEGMENT2 = :P_MJR_CAT)
                AND ( :P_MNR_CAT IS NULL OR MIC.SEGMENT3 = :P_MNR_CAT)),
    TRANS
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUM (OPN_QTY)     OPN_QTY,
                  SUM (RCV_QTY)     RCV_QTY,
                  SUM (ISU_QTY)     ISU_QTY,
                  SUM (CLS_QTY)     CLS_QTY
             FROM (  SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            SUM (MMT.PRIMARY_QUANTITY)     OPN_QTY,
                            TO_NUMBER (0)                  RCV_QTY,
                            TO_NUMBER (0)                  ISU_QTY,
                            TO_NUMBER (0)                  CLS_QTY
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) < :P_DATE_FR
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  OPN_QTY,
                            SUM (MMT.PRIMARY_QUANTITY)     RCV_QTY,
                            TO_NUMBER (0)                  ISU_QTY,
                            TO_NUMBER (0)                  CLS_QTY
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  OPN_QTY,
                            TO_NUMBER (0)                  RCV_QTY,
                            SUM (MMT.PRIMARY_QUANTITY)     ISU_QTY,
                            TO_NUMBER (0)                  CLS_QTY
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  OPN_QTY,
                            TO_NUMBER (0)                  RCV_QTY,
                            TO_NUMBER (0)                  ISU_QTY,
                            SUM (MMT.PRIMARY_QUANTITY)     CLS_QTY
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) <= :P_DATE_TO
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID)
  SELECT M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         --M.INVENTORY_ITEM_ID,
         M.ITEM_CODE,
         M.ITEM_NAME,
         M.UOM,
         T.OPN_QTY,
         T.RCV_QTY,
         T.OPN_QTY + T.RCV_QTY     AVL_QTY,
         T.ISU_QTY,
         T.CLS_QTY
    FROM MAINS M, TRANS T
   WHERE     M.ORGANIZATION_ID = T.ORGANIZATION_ID
         AND M.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
         AND (T.OPN_QTY > 0 OR T.RCV_QTY > 0 OR T.ISU_QTY <> 0)
ORDER BY M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         M.ITEM_CODE;