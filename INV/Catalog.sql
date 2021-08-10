SELECT c.segment1 || '-' || a.element_value
FROM mtl_descr_element_values a
,mtl_descriptive_elements b
,mtl_item_catalog_groups c
,mtl_system_items_fvl d
WHERE a.element_name = b.element_name
AND a.inventory_item_id = d.inventory_item_id
-- AND d.organization_id = 'Your Organization ID'
AND b.item_catalog_group_id = d.item_catalog_group_id
AND b.item_catalog_group_id = c.item_catalog_group_id
AND a.element_name = b.element_name
--AND a.element_name LIKE '%Vendor%'
--AND a.inventory_item_id = 'Your Inventory Item ID'
AND ROWNUM = 1;

--------------------------------------------------------------------------------
select
*
from
MTL_SYSTEM_ITEMS_FVL 


select
*
from
MTL_DESCR_ELEMENT_VALUES_V 

select
*
from
MTL_ITEM_CATALOG_GROUPS_B


--------------------------------------------------------------------------------
/* Formatted on 10/13/2020 1:48:29 PM (QP5 v5.287) */
SELECT *
  FROM mtl_descr_element_values a,
       mtl_descriptive_elements b,
       mtl_item_catalog_groups c,
       mtl_system_items_fvl d
 WHERE     a.element_name = b.element_name
       AND a.inventory_item_id = d.inventory_item_id
       -- AND d.organization_id = 'Your Organization ID'
       AND b.item_catalog_group_id = d.item_catalog_group_id
       AND b.item_catalog_group_id = c.item_catalog_group_id
       AND a.element_name = b.element_name
       and c.item_catalog_group_id=54
       and d.segment1='PAPLINRK0GS125R01150'
       and d.organization_id=138
       --AND a.element_name LIKE '%Vendor%'
       --AND a.inventory_item_id = 'Your Inventory Item ID'
       --AND ROWNUM = 1;