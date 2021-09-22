/* Formatted on 9/21/2021 11:37:36 AM (QP5 v5.354) */
SELECT DISTINCT A.ELEMENT_VALUE
  FROM MTL_DESCR_ELEMENT_VALUES_V a, apps.mtl_system_items_kfv msi
 WHERE     1 = 1
       AND msi.inventory_item_id = a.inventory_item_id
       AND msi.concatenated_segments = :ITEM
       AND A.ELEMENT_NAME = 'Manufacturer'
       AND MSI.ORGANIZATION_ID = 138