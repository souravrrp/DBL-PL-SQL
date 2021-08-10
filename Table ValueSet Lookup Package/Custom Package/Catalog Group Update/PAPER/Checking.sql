/* Formatted on 9/24/2020 11:30:42 AM (QP5 v5.354) */
SELECT msi.segment1, msi.inventory_item_id
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       AND msi.organization_id = 138
       AND EXISTS
               (SELECT 1
                  FROM APPS.MTL_ITEM_CATEGORIES_V CAT
                 WHERE     1 = 1
                       AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                       AND CAT.SEGMENT3 IN ('PAPER'))
;

SELECT * FROM mtl_desc_elem_val_interface;

SELECT * FROM mtl_system_items;


SELECT
*
FROM
mtl_item_catalog_groups c
WHERE 1=1
AND SEGMENT1='Paper'


SELECT *
  FROM mtl_system_items_interface
 WHERE 1 = 1 AND INVENTORY_ITEM_ID = 59782 AND organization_id = 138;

DELETE FROM mtl_system_items_interface
      WHERE 1 = 1 AND INVENTORY_ITEM_ID = 168027 AND organization_id = 138;
      

SELECT 'Item Type' ct_item_type, 'PAPER' ct_element_name
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS not NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       and msi.organization_id = 138;
      
SELECT TO_CHAR (SUBSTR (msi.segment1, 1, 3)) ct_item_type, 'PAPER' ct_element_name
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS not NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       and msi.organization_id = 138;
             
             
SELECT TO_CHAR (SUBSTR (msi.segment1, 4, 6)) l_element, REGEXP_SUBSTR (msi.description, '[^,]+', 1, 1) l_element_value
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS not NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       and msi.organization_id = 138;
             
SELECT TO_CHAR (SUBSTR (msi.segment1, 10, 5)) l_element,  REGEXP_SUBSTR (msi.description,  '[^,]+', 1, 2) l_element_value
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS not NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       and msi.organization_id = 138;
             
SELECT TO_CHAR (SUBSTR (msi.segment1, 15, 6)) l_element, REGEXP_SUBSTR (msi.description,  '[^,]+', 1, 3) l_element_value
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS not NULL
       AND msi.segment1 LIKE 'PAP%'
       AND msi.segment1 IN ( 'PAPLINRK0GS125R01150')
       and msi.organization_id = 138;
             
             
             