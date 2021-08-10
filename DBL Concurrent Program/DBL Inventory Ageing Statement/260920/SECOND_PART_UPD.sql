/* Formatted on 9/26/2020 5:52:31 PM (QP5 v5.354) */
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
         LOT.LOT_NUMBER,
         LOT.EXPIRY_DATE,
         (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
            FROM INV.MTL_MATERIAL_TRANSACTIONS A, MTL_TRANSACTION_LOT_NUMBERS B
           WHERE     A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                 AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                 AND A.TRANSACTION_ID = B.TRANSACTION_ID(+)
                 AND B.LOT_NUMBER = LOT.LOT_NUMBER
                 AND TRUNC (A.TRANSACTION_DATE) <= :P_TO_DATE + .99999
                 AND SIGN (A.TRANSACTION_QUANTITY) = 1
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
             - (SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                  FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                       MTL_TRANSACTION_LOT_NUMBERS  B
                 WHERE     A.INVENTORY_ITEM_ID = MMT.INVENTORY_ITEM_ID
                       AND A.ORGANIZATION_ID = MMT.ORGANIZATION_ID
                       AND A.transaction_id = B.TRANSACTION_ID(+)
                       AND B.LOT_NUMBER = LOT.LOT_NUMBER
                       AND SIGN (A.TRANSACTION_QUANTITY) = 1
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
                                                         64)),
             0)
             AS "DAYS",
         SUM (NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY))
             QTY
    FROM INV.MTL_MATERIAL_TRANSACTIONS    MMT,
         APPS.MTL_SYSTEM_ITEMS_B_KFV      MSI,
         APPS.MTL_ITEM_CATEGORIES_V       MIC,
         APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
         INV.MTL_PARAMETERS               MP,
         (SELECT MTLN.TRANSACTION_ID,
                 MTLN.INVENTORY_ITEM_ID,
                 MTLN.ORGANIZATION_ID,
                 MTL.LOT_NUMBER,
                 TO_CHAR (
                     DECODE (
                         MTL.ATTRIBUTE_CATEGORY,
                         'Dyes and Chemical Information', TO_TIMESTAMP (
                                                              MTL.ATTRIBUTE2,
                                                              'YYYY-MM-DD:HH24:MI:SS'),
                         NULL),
                     'YYYY/MM/DD')               EXPIRY_DATE,
                 TRUNC (MTL.ORIGINATION_DATE)    ORIGINATION_DATE,
                 MTLN.PRIMARY_QUANTITY           PRIMARY_QUANTITY
            FROM APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                 APPS.MTL_LOT_NUMBERS            MTL
           WHERE     MTLN.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
                 AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID
                 AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER) LOT
   WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
         AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
         AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
         AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
         AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND MP.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND MIC.CATEGORY_SET_ID = 1
         AND PROCESS_ENABLED_FLAG = 'N'
         AND MMT.TRANSACTION_ID = LOT.TRANSACTION_ID(+)
         AND MMT.INVENTORY_ITEM_ID = LOT.INVENTORY_ITEM_ID(+)
         AND MMT.ORGANIZATION_ID = LOT.ORGANIZATION_ID(+)
         --   AND MMT.TRANSACTION_TYPE_ID <> 98
         --   AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
         AND OOD.SET_OF_BOOKS_ID = :P_LEDGER_ID
         AND ( :P_ORG_ID IS NULL OR OOD.ORGANIZATION_ID = :P_ORG_ID)
         AND :P_REPORT_TYPE = 'Details'
         AND ( :P_ITEM_CATEGORY IS NULL OR MIC.SEGMENT2 = :P_ITEM_CATEGORY)
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
         MSI.SECONDARY_UOM_CODE,
         LOT.LOT_NUMBER,
         LOT.EXPIRY_DATE
  HAVING SUM (NVL (LOT.PRIMARY_QUANTITY, MMT.PRIMARY_QUANTITY)) <> 0