select
*
from
APPS.XXDBL_MTL_ITEM_CTG_INFO
APPS.XX_AR_CUSTOMER_SITE_V
where 1=1
and inventory_Item_id = 310200
and organization_id=152;

SELECT CAT.ORGANIZATION_ID,
            CAT.INVENTORY_ITEM_ID,
            MAX (CAT.SEGMENT1) SEGMENT1,
            MAX (
               CASE
                  WHEN CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET'
                  THEN
                     CAT.SEGMENT2
               END)
               ITEM_SIZE,
            MAX (
               CASE WHEN CATEGORY_SET_NAME = 'Inventory' THEN CAT.SEGMENT3 END)
               PRODUCT_TYPE,
            MAX (CAT.SEGMENT4) SEGMENT4,
            MAX (
               CASE
                  WHEN CATEGORY_SET_NAME = 'DBL_SALES_CAT_SET'
                  THEN
                     CATEGORY_CONCAT_SEGS
               END)
               PRODUCT_CATEGORY
       FROM MTL_ITEM_CATEGORIES_V CAT             --, mtl_system_items_KFV MSI
      WHERE CAT.CATEGORY_SET_NAME IN ('DBL_SALES_CAT_SET', 'Inventory')
   -- AND CAT.INVENTORY_ITEM_ID = MSI.INVENTORY_iTEM_ID
      AND CAT.inventory_Item_id = 310200
   GROUP BY CAT.ORGANIZATION_ID, CAT.INVENTORY_ITEM_ID;