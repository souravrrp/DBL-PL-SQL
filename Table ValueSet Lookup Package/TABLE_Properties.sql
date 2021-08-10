/* Formatted on 3/16/2020 2:03:07 PM (QP5 v5.287) */
  SELECT obj.object_name,
         atc.column_name,
         atc.data_type,
         atc.data_length,
         atc.column_name||' '||atc.data_type||' ('||atc.data_length||' BYTE),' PROPERTIES
    FROM all_tab_columns atc, all_objects obj
   WHERE     1 = 1
         AND atc.table_name = obj.object_name
         AND OBJ.object_name LIKE 'MTL_ITEM_CATEGORIES_V%'
         --AND owner = 'GL'
         AND object_type IN ('TABLE', 'VIEW')
ORDER BY obj.object_name, atc.column_name;

--------------------------------------------------------------------------------


  SELECT obj.object_name,
         atc.column_name,
         atc.data_type,
         atc.data_length
    FROM all_tab_columns atc,
         (SELECT *
            FROM all_objects
           WHERE     object_name LIKE 'MTL_ITEM_CATEGORIES_V%' --AND owner = 'GL'
                 AND object_type IN ('TABLE', 'VIEW')) obj
   WHERE atc.table_name = obj.object_name
ORDER BY obj.object_name, atc.column_name;