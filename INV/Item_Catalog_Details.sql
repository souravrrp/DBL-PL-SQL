/* Formatted on 9/8/2020 10:52:07 AM (QP5 v5.354) */
---------------------------------CATALOG_GROUP----------------------------------

SELECT icg.segment1        catalog_group_name,
       icg.item_catalog_group_id,
       icg.description     catalog_group_description,
       --icg.enabled_flag,
       de.element_name,
       de.description      element_description
  --,icg.*
  --,de.*
  FROM mtl_descriptive_elements de, mtl_item_catalog_groups icg
 WHERE     1 = 1
       AND de.item_catalog_group_id = icg.item_catalog_group_id
       --AND icg.item_catalog_group_id = 9006
       AND icg.segment1 = 'ECO Thread FG';

---------------------------------CATALOG_ELEMENTS-------------------------------

SELECT icg.segment1        catalog_group_name,
       icg.item_catalog_group_id,
       icg.description     catalog_group_description,
       de.element_name,
       de.description      element_description,
       dev.ROWID           row_id,
       dev.inventory_item_id,
       dev.element_name,
       dev.element_value,
       dev.default_element_flag,
       dev.element_sequence,
       de.required_element_flag,
       de.item_catalog_group_id,
       dev.last_update_date,
       dev.last_updated_by,
       dev.creation_date,
       dev.created_by,
       dev.last_update_login
  FROM mtl_descriptive_elements  de,
       mtl_descr_element_values  dev,
       mtl_item_catalog_groups   icg
 WHERE     dev.element_name = de.element_name
       AND de.item_catalog_group_id = icg.item_catalog_group_id
       --AND icg.item_catalog_group_id = 9006
       AND icg.segment1 = 'ECO Thread FG';