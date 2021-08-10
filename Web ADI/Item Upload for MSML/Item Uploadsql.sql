SELECT * FROM xxdbl.xxdbl_item_upload_webadi stg
WHERE 1=1
AND  FLAG IS NULL
AND ( :p_item_code IS NULL OR (stg.segment1 = :p_item_code))
AND ( :p_item_desc IS NULL OR (stg.description = :p_item_desc));

SELECT *
  FROM mtl_system_items_interface msii
 WHERE 1 = 1 AND ( :p_item_code IS NULL OR (msii.segment1 = :p_item_code))
 AND (:p_item_desc IS NULL OR (UPPER(msii.description) LIKE UPPER('%'||:p_item_desc||'%') ))
 AND SET_PROCESS_ID='-999'
 --AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE)
 AND PROCESS_FLAG = 1;
 
 SELECT SET_PROCESS_ID
  FROM mtl_system_items_interface msii
 WHERE     1 = 1
       AND TRUNC (CREATION_DATE) = TRUNC (SYSDATE-1)
       AND SET_PROCESS_ID = '-999'
       AND PROCESS_FLAG = 1;

select
*
from
apps.mtl_system_items_b msi
where 1=1
AND (   :P_ITEM_CODE IS NULL         OR (MSI.SEGMENT1 = :P_ITEM_CODE))
AND (   :P_ITEM_DESC IS NULL         OR (UPPER(MSI.DESCRIPTION) LIKE UPPER('%'||:P_ITEM_DESC||'%') )) ;

--------------------------------------------------------------------------------

SELECT ffv.flex_value, ffv.attribute1
  --INTO l_item_type, cd_item_type
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_ITEM_TYPE'
       AND ENABLED_FLAG = 'Y'
       AND (   :p_item_type IS NULL OR (ffv.attribute1 = :p_item_type))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 1, 3))))
       --AND ffv.attribute1 = p_item_type
       --AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR ( :ct_item_code, 1, 3))
       AND ROWNUM = 1;


SELECT ffv.flex_value, ffv.attribute1
  --INTO l_item_count, cd_item_count
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_COUNT'
       AND ENABLED_FLAG = 'Y'
       AND (   :p_item_count IS NULL OR (ffv.attribute1 = :p_item_count))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 4, 6))))
       --AND ffv.attribute1 = :p_item_count
       --AND TO_CHAR (ffv.attribute1) = (SUBSTR ( :ct_item_code, 4, 6))
       AND ROWNUM = 1;


SELECT ffv.flex_value, ffv.attribute1
  --INTO l_product_type, cd_product_type
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_PRODUCT_TYPE'
       AND ENABLED_FLAG = 'Y'
       AND (   :p_product_type IS NULL OR (ffv.attribute1 = :p_product_type))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 10, 3))))
       --AND ffv.attribute1 = p_product_type
       --AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR ( :ct_item_code, 10, 3))
       AND ROWNUM = 1;


SELECT ffv.flex_value, ffv.attribute1
  --INTO l_item_content, cd_item_content
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_CONTENT'
       AND ENABLED_FLAG = 'Y'
       AND (   :p_item_content IS NULL OR (ffv.attribute1 = :p_item_content))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 13, 3))))
       --AND ffv.attribute1 = p_item_content
       --AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR (:ct_item_code, 13, 3))
       AND ROWNUM = 1;

SELECT ffv.flex_value, ffv.attribute1
  --INTO l_item_style, cd_item_style
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_STYLE'
       --AND ffv.attribute1 = :p_item_style
       AND (   :p_item_style IS NULL OR (ffv.attribute1 = :p_item_style))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 16, 3))))
       --AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR ( :ct_item_code, 16, 3))
       AND ENABLED_FLAG = 'Y'
       AND ROWNUM = 1;

SELECT ffv.flex_value, ffv.attribute1
  --INTO l_item_process, cd_item_process
  FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
 WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
       AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_PROCESS'
       AND ENABLED_FLAG = 'Y'
       AND (   :p_item_process IS NULL OR (ffv.attribute1 = :p_item_process))
       AND (   :ct_item_code IS NULL OR (TO_CHAR (ffv.attribute1) = TO_CHAR (SUBSTR ( :ct_item_code, 19, 2))))
       --AND ffv.attribute1 = p_item_process
       --AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR (:ct_item_code, 19, 2))
       AND ROWNUM = 1;


--------------------------------------------------------------------------------

SELECT FFV.DESCRIPTION ct_item_type, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_ITEM_TYPE'
       AND ENABLED_FLAG = 'Y'
       AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR ( :ct_item_code, 1, 3))
       AND ROWNUM = 1
       AND EXISTS
               (SELECT 1
                  FROM mtl_system_items_b msi, apps.mtl_item_categories_v cat
                 WHERE     msi.segment1 = :ct_item_code
                       AND msi.inventory_item_id = cat.inventory_item_id
                       AND msi.organization_id = cat.organization_id
                       AND msi.organization_id = 138
                       AND CAT.SEGMENT3 = FFV.DESCRIPTION
                       AND item_catalog_group_id = val_set.catalog_group_id);


SELECT FFV.DESCRIPTION ct_item_count, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_COUNT'
       AND ENABLED_FLAG = 'Y'
       AND TO_CHAR (FFV.ATTRIBUTE1) = (SUBSTR ( :ct_item_code, 4, 6))
       AND ROWNUM = 1;


SELECT FFV.DESCRIPTION ct_product_type, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_PRODUCT_TYPE'
       AND ENABLED_FLAG = 'Y'
       AND TO_CHAR (FFV.ATTRIBUTE1) =
           TO_CHAR (SUBSTR ( :ct_item_code, 10, 3))
       AND ROWNUM = 1;

SELECT FFV.DESCRIPTION ct_item_content, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_CONTENT'
       AND ENABLED_FLAG = 'Y'
       AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR (ct_item_code, 13, 3))
       AND ROWNUM = 1;


SELECT FFV.DESCRIPTION ct_item_style, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_STYLE'
       AND TO_CHAR (FFV.ATTRIBUTE1) =
           TO_CHAR (SUBSTR ( :ct_item_code, 16, 3))
       AND ENABLED_FLAG = 'Y'
       AND ROWNUM = 1;


SELECT FFV.DESCRIPTION ct_item_process, val_set.ELEMENT_NAME ct_element_name
  FROM xxdbl.xxdbl_catalog_desc_elements val_set, apps.fnd_flex_values_vl ffv
 WHERE     val_set.VALUE_SET_ID = ffv.flex_value_set_id
       AND val_set.VALUE_SET_NAME = 'XXDBL_SPINNING_FG_PROCESS'
       AND ENABLED_FLAG = 'Y'
       AND TO_CHAR (FFV.ATTRIBUTE1) = TO_CHAR (SUBSTR (ct_item_code, 19, 2))
       AND ROWNUM = 1;