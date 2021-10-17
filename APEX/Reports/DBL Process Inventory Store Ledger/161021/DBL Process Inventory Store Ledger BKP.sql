/* Formatted on 10/16/2021 11:20:10 AM (QP5 v5.365) */
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
           FROM APPS.ORG_ORGANIZATION_DEFINITIONS  OOD,
                APPS.MTL_SYSTEM_ITEMS_B_KFV        MSIK,
                APPS.MTL_ITEM_CATEGORIES_V         MIC,
                INV.MTL_PARAMETERS                 MP
          WHERE     MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND PROCESS_ENABLED_FLAG = 'Y'
                AND OOD.ORGANIZATION_ID = 150
                AND MSIK.INVENTORY_ITEM_ID = 5200
                AND MIC.CATEGORY_SET_ID = 1
                AND (   :P_LEGAL_ENTITY IS NULL
                     OR OOD.LEGAL_ENTITY = :P_LEGAL_ENTITY)
                AND ( :P_ORG_ID IS NULL OR MSIK.ORGANIZATION_ID = :P_ORG_ID)
                AND (   :P_ITEM_ID IS NULL
                     OR MSIK.INVENTORY_ITEM_ID = :P_ITEM_ID)
                AND ( :P_MJR_CAT IS NULL OR MIC.SEGMENT2 = :P_MJR_CAT)
                AND ( :P_MNR_CAT IS NULL OR MIC.SEGMENT3 = :P_MNR_CAT)),
    TRANS
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUM (OPN_QTY)               AS OPN_QTY,
                  SUM (OPN_VAL)               AS OPN_VAL,
                  SUM (RCV_QTY)               AS RCV_QTY,
                  SUM (RCV_QTY) * CLS_CST     AS RCV_VAL,
                  SUM (ISU_QTY)               AS ISU_QTY,
                  SUM (ISU_QTY) * CLS_CST     AS ISU_VAL,
                  SUM (AVL_QTY)               AS AVL_QTY,
                  SUM (AVL_QTY) * CLS_CST     AS AVL_VAL,
                  SUM (CLS_QTY)               AS CLS_QTY,
                  SUM (CLS_QTY) * CLS_CST     AS CLS_VAL
             FROM (  SELECT ORGANIZATION_ID,
                            INVENTORY_ITEM_ID,
                            SUM (OPN_QTY)
                                OPN_QTY,
                            SUM (OPN_VAL)
                                OPN_VAL,
                            SUM (RCV_QTY)
                                RCV_QTY,
                            SUM (ISU_QTY)
                                ISU_QTY,
                            ROUND (SUM (OPN_QTY) + SUM (RCV_QTY), 2)
                                AS AVL_QTY,
                            SUM (CLS_QTY)
                                CLS_QTY,
                            (SELECT COST
                               FROM (SELECT COUNT (ccd.inventory_item_id)
                                                inventory_item_id,
                                            NVL (SUM (ccd.cmpnt_cost), 0)
                                                cost
                                       FROM APPS.cm_cldr_mst_v ccm,
                                            APPS.cm_cmpt_dtl ccd
                                      WHERE     ccd.period_id = ccm.period_id
                                            AND ccd.inventory_item_id =
                                                MTL.INVENTORY_ITEM_ID
                                            AND ccd.organization_id =
                                                MTL.ORGANIZATION_ID
                                            AND TO_CHAR (
                                                    TO_DATE (ccm.period_desc,
                                                             'MON-YY'),
                                                    'MON-YY') =
                                                :P4_DATE_TO))
                                CLS_CST
                       FROM (  SELECT MMT.ORGANIZATION_ID,
                                      MMT.INVENTORY_ITEM_ID,
                                      SUM (MMT.PRIMARY_QUANTITY)      OPN_QTY,
                                        (SELECT COST
                                           FROM (SELECT COUNT (
                                                            ccd.inventory_item_id)
                                                            inventory_item_id,
                                                        NVL (SUM (ccd.cmpnt_cost),
                                                             0)
                                                            cost
                                                   FROM APPS.cm_cldr_mst_v ccm,
                                                        APPS.cm_cmpt_dtl ccd
                                                  WHERE     ccd.period_id =
                                                            ccm.period_id
                                                        AND ccd.inventory_item_id =
                                                            MMT.INVENTORY_ITEM_ID
                                                        AND ccd.organization_id =
                                                            MMT.ORGANIZATION_ID
                                                        AND TO_CHAR (
                                                                TO_DATE (
                                                                    ccm.period_desc,
                                                                    'MON-YY'),
                                                                'MON-YY') =
                                                            :P4_DATE_FR))
                                      * SUM (MMT.PRIMARY_QUANTITY)    OPN_VAL,
                                      TO_NUMBER (0)                   RCV_QTY,
                                      TO_NUMBER (0)                   ISU_QTY,
                                      TO_NUMBER (0)                   CLS_QTY
                                 FROM INV.MTL_MATERIAL_TRANSACTIONS MMT
                                WHERE     (   :P_ORG_ID IS NULL
                                           OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                                      AND (   :P_ITEM_ID IS NULL
                                           OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                                      AND TRANSACTION_ACTION_ID != 24
                                      AND (   LOGICAL_TRANSACTION = 2
                                           OR LOGICAL_TRANSACTION IS NULL)
                                      AND MMT.TRANSACTION_TYPE_ID NOT IN (80,
                                                                          98,
                                                                          99,
                                                                          120,
                                                                          52,
                                                                          26,
                                                                          64,
                                                                          2)
                             GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                             UNION ALL
                               SELECT MMT.ORGANIZATION_ID,
                                      MMT.INVENTORY_ITEM_ID,
                                      TO_NUMBER (0)                  OPN_QTY,
                                      TO_NUMBER (0)                  OPN_VAL,
                                      SUM (MMT.PRIMARY_QUANTITY)     RCV_QTY,
                                      TO_NUMBER (0)                  ISU_QTY,
                                      TO_NUMBER (0)                  CLS_QTY
                                 FROM INV.MTL_MATERIAL_TRANSACTIONS MMT
                                WHERE     (   :P_ORG_ID IS NULL
                                           OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                                      AND (   :P_ITEM_ID IS NULL
                                           OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                                      AND TRANSACTION_ACTION_ID != 24
                                      AND (   LOGICAL_TRANSACTION = 2
                                           OR LOGICAL_TRANSACTION IS NULL)
                                      AND MMT.TRANSACTION_TYPE_ID NOT IN (80,
                                                                          98,
                                                                          99,
                                                                          120,
                                                                          52,
                                                                          26,
                                                                          64,
                                                                          2)
                                      AND SIGN (PRIMARY_QUANTITY) = 1
                             GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                             UNION ALL
                               SELECT MMT.ORGANIZATION_ID,
                                      MMT.INVENTORY_ITEM_ID,
                                      TO_NUMBER (0)                  OPN_QTY,
                                      TO_NUMBER (0)                  OPN_VAL,
                                      TO_NUMBER (0)                  RCV_QTY,
                                      SUM (MMT.PRIMARY_QUANTITY)     ISU_QTY,
                                      TO_NUMBER (0)                  CLS_QTY
                                 FROM INV.MTL_MATERIAL_TRANSACTIONS MMT
                                WHERE     (   :P_ORG_ID IS NULL
                                           OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                                      AND (   :P_ITEM_ID IS NULL
                                           OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                                      AND TRANSACTION_ACTION_ID != 24
                                      AND (   LOGICAL_TRANSACTION = 2
                                           OR LOGICAL_TRANSACTION IS NULL)
                                      AND MMT.TRANSACTION_TYPE_ID NOT IN (80,
                                                                          98,
                                                                          99,
                                                                          120,
                                                                          52,
                                                                          26,
                                                                          64,
                                                                          2)
                                      AND SIGN (PRIMARY_QUANTITY) = -1
                             GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                             UNION ALL
                               SELECT MMT.ORGANIZATION_ID,
                                      MMT.INVENTORY_ITEM_ID,
                                      TO_NUMBER (0)                  OPN_QTY,
                                      TO_NUMBER (0)                  OPN_VAL,
                                      TO_NUMBER (0)                  RCV_QTY,
                                      TO_NUMBER (0)                  ISU_QTY,
                                      SUM (MMT.PRIMARY_QUANTITY)     CLS_QTY
                                 FROM INV.MTL_MATERIAL_TRANSACTIONS MMT
                                WHERE     (   :P_ORG_ID IS NULL
                                           OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                                      AND (   :P_ITEM_ID IS NULL
                                           OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                                      AND TRANSACTION_ACTION_ID != 24
                                      AND (   LOGICAL_TRANSACTION = 2
                                           OR LOGICAL_TRANSACTION IS NULL)
                                      AND MMT.TRANSACTION_TYPE_ID NOT IN (80,
                                                                          98,
                                                                          99,
                                                                          120,
                                                                          52,
                                                                          26,
                                                                          64,
                                                                          2)
                             GROUP BY MMT.ORGANIZATION_ID,
                                      MMT.INVENTORY_ITEM_ID,
                                      TO_CHAR (MMT.TRANSACTION_DATE, 'MON-RR'))
                            MTL
                   GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID, CLS_CST)
SELECT M.ORGANIZATION_ID,
       M.ORGANIZATION_NAME,
       M.ITEM_MJR_CAT,
       M.ITEM_MNR_CAT,
       M.INVENTORY_ITEM_ID,
       M.ITEM_CODE,
       M.ITEM_NAME,
       M.UOM,
       ROUND (T.OPN_QTY, 2)                              AS OPN_QTY,
       ROUND (T.OPN_VAL, 2)                              AS OPN_VAL,
       ROUND (T.RCV_QTY, 2)                              AS RCV_QTY,
       ROUND (T.RCV_VAL, 2)                              AS RCV_VAL,
       ROUND (T.OPN_QTY + T.RCV_QTY, 2)                  AS AVL_QTY,
       ROUND (T.OPN_VAL + T.RCV_VAL, 2)                  AS AVL_VAL,
       ROUND (T.ISU_QTY, 2)                              AS ISU_QTY,
       ROUND (
           (  ((T.OPN_VAL + T.RCV_VAL) / (T.OPN_QTY + T.RCV_QTY))
            * ROUND (T.ISU_QTY, 2)),
           2)                                            AS ISU_VAL,
       ROUND ((T.OPN_QTY + T.RCV_QTY + T.ISU_QTY), 2)    AS CLS_QTY,
       ROUND (
           (  (T.OPN_VAL + T.RCV_VAL)
            + (  ((T.OPN_VAL + T.RCV_VAL) / (T.OPN_QTY + T.RCV_QTY))
               * (ROUND (T.ISU_QTY, 2)))),
           2)                                            AS CLS_VAL,
       ROUND (
           (  (  ((T.OPN_VAL + T.RCV_VAL) / (T.OPN_QTY + T.RCV_QTY))
               * T.ISU_QTY)
            / DECODE (T.ISU_QTY, 0, 1, T.ISU_QTY)),
           2)                                            AVG_ISS_VAL,
       ROUND (
             (T.OPN_VAL + T.RCV_VAL)
           / (NVL (T.OPN_QTY, 1) + NVL (T.RCV_QTY, 1)),
           2)                                            AVG_COST_AVA_STOCK
  FROM MAINS M, TRANS T
 WHERE     M.ORGANIZATION_ID = T.ORGANIZATION_ID
       AND M.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
       AND (T.OPN_QTY > 0 OR T.RCV_QTY > 0 OR T.ISU_QTY <> 0);