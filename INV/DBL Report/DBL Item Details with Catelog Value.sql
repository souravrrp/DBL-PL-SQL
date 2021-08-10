/* Formatted on 10/13/2020 9:45:14 AM (QP5 v5.354) */
SELECT MSI.ORGANIZATION_ID,
       OOD.ORGANIZATION_CODE,
       OOD.ORGANIZATION_NAME,
       MSI.INVENTORY_ITEM_ID,
       MSI.SEGMENT1                ITEM_CODE,
       MSI.DESCRIPTION,
       MSI.PRIMARY_UOM_CODE,
       MSI.SECONDARY_UOM_CODE,
       MSI.ATTRIBUTE14             TEMPLATE_NAME,
       CAT.CATEGORY_SET_NAME       CATEGORY_SET,
       CAT.CATEGORY_ID,
       CAT.SEGMENT1                LINE_OF_BUSINESS,
       CAT.SEGMENT2                ITEM_CATEGORY,
       CAT.SEGMENT3                ITEM_TYPE,
       CAT.SEGMENT4                CATELOG,
       CAT.CATEGORY_CONCAT_SEGS    CATEGORY_SEGMENTS,
       MSI.PROCESS_COSTING_ENABLED_FLAG,
       MSI.PROCESS_YIELD_SUBINVENTORY,
       MSI.PROCESS_SUPPLY_SUBINVENTORY,
       MSI.INVENTORY_ITEM_FLAG,
       MSI.CUSTOMER_ORDER_FLAG,
       MSI.CUSTOMER_ORDER_ENABLED_FLAG,
       MSI.INVOICE_ENABLED_FLAG,
       MSI.PURCHASING_ITEM_FLAG,
       MSI.SERVICE_ITEM_FLAG,
       MSI.PURCHASING_ENABLED_FLAG,
       MSI.STOCK_ENABLED_FLAG,
       MSI.LIST_PRICE_PER_UNIT,
       MSI.INVENTORY_ASSET_FLAG,
       MSI.CREATION_DATE,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_ITEM_TYPE'
               AND ENABLED_FLAG = 'Y'
               AND TO_CHAR (FFV.ATTRIBUTE1) =
                   TO_CHAR (SUBSTR (MSI.SEGMENT1, 1, 3))
               AND ROWNUM = 1)     ITEM_TYPE_CATELOG,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_COUNT'
               AND ENABLED_FLAG = 'Y'
               AND TO_CHAR (FFV.ATTRIBUTE1) = (SUBSTR (MSI.SEGMENT1, 4, 6))
               AND ROWNUM = 1)     ITEM_COUNT,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_PRODUCT_TYPE'
               AND ENABLED_FLAG = 'Y'
               AND TO_CHAR (FFV.ATTRIBUTE1) =
                   TO_CHAR (SUBSTR (MSI.SEGMENT1, 10, 3))
               AND ROWNUM = 1)     PRODUCT_TYPE,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_CONTENT'
               AND ENABLED_FLAG = 'Y'
               AND TO_CHAR (FFV.ATTRIBUTE1) =
                   TO_CHAR (SUBSTR (MSI.SEGMENT1, 13, 3))
               AND ROWNUM = 1)     ITEM_CONTENT,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_STYLE'
               AND TO_CHAR (FFV.ATTRIBUTE1) =
                   TO_CHAR (SUBSTR (MSI.SEGMENT1, 16, 3))
               AND ENABLED_FLAG = 'Y'
               AND ROWNUM = 1)     ITEM_STYLE,
       (SELECT FFV.DESCRIPTION
          FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
               apps.fnd_flex_values_vl            ffv
         WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
               AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_PROCESS'
               AND ENABLED_FLAG = 'Y'
               AND TO_CHAR (FFV.ATTRIBUTE1) =
                   TO_CHAR (SUBSTR (MSI.SEGMENT1, 19, 2))
               AND ROWNUM = 1)     item_process
  --,MSI.*
  --,OOD.*
  --,CAT.*
  FROM APPS.MTL_SYSTEM_ITEMS_B            MSI,
       APPS.ORG_ORGANIZATION_DEFINITIONS  OOD,
       APPS.MTL_ITEM_CATEGORIES_V         CAT
 WHERE     1 = 1
       AND MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
       AND MSI.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID
       AND MSI.ORGANIZATION_ID = CAT.ORGANIZATION_ID
       AND (   :P_OPERATING_UNIT IS NULL
            OR (OOD.OPERATING_UNIT = :P_OPERATING_UNIT))
       AND (   :P_ORGANIZATION_CODE IS NULL
            OR (OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
       AND (   :P_ORG_NAME IS NULL
            OR (UPPER (OOD.ORGANIZATION_NAME) LIKE
                    UPPER ('%' || :P_ORG_NAME || '%')))
       AND (   :P_OPERATING_UNIT IS NULL
            OR (OOD.OPERATING_UNIT = :P_OPERATING_UNIT))
       AND (   :P_ORGANIZATION_CODE IS NULL
            OR (OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
       AND ( :P_ITEM_CODE IS NULL OR (MSI.SEGMENT1 = :P_ITEM_CODE))
       AND (   :P_ITEM_DESC IS NULL
            OR (UPPER (MSI.DESCRIPTION) LIKE
                    UPPER ('%' || :P_ITEM_DESC || '%')))
       AND (   :P_LINE_OF_BUSINESS IS NULL
            OR (CAT.SEGMENT1 = :P_LINE_OF_BUSINESS))
       AND ( :P_MAJOR_CATEGORY IS NULL OR (CAT.SEGMENT2 = :P_MAJOR_CATEGORY))
       AND ( :P_MINOR_CATEGORY IS NULL OR (CAT.SEGMENT3 = :P_MINOR_CATEGORY))
       AND ( :P_ITEM_CATELOG IS NULL OR (CAT.SEGMENT4 = :P_ITEM_CATELOG))
       AND CAT.CATEGORY_SET_ID = 1
       --AND INVENTORY_ITEM_STATUS_CODE='Active'
       --AND CAT.CATEGORY_ID='74551'
       AND ORGANIZATION_CODE IN ('101')
       --AND ORGANIZATION_CODE IN ('193')
       --AND OPERATING_UNIT IN (85)
       --AND MSI.ORGANIZATION_ID IN (101)
       --AND MSI.SEGMENT2='BRND'
       --AND MSI.SEGMENT3='GIFT'
       --AND MSI.INVENTORY_ITEM_ID IN ('7297')
       --AND MSI.SEGMENT1 LIKE '%RRRRRRR%'
       --AND CAT.CATEGORY_CONCAT_SEGS='NA.NA.NA.NA'
       --AND MSI.DESCRIPTION IN ('40S1-COTTON-100%-CH ORGANIC')
       AND CAT.SEGMENT3 IN ('YARN', 'DYED YARN')
       --AND MSI.PRIMARY_UOM_CODE='PCS'
       --AND CAT.SEGMENT2 NOT IN ('FINISH GOODS')
       AND MSI.ENABLED_FLAG = 'Y';