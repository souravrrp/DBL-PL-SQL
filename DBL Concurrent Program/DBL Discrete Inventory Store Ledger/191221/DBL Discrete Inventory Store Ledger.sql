/* Formatted on 12/19/2021 12:14:07 PM (QP5 v5.374) */
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
                MTL_ITEM_CATEGORIES_V         MIC,
                INV.MTL_PARAMETERS            MP
          WHERE     MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND PROCESS_ENABLED_FLAG <> 'Y'
                AND MIC.CATEGORY_SET_ID = 1
                AND (   :P_LEGAL_ENTITY IS NULL
                     OR OOD.LEGAL_ENTITY = :P_LEGAL_ENTITY)
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
                  SUM (OPN_VAL)     OPN_VAL,
                  SUM (RCV_QTY)     RCV_QTY,
                  SUM (RCV_VAL)     RCV_VAL,
                  SUM (ISU_QTY)     ISU_QTY,
                  SUM (ISU_VAL)     ISU_VAL,
                  SUM (CLS_QTY)     CLS_QTY,
                  SUM (CLS_VAL)     CLS_VAL
             FROM (  SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            SUM (MMT.PRIMARY_QUANTITY)               OPN_QTY,
                            APPS.XX_INV_TRAN_VAL (INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  'O',
                                                  '01-JAN-1950',
                                                  :P_DATE_FR - 1)    OPN_VAL,
                            TO_NUMBER (0)                            RCV_QTY,
                            TO_NUMBER (0)                            RCV_VAL,
                            TO_NUMBER (0)                            ISU_QTY,
                            TO_NUMBER (0)                            ISU_VAL,
                            TO_NUMBER (0)                            CLS_QTY,
                            TO_NUMBER (0)                            CLS_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) < :P_DATE_FR
                            AND (   LOGICAL_TRANSACTION = 2
                                 OR LOGICAL_TRANSACTION IS NULL)
                            AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                        OPN_QTY,
                            TO_NUMBER (0)                        OPN_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)           RCV_QTY,
                            APPS.XX_INV_TRAN_VAL (INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  'R',
                                                  :P_DATE_FR,
                                                  :P_DATE_TO)    RCV_VAL,
                            TO_NUMBER (0)                        ISU_QTY,
                            TO_NUMBER (0)                        ISU_VAL,
                            TO_NUMBER (0)                        CLS_QTY,
                            TO_NUMBER (0)                        CLS_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND (   LOGICAL_TRANSACTION = 2
                                 OR LOGICAL_TRANSACTION IS NULL)
                            AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                        OPN_QTY,
                            TO_NUMBER (0)                        OPN_VAL,
                            TO_NUMBER (0)                        RCV_QTY,
                            TO_NUMBER (0)                        RCV_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)           ISU_QTY,
                            APPS.XX_INV_TRAN_VAL (INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  'I',
                                                  :P_DATE_FR,
                                                  :P_DATE_TO)    ISU_VAL,
                            TO_NUMBER (0)                        CLS_QTY,
                            TO_NUMBER (0)                        CLS_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND (   LOGICAL_TRANSACTION = 2
                                 OR LOGICAL_TRANSACTION IS NULL)
                            AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                        OPN_QTY,
                            TO_NUMBER (0)                        OPN_VAL,
                            TO_NUMBER (0)                        RCV_QTY,
                            TO_NUMBER (0)                        RCV_VAL,
                            TO_NUMBER (0)                        ISU_QTY,
                            TO_NUMBER (0)                        ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)           CLS_QTY,
                            APPS.XX_INV_TRAN_VAL (INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  'C',
                                                  '01-JAN-1951',
                                                  :P_DATE_TO)    CLS_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) <= :P_DATE_TO
                            AND (   LOGICAL_TRANSACTION = 2
                                 OR LOGICAL_TRANSACTION IS NULL)
                            AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID)
  SELECT M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         M.INVENTORY_ITEM_ID,
         M.ITEM_CODE,
         M.ITEM_NAME,
         M.UOM,
         T.OPN_QTY,
         T.OPN_VAL,
         T.RCV_QTY,
         T.RCV_VAL,
         T.OPN_QTY + T.RCV_QTY
             AVL_QTY,
         T.OPN_VAL + T.RCV_VAL
             AVL_VAL,
         T.ISU_QTY,
         T.ISU_VAL,
         T.CLS_QTY,
         T.CLS_VAL,
         ROUND ((T.ISU_VAL / DECODE (T.ISU_QTY, 0, 1, T.ISU_QTY)), 2)
             AVG_ISS_VAL,
         TO_CHAR (
             (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), NULL)
                FROM INV.MTL_MATERIAL_TRANSACTIONS A
               WHERE     SIGN (PRIMARY_QUANTITY) = 1
                     AND (   LOGICAL_TRANSACTION = 2
                          OR LOGICAL_TRANSACTION IS NULL)
                     AND A.TRANSACTION_TYPE_ID != 2
                     AND TRANSACTION_ACTION_ID != 24
                     AND A.INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                     AND A.ORGANIZATION_ID = M.ORGANIZATION_ID
                     AND TRUNC (A.TRANSACTION_DATE) <= :P_DATE_TO + .99999))
             AS LAST_RECEIVE_DATE,
         TO_CHAR (
             (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), NULL)
                FROM INV.MTL_MATERIAL_TRANSACTIONS A
               WHERE     SIGN (PRIMARY_QUANTITY) = -1
                     AND (   LOGICAL_TRANSACTION = 2
                          OR LOGICAL_TRANSACTION IS NULL)
                     AND A.TRANSACTION_TYPE_ID != 2
                     AND TRANSACTION_ACTION_ID != 24
                     AND A.INVENTORY_ITEM_ID = M.INVENTORY_ITEM_ID
                     AND A.ORGANIZATION_ID = M.ORGANIZATION_ID
                     AND TRUNC (A.TRANSACTION_DATE) <= :P_DATE_TO + .99999))
             AS LAST_ISSUE_DATE
    FROM MAINS M, TRANS T
   WHERE     M.ORGANIZATION_ID = T.ORGANIZATION_ID
         AND M.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
         AND (T.OPN_QTY > 0 OR T.RCV_QTY > 0 OR T.ISU_QTY <> 0)
ORDER BY M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         M.ITEM_CODE