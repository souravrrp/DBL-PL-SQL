/* Formatted on 12/9/2021 3:23:57 PM (QP5 v5.374) */
SELECT XIB.BATCH_NAME,
       XIB.BATCH_STATUS,
       XIM.ITEM_STATUS,
       XIM.CATALOG_TYPE,
       XIM.ITEM_MASTER_ID     ITEM_ID,
       XIM.ITEM_CODE,
       XIM.ITEM_DESCRIPTION,
       XIM.LONG_DESCRIPTION,
       XIM.PRIMARY_UOM_CODE,
       XIM.SECONDARY_UOM_CODE,
       XIM.DUAL_UOM_FLAG,
       XIOH.ORG_HIERARCHY,
       XIOH.TEMPLATE_NAME,
       XIOH.CATEGORY_SET_ID,
       XIOH.CATEGORY_ID,
       XIOH.CATEGORY_NAME,
       XIOH.LCM_FLAG,
       XIOH.EXPENSE_ACCOUNT,
       XIOH.PRODUCT_LINE,
       XIOH.EXPENSE_SUB_ACCOUNT
  --,XIB.*
  --,XIM.*
  --,XIOH.*
  FROM XXDBL_ITEM_BATCHES        XIB,
       XXDBL_ITEM_MASTER         XIM,
       XXDBL_ITEM_ORG_HIERARCHY  XIOH
 WHERE     1 = 1
       AND XIB.BATCH_ID = XIM.BATCH_ID
       AND XIM.ITEM_MASTER_ID = XIOH.ITEM_MASTER_ID
       AND XIM.BATCH_ID = XIOH.BATCH_ID
       --AND XIM.ITEM_CODE LIKE '%DYES%'
       AND XIB.BATCH_NAME = '13222';

--------------------------------------------------------------------------------

SELECT XIM.*
  FROM XXDBL_ITEM_MASTER XIM;

SELECT *
  FROM XXDBL_ITEM_ORG_HIERARCHY
 WHERE 1 = 1 AND BATCH_ID = 10207;

SELECT * FROM XXDBL_ITEM_BATCHES;

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