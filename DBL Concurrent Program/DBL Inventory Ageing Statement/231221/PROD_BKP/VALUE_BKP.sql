/* Formatted on 12/12/2021 10:51:52 AM (QP5 v5.374) */
  SELECT ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         -- LOT_NUMBER,
         ITEM_CATG,
         ITEM_TYPE,
         SUM (V_BELOW_30_DAYS)        AS "V_BELOW_30_DAYS",
         SUM (V_SIXTY_DAYS)           AS "V_SIXTY_DAYS",
         SUM (V_NINETY_DAYS)          AS "V_NINETY_DAYS",
         SUM (V_ONE_TWENTY_DAYS)      AS "V_ONE_TWENTY_DAYS",
         SUM (V_ONE_FIFTY_DAYS)       AS "V_ONE_FIFTY_DAYS",
         SUM (V_ONE_EIGHTY_DAYS)      AS "V_ONE_EIGHTY_DAYS",
         SUM (V_THREE_SIXTY_DAYS)     AS "V_THREE_SIXTY_DAYS",
         SUM (V_ABOVE_360_DAYS)       AS "V_ABOVE_360_DAYS",
         SUM (TOTAL_VALUE)            AS "TOTAL_VALUE",
         SUM (Q_BELOW_30_DAYS)        AS "Q_BELOW_30_DAYS",
         SUM (Q_SIXTY_DAYS)           AS "Q_DAYS_60",
         SUM (Q_NINETY_DAYS)          AS "Q_DAYS_90",
         SUM (Q_ONE_TWENTY_DAYS)      AS "Q_DAYS_120",
         SUM (Q_ONE_FIFTY_DAYS)       AS "Q_DAYS_150",
         SUM (Q_ONE_EIGHTY_DAYS)      AS "Q_DAYS_180",
         SUM (Q_THREE_SIXTY_DAYS)     AS "Q_DAYS_360",
         SUM (Q_ABOVE_360_DAYS)       AS "Q_ABOVE_360_DAYS",
         SUM (TOTAL_QTY)              AS "TOTAL_QTY"
    FROM (  SELECT ORGANIZATION_CODE,
                   ORGANIZATION_NAME,
                   OPERATING_UNIT,
                   ITEM_CATG,
                   ITEM_TYPE,
                   ITEM_CODE,
                   ITEM_DESCRIPTION,
                   UOM,
                   --         LOT_NUMBER,
                   CASE WHEN DAYS <= 30 THEN SUM (VALUE) ELSE 0 END
                       V_BELOW_30_DAYS,
                   CASE
                       WHEN (DAYS >= 31 AND DAYS <= 60) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_SIXTY_DAYS,
                   CASE
                       WHEN (DAYS >= 61 AND DAYS <= 90) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_NINETY_DAYS,
                   CASE
                       WHEN (DAYS >= 91 AND DAYS <= 120) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_ONE_TWENTY_DAYS,
                   CASE
                       WHEN (DAYS >= 121 AND DAYS <= 150) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_ONE_FIFTY_DAYS,
                   CASE
                       WHEN (DAYS >= 151 AND DAYS <= 180) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_ONE_EIGHTY_DAYS,
                   CASE
                       WHEN (DAYS >= 181 AND DAYS <= 360) THEN SUM (VALUE)
                       ELSE 0
                   END
                       V_THREE_SIXTY_DAYS,
                   CASE WHEN DAYS >= 361 THEN SUM (VALUE) ELSE 0 END
                       V_ABOVE_360_DAYS,
                   SUM (VALUE)
                       TOTAL_VALUE,
                   CASE WHEN DAYS <= 30 THEN SUM (QTY) ELSE 0 END
                       Q_BELOW_30_DAYS,
                   CASE
                       WHEN (DAYS >= 31 AND DAYS <= 60) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_SIXTY_DAYS,
                   CASE
                       WHEN (DAYS >= 61 AND DAYS <= 90) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_NINETY_DAYS,
                   CASE
                       WHEN (DAYS >= 91 AND DAYS <= 120) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_ONE_TWENTY_DAYS,
                   CASE
                       WHEN (DAYS >= 121 AND DAYS <= 150) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_ONE_FIFTY_DAYS,
                   CASE
                       WHEN (DAYS >= 151 AND DAYS <= 180) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_ONE_EIGHTY_DAYS,
                   CASE
                       WHEN (DAYS >= 181 AND DAYS <= 360) THEN SUM (QTY)
                       ELSE 0
                   END
                       Q_THREE_SIXTY_DAYS,
                   CASE WHEN DAYS >= 361 THEN SUM (QTY) ELSE 0 END
                       Q_ABOVE_360_DAYS,
                   SUM (QTY)
                       TOTAL_QTY
              FROM (  SELECT OOD.ORGANIZATION_CODE,
                             OOD.ORGANIZATION_NAME,
                             OOD.OPERATING_UNIT,
                             MMT.ORGANIZATION_ID
                                 ORG_ID,
                             MSI.INVENTORY_ITEM_ID
                                 ITEM_ID,
                             MSI.CONCATENATED_SEGMENTS
                                 ITEM_CODE,
                             MSI.DESCRIPTION
                                 ITEM_DESCRIPTION,
                             MIC.SEGMENT2
                                 AS ITEM_CATG,
                             MIC.SEGMENT3
                                 AS ITEM_TYPE,
                             MSI.PRIMARY_UOM_CODE
                                 AS UOM,
                             MSI.SECONDARY_UOM_CODE
                                 AS S_UOM,
                             --        MMT.SUBINVENTORY_CODE SUBINV,
                             LOT.LOT_NUMBER,
                             (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                          '30-SEP-2017')
                                FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                                     MTL_TRANSACTION_LOT_NUMBERS b
                               WHERE     A.transaction_id = b.transaction_id(+)
                                     AND A.INVENTORY_ITEM_ID =
                                         MMT.INVENTORY_ITEM_ID
                                     AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                                     AND A.SUBINVENTORY_CODE =
                                         MMT.SUBINVENTORY_CODE
                                     AND LOT.LOT_NUMBER = B.LOT_NUMBER(+)
                                     AND SIGN (a.TRANSACTION_QUANTITY) = 1
                                     AND A.TRANSACTION_TYPE_ID != 42
                                     AND A.TRANSACTION_TYPE_ID IN (3,
                                                                   18,
                                                                   41,
                                                                   44)
                                     AND TRUNC (A.TRANSACTION_DATE) <=
                                         :P_TO_DATE + .99999
                                     AND A.TRANSACTION_TYPE_ID NOT IN (2,
                                                                       80,
                                                                       98,
                                                                       50,
                                                                       51,
                                                                       53,
                                                                       99,
                                                                       120,
                                                                       52,
                                                                       26,
                                                                       64))
                                 AS ORIGINATION_DATE,
                             ROUND (
                                   :P_TO_DATE
                                 - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                                '30-SEP-2017')
                                      FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                                           MTL_TRANSACTION_LOT_NUMBERS b
                                     WHERE     A.transaction_id =
                                               b.transaction_id(+)
                                           AND A.INVENTORY_ITEM_ID =
                                               MMT.INVENTORY_ITEM_ID
                                           AND A.ORGANIZATION_ID =
                                               MMT.ORGANIZATION_ID
                                           AND A.SUBINVENTORY_CODE =
                                               MMT.SUBINVENTORY_CODE
                                           AND LOT.LOT_NUMBER = B.LOT_NUMBER(+)
                                           AND SIGN (a.TRANSACTION_QUANTITY) = 1
                                           AND (   LOGICAL_TRANSACTION = 2
                                                OR LOGICAL_TRANSACTION IS NULL)
                                           AND TRUNC (A.TRANSACTION_DATE) <=
                                               :P_TO_DATE + .99999
                                           AND A.TRANSACTION_TYPE_ID NOT IN (2,
                                                                             80,
                                                                             98,
                                                                             50,
                                                                             51,
                                                                             53,
                                                                             99,
                                                                             120,
                                                                             52,
                                                                             26,
                                                                             64)),
                                 0)
                                 AS "DAYS",
                             ITEM_COST,
                             SUM (NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY))
                                 QTY,
                             ROUND (
                                   ITEM_COST
                                 * SUM (
                                       NVL (LOT.PRIMARY_QUANTITY,
                                            MMT.PRIMARY_QUANTITY)),
                                 2)
                                 VALUE
                        FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                             APPS.MTL_SYSTEM_ITEMS_B_KFV  MSI,
                             APPS.MTL_ITEM_CATEGORIES_V   MIC,
                             APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                             INV.MTL_PARAMETERS           MP,
                             (SELECT MTLN.TRANSACTION_ID,
                                     MTLN.INVENTORY_ITEM_ID,
                                     MTLN.ORGANIZATION_ID,
                                     MTL.LOT_NUMBER,
                                     TRUNC (MTL.ORIGINATION_DATE)
                                         ORIGINATION_DATE,
                                     MTLN.PRIMARY_QUANTITY
                                         PRIMARY_QUANTITY
                                FROM APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                                     APPS.MTL_LOT_NUMBERS        MTL
                               WHERE     MTLN.INVENTORY_ITEM_ID =
                                         MTL.INVENTORY_ITEM_ID
                                     AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID
                                     AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER) LOT,
                             (  SELECT PERIOD_ID,
                                       INVENTORY_ITEM_ID,
                                       ORGANIZATION_ID,
                                       SUM (CMPNT_COST)     ITEM_COST
                                  FROM CM_CMPT_DTL
                              GROUP BY PERIOD_ID,
                                       INVENTORY_ITEM_ID,
                                       ORGANIZATION_ID) CST,
                             CM_CLDR_MST_V                CLND
                       WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                             AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                             AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                             AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                             AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                             AND LOT.TRANSACTION_ID(+) = MMT.TRANSACTION_ID
                             AND MMT.INVENTORY_ITEM_ID = LOT.INVENTORY_ITEM_ID(+)
                             AND MMT.ORGANIZATION_ID = LOT.ORGANIZATION_ID(+)
                             AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                             AND MMT.INVENTORY_ITEM_ID = CST.INVENTORY_ITEM_ID
                             AND MMT.ORGANIZATION_ID = CST.ORGANIZATION_ID
                             AND CST.PERIOD_ID = CLND.PERIOD_ID
                             AND OOD.LEGAL_ENTITY = CLND.LEGAL_ENTITY_ID
                             -- AND CLND.PERIOD_CODE =
                             --      TO_CHAR (TRUNC (MMT.TRANSACTION_DATE), 'MON-YY')
                             AND CLND.PERIOD_CODE = TO_CHAR ( :P_TO_DATE, 'MON-YY')
                             AND MIC.CATEGORY_SET_ID = 1
                             AND PROCESS_ENABLED_FLAG = 'Y'
                             AND :P_REPORT_TYPE = 'Value'
                             --   AND MMT.TRANSACTION_TYPE_ID <> 98
                             AND (   MMT.LOGICAL_TRANSACTION = 2
                                  OR MMT.LOGICAL_TRANSACTION IS NULL)
                             AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                             AND (   :P_ORG_ID IS NULL
                                  OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                             AND (   :P_SUB_INVENTORY IS NULL
                                  OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                             AND (   :P_ITEM_CATEGORY IS NULL
                                  OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                             AND (   :P_ITEM_TYPE IS NULL
                                  OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                             AND TRUNC (MMT.TRANSACTION_DATE) <=
                                 :P_TO_DATE + .99999
                    --   AND MSI.LOT_CONTROL_CODE = 2
                    --     AND MSI.INVENTORY_ITEM_ID = 5106
                    GROUP BY OOD.ORGANIZATION_CODE,
                             OOD.ORGANIZATION_NAME,
                             MMT.ORGANIZATION_ID,
                             MMT.INVENTORY_ITEM_ID,
                             MSI.INVENTORY_ITEM_ID,
                             OOD.OPERATING_UNIT,
                             MIC.SEGMENT2,
                             MIC.SEGMENT3,
                             MMT.SUBINVENTORY_CODE,
                             MSI.CONCATENATED_SEGMENTS,
                             MSI.DESCRIPTION,
                             MSI.PRIMARY_UOM_CODE,
                             MSI.SECONDARY_UOM_CODE,
                             LOT.LOT_NUMBER,
                             LOT.ORIGINATION_DATE,
                             ITEM_COST
                      HAVING SUM (
                                 NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY)) <>
                             0
                    UNION
                      SELECT OOD.ORGANIZATION_CODE,
                             OOD.ORGANIZATION_NAME,
                             OOD.OPERATING_UNIT,
                             MMT.ORGANIZATION_ID
                                 ORG_ID,
                             MSI.INVENTORY_ITEM_ID
                                 ITEM_ID,
                             MSI.CONCATENATED_SEGMENTS
                                 ITEM_CODE,
                             MSI.DESCRIPTION
                                 ITEM_DESCRIPTION,
                             MIC.SEGMENT2
                                 AS ITEM_CATG,
                             MIC.SEGMENT3
                                 AS ITEM_TYPE,
                             MSI.PRIMARY_UOM_CODE
                                 AS UOM,
                             MSI.SECONDARY_UOM_CODE
                                 AS S_UOM,
                             NULL
                                 LOT_NUMBER,
                             (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                          '30-SEP-2017')
                                FROM INV.MTL_MATERIAL_TRANSACTIONS A
                               WHERE     A.INVENTORY_ITEM_ID =
                                         MMT.INVENTORY_ITEM_ID
                                     AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                                     AND A.SUBINVENTORY_CODE =
                                         MMT.SUBINVENTORY_CODE
                                     AND SIGN (TRANSACTION_QUANTITY) = 1
                                     AND A.TRANSACTION_TYPE_ID != 42
                                     AND A.TRANSACTION_TYPE_ID IN (3, 18)
                                     AND TRUNC (A.TRANSACTION_DATE) <=
                                         :P_TO_DATE + .99999
                                     AND A.TRANSACTION_TYPE_ID NOT IN (2,
                                                                       80,
                                                                       98,
                                                                       50,
                                                                       51,
                                                                       53,
                                                                       99,
                                                                       120,
                                                                       52,
                                                                       26,
                                                                       64))
                                 AS LAST_RECEIVE_DATE,
                             ROUND (
                                   :P_TO_DATE
                                 - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                                '30-SEP-2017')
                                      FROM INV.MTL_MATERIAL_TRANSACTIONS A
                                     WHERE     A.INVENTORY_ITEM_ID =
                                               MMT.INVENTORY_ITEM_ID
                                           AND A.ORGANIZATION_ID =
                                               MMT.ORGANIZATION_ID
                                           AND A.SUBINVENTORY_CODE =
                                               MMT.SUBINVENTORY_CODE
                                           AND TRUNC (A.TRANSACTION_DATE) <=
                                               :P_TO_DATE + .99999
                                           AND SIGN (TRANSACTION_QUANTITY) = 1
                                           AND (   LOGICAL_TRANSACTION = 2
                                                OR LOGICAL_TRANSACTION IS NULL)
                                           AND A.TRANSACTION_TYPE_ID NOT IN (2,
                                                                             80,
                                                                             98,
                                                                             50,
                                                                             51,
                                                                             53,
                                                                             99,
                                                                             120,
                                                                             52,
                                                                             26,
                                                                             64)),
                                 0)
                                 AS "DAYS",
                               --                             MMT.ACTUAL_COST ITEM_COST,
                               --                             SUM (MMT.PRIMARY_QUANTITY) QTY,
                               --                             ROUND (MMT.ACTUAL_COST * SUM (MMT.PRIMARY_QUANTITY),
                               --                                    2)
                               --                                VALUE
                               APPS.XX_INV_TRAN_VAL (MMT.INVENTORY_ITEM_ID,
                                                     MMT.ORGANIZATION_ID,
                                                     'C',
                                                     '01-JAN-1951',
                                                     :P_TO_DATE)
                             / SUM (MMT.PRIMARY_QUANTITY)
                                 ITEM_COST,
                             SUM (MMT.PRIMARY_QUANTITY)
                                 QTY,
                             APPS.XX_INV_TRAN_VAL (MMT.INVENTORY_ITEM_ID,
                                                   MMT.ORGANIZATION_ID,
                                                   'C',
                                                   '01-JAN-1951',
                                                   :P_TO_DATE)
                                 VALUE
                        FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                             APPS.MTL_SYSTEM_ITEMS_B_KFV  MSI,
                             APPS.MTL_ITEM_CATEGORIES_V   MIC,
                             APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                             INV.MTL_PARAMETERS           MP
                       WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                             AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                             AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                             AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                             AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                             AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                             AND MIC.CATEGORY_SET_ID = 1
                             AND PROCESS_ENABLED_FLAG = 'N'
                             AND MMT.TRANSACTION_TYPE_ID <> 80
                             --   AND MMT.TRANSACTION_TYPE_ID <> 98
                             AND (   LOGICAL_TRANSACTION = 2
                                  OR LOGICAL_TRANSACTION IS NULL)
                             AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                             AND (   :P_ORG_ID IS NULL
                                  OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                             AND (   :P_SUB_INVENTORY IS NULL
                                  OR MMT.SUBINVENTORY_CODE = :P_SUB_INVENTORY)
                             AND :P_REPORT_TYPE = 'Value'
                             AND (   :P_ITEM_CATEGORY IS NULL
                                  OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                             AND (   :P_ITEM_TYPE IS NULL
                                  OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                             AND TRUNC (MMT.TRANSACTION_DATE) <=
                                 :P_TO_DATE + .99999
                    GROUP BY OOD.ORGANIZATION_CODE,
                             OOD.ORGANIZATION_NAME,
                             OOD.OPERATING_UNIT,
                             MMT.SUBINVENTORY_CODE,
                             MMT.ORGANIZATION_ID,
                             MSI.INVENTORY_ITEM_ID,
                             MMT.INVENTORY_ITEM_ID,
                             MSI.CONCATENATED_SEGMENTS,
                             MSI.DESCRIPTION,
                             MIC.SEGMENT2,
                             MIC.SEGMENT3,
                             MSI.PRIMARY_UOM_CODE,
                             MSI.SECONDARY_UOM_CODE                        --,
                      --MMT.ACTUAL_COST
                      HAVING SUM (MMT.PRIMARY_QUANTITY) <> 0)
          GROUP BY ORGANIZATION_CODE,
                   ORGANIZATION_NAME,
                   OPERATING_UNIT,
                   ITEM_CATG,
                   ITEM_TYPE,
                   ITEM_CODE,
                   ITEM_DESCRIPTION,
                   --        LOT_NUMBER,
                   UOM,
                   DAYS)
GROUP BY ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         ITEM_CATG,
         ITEM_TYPE