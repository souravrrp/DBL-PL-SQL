/* Formatted on 1/5/2021 3:47:58 PM (QP5 v5.287) */
WITH ITM
     AS (SELECT MSIK.ORGANIZATION_ID,
                OOD.ORGANIZATION_NAME,
                MSI.SECONDARY_INVENTORY_NAME SECONDARY_INVENTORY,
                MSIK.INVENTORY_ITEM_ID,
                MSIK.CONCATENATED_SEGMENTS ITEM_CODE,
                MSIK.DESCRIPTION ITEM_NAME,
                MSIK.PRIMARY_UOM_CODE UOM,
                MIC.SEGMENT2 ITEM_MJR_CAT,
                MIC.SEGMENT3 ITEM_MNR_CAT
           FROM ORG_ORGANIZATION_DEFINITIONS OOD,
                MTL_SYSTEM_ITEMS_B_KFV MSIK,
                MTL_ITEM_CATEGORIES_V MIC,
                MTL_SECONDARY_INVENTORIES MSI
          WHERE     MSIK.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                AND MSIK.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND MSIK.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                AND MIC.CATEGORY_SET_ID = 1
                AND 'Without-Sub-Inv' = :p_report_type
                AND ( :P_ORG_ID IS NULL OR MSIK.ORGANIZATION_ID = :P_ORG_ID)
                AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND (   :P_SUB_INVENTORY IS NULL
                     OR MSI.SECONDARY_INVENTORY_NAME = :P_SUB_INVENTORY)
                AND (   :P_ITEM_ID IS NULL
                     OR MSIK.INVENTORY_ITEM_ID = :P_ITEM_ID)
                AND ( :P_MJR_CAT IS NULL OR MIC.SEGMENT2 = :P_MJR_CAT)
                AND ( :P_MNR_CAT IS NULL OR MIC.SEGMENT3 = :P_MNR_CAT)),
     RCV
     AS (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUBINVENTORY_CODE,
                  SUM (PO_RCV_QTY) PO_RCV_QTY,
                  SUM (INT_ORG_RCV_QTY) INT_ORG_RCV_QTY,
                  SUM (SUB_INV_RCV_QTY) SUB_INV_RCV_QTY,
                  SUM (RTN_ISU_QTY) RTN_ISU_QTY,
                  (  SUM (PO_RCV_QTY)
                   + SUM (INT_ORG_RCV_QTY)
                   + SUM (SUB_INV_RCV_QTY)
                   + SUM (RTN_ISU_QTY))
                     RCV_QTY,
                  SUM (PO_RCV_VAL) PO_RCV_VAL,
                  SUM (INT_ORG_RCV_VAL) INT_ORG_RCV_VAL,
                  SUM (SUB_INV_RCV_VAL) SUB_INV_RCV_VAL,
                  SUM (RTN_ISU_VAL) RTN_ISU_VAL,
                  (  SUM (PO_RCV_VAL)
                   + SUM (INT_ORG_RCV_VAL)
                   + SUM (SUB_INV_RCV_VAL)
                   + SUM (RTN_ISU_VAL))
                     RCV_VAL
             FROM (       --------------------------PO_RECEIPT----------------
                   SELECT   MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            SUM (MMT.PRIMARY_QUANTITY) PO_RCV_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               PO_RCV_VAL,
                            TO_NUMBER (0) RTN_ISU_QTY,
                            TO_NUMBER (0) RTN_ISU_VAL,
                            TO_NUMBER (0) INT_ORG_RCV_QTY,
                            TO_NUMBER (0) INT_ORG_RCV_VAL,
                            TO_NUMBER (0) SUB_INV_RCV_QTY,
                            TO_NUMBER (0) SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 18
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL --------------------------RETURN_TO_VENDOR-----------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            TO_NUMBER (0) PO_RCV_QTY,
                            TO_NUMBER (0) PO_RCV_VAL,
                            SUM (MMT.PRIMARY_QUANTITY) RTN_ISU_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               RTN_ISU_VAL,
                            TO_NUMBER (0) INT_ORG_RCV_QTY,
                            TO_NUMBER (0) INT_ORG_RCV_VAL,
                            TO_NUMBER (0) SUB_INV_RCV_QTY,
                            TO_NUMBER (0) SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 36
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL ---------INTRANSIT_SHIPMENT+INTER_ORG_TRNS+INTRANSIT_RECEIPT---------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            TO_NUMBER (0) PO_RCV_QTY,
                            TO_NUMBER (0) PO_RCV_VAL,
                            TO_NUMBER (0) RTN_ISU_QTY,
                            TO_NUMBER (0) RTN_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY) INT_ORG_RCV_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               INT_ORG_RCV_VAL,
                            TO_NUMBER (0) SUB_INV_RCV_QTY,
                            TO_NUMBER (0) SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID IN (3, 21, 12)
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL --------------------------SUB_INV_TRNS------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            TO_NUMBER (0) PO_RCV_QTY,
                            TO_NUMBER (0) PO_RCV_VAL,
                            TO_NUMBER (0) RTN_ISU_QTY,
                            TO_NUMBER (0) RTN_ISU_VAL,
                            TO_NUMBER (0) INT_ORG_RCV_QTY,
                            TO_NUMBER (0) INT_ORG_VAL,
                            SUM (MMT.PRIMARY_QUANTITY) SUB_INV_RCV_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               SUB_INV_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 2
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL        --------------------------DUAL------------
                   SELECT TO_NUMBER ( :P_ORG_ID) ORGANIZATION_ID,
                          TO_NUMBER ( :P_ITEM_ID) INVENTORY_ITEM_ID,
                          NULL SUBINVENTORY_CODE,
                          TO_NUMBER (0) PO_RCV_QTY,
                          TO_NUMBER (0) PO_RCV_VAL,
                          TO_NUMBER (0) RTN_ISU_QTY,
                          TO_NUMBER (0) RTN_ISU_VAL,
                          TO_NUMBER (0) INT_ORG_RCV_QTY,
                          TO_NUMBER (0) INT_ORG_VAL,
                          TO_NUMBER (0) SUB_INV_RCV_QTY,
                          TO_NUMBER (0) SUB_INV_RCV_VAL
                     FROM DUAL)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID, SUBINVENTORY_CODE),
     ISSUE
     AS (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUBINVENTORY_CODE,
                  SUM (INT_ORG_ISU_QTY) INT_ORG_ISU_QTY,
                  SUM (SUB_INV_ISU_QTY) SUB_INV_ISU_QTY,
                  (SUM (INT_ORG_ISU_QTY) + SUM (SUB_INV_ISU_QTY)) ISU_QTY,
                  SUM (INT_ORG_ISU_VAL) INT_ORG_ISU_VAL,
                  SUM (SUB_INV_ISU_VAL) SUB_INV_ISU_VAL,
                  (SUM (INT_ORG_ISU_VAL) + SUM (SUB_INV_ISU_VAL)) ISU_VAL
             FROM (        ---------INTRANSIT_SHIPMENT+INTER_ORG_TRNS---------
                   SELECT   MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            SUM (MMT.PRIMARY_QUANTITY) INT_ORG_ISU_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               INT_ORG_ISU_VAL,
                            TO_NUMBER (0) SUB_INV_ISU_QTY,
                            TO_NUMBER (0) SUB_INV_ISU_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID IN (3, 21)
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL --------------------------SUB_INV_TRNS------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            TO_NUMBER (0) INT_ORG_ISU_QTY,
                            TO_NUMBER (0) INT_ORG_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY) SUB_INV_ISU_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               SUB_INV_ISU_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 2
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL        --------------------------DUAL------------
                   SELECT TO_NUMBER ( :P_ORG_ID) ORGANIZATION_ID,
                          TO_NUMBER ( :P_ITEM_ID) INVENTORY_ITEM_ID,
                          NULL SUBINVENTORY_CODE,
                          TO_NUMBER (0) INT_ORG_ISU_QTY,
                          TO_NUMBER (0) INT_ORG_ISU_VAL,
                          TO_NUMBER (0) SUB_INV_ISU_QTY,
                          TO_NUMBER (0) SUB_INV_ISU_VAL
                     FROM DUAL)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID, SUBINVENTORY_CODE),
     CON
     AS (  SELECT ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  SUBINVENTORY_CODE,
                  SUM (MO_ISU_QTY) MO_ISU_QTY,
                  SUM (MSC_RCV_QTY) MSC_RCV_QTY,
                  (SUM (MO_ISU_QTY) + SUM (MSC_RCV_QTY)) CON_QTY,
                  SUM (MO_ISU_VAL) MO_ISU_VAL,
                  SUM (MSC_RCV_VAL) MSC_RCV_VAL,
                  (SUM (MO_ISU_VAL) + SUM (MSC_RCV_VAL)) CON_VAL
             FROM (       --------------------------MOVE_ORD_ISSUE------------
                   SELECT   MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            SUM (MMT.PRIMARY_QUANTITY) MO_ISU_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               MO_ISU_VAL,
                            TO_NUMBER (0) MSC_RCV_QTY,
                            TO_NUMBER (0) MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 63
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = -1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL --------------MISCELLANEOUS_RECEIPT----------------
                     SELECT MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.SUBINVENTORY_CODE,
                            TO_NUMBER (0) MO_ISU_QTY,
                            TO_NUMBER (0) MO_ISU_VAL,
                            SUM (MMT.PRIMARY_QUANTITY) MSC_RCV_QTY,
                            SUM (MMT.PRIMARY_QUANTITY) * MMT.ACTUAL_COST
                               MSC_RCV_VAL
                       FROM MTL_MATERIAL_TRANSACTIONS MMT
                      WHERE     (   :P_ORG_ID IS NULL
                                 OR MMT.ORGANIZATION_ID = :P_ORG_ID)
                            AND (   :P_ITEM_ID IS NULL
                                 OR MMT.INVENTORY_ITEM_ID = :P_ITEM_ID)
                            AND TRUNC (MMT.TRANSACTION_DATE) BETWEEN :P_DATE_FR
                                                                 AND :P_DATE_TO
                            AND MMT.TRANSACTION_TYPE_ID = 42
                            AND TRANSACTION_ACTION_ID != 24
                            AND SIGN (PRIMARY_QUANTITY) = 1
                   GROUP BY MMT.ORGANIZATION_ID,
                            MMT.INVENTORY_ITEM_ID,
                            MMT.ACTUAL_COST,
                            MMT.SUBINVENTORY_CODE
                   UNION ALL        --------------------------DUAL------------
                   SELECT TO_NUMBER ( :P_ORG_ID) ORGANIZATION_ID,
                          TO_NUMBER ( :P_ITEM_ID) INVENTORY_ITEM_ID,
                          NULL SUBINVENTORY_CODE,
                          TO_NUMBER (0) MO_ISU_QTY,
                          TO_NUMBER (0) MO_ISU_VAL,
                          TO_NUMBER (0) MSC_RCV_QTY,
                          TO_NUMBER (0) MSC_RCV_VAL
                     FROM DUAL)
         GROUP BY ORGANIZATION_ID, INVENTORY_ITEM_ID, SUBINVENTORY_CODE)
  SELECT MMT.ORGANIZATION_ID,
         MMT.ORGANIZATION_NAME,
         MMT.SECONDARY_INVENTORY,
         MMT.ITEM_MJR_CAT,
         MMT.ITEM_MNR_CAT,
         MMT.INVENTORY_ITEM_ID,
         MMT.ITEM_CODE,
         MMT.ITEM_NAME,
         MMT.UOM,
         SUM (MMT.PO_RCV_QTY) PO_RCV_QTY,
         SUM (MMT.PO_RCV_VAL) PO_RCV_VAL,
         SUM (MMT.RTN_ISU_QTY) RTN_ISU_QTY,
         SUM (MMT.RTN_ISU_VAL) RTN_ISU_VAL,
         SUM (MMT.INT_ORG_RCV_QTY) INT_ORG_RCV_QTY,
         SUM (MMT.INT_ORG_RCV_VAL) INT_ORG_RCV_VAL,
         SUM (MMT.SUB_INV_RCV_QTY) SUB_INV_RCV_QTY,
         SUM (MMT.SUB_INV_RCV_VAL) SUB_INV_RCV_VAL,
         SUM (MMT.RCV_QTY) RCV_QTY,
         SUM (MMT.RCV_VAL) RCV_VAL,
         SUM (MMT.INT_ORG_ISU_QTY) INT_ORG_ISU_QTY,
         SUM (MMT.INT_ORG_ISU_VAL) INT_ORG_ISU_VAL,
         SUM (MMT.SUB_INV_ISU_QTY) SUB_INV_ISU_QTY,
         SUM (MMT.SUB_INV_ISU_VAL) SUB_INV_ISU_VAL,
         SUM (MMT.ISU_QTY) ISU_QTY,
         SUM (MMT.ISU_VAL) ISU_VAL,
         (SUM (MMT.RCV_QTY) + SUM (MMT.ISU_QTY)) NET_RCV_QTY,
         (SUM (MMT.RCV_VAL) + SUM (MMT.ISU_VAL)) NET_RCV_VAL,
         SUM (MMT.MO_ISU_QTY) MO_ISU_QTY,
         SUM (MMT.MO_ISU_VAL) MO_ISU_VAL,
         SUM (MMT.MSC_RCV_QTY) MSC_RCV_QTY,
         SUM (MMT.MSC_RCV_VAL) MSC_RCV_VAL,
         SUM (MMT.CON_QTY) CON_QTY,
         SUM (MMT.CON_VAL) CON_VAL,
         (SUM (MMT.RCV_QTY) + SUM (MMT.ISU_QTY) + SUM (MMT.CON_QTY))
            CLOSING_QTY,
         (SUM (MMT.RCV_VAL) + SUM (MMT.ISU_VAL) + SUM (MMT.CON_VAL))
            CLOSING_VAL,
         ROUND (
            (  SUM (MMT.ISU_VAL)
             / DECODE (SUM (MMT.ISU_QTY), 0, 1, SUM (MMT.ISU_QTY))),
            2)
            AVG_ISS_VAL
    FROM (SELECT ITM.ORGANIZATION_ID,
                 ITM.ORGANIZATION_NAME,
                 ITM.SECONDARY_INVENTORY,
                 ITM.ITEM_MJR_CAT,
                 ITM.ITEM_MNR_CAT,
                 ITM.INVENTORY_ITEM_ID,
                 ITM.ITEM_CODE,
                 ITM.ITEM_NAME,
                 ITM.UOM,
                 RCV.PO_RCV_QTY,
                 RCV.PO_RCV_VAL,
                 RCV.RTN_ISU_QTY,
                 RCV.RTN_ISU_VAL,
                 RCV.INT_ORG_RCV_QTY,
                 RCV.INT_ORG_RCV_VAL,
                 RCV.SUB_INV_RCV_QTY,
                 RCV.SUB_INV_RCV_VAL,
                 RCV.RCV_QTY,
                 RCV.RCV_VAL,
                 TO_NUMBER (0) INT_ORG_ISU_QTY,
                 TO_NUMBER (0) INT_ORG_ISU_VAL,
                 TO_NUMBER (0) SUB_INV_ISU_QTY,
                 TO_NUMBER (0) SUB_INV_ISU_VAL,
                 TO_NUMBER (0) ISU_QTY,
                 TO_NUMBER (0) ISU_VAL,
                 TO_NUMBER (0) MO_ISU_QTY,
                 TO_NUMBER (0) MO_ISU_VAL,
                 TO_NUMBER (0) MSC_RCV_QTY,
                 TO_NUMBER (0) MSC_RCV_VAL,
                 TO_NUMBER (0) CON_QTY,
                 TO_NUMBER (0) CON_VAL
            FROM ITM
                 JOIN RCV
                    ON     1 = 1
                       AND ITM.ORGANIZATION_ID = RCV.ORGANIZATION_ID
                       AND ITM.INVENTORY_ITEM_ID = RCV.INVENTORY_ITEM_ID
                       AND ITM.SECONDARY_INVENTORY = RCV.SUBINVENTORY_CODE
                       AND RCV.RCV_QTY > 0
          UNION ALL
          SELECT ITM.ORGANIZATION_ID,
                 ITM.ORGANIZATION_NAME,
                 ITM.SECONDARY_INVENTORY,
                 ITM.ITEM_MJR_CAT,
                 ITM.ITEM_MNR_CAT,
                 ITM.INVENTORY_ITEM_ID,
                 ITM.ITEM_CODE,
                 ITM.ITEM_NAME,
                 ITM.UOM,
                 TO_NUMBER (0) PO_RCV_QTY,
                 TO_NUMBER (0) PO_RCV_VAL,
                 TO_NUMBER (0) RTN_ISU_QTY,
                 TO_NUMBER (0) RTN_ISU_VAL,
                 TO_NUMBER (0) INT_ORG_RCV_QTY,
                 TO_NUMBER (0) INT_ORG_RCV_VAL,
                 TO_NUMBER (0) SUB_INV_RCV_QTY,
                 TO_NUMBER (0) SUB_INV_RCV_VAL,
                 TO_NUMBER (0) RCV_QTY,
                 TO_NUMBER (0) RCV_VAL,
                 ISU.INT_ORG_ISU_QTY,
                 ISU.INT_ORG_ISU_VAL,
                 ISU.SUB_INV_ISU_QTY,
                 ISU.SUB_INV_ISU_VAL,
                 ISU.ISU_QTY,
                 ISU.ISU_VAL,
                 TO_NUMBER (0) MO_ISU_QTY,
                 TO_NUMBER (0) MO_ISU_VAL,
                 TO_NUMBER (0) MSC_RCV_QTY,
                 TO_NUMBER (0) MSC_RCV_VAL,
                 TO_NUMBER (0) CON_QTY,
                 TO_NUMBER (0) CON_VAL
            FROM ITM, ISSUE ISU
           WHERE     1 = 1
                 AND ITM.ORGANIZATION_ID = ISU.ORGANIZATION_ID
                 AND ITM.INVENTORY_ITEM_ID = ISU.INVENTORY_ITEM_ID
                 AND ITM.SECONDARY_INVENTORY = ISU.SUBINVENTORY_CODE
                 AND ISU.ISU_QTY <> 0
          UNION ALL
          SELECT ITM.ORGANIZATION_ID,
                 ITM.ORGANIZATION_NAME,
                 ITM.SECONDARY_INVENTORY,
                 ITM.ITEM_MJR_CAT,
                 ITM.ITEM_MNR_CAT,
                 ITM.INVENTORY_ITEM_ID,
                 ITM.ITEM_CODE,
                 ITM.ITEM_NAME,
                 ITM.UOM,
                 TO_NUMBER (0) PO_RCV_QTY,
                 TO_NUMBER (0) PO_RCV_VAL,
                 TO_NUMBER (0) RTN_ISU_QTY,
                 TO_NUMBER (0) RTN_ISU_VAL,
                 TO_NUMBER (0) INT_ORG_RCV_QTY,
                 TO_NUMBER (0) INT_ORG_RCV_VAL,
                 TO_NUMBER (0) SUB_INV_RCV_QTY,
                 TO_NUMBER (0) SUB_INV_RCV_VAL,
                 TO_NUMBER (0) RCV_QTY,
                 TO_NUMBER (0) RCV_VAL,
                 TO_NUMBER (0) INT_ORG_ISU_QTY,
                 TO_NUMBER (0) INT_ORG_ISU_VAL,
                 TO_NUMBER (0) SUB_INV_ISU_QTY,
                 TO_NUMBER (0) SUB_INV_ISU_VAL,
                 TO_NUMBER (0) ISU_QTY,
                 TO_NUMBER (0) ISU_VAL,
                 CON.MO_ISU_QTY,
                 CON.MO_ISU_VAL,
                 CON.MSC_RCV_QTY,
                 CON.MSC_RCV_VAL,
                 CON.CON_QTY,
                 CON.CON_VAL
            FROM ITM, CON
           WHERE     1 = 1
                 AND ITM.ORGANIZATION_ID = CON.ORGANIZATION_ID
                 AND ITM.INVENTORY_ITEM_ID = CON.INVENTORY_ITEM_ID
                 AND ITM.SECONDARY_INVENTORY = CON.SUBINVENTORY_CODE) MMT
GROUP BY ORGANIZATION_ID,
         ORGANIZATION_NAME,
         SECONDARY_INVENTORY,
         ITEM_MJR_CAT,
         ITEM_MNR_CAT,
         INVENTORY_ITEM_ID,
         ITEM_CODE,
         ITEM_NAME,
         UOM;