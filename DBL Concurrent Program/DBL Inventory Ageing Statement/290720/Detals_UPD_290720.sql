/* Formatted on 2/2/2020 2:19:08 PM (QP5 v5.287) */
  SELECT ORGANIZATION_CODE,
         ORGANIZATION_NAME,
         OPERATING_UNIT,
         ITEM_CATG,
         ITEM_TYPE,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         UOM,
         TO_CHAR (LOT_NUMBER)                    LOT_NUMBER,
         ORIGINATION_DATE LAST_RCV_DATE,
         LAST_ISSUE_DATE LAST_ISSUE_DATE,
         TO_DATE (EXPIRY_DATE, 'YYYY/MM/DD') EXPIRY_DATE,
         CEIL(((APPS.XX_COM_PKG.GET_SECCOND_FROM_TIME_DIFF(SYSDATE,TO_DATE (EXPIRY_DATE, 'YYYY/MM/DD')))/3600)/24) REMAINING_DAYS,
         DAYS,
         SUM (QTY) TOTAL_QTY
    FROM (  SELECT OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MSI.SECONDARY_UOM_CODE AS S_UOM,
                   --        MMT.SUBINVENTORY_CODE SUBINV,
                   LOT.LOT_NUMBER,
                   LOT.EXPIRY_DATE,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                           MTL_TRANSACTION_LOT_NUMBERS b
                     WHERE     A.transaction_id = b.transaction_id(+)
                           AND A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                           AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                           AND LOT.LOT_NUMBER = B.LOT_NUMBER
                           AND SIGN (a.TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <= :P_TO_DATE + .99999
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
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM INV.MTL_MATERIAL_TRANSACTIONS A
                     WHERE     TRANSACTION_TYPE_ID IN (35, 31)
                           AND A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                           AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                           AND TRUNC (A.TRANSACTION_DATE) <= :P_TO_DATE + .99999)
                      AS LAST_ISSUE_DATE,
                   ROUND (
                        :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                                MTL_TRANSACTION_LOT_NUMBERS b
                          WHERE     A.transaction_id = b.transaction_id(+)
                                AND A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                                AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                                AND LOT.LOT_NUMBER = B.LOT_NUMBER
                                AND SIGN (a.TRANSACTION_QUANTITY) = 1
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
                   SUM (NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY)) QTY
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                   INV.MTL_PARAMETERS MP,
                   (SELECT MTLN.TRANSACTION_ID,
                           MTLN.INVENTORY_ITEM_ID,
                           MTLN.ORGANIZATION_ID,
                           MTL.LOT_NUMBER,
                           MTL.ATTRIBUTE2                   EXPIRY_DATE,
                           TRUNC (MTL.ORIGINATION_DATE) ORIGINATION_DATE,
                           MTLN.PRIMARY_QUANTITY PRIMARY_QUANTITY
                      FROM APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                           APPS.MTL_LOT_NUMBERS MTL
                     WHERE     MTLN.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
                           AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID
                           AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER) LOT
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND LOT.TRANSACTION_ID(+) = MMT.TRANSACTION_ID
                   AND MMT.INVENTORY_ITEM_ID = LOT.INVENTORY_ITEM_ID(+)
                   AND MMT.ORGANIZATION_ID = LOT.ORGANIZATION_ID(+)
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MIC.CATEGORY_SET_ID = 1
                   AND PROCESS_ENABLED_FLAG = 'Y'
                   AND :P_REPORT_TYPE = 'Details'
                   --   AND MMT.TRANSACTION_TYPE_ID <> 98
                   --    AND (MMT.LOGICAL_TRANSACTION = 2 OR MMT.LOGICAL_TRANSACTION IS NULL)
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND ( :P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND (   :P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND ( :P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + .99999
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
                   -- MMT.SUBINVENTORY_CODE,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MSI.PRIMARY_UOM_CODE,
                   MSI.SECONDARY_UOM_CODE,
                   LOT.LOT_NUMBER,
                   LOT.EXPIRY_DATE,
                   LOT.ORIGINATION_DATE
            HAVING SUM (NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY)) <> 0
          UNION
            SELECT OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID ORG_ID,
                   MSI.INVENTORY_ITEM_ID ITEM_ID,
                   MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                   MSI.DESCRIPTION ITEM_DESCRIPTION,
                   MIC.SEGMENT2 AS ITEM_CATG,
                   MIC.SEGMENT3 AS ITEM_TYPE,
                   MSI.PRIMARY_UOM_CODE AS UOM,
                   MSI.SECONDARY_UOM_CODE AS S_UOM,
                   NULL LOT_NUMBER,
                   NULL EXPIRY_DATE,
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM INV.MTL_MATERIAL_TRANSACTIONS A
                     WHERE     A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                           AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                           AND TRUNC (A.TRANSACTION_DATE) <= :P_TO_DATE + .99999
                           AND SIGN (TRANSACTION_QUANTITY) = 1
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
                   (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM INV.MTL_MATERIAL_TRANSACTIONS A
                     WHERE     TRANSACTION_TYPE_ID = 63
                           AND A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                           AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID)
                      AS LAST_ISSUE_DATE,
                   ROUND (
                        :P_TO_DATE
                      - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)),
                                     '30-SEP-2017')
                           FROM INV.MTL_MATERIAL_TRANSACTIONS A
                          WHERE     A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                                AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                                AND SIGN (TRANSACTION_QUANTITY) = 1
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
                   SUM (MMT.PRIMARY_QUANTITY) QTY
              FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                   APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                   APPS.MTL_ITEM_CATEGORIES_V MIC,
                   APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                   INV.MTL_PARAMETERS MP
             WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                   AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                   AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                   AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                   AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                   AND MIC.CATEGORY_SET_ID = 1
                   AND PROCESS_ENABLED_FLAG = 'N'
                   --   AND MMT.TRANSACTION_TYPE_ID <> 98
                   --   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                   AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
                   AND ( :P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
                   AND :P_REPORT_TYPE = 'Details'
                   AND (   :P_ITEM_CATEGORY IS NULL
                        OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
                   AND ( :P_ITEM_TYPE IS NULL OR MIC.SEGMENT3 = :P_ITEM_TYPE)
                   AND TRUNC (MMT.TRANSACTION_DATE) <= :P_TO_DATE + .99999
          GROUP BY OOD.ORGANIZATION_CODE,
                   OOD.ORGANIZATION_NAME,
                   OOD.OPERATING_UNIT,
                   MMT.ORGANIZATION_ID,
                   MSI.INVENTORY_ITEM_ID,
                   MMT.INVENTORY_ITEM_ID,
                   MSI.CONCATENATED_SEGMENTS,
                   MSI.DESCRIPTION,
                   MIC.SEGMENT2,
                   MIC.SEGMENT3,
                   MSI.PRIMARY_UOM_CODE,
                   MSI.SECONDARY_UOM_CODE
            HAVING SUM (MMT.PRIMARY_QUANTITY) <> 0)
GROUP BY ORGANIZATION_CODE,
         ORGANIZATION_NAME,
         OPERATING_UNIT,
         ITEM_CATG,
         ITEM_TYPE,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         LOT_NUMBER,
         ORIGINATION_DATE,
         UOM,
         EXPIRY_DATE,
         DAYS,
         LAST_ISSUE_DATE;