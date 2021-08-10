/* Formatted on 10/8/2020 3:58:41 PM (QP5 v5.354) */
WITH
    MAINS
    AS
        (SELECT MSIK.ORGANIZATION_ID,
                OOD.ORGANIZATION_NAME,
                MSI.SECONDARY_INVENTORY_NAME     SECONDARY_INVENTORY,
                MSIK.INVENTORY_ITEM_ID,
                MSIK.CONCATENATED_SEGMENTS       ITEM_CODE,
                MSIK.DESCRIPTION                 ITEM_NAME,
                MSIK.PRIMARY_UOM_CODE            UOM,
                MIC.SEGMENT2                     ITEM_MJR_CAT,
                MIC.SEGMENT3                     ITEM_MNR_CAT
           FROM ORG_ORGANIZATION_DEFINITIONS  OOD,
                MTL_SYSTEM_ITEMS_B_KFV        MSIK,
                MTL_ITEM_CATEGORIES_V         MIC,
                MTL_SECONDARY_INVENTORIES     MSI
          WHERE     MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                AND MIC.CATEGORY_SET_ID = 1
                -- AND INVENTORY_ITEM_STATUS_CODE<>'Inactive'
                AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND (   :P_SUB_INVENTORY IS NULL
                     OR MSI.SECONDARY_INVENTORY_NAME = :P_SUB_INVENTORY)
                AND ( :P_ORG_ID IS NULL OR MSIK.ORGANIZATION_ID = :P_ORG_ID)
                AND (   :P_ITEM_ID IS NULL
                     OR MSIK.INVENTORY_ITEM_ID = :P_ITEM_ID)
                AND ( :P_MJR_CAT IS NULL OR MIC.SEGMENT2 = :P_MJR_CAT)
                AND ( :P_MNR_CAT IS NULL OR MIC.SEGMENT3 = :P_MNR_CAT)),
    OPENING
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  NVL (SUM (OPN_QTY), 0)     OPN_QTY,
                  NVL (SUM (OPN_VAL), 0)     OPN_VAL
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
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) < :P_DATE_FR
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID),
    RECEIVE
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUM (PO_RCV_QTY)             PO_RCV_QTY,
                  SUM (INT_ORG_RCV_QTY)        INT_ORG_RCV_QTY,
                  SUM (SUB_INV_RCV_QTY)        SUB_INV_RCV_QTY,
                  (  SUM (PO_RCV_QTY)
                   + SUM (INT_ORG_RCV_QTY)
                   + SUM (SUB_INV_RCV_QTY))    RCV_QTY,
                  SUM (PO_RCV_VAL)             PO_RCV_VAL,
                  SUM (INT_ORG_RCV_VAL)        INT_ORG_RCV_VAL,
                  SUM (SUB_INV_RCV_VAL)        SUB_INV_RCV_VAL,
                  (  SUM (PO_RCV_VAL)
                   + SUM (INT_ORG_RCV_VAL)
                   + SUM (SUB_INV_RCV_VAL))    RCV_VAL
             FROM (       --------------------------PO_RECEIPT----------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            SUM (MMT.PRIMARY_QUANTITY)     PO_RCV_QTY,
                            SUM (MMT.ACTUAL_COST)          PO_RCV_VAL,
                            TO_NUMBER (0)                  INT_ORG_RCV_QTY,
                            TO_NUMBER (0)                  INT_ORG_RCV_VAL,
                            TO_NUMBER (0)                  SUB_INV_RCV_QTY,
                            TO_NUMBER (0)                  SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 18
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL ---------INTRANSIT_SHIPMENT+INTER_ORG_TRNS---------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  PO_RCV_QTY,
                            TO_NUMBER (0)                  PO_RCV_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     INT_ORG_RCV_QTY,
                            SUM (MMT.ACTUAL_COST)          INT_ORG_RCV_VAL,
                            TO_NUMBER (0)                  SUB_INV_RCV_QTY,
                            TO_NUMBER (0)                  SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID IN (3, 21)
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL --------------------------SUB_INV_TRNS------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  PO_RCV_QTY,
                            TO_NUMBER (0)                  PO_RCV_VAL,
                            TO_NUMBER (0)                  INT_ORG_RCV_QTY,
                            TO_NUMBER (0)                  INT_ORG_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     SUB_INV_RCV_QTY,
                            SUM (MMT.ACTUAL_COST)          SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 2
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID),
    ISSUE
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  --SUM (MO_ISU_QTY)         MO_ISU_QTY,
                  (SUM (MO_ISU_QTY) + SUM (MSC_RCV_QTY))    MO_ISU_QTY,
                  SUM (INT_ORG_ISU_QTY)                     INT_ORG_ISU_QTY,
                  SUM (SUB_INV_ISU_QTY)                     SUB_INV_ISU_QTY,
                  SUM (RTN_ISU_QTY)                         RTN_ISU_QTY,
                  (  SUM (MO_ISU_QTY)
                   + SUM (INT_ORG_ISU_QTY)
                   + SUM (SUB_INV_ISU_QTY)
                   + SUM (RTN_ISU_QTY)
                   + SUM (MSC_RCV_QTY))                     ISU_QTY,
                  --SUM (MO_ISU_VAL)         MO_ISU_VAL,
                  -(SUM (MO_ISU_VAL) - SUM (MSC_RCV_VAL))    MO_ISU_VAL,
                  -SUM (INT_ORG_ISU_VAL)                     INT_ORG_ISU_VAL,
                  -SUM (SUB_INV_ISU_VAL)                     SUB_INV_ISU_VAL,
                  -SUM (RTN_ISU_VAL)                         RTN_ISU_VAL,
                  -(  SUM (MO_ISU_VAL)
                   + SUM (INT_ORG_ISU_VAL)
                   + SUM (SUB_INV_ISU_VAL)
                   + SUM (RTN_ISU_VAL)
                   - SUM (MSC_RCV_VAL))                     ISU_VAL
             FROM (       --------------------------MOVE_ORD_ISSUE------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            SUM (MMT.PRIMARY_QUANTITY)     MO_ISU_QTY,
                            SUM (MMT.ACTUAL_COST)          MO_ISU_VAL,
                            TO_NUMBER (0)                  INT_ORG_ISU_QTY,
                            TO_NUMBER (0)                  INT_ORG_ISU_VAL,
                            TO_NUMBER (0)                  SUB_INV_ISU_QTY,
                            TO_NUMBER (0)                  SUB_INV_ISU_VAL,
                            TO_NUMBER (0)                  RTN_ISU_QTY,
                            TO_NUMBER (0)                  RTN_ISU_VAL,
                            TO_NUMBER (0)                  MSC_RCV_QTY,
                            TO_NUMBER (0)                  MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 63
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL ---------INTRANSIT_SHIPMENT+INTER_ORG_TRNS---------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  MO_ISU_QTY,
                            TO_NUMBER (0)                  MO_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     INT_ORG_ISU_QTY,
                            SUM (MMT.ACTUAL_COST)          INT_ORG_ISU_VAL,
                            TO_NUMBER (0)                  SUB_INV_ISU_QTY,
                            TO_NUMBER (0)                  SUB_INV_ISU_VAL,
                            TO_NUMBER (0)                  RTN_ISU_QTY,
                            TO_NUMBER (0)                  RTN_ISU_VAL,
                            TO_NUMBER (0)                  MSC_RCV_QTY,
                            TO_NUMBER (0)                  MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID IN (3, 21)
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL --------------------------SUB_INV_TRNS------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  MO_ISU_QTY,
                            TO_NUMBER (0)                  MO_ISU_VAL,
                            TO_NUMBER (0)                  INT_ORG_ISU_QTY,
                            TO_NUMBER (0)                  INT_ORG_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     SUB_INV_ISU_QTY,
                            SUM (MMT.ACTUAL_COST)          SUB_INV_ISU_VAL,
                            TO_NUMBER (0)                  RTN_ISU_QTY,
                            TO_NUMBER (0)                  RTN_ISU_VAL,
                            TO_NUMBER (0)                  MSC_RCV_QTY,
                            TO_NUMBER (0)                  MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 2
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL --------------------------RETURN_TO_VENDOR-----------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  MO_ISU_QTY,
                            TO_NUMBER (0)                  MO_ISU_VAL,
                            TO_NUMBER (0)                  INT_ORG_ISU_QTY,
                            TO_NUMBER (0)                  INT_ORG_ISU_VAL,
                            TO_NUMBER (0)                  SUB_INV_ISU_QTY,
                            TO_NUMBER (0)                  SUB_INV_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     RTN_ISU_QTY,
                            SUM (MMT.ACTUAL_COST)          RTN_ISU_VAL,
                            TO_NUMBER (0)                  MSC_RCV_QTY,
                            TO_NUMBER (0)                  MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 36
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID
                   UNION ALL --------------MISCELLANEOUS_RECEIPT----------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            TO_NUMBER (0)                  MO_ISU_QTY,
                            TO_NUMBER (0)                  MO_ISU_VAL,
                            TO_NUMBER (0)                  INT_ORG_ISU_QTY,
                            TO_NUMBER (0)                  INT_ORG_ISU_VAL,
                            TO_NUMBER (0)                  SUB_INV_ISU_QTY,
                            TO_NUMBER (0)                  SUB_INV_ISU_VAL,
                            TO_NUMBER (0)                  RTN_ISU_QTY,
                            TO_NUMBER (0)                  RTN_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY)     MSC_RCV_QTY,
                            SUM (MMT.ACTUAL_COST)          MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 42
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID),
    CLOSING
    AS
        (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUM (CLS_QTY)     CLS_QTY,
                  SUM (CLS_VAL)     CLS_VAL
             FROM (  SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            SUM (MMT.PRIMARY_QUANTITY)           CLS_QTY,
                            APPS.XX_INV_TRAN_VAL (INVENTORY_ITEM_ID,
                                                  ORGANIZATION_ID,
                                                  'C',
                                                  '01-JAN-1951',
                                                  :P_DATE_TO)    CLS_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_SUB_INVENTORY IS NULL
                                 OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) <= :P_DATE_TO
                            --AND MMT.TRANSACTION_TYPE_ID != 2
                            AND TRANSACTION_ACTION_ID != 24
                   GROUP BY MMT.ORGANIZATION_ID, MMT.INVENTORY_ITEM_ID)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID)
  SELECT M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.SECONDARY_INVENTORY,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         M.INVENTORY_ITEM_ID,
         M.ITEM_CODE,
         M.ITEM_NAME,
         M.UOM,
         O.OPN_QTY,
         O.OPN_VAL,
         R.PO_RCV_QTY,
         R.PO_RCV_VAL,
         R.INT_ORG_RCV_QTY,
         R.INT_ORG_RCV_VAL,
         R.SUB_INV_RCV_QTY,
         R.SUB_INV_RCV_VAL,
         R.RCV_QTY,
         R.RCV_VAL,
         I.MO_ISU_QTY,
         I.MO_ISU_VAL,
         I.INT_ORG_ISU_QTY,
         I.INT_ORG_ISU_VAL,
         I.SUB_INV_ISU_QTY,
         I.SUB_INV_ISU_VAL,
         I.RTN_ISU_QTY,
         I.RTN_ISU_VAL,
         I.ISU_QTY,
         I.ISU_VAL,
         (R.RCV_QTY + I.ISU_QTY)                                         CLOSING_QTY,
         (R.RCV_VAL + I.ISU_VAL)                                         CLOSING_VAL,
         C.CLS_QTY,
         C.CLS_VAL,
         ROUND ((I.ISU_VAL / DECODE (I.ISU_QTY, 0, 1, I.ISU_QTY)), 2)    AVG_ISS_VAL
    FROM MAINS  M,
         OPENING O,
         RECEIVE R,
         ISSUE  I,
         CLOSING C
   WHERE     1 = 1
         AND M.ORGANIZATION_ID = R.ORGANIZATION_ID
         AND M.INVENTORY_ITEM_ID = R.INVENTORY_ITEM_ID
         AND M.ORGANIZATION_ID = I.ORGANIZATION_ID
         AND M.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
         AND M.ORGANIZATION_ID = C.ORGANIZATION_ID(+)
         AND M.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID(+)
         AND M.ORGANIZATION_ID = O.ORGANIZATION_ID(+)
         AND M.INVENTORY_ITEM_ID = O.INVENTORY_ITEM_ID(+)
         AND :P_REPORT_TYPE = 'YES'
         AND (O.OPN_QTY > 0 OR R.RCV_QTY > 0 OR I.ISU_QTY <> 0)
ORDER BY M.ORGANIZATION_ID,
         M.ORGANIZATION_NAME,
         M.ITEM_MJR_CAT,
         M.ITEM_MNR_CAT,
         M.ITEM_CODE;