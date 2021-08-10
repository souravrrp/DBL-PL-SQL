/* Formatted on 9/8/2020 10:20:03 AM (QP5 v5.354) */
SELECT msi.segment1     v_item_code
  FROM mtl_system_items_b_kfv msi, apps.mtl_item_categories_v ctg
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS NOT NULL
       --AND msi.segment1 NOT LIKE 'YRNDY%'
       --AND msi.segment1 LIKE 'YRN%'
       AND ctg.segment3 IN ('YARN')
       --AND msi.segment1 = 'YRN08S100CTN52120442'
       --AND TO_CHAR (msi.creation_date, 'YYYY') = '2018'
       --AND EXISTS(SELECT 1 FROM MTL_DESCR_ELEMENT_VALUES EV WHERE EV.INVENTORY_ITEM_ID!=MSI.INVENTORY_ITEM_ID)
       --AND NOT EXISTS (SELECT 1 FROM MTL_DESCR_ELEMENT_VALUES EV WHERE EV.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID)
       AND msi.inventory_item_id = ctg.inventory_item_id
       AND msi.organization_id = ctg.organization_id
       AND msi.organization_id = 138
       AND NOT EXISTS
               (SELECT 1
                  FROM MTL_DESCR_ELEMENT_VALUES_V CAT
                 WHERE     1 = 1
                       AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND CAT.ELEMENT_NAME = 'Item Type'
                       AND CAT.ELEMENT_VALUE =ctg.segment3  --IN ('YARN', 'DYED YARN')
                       AND CAT.ITEM_CATALOG_GROUP_ID =
                           msi.item_catalog_group_id)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME = 'XXDBL_ITEM_TYPE'
                       AND ENABLED_FLAG = 'Y'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           TO_CHAR (SUBSTR (msi.segment1, 1, 3))
                       AND ROWNUM = 1)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_COUNT'
                       AND ENABLED_FLAG = 'Y'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           (SUBSTR (msi.segment1, 4, 6))
                       AND ROWNUM = 1)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME =
                           'XXDBL_SPINNING_FG_PRODUCT_TYPE'
                       AND ENABLED_FLAG = 'Y'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           TO_CHAR (SUBSTR (msi.segment1, 10, 3))
                       AND ROWNUM = 1)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME =
                           'XXDBL_SPINNING_FG_CONTENT'
                       AND ENABLED_FLAG = 'Y'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           TO_CHAR (SUBSTR (msi.segment1, 13, 3))
                       AND ROWNUM = 1)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_STYLE'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           TO_CHAR (SUBSTR (msi.segment1, 16, 3))
                       AND ENABLED_FLAG = 'Y'
                       AND ROWNUM = 1)
       AND EXISTS
               (SELECT 1
                  FROM xxdbl.xxdbl_catalog_desc_elements  val_set,
                       apps.fnd_flex_values               ffv
                 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                       AND val_set.VALUE_SET_NAME =
                           'XXDBL_SPINNING_FG_PROCESS'
                       AND ENABLED_FLAG = 'Y'
                       AND TO_CHAR (FFV.ATTRIBUTE1) =
                           TO_CHAR (SUBSTR (msi.segment1, 19, 2))
                       AND ROWNUM = 1);



--------------------Spare Consumable Item--------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE '%SPRECONS000000064%' AND msi.organization_id = 138;

--------------------Fixed Asset Item--------------------------------------------

SELECT MAX (segment1)
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'FASSET%' AND msi.organization_id = 138;

--------------------Yarn Item--------------------------------------------

SELECT *
  FROM mtl_system_items_b_kfv msi
 WHERE     1 = 1
       AND segment1 = 'YRN06S100CVC53899999'
       AND segment1 LIKE 'YRN%'
       AND msi.organization_id = 138;


------------------------------------------------------------------------------------------------

SELECT * FROM MTL_DESCR_ELEMENT_VALUES_V;


