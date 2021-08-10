SELECT ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         ITEM_CATG,
         ITEM_TYPE,
         LOT_NUMBER,
         CASE WHEN DAYS <= 30 THEN SUM (QTY) ELSE 0 END BELOW_30_DAYS,
         CASE WHEN (DAYS >= 31 AND DAYS <= 60) THEN SUM (QTY) ELSE 0 END
            SIXTY_DAYS,
         CASE WHEN (DAYS >= 61 AND DAYS <= 90) THEN SUM (QTY) ELSE 0 END
            NINETY_DAYS,
         CASE WHEN (DAYS >= 91 AND DAYS <= 120) THEN SUM (QTY) ELSE 0 END
            ONE_TWENTY_DAYS,
         CASE WHEN (DAYS >= 121 AND DAYS <= 150) THEN SUM (QTY) ELSE 0 END
            ONE_FIFTY_DAYS,
         CASE WHEN (DAYS >= 151 AND DAYS <= 180) THEN SUM (QTY) ELSE 0 END
            ONE_EIGHTY_DAYS,
         CASE WHEN (DAYS >= 181 AND DAYS <= 360) THEN SUM (QTY) ELSE 0 END
            THREE_SIXTY_DAYS,
         CASE WHEN DAYS >= 361 THEN SUM (QTY) ELSE 0 END ABOVE_360_DAYS
    FROM (  SELECT '1#OPMLOT',
                   OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM MTL_TRANSACTION_LOT_NUMBERS a
                     WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                           AND a.organization_id = mtln.ORGANIZATION_ID
                           AND lot_number = mtln.lot_number
                           AND SIGN (TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_RCV_DATE,
                   (SELECT MAX (TRUNC (A.TRANSACTION_DATE))
                      FROM MTL_TRANSACTION_LOT_NUMBERS a
                     WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                           AND a.organization_id = mtln.ORGANIZATION_ID
                           AND lot_number = mtln.lot_number
                           AND SIGN (TRANSACTION_QUANTITY) = -1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_ISSUE_DATE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MMT.SECONDARY_UOM_CODE AS S_UOM,
                   MTL.LOT_NUMBER AS LOT_NUMBER,
                   ROUND (
                      :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM MTL_TRANSACTION_LOT_NUMBERS a
                          WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                                AND a.organization_id = mtln.ORGANIZATION_ID
                                AND lot_number = mtln.lot_number
                                AND SIGN (TRANSACTION_QUANTITY) = 1
                                AND TRUNC (A.TRANSACTION_DATE) <=
                                      :P_TO_DATE + 8399 / 8400),
                      0)
                      AS "DAYS",
                   SUM (MTLN.PRIMARY_QUANTITY) QTY,
                   ROUND (SUM (ITEM_COST) * SUM (MTLN.PRIMARY_QUANTITY), 2) VALUE
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                   APPS.MTL_LOT_NUMBERS MTL,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                   (  SELECT PERIOD_ID,
                             INVENTORY_ITEM_ID,
                             ORGANIZATION_ID,
                             SUM (CMPNT_COST) ITEM_COST
                        FROM CM_CMPT_DTL
                    GROUP BY PERIOD_ID, INVENTORY_ITEM_ID, ORGANIZATION_ID) CST,
                   CM_CLDR_MST_V CLND
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MMT.TRANSACTION_ID = MTLN.TRANSACTION_ID
                   AND MTLN.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
                   AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID
                   AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MMT.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = CST.ORGANIZATION_ID
                   AND CST.PERIOD_ID = CLND.PERIOD_ID
                   AND MIC.CATEGORY_SET_ID = 1
                   AND MSI.LOT_CONTROL_CODE = 2
                   AND MMT.TRANSACTION_TYPE_ID NOT IN
                            (64, 120, 96, 50, 5, 9, 2, 51, 66, 67, 68, 80)
                   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                   AND CLND.PERIOD_CODE = TO_CHAR (:P_TO_DATE, 'MON-YY')
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND (:P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND:P_REPORT_TYPE = 'Quantity'
                   AND (:P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND (:P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + 8399 / 8400
          GROUP BY OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID,
                   MSI.INVENTORY_ITEM_ID,
                   MIC.SEGMENT2,
                   MIC.SEGMENT3,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MSI.PRIMARY_UOM_CODE,
                   MMT.SECONDARY_UOM_CODE,
                   MTL.LOT_NUMBER,
                   mtln.lot_number,
                   mtln.INVENTORY_ITEM_ID,
                   mtln.ORGANIZATION_ID
            HAVING SUM (MTLN.PRIMARY_QUANTITY) <> 0
          UNION
            SELECT '2#OPMNOLOT',
                   OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM MTL_MATERIAL_TRANSACTIONS a
                     WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                           AND a.organization_id = mmt.ORGANIZATION_ID
                           AND SIGN (TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_RCV_DATE,
                   (SELECT MAX (TRUNC (A.TRANSACTION_DATE))
                      FROM MTL_MATERIAL_TRANSACTIONS a
                     WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                           AND a.organization_id = mmt.ORGANIZATION_ID
                           AND SIGN (TRANSACTION_QUANTITY) = -1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_ISSUE_DATE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MMT.SECONDARY_UOM_CODE AS S_UOM,
                   NULL AS LOT_NUMBER,
                   ROUND (
                      :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM MTL_MATERIAL_TRANSACTIONS a
                          WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                                AND a.organization_id = mmt.ORGANIZATION_ID
                                AND SIGN (TRANSACTION_QUANTITY) = 1
                                AND TRUNC (A.TRANSACTION_DATE) <=
                                      :P_TO_DATE + 8399 / 8400),
                      0)
                      AS "DAYS",
                   SUM (MMT.PRIMARY_QUANTITY) QTY,
                   ROUND (SUM (ITEM_COST) * SUM (MMT.PRIMARY_QUANTITY), 2) VALUE
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                   (  SELECT PERIOD_ID,
                             INVENTORY_ITEM_ID,
                             ORGANIZATION_ID,
                             SUM (CMPNT_COST) ITEM_COST
                        FROM CM_CMPT_DTL
                    GROUP BY PERIOD_ID, INVENTORY_ITEM_ID, ORGANIZATION_ID) CST,
                   CM_CLDR_MST_V CLND
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MMT.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = CST.ORGANIZATION_ID
                   AND CST.PERIOD_ID = CLND.PERIOD_ID
                   AND MSI.LOT_CONTROL_CODE <> 2
                   AND MIC.CATEGORY_SET_ID = 1
                   AND MSI.LOT_CONTROL_CODE = 1
                   AND MMT.TRANSACTION_TYPE_ID NOT IN
                            (64, 120, 96, 50, 5, 9, 2, 51, 66, 67, 68, 80)
                   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                   AND CLND.PERIOD_CODE = TO_CHAR (:P_TO_DATE, 'MON-YY')
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND (:P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND:P_REPORT_TYPE = 'Quantity'
                   AND (:P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND (:P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + 8399 / 8400
          GROUP BY OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID,
                   MSI.INVENTORY_ITEM_ID,
                   MIC.SEGMENT2,
                   MIC.SEGMENT3,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MSI.PRIMARY_UOM_CODE,
                   MMT.SECONDARY_UOM_CODE,
                   mmt.INVENTORY_ITEM_ID,
                   mmt.ORGANIZATION_ID
            HAVING SUM (MMT.PRIMARY_QUANTITY) <> 0
          UNION
            SELECT '3#DISNOLOT',
                   OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM MTL_MATERIAL_TRANSACTIONS a
                     WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                           AND a.organization_id = mmt.ORGANIZATION_ID
                           AND SIGN (TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_RCV_DATE,
                   (SELECT MAX (TRUNC (A.TRANSACTION_DATE))
                      FROM MTL_MATERIAL_TRANSACTIONS a
                     WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                           AND a.organization_id = mmt.ORGANIZATION_ID
                           AND SIGN (TRANSACTION_QUANTITY) = -1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_ISSUE_DATE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MMT.SECONDARY_UOM_CODE AS S_UOM,
                   NULL AS LOT_NUMBER,
                   ROUND (
                      :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM MTL_MATERIAL_TRANSACTIONS a
                          WHERE     a.inventory_item_id = mmt.INVENTORY_ITEM_ID
                                AND a.organization_id = mmt.ORGANIZATION_ID
                                AND SIGN (TRANSACTION_QUANTITY) = 1
                                AND TRUNC (A.TRANSACTION_DATE) <=
                                      :P_TO_DATE + 8399 / 8400),
                      0)
                      AS "DAYS",
                   SUM (MMT.PRIMARY_QUANTITY) QTY,
                   ROUND (SUM (MMT.ACTUAL_COST) * SUM (MMT.PRIMARY_QUANTITY), 2)
                      VALUE
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MIC.CATEGORY_SET_ID = 1
                   AND MSI.LOT_CONTROL_CODE <> 2
                   AND MMT.TRANSACTION_TYPE_ID NOT IN
                            (64, 120, 96, 50, 5, 9, 2, 51, 66, 67, 68, 80)
                   AND MMT.ORGANIZATION_ID IN
                            (SELECT ORGANIZATION_ID
                               FROM MTL_PARAMETERS
                              WHERE PROCESS_ENABLED_FLAG <> 'Y')
                   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND (:P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND:P_REPORT_TYPE = 'Quantity'
                   AND (:P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND (:P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + 8399 / 8400
          GROUP BY OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID,
                   MSI.INVENTORY_ITEM_ID,
                   MIC.SEGMENT2,
                   MIC.SEGMENT3,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MSI.PRIMARY_UOM_CODE,
                   MMT.SECONDARY_UOM_CODE,
                   mmt.INVENTORY_ITEM_ID,
                   mmt.ORGANIZATION_ID
            HAVING SUM (MMT.PRIMARY_QUANTITY) <> 0
          UNION
            SELECT '4#DISLOT',
                   OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM MTL_TRANSACTION_LOT_NUMBERS a
                     WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                           AND a.organization_id = mtln.ORGANIZATION_ID
                           AND lot_number = mtln.lot_number
                           AND SIGN (TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_RCV_DATE,
                   (SELECT MAX (TRUNC (A.TRANSACTION_DATE))
                      FROM MTL_TRANSACTION_LOT_NUMBERS a
                     WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                           AND a.organization_id = mtln.ORGANIZATION_ID
                           AND lot_number = mtln.lot_number
                           AND SIGN (TRANSACTION_QUANTITY) = -1
                           AND TRUNC (A.TRANSACTION_DATE) <=
                                 :P_TO_DATE + 8399 / 8400)
                      LAST_ISSUE_DATE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MMT.SECONDARY_UOM_CODE AS S_UOM,
                   MTL.LOT_NUMBER AS LOT_NUMBER,
                   ROUND (
                      :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM MTL_TRANSACTION_LOT_NUMBERS a
                          WHERE     a.inventory_item_id = mtln.INVENTORY_ITEM_ID
                                AND a.organization_id = mtln.ORGANIZATION_ID
                                AND lot_number = mtln.lot_number
                                AND SIGN (TRANSACTION_QUANTITY) = 1
                                AND TRUNC (A.TRANSACTION_DATE) <=
                                      :P_TO_DATE + 8399 / 8400),
                      0)
                      AS "DAYS",
                   SUM (MTLN.PRIMARY_QUANTITY) QTY,
                   ROUND (SUM (MMT.ACTUAL_COST) * SUM (MTLN.PRIMARY_QUANTITY), 2)
                      VALUE
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                   APPS.MTL_LOT_NUMBERS MTL,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MMT.TRANSACTION_ID = MTLN.TRANSACTION_ID
                   AND MTLN.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
                   AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID
                   AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MIC.CATEGORY_SET_ID = 1
                   AND MSI.LOT_CONTROL_CODE = 2
                   AND MMT.TRANSACTION_TYPE_ID NOT IN
                            (64, 120, 96, 50, 5, 9, 2, 51, 66, 67, 68, 80)
                   AND MMT.ORGANIZATION_ID IN
                            (SELECT ORGANIZATION_ID
                               FROM MTL_PARAMETERS
                              WHERE PROCESS_ENABLED_FLAG <> 'Y')
                   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND (:P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND:P_REPORT_TYPE = 'Quantity'
                   AND (:P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND (:P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + 8399 / 8400
          GROUP BY OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID,
                   MSI.INVENTORY_ITEM_ID,
                   MIC.SEGMENT2,
                   MIC.SEGMENT3,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MSI.PRIMARY_UOM_CODE,
                   MMT.SECONDARY_UOM_CODE,
                   MTL.LOT_NUMBER,
                   mtln.lot_number,
                   mtln.INVENTORY_ITEM_ID,
                   mtln.ORGANIZATION_ID
            HAVING SUM (MTLN.PRIMARY_QUANTITY) <> 0)
GROUP BY ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         ITEM_CATG,
         ITEM_TYPE,
         LOT_NUMBER,
         DAYS