select
*
from
xxdbl.XXDBL_ITEM_UPLOAD_WEBADI
WHERE 1=1
and SEGMENT1='YRNTW30S3CTN54999922'
--and FLAG IS NULL
;

SELECT *
           FROM XXDBL.XXDBL_ITEM_UPLOAD_WEBADI XXDBL
          WHERE     1=1
          --and FLAG IS NULL
          and SEGMENT1='YRNTW30S3CTN54999922'
                AND EXISTS
                       (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_B MSI
                         WHERE XXDBL.SEGMENT1 = MSI.SEGMENT1);


-------------------------------------------
      --------Validate Item Type-----------------
      -------------------------------------------

         SELECT ffv.flex_value, ffv.attribute1           
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_ITEM_TYPE'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = 'YRN'
                AND ROWNUM = 1;

         SELECT ffv.flex_value, ffv.attribute1
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_COUNT'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = 'TW52S2'
                AND ROWNUM = 1;
   
         SELECT ffv.flex_value, ffv.attribute1
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name =
                       'XXDBL_SPINNING_FG_PRODUCT_TYPE'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = 'MT'
                AND ROWNUM = 1;

         SELECT ffv.flex_value, ffv.attribute1
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_CONTENT'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = '546'
                AND ROWNUM = 1;
      
         SELECT ffv.flex_value, ffv.attribute1
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_STYLE'
                AND ffv.attribute1 = '999'
                AND ENABLED_FLAG = 'Y'
                AND ROWNUM = 1;
                
         SELECT ffv.flex_value, ffv.attribute1
           FROM apps.fnd_flex_value_sets val_set, apps.fnd_flex_values ffv
          WHERE     val_set.flex_value_set_id = ffv.flex_value_set_id
                AND val_set.flex_value_set_name = 'XXDBL_SPINNING_FG_PROCESS'
                AND ENABLED_FLAG = 'Y'
                AND ffv.attribute1 = '99'
                AND ROWNUM = 1;