SELECT V.ROWID ROW_ID,
       V.INVENTORY_ITEM_ID,
       V.ELEMENT_NAME,
       V.ELEMENT_VALUE,
       V.DEFAULT_ELEMENT_FLAG,
       V.ELEMENT_SEQUENCE,
       E.REQUIRED_ELEMENT_FLAG,
       E.ITEM_CATALOG_GROUP_ID,
       V.LAST_UPDATE_DATE,
       V.LAST_UPDATED_BY,
       V.CREATION_DATE,
       V.CREATED_BY,
       V.LAST_UPDATE_LOGIN
  FROM MTL_DESCRIPTIVE_ELEMENTS E, MTL_DESCR_ELEMENT_VALUES V
 WHERE V.ELEMENT_NAME = E.ELEMENT_NAME;

SELECT *
  FROM MTL_DESCR_ELEMENT_VALUES EV
 WHERE 1 = 1 AND ELEMENT_VALUE IS NULL;

SELECT *
  FROM mtl_system_items_b_kfv
 WHERE segment1 LIKE 'YRN06S100CVC53899999%' AND msi.organization_id = 138;

SELECT item_catalog_group_id
  FROM mtl_item_catalog_groups
 WHERE segment1 = 'Yarn';


SELECT *
  FROM MTL_DESCR_ELEMENT_VALUES_V CAT
 WHERE     1 = 1
       AND CAT.INVENTORY_ITEM_ID = 425677                  --INVENTORY_ITEM_ID
       AND CAT.ELEMENT_NAME = 'Item Type'
       AND CAT.ELEMENT_VALUE = 'YARN'
       AND CAT.ITEM_CATALOG_GROUP_ID = 26;
       
------------------------------------YARN----------------------------------------

SELECT segment1 v_item_code
  FROM mtl_system_items_b_kfv msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS NOT NULL
       AND msi.segment1 LIKE 'YRN%'
       --AND msi.segment1 = 'YRN08S100CTN52120442'
       AND TO_CHAR (msi.creation_date, 'YYYY') = '2018'
       --AND EXISTS(SELECT 1 FROM MTL_DESCR_ELEMENT_VALUES EV WHERE EV.INVENTORY_ITEM_ID!=MSI.INVENTORY_ITEM_ID)
       --AND NOT EXISTS (SELECT 1 FROM MTL_DESCR_ELEMENT_VALUES EV WHERE EV.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID)
       AND msi.organization_id = 138
       AND NOT EXISTS
              (SELECT 1
                 FROM MTL_DESCR_ELEMENT_VALUES_V CAT
                WHERE     1 = 1
                      AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                      AND CAT.ELEMENT_NAME = 'Item Type'
                      AND CAT.ELEMENT_VALUE IN ('YARN', 'DYED YARN')
                      AND CAT.ITEM_CATALOG_GROUP_ID =
                             msi.item_catalog_group_id)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME = 'XXDBL_ITEM_TYPE'
                      AND ENABLED_FLAG = 'Y'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             TO_CHAR (SUBSTR (msi.segment1, 1, 3))
                      AND ROWNUM = 1)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_COUNT'
                      AND ENABLED_FLAG = 'Y'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             (SUBSTR (msi.segment1, 4, 6))
                      AND ROWNUM = 1)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME =
                             'XXDBL_SPINNING_FG_PRODUCT_TYPE'
                      AND ENABLED_FLAG = 'Y'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             TO_CHAR (SUBSTR (msi.segment1, 10, 3))
                      AND ROWNUM = 1)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME =
                             'XXDBL_SPINNING_FG_CONTENT'
                      AND ENABLED_FLAG = 'Y'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             TO_CHAR (SUBSTR (msi.segment1, 13, 3))
                      AND ROWNUM = 1)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_STYLE'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             TO_CHAR (SUBSTR (msi.segment1, 16, 3))
                      AND ENABLED_FLAG = 'Y'
                      AND ROWNUM = 1)
       AND EXISTS
              (SELECT 1
                 FROM xxdbl.xxdbl_catalog_desc_elements val_set,
                      apps.fnd_flex_values ffv
                WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
                      AND val_set.VALUE_SET_NAME =
                             'XXDBL_SPINNING_FG_PROCESS'
                      AND ENABLED_FLAG = 'Y'
                      AND TO_CHAR (FFV.ATTRIBUTE1) =
                             TO_CHAR (SUBSTR (msi.segment1, 19, 2))
                      AND ROWNUM = 1);