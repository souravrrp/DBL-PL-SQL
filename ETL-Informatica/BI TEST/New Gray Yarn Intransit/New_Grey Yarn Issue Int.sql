/* Formatted on 4/4/2020 11:32:37 AM (QP5 v5.287) */
  SELECT ood.organization_code,
         ood.ORGANIZATION_NAME,
         MMT.SUBINVENTORY_CODE,
         MMT.TRANSACTION_UOM,
         MMT.TRANSACTION_DATE,
         TO_CHAR (MMT.TRANSACTION_DATE, 'Month') AS TRANSACTION_MONTH,
         MMT.SOURCE_CODE,
         MTT.TRANSACTION_TYPE_NAME,
         YCAT.YRN_TYPE,
         MSIB.SEGMENT1 ITEMCODE,
         MSIB.DESCRIPTION,
         MLN.ATTRIBUTE1 BRAND,
         MLN.LOT_NUMBER,
         C.CUSTOMER_NAME AS BUYER,
         SUM (MMT.PRIMARY_QUANTITY) QTY_KG,
         ROUND (
              (SUM (MMT.PRIMARY_QUANTITY) * SUM (MMT.NEW_COST))
            / SUM (MMT.PRIMARY_QUANTITY),
            2)
            RATE
    FROM MTL_MATERIAL_TRANSACTIONS MMT,
         MTL_TRANSACTION_TYPES MTT,
         MTL_SYSTEM_ITEMS_B MSIB,
         apps.mtl_transaction_lot_numbers mlt,
         APPS.mtl_lot_numbers MLN,
         apps.ORG_ORGANIZATION_DEFINITIONS OOD,
         apps.mtl_item_categories_v MIC,
         XXDBL.XXDBL_YRN_CATG YCAT,
         (SELECT TR.TRANSACTION_ID, C.CUSTOMER_NAME
            FROM MTL_MATERIAL_TRANSACTIONS TR, ar_customers C
           WHERE     TO_NUMBER (NVL (TR.ATTRIBUTE2, '0')) = C.CUSTOMER_ID
                 AND TR.ATTRIBUTE_CATEGORY = 'Grey Yarn Issue for Knitting') C
   WHERE     TO_DATE (MMT.TRANSACTION_DATE, 'DD/MM/RRRR hh12:mi:ssAM') BETWEEN TO_DATE (
                                                                                  :p_StartDate,
                                                                                  'DD/MM/RRRR hh12:mi:ssAM')
                                                                           AND TO_DATE (
                                                                                  :p_EndDate,
                                                                                  'DD/MM/RRRR hh12:mi:ssAM')
         AND MTT.TRANSACTION_TYPE_ID = MMT.TRANSACTION_TYPE_ID
         --  AND MMT.SUBINVENTORY_CODE LIKE 'YR%'
         -- AND MMT.PRIMARY_QUANTITY < 0
         AND MMT.INVENTORY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
         AND MSIB.INVENTORY_ITEM_ID = YCAT.INVENTORY_ITEM_ID(+)
         AND MMT.ORGANIZATION_ID = MSIB.ORGANIZATION_ID
         AND MSIB.organization_id = MIC.organization_id
         AND MSIB.inventory_item_id = MIC.inventory_item_id
         AND MLT.organization_id = mln.organization_id(+)
         AND MLT.inventory_item_id = mln.inventory_item_id(+)
         AND MLT.lot_number = mln.lot_number(+)
         AND mmt.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND MMT.TRANSACTION_ID = MLT.TRANSACTION_ID(+)
         AND MIC.SEGMENT2 = 'RAW MATERIAL'
         AND MIC.SEGMENT3 = 'YARN'
         AND MIC.CATEGORY_SET_ID = 1
         AND MTT.TRANSACTION_TYPE_ID IN (31, 41)
         AND MMT.TRANSACTION_ID = C.TRANSACTION_ID(+)
         --AND MMT.ORGANIZATION_ID <> 206
         AND MMT.SUBINVENTORY_CODE NOT LIKE 'DYR ST%'
GROUP BY ood.organization_code,
         ood.ORGANIZATION_NAME,
         MMT.SUBINVENTORY_CODE,
         MMT.TRANSACTION_UOM,
         MMT.TRANSACTION_DATE,
         MMT.SOURCE_CODE,
         MTT.TRANSACTION_TYPE_NAME,
         MSIB.SEGMENT1,
         MSIB.DESCRIPTION,
         MLN.ATTRIBUTE1,
         MLN.LOT_NUMBER,
         C.CUSTOMER_NAME,
         YCAT.YRN_TYPE