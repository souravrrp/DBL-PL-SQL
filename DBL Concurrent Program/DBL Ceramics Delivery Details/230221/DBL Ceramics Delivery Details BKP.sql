/* Formatted on 2/23/2021 4:49:59 PM (QP5 v5.354) */
  SELECT CUSTOMER_NUMBER,
         CUSTOMER_NAME,
         ORDER_TYPE,
         ORDER_NUMBER,
         ORDERED_DATE,
         DELIVERY_DATE,
         FREIGHT,
         ORDERED_ITEM,
         DESCRIPTION,
         GRADE,
         ITEM_SIZE,
         PRODUCT_CATEGORY,
         PRODUCT_TYPE,
         ORDERED_QUANTITY,
         UOM,
         ORDERED_QUANTITY2,
         UOM2,
         TO_NUMBER (SAMPLE_PCS)     SAMPLE_PCS,
         CHALLAN_NO,
         TRANSPOTER,
         DELIVERY_PERSON,
         VEHICLE_NUMBER,
         VEHICLE_TYPE,
         DRIVER_NAME,
         DRIVER_CONTACT_NO
    FROM (SELECT AC.CUSTOMER_NUMBER,
                 AC.CUSTOMER_NAME,
                 OTT.NAME                            ORDER_TYPE,
                 OHA.ORDER_NUMBER,
                 TRUNC (OHA.ORDERED_DATE)            ORDERED_DATE,
                 TRUNC (OLA.ACTUAL_SHIPMENT_DATE)    DELIVERY_DATE,
                 OHA.FREIGHT_TERMS_CODE              FREIGHT,
                 OLA.FLOW_STATUS_CODE,
                 OLA.ORDERED_ITEM,
                 MSI.DESCRIPTION,
                 OLA.PREFERRED_GRADE                 GRADE,
                 CAT.SEGMENT2                        ITEM_SIZE,
                 CAT.CATEGORY_CONCAT_SEGS            PRODUCT_CATEGORY,
                 CAY.SEGMENT3                        PRODUCT_TYPE,
                 OLA.ORDERED_QUANTITY,
                 OLA.ORDER_QUANTITY_UOM              UOM,
                 OLA.ORDERED_QUANTITY2,
                 OLA.ORDERED_QUANTITY_UOM2           UOM2,
                 CASE
                     WHEN OTT.TRANSACTION_TYPE_ID IN ('1006', '1014')
                     THEN
                         OLA.SHIPPING_INSTRUCTIONS || ''
                     ELSE
                         NULL
                 END                                 SAMPLE_PCS,
                 OLV.DELIVERY_CHALLAN_NUMBER         CHALLAN_NO,
                 OLV.TRANSPORT_NAME                  TRANSPOTER,
                 TH.DELIVERY_PERSON,
                 TH.VEHICLE_NO                       VEHICLE_NUMBER,
                 TH.DELIVERY_MODE_CODE               VEHICLE_TYPE,
                 TH.DRIVER_NAME                      DRIVER_NAME,
                 TH.TRANSPORTER_NO                   DRIVER_CONTACT_NO
            FROM OE_ORDER_HEADERS_ALL         OHA,
                 OE_ORDER_LINES_ALL           OLA,
                 APPS.OE_TRANSACTION_TYPES_TL OTT,
                 INV.MTL_SYSTEM_ITEMS_B       MSI,
                 AR_CUSTOMERS                 AC,
                 MTL_ITEM_CATEGORIES_V        CAT,
                 MTL_ITEM_CATEGORIES_V        CAY,
                 XXDBL.XXDBL_OMSHIPPING_LINE_V OLV,
                 XXDBL_TRANSPOTER_HEADERS     TH
           WHERE     OHA.HEADER_ID = OLA.HEADER_ID
                 AND OHA.ORG_ID = OLA.ORG_ID
                 AND OHA.ORDER_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OLA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                 AND OLA.SHIP_FROM_ORG_ID = MSI.ORGANIZATION_ID
                 AND OHA.SOLD_TO_ORG_ID = AC.CUSTOMER_ID
                 AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID(+)
                 AND MSI.INVENTORY_ITEM_ID = CAY.INVENTORY_ITEM_ID
                 AND CAT.CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET'
                 AND CAY.CATEGORY_SET_NAME = 'Inventory'
                 AND OTT.TRANSACTION_TYPE_ID NOT IN (1008,
                                                     1010,
                                                     1030,
                                                     1032,
                                                     1034)
                 AND OLA.LINE_ID = OLV.ORDER_LINE_ID
                 AND OLA.INVENTORY_ITEM_ID = OLV.ITEM_ID
                 AND OLV.TRANSPORT_CHALLAN_NUMBER =
                     TH.TRANSPOTER_CHALLAN_NUMBER(+)
                 AND CAY.ORGANIZATION_ID = 152
                 AND CAT.ORGANIZATION_ID = 152
                 AND OLA.FLOW_STATUS_CODE IN ('CLOSED')
                 AND OMSHIPPING_LINE_STATUS IN ('CLOSED')
                 AND OHA.ORG_ID = 126
                 AND OHA.ORG_ID = :P_ORG_ID
                 AND (   :P_PRODUCT_CATEGORY IS NULL
                      OR CAT.CATEGORY_CONCAT_SEGS = :P_PRODUCT_CATEGORY)
                 AND (   :P_PRODUCT_TYPE IS NULL
                      OR CAY.SEGMENT3 = :P_PRODUCT_TYPE)
                 AND (   :P_ITEM_GRADE IS NULL
                      OR OLA.PREFERRED_GRADE = :P_ITEM_GRADE)
                 AND (   :P_CUSTOMER_ID IS NULL
                      OR AC.CUSTOMER_ID = :P_CUSTOMER_ID)
                 AND (   :P_ORDER_NUMBER IS NULL
                      OR OHA.ORDER_NUMBER = :P_ORDER_NUMBER)
                 AND (   :P_ORDERED_ITEM IS NULL
                      OR OLA.ORDERED_ITEM = :P_ORDERED_ITEM)
                 AND TRUNC (OLA.ACTUAL_SHIPMENT_DATE) BETWEEN :P_DATE_FROM
                                                          AND :P_DATE_TO
          UNION ALL
          SELECT AC.CUSTOMER_NUMBER,
                 AC.CUSTOMER_NAME,
                 OTT.NAME                            ORDER_TYPE,
                 OHA.ORDER_NUMBER,
                 TRUNC (OHA.ORDERED_DATE)            ORDERED_DATE,
                 TRUNC (OLA.ACTUAL_SHIPMENT_DATE)    DELIVERY_DATE,
                 OHA.FREIGHT_TERMS_CODE              FREIGHT,
                 OLA.FLOW_STATUS_CODE,
                 OLA.ORDERED_ITEM,
                 MSI.DESCRIPTION,
                 OLA.PREFERRED_GRADE                 GRADE,
                 CAT.SEGMENT2                        ITEM_SIZE,
                 CAT.CATEGORY_CONCAT_SEGS            PRODUCT_CATEGORY,
                 CAY.SEGMENT3                        PRODUCT_TYPE,
                 OLA.ORDERED_QUANTITY,
                 OLA.ORDER_QUANTITY_UOM              UOM,
                 OLA.ORDERED_QUANTITY2,
                 OLA.ORDERED_QUANTITY_UOM2           UOM2,
                 CASE
                     WHEN OTT.TRANSACTION_TYPE_ID IN ('1006', '1014')
                     THEN
                         OLA.SHIPPING_INSTRUCTIONS || ''
                     ELSE
                         NULL
                 END                                 SAMPLE_PCS,
                 NULL                                CHALLAN_NO,
                 NULL                                TRANSPOTER,
                 NULL                                DELIVERY_PERSON,
                 NULL                                VEHICLE_NUMBER,
                 NULL                                VEHICLE_TYPE,
                 NULL                                DRIVER_NAME,
                 NULL                                DRIVER_CONTACT_NO
            FROM OE_ORDER_HEADERS_ALL        OHA,
                 OE_ORDER_LINES_ALL          OLA,
                 APPS.OE_TRANSACTION_TYPES_TL OTT,
                 INV.MTL_SYSTEM_ITEMS_B      MSI,
                 AR_CUSTOMERS                AC,
                 MTL_ITEM_CATEGORIES_V       CAT,
                 MTL_ITEM_CATEGORIES_V       CAY
           WHERE     OHA.HEADER_ID = OLA.HEADER_ID
                 AND OHA.ORG_ID = OLA.ORG_ID
                 AND OHA.ORDER_TYPE_ID = OTT.TRANSACTION_TYPE_ID
                 AND OLA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                 AND OLA.SHIP_FROM_ORG_ID = MSI.ORGANIZATION_ID
                 AND OHA.SOLD_TO_ORG_ID = AC.CUSTOMER_ID
                 AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID(+)
                 AND MSI.INVENTORY_ITEM_ID = CAY.INVENTORY_ITEM_ID
                 AND CAT.CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET'
                 AND CAY.CATEGORY_SET_NAME = 'Inventory'
                 AND OTT.TRANSACTION_TYPE_ID NOT IN (1008,
                                                     1010,
                                                     1030,
                                                     1032,
                                                     1034)
                 AND CAY.ORGANIZATION_ID = 152
                 AND CAT.ORGANIZATION_ID = 152
                 AND OLA.FLOW_STATUS_CODE IN ('CLOSED')
                 AND OHA.ORG_ID = 126
                 AND OHA.ORG_ID = :P_ORG_ID
                 AND (   :P_PRODUCT_CATEGORY IS NULL
                      OR CAT.CATEGORY_CONCAT_SEGS = :P_PRODUCT_CATEGORY)
                 AND (   :P_PRODUCT_TYPE IS NULL
                      OR CAY.SEGMENT3 = :P_PRODUCT_TYPE)
                 AND (   :P_ITEM_GRADE IS NULL
                      OR OLA.PREFERRED_GRADE = :P_ITEM_GRADE)
                 AND (   :P_CUSTOMER_ID IS NULL
                      OR AC.CUSTOMER_ID = :P_CUSTOMER_ID)
                 AND (   :P_ORDER_NUMBER IS NULL
                      OR OHA.ORDER_NUMBER = :P_ORDER_NUMBER)
                 AND (   :P_ORDERED_ITEM IS NULL
                      OR OLA.ORDERED_ITEM = :P_ORDERED_ITEM)
                 AND TRUNC (OLA.ACTUAL_SHIPMENT_DATE) BETWEEN :P_DATE_FROM
                                                          AND :P_DATE_TO
                 AND NOT EXISTS
                         (SELECT 1
                            FROM XXDBL.XXDBL_OMSHIPPING_LINE_V OLV
                           WHERE     OLA.LINE_ID = OLV.ORDER_LINE_ID
                                 AND OMSHIPPING_LINE_STATUS IN ('CLOSED')))
ORDER BY CUSTOMER_NAME