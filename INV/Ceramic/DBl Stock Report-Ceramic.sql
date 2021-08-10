/* Formatted on 10/1/2020 9:25:21 AM (QP5 v5.287) */
SELECT OOD.ORGANIZATION_CODE,
       MMT.ORGANIZATION_ID ORG_ID,
       MSI.INVENTORY_ITEM_ID ITEM_ID,
       MIC.SEGMENT2 AS ITEM_SIZE,
       MSI.ATTRIBUTE3 AS ITEM_TYPE,
       MSI.CONCATENATED_SEGMENTS ITEM_CODE,
       MSI.DESCRIPTION ITEM_DESCRIPTION,
       MSI.PRIMARY_UOM_CODE AS P_UOM,
       MMT.SECONDARY_UOM_CODE AS S_UOM,
       TRUNC (MLT.ORIGINATION_DATE) PROD_DATE,
       MLT.GRADE_CODE,
       MLT.LOT_NUMBER,
       CASE SIGN (TRUNC (MMT.TRANSACTION_DATE) - ( :P_DATE_FROM - .99999))
          WHEN -1 THEN MTLN.PRIMARY_QUANTITY
          ELSE 0
       END
          OPEN_BAL_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
          ELSE 0
       END
          OPEN_BAL_S,
       --                 CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
       --                    WHEN -1
       --                    THEN
       --                       0
       --                    ELSE
       --                       CASE MTLN.TRANSACTION_SOURCE_TYPE_ID
       --                          WHEN 5 THEN MTLN.PRIMARY_QUANTITY
       --                          ELSE 0
       --                       END
       --                 END
       --                    RCV_QTY_PROD_P,
       CASE SIGN (mtln.transaction_date - :p_date_from)
          WHEN -1
          THEN
             0
          ELSE
             CASE
                WHEN mmt.transaction_type_id IN (17, 44)
                THEN
                   mtln.primary_quantity
                ELSE
                   0
             END
       END
          rcv_qty_prod_p,
       --                 CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
       --                    WHEN -1
       --                    THEN
       --                       0
       --                    ELSE
       --                       CASE MTLN.TRANSACTION_SOURCE_TYPE_ID
       --                          WHEN 5 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
       --                          ELSE 0
       --                       END
       --                 END
       --                    RCV_QTY_PROD_S,
       CASE SIGN (mtln.transaction_date - :p_date_from)
          WHEN -1
          THEN
             0
          ELSE
             CASE
                WHEN mmt.transaction_type_id IN (17, 44)
                THEN
                   mtln.secondary_transaction_quantity
                ELSE
                   0
             END
       END
          rcv_qty_prod_s,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 42 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          RCV_QTY_MISC_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 42 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          RCV_QTY_MISC_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 15 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          RCV_QTY_RMA_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 15 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          RCV_QTY_RMA_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 33 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          SALES_QTY_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 33 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          SALES_QTY_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 864 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          BROKEN_QTY_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 864 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          BROKEN_QTY_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 32 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          ISSU_QTY_MISC_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_TYPE_ID
                WHEN 32 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          ISSU_QTY_MISC_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 884 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          SAMPLE_QTY_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 884 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          SAMPLE_QTY_S,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 904 THEN MTLN.PRIMARY_QUANTITY
                ELSE 0
             END
       END
          BROKEN_REC_QTY_P,
       CASE SIGN (MTLN.TRANSACTION_DATE - :P_DATE_FROM)
          WHEN -1
          THEN
             0
          ELSE
             CASE MMT.TRANSACTION_SOURCE_ID
                WHEN 904 THEN MTLN.SECONDARY_TRANSACTION_QUANTITY
                ELSE 0
             END
       END
          BROKEN_REC_QTY_S
  FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
       INV.MTL_TRANSACTION_LOT_NUMBERS MTLN,
       INV.MTL_LOT_NUMBERS MLT,
       APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
       APPS.MTL_ITEM_CATEGORIES_V MIC,
       APPS.ORG_ORGANIZATION_DEFINITIONS OOD
 WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
       AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
       AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
       AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
       AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       AND MMT.INVENTORY_ITEM_ID = MTLN.INVENTORY_ITEM_ID
       AND MMT.ORGANIZATION_ID = MTLN.ORGANIZATION_ID
       AND MMT.TRANSACTION_ID = MTLN.TRANSACTION_ID
       AND MLT.INVENTORY_ITEM_ID = MTLN.INVENTORY_ITEM_ID
       AND MLT.ORGANIZATION_ID = MTLN.ORGANIZATION_ID
       AND MLT.LOT_NUMBER = MTLN.LOT_NUMBER
       AND MIC.CATEGORY_SET_ID = 1100000061
       AND MMT.TRANSACTION_TYPE_ID <> 98
       AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
       AND MMT.TRANSACTION_TYPE_ID NOT IN (80,
                                           98,
                                           99,
                                           120,
                                           52,
                                           26,
                                           64)
       AND MMT.SUBINVENTORY_CODE IN ('CEM-REJECT', 'CEM-STAG', 'CEM-SAMPLE')
       AND MMT.ORGANIZATION_ID = 152
       AND MTLN.TRANSACTION_DATE BETWEEN '01-JAN-2010'
                                     AND :P_DATE_TO + .99999
       AND MSI.INVENTORY_ITEM_ID IN (456216)
       AND (CASE SIGN (mtln.transaction_date - :p_date_from)
               WHEN -1
               THEN
                  0
               ELSE
                  CASE
                     WHEN mmt.transaction_type_id IN (17, 44)
                     THEN
                        mtln.primary_quantity
                     ELSE
                        0
                  END
            END) > 0