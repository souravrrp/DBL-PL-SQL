/* Formatted on 9/24/2020 11:30:42 AM (QP5 v5.354) */
SELECT msi.segment1, msi.inventory_item_id
  FROM mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.item_catalog_group_id IS NULL
       AND msi.segment1 LIKE 'YRN%'
       --AND msi.segment1 IN ( 'YRN04S100CTN52120313')
       AND msi.organization_id = 138
--       AND EXISTS
--               (SELECT 1
--                  FROM APPS.MTL_ITEM_CATEGORIES_V CAT
--                 WHERE     1 = 1
--                       AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
--                       AND CAT.SEGMENT3 IN ('YARN', 'DYED YARN'))
;

SELECT * FROM mtl_desc_elem_val_interface;

SELECT * FROM mtl_system_items;


SELECT *
  FROM mtl_system_items_interface
 WHERE 1 = 1 AND INVENTORY_ITEM_ID = 414484 AND organization_id = 138;

DELETE FROM mtl_system_items_interface
      WHERE 1 = 1 AND INVENTORY_ITEM_ID = 168027 AND organization_id = 138;