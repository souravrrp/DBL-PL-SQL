/* Formatted on 7/8/2020 11:58:55 AM (QP5 v5.287) */
  SELECT ORGANIZATION_CODE,
         ORG_ID,
         ITEM_ID,
         ITEM_CATG,
         ITEM_TYPE,
         -- SUBINV,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         P_UOM,
         S_UOM,
         --  LOT_NUMBER,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         CUSTOMER_NAME,
         --      SUM (OPEN_BAL) OPBAL,
         --   SUM (RCV_QTY) RCVQ,
         ABS (SUM (ISU_QTY) + SUM (RCV_QTY)) NET_SALES
    FROM (SELECT OOD.ORGANIZATION_CODE,
                 MMT.ORGANIZATION_ID ORG_ID,
                 MSI.INVENTORY_ITEM_ID ITEM_ID,
                 MIC.SEGMENT2 AS ITEM_CATG,
                 MIC.SEGMENT3 AS ITEM_TYPE,
                 --   mmt.subinventory_code subinv,
                 mmt.TRANSACTION_DATE,
                 MSI.CONCATENATED_SEGMENTS ITEM_CODE,
                 MSI.DESCRIPTION ITEM_DESCRIPTION,
                 MSI.PRIMARY_UOM_CODE AS P_UOM,
                 MMT.SECONDARY_UOM_CODE AS S_UOM,
                 MTL.LOT_NUMBER AS LOT_NUMBER,
                 MMT.SOURCE_CODE,
                 MMT.ATTRIBUTE1,
                 MMT.ATTRIBUTE2,
                 MMT.ATTRIBUTE3,
                 CUST.CUSTOMER_NAME,
                 --                 DECODE (SIGN (MMT.TRANSACTION_DATE - :P_DATE_FROM),
                 --                         -1, MMT.PRIMARY_QUANTITY,
                 --                         0)
                 --                    OPEN_BAL,
                 --                 DECODE (
                 --                    SIGN (MMT.TRANSACTION_DATE - :P_DATE_FROM),
                 --                    -1,
                 --                    0,
                 NVL (
                    DECODE (SIGN (MMT.PRIMARY_QUANTITY),
                            1, MMT.PRIMARY_QUANTITY),
                    0)
                    RCV_QTY,
                 --                 DECODE (
                 --                    SIGN (MMT.TRANSACTION_DATE - :P_DATE_FROM),
                 --                    -1,
                 --                    0,
                 NVL (
                    DECODE (SIGN (MMT.PRIMARY_QUANTITY),
                            -1, MMT.PRIMARY_QUANTITY),
                    0)
                    ISU_QTY
            FROM INV.MTL_MATERIAL_TRANSACTIONS MMT,
                 APPS.MTL_SYSTEM_ITEMS_B_KFV MSI,
                 APPS.MTL_ITEM_CATEGORIES_V MIC,
                 APPS.MTL_TRANSACTION_LOT_NUMBERS MTLN,
                 APPS.MTL_LOT_NUMBERS MTL,
                 APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
                 APPS.AR_CUSTOMERS CUST
           WHERE     MMT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                 AND MMT.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                 AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                 AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                 AND MMT.TRANSACTION_ID = MTLN.TRANSACTION_ID(+)
                 AND MTLN.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID(+)
                 AND MTLN.ORGANIZATION_ID = MTL.ORGANIZATION_ID(+)
                 AND MTLN.LOT_NUMBER = MTL.LOT_NUMBER(+)
                 AND MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                 AND CUST.CUSTOMER_ID = MMT.ATTRIBUTE1(+)
                 --  AND mmt.source_code IN ('220', '222') --= mgd.disposition_id(+)
                 AND MIC.CATEGORY_SET_ID = 1
                 AND MMT.TRANSACTION_TYPE_ID <> 98
                 AND (LOGICAL_TRANSACTION = 2 OR LOGICAL_TRANSACTION IS NULL)
                 --   AND mmt.organization_id = NVL (:p_org_id, mmt.organization_id)
                 AND MMT.ATTRIBUTE1 = NVL ( :P_CUST, MMT.ATTRIBUTE1)
                 AND MIC.SEGMENT3 = NVL ( :P_ITEM_TYPE, MIC.SEGMENT3)
                 AND MMT.TRANSACTION_DATE BETWEEN :P_DATE_FROM
                                              AND :P_DATE_TO + .999999
                 AND MMT.TRANSACTION_SOURCE_ID IN (522,
                                                   594,
                                                   590,
                                                   592,
                                                   586,
                                                   588)
                 AND MMT.ATTRIBUTE_CATEGORY = 'Distribution Sales')
--AND MSI.CONCATENATED_SEGMENTS = 'TRD00000000000000138')
GROUP BY ORGANIZATION_CODE,
         ORG_ID,
         ITEM_ID,
         ITEM_CATG,
         ITEM_TYPE,
         --  SUBINV,
         SOURCE_CODE,
         ITEM_CODE,
         ITEM_DESCRIPTION,
         P_UOM,
         S_UOM,
         -- LOT_NUMBER,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         CUSTOMER_NAME
--   and msi.CONCATENATED_SEGMENTS ='YRN18S100CTN52120733'