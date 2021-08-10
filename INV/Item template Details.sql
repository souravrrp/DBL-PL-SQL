/* Formatted on 10/4/2020 4:25:07 PM (QP5 v5.287) */
  SELECT it.template_name,
         it.description Template_description,
         ita.attribute_name,
         ita.attribute_value,
         ita.REPORT_USER_VALUE,
         it.*
    --,ita.*
    FROM apps.mtl_item_templates it, apps.mtl_item_templ_attributes ita
   WHERE     1 = 1
         --AND it.template_name = 'DBL DIS RAW MATL DUAL UOM LOT'
         AND it.template_id = ita.template_id
         AND ita.attribute_value IS NOT NULL
ORDER BY 1, 2;

SELECT msi.segment1, mit.template_name, msi.attribute14 template_name
  FROM mtl_item_templ_attributes mita,
       mtl_system_items_kfv msi,
       mtl_item_templates mit
 WHERE     mita.attribute_value IS NOT NULL
       AND mita.attribute_name = 'MTL_SYSTEM_ITEMS.ITEM_TYPE'
       AND mit.template_id = mita.template_id
       AND mita.attribute_value = msi.item_type
       AND msi.organization_id = 138
       AND msi.segment1 = 'CHEMICAL000000000006';


SELECT msi.segment1, msi.*
  FROM
       mtl_system_items_kfv msi
 WHERE  1=1
       AND msi.organization_id = 138
       AND msi.segment1 = 'CHEMICAL000000000006';