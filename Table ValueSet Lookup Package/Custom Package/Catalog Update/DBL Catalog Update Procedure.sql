/* Formatted on 9/8/2020 10:07:02 AM (QP5 v5.287) */
DECLARE
   CURSOR cur_item_code
   IS
      SELECT segment1 v_item_code
        FROM mtl_system_items_b_kfv msi
       WHERE     1 = 1
             AND msi.item_catalog_group_id IS NOT NULL
             AND msi.segment1 LIKE 'YRN%'
             --AND msi.segment1 = 'YRN08S100CTN52120442'
             AND TO_CHAR (msi.creation_date, 'YYYY') = '2018'
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
                            AND val_set.VALUE_SET_NAME =
                                   'XXDBL_SPINNING_FG_COUNT'
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
                            AND val_set.VALUE_SET_NAME =
                                   'XXDBL_SPINNING_FG_STYLE'
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
BEGIN
   FOR ln_cur_item_code IN cur_item_code
   LOOP
      BEGIN
         apps.xxdbl_item_upload_webadi_pkg.item_catalog_update (
            ln_cur_item_code.v_item_code);
         COMMIT;
      END;
   END LOOP;
END;