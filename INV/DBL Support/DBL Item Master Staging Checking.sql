/* Formatted on 9/2/2021 12:13:52 PM (QP5 v5.354) */
SELECT *
  FROM xxdbl_item_errors
 WHERE 1 = 1
 ORDER BY LAST_UPDATE_DATE DESC;

  SELECT *
    FROM xxdbl_catalog_elem_serial
   WHERE 1 = 1
ORDER BY last_update_date DESC;

  SELECT *
    FROM xxdbl_item_code_elements
   WHERE 1 = 1
ORDER BY last_update_date DESC;

  SELECT *
    FROM xxdbl_catalog_desc_elements
   WHERE 1 = 1
ORDER BY last_update_date DESC;

  SELECT *
    FROM xxdbl_item_master
   WHERE 1 = 1 AND ITEM_STATUS = 'SUBMITTED'
ORDER BY last_update_date DESC;

SELECT *
  FROM xxdbl_item_batches
 WHERE 1 = 1
ORDER BY last_update_date DESC;

SELECT *
  FROM xxdbl_item_orgs
 WHERE 1 = 1
ORDER BY last_update_date DESC;

SELECT *
  FROM xxdbl_item_org_hierarchy
 WHERE 1 = 1
ORDER BY last_update_date DESC;


SELECT *
  FROM mtl_uom_class_conversions
 WHERE 1 = 1;

SELECT *
  FROM mtl_units_of_measure
 WHERE 1 = 1;

SELECT *
  FROM mtl_system_items
 WHERE 1 = 1;

SELECT *
  FROM mtl_parameters
 WHERE 1 = 1;

SELECT *
  FROM gl_code_combinations_kfv
 WHERE 1 = 1;

SELECT *
  FROM mtl_item_categories
 WHERE 1 = 1;

SELECT *
  FROM mtl_descr_element_values_v
 WHERE 1 = 1;


SELECT *
  FROM mtl_uom_conversions
 WHERE 1 = 1;