/* Formatted on 3/27/2021 2:53:33 PM (QP5 v5.354) */
select msi.organization_id,
       ood.organization_code,
       ood.organization_name,
       msi.inventory_item_id,
       msi.segment1                               item_code,
       msi.description,
       msi.primary_uom_code,
       msi.secondary_uom_code,
       msi.attribute14                            template_name,
       cat.category_set_name                      category_set,
       cat.category_id,
       cat.segment1                               line_of_business,
       cat.segment2                               item_category,
       cat.segment3                               item_type,
       cat.segment4                               catelog,
       cat.category_concat_segs                   category_segments,
       msi.creation_date,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 10)    item_type,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 20)    count_name,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 30)    product_type,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 40)    content_name,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 50)    style_name,
       (select mdev.element_value from apps.mtl_descr_element_values mdev where     mdev.inventory_item_id = msi.inventory_item_id and mdev.element_sequence = 60)    process_name
  --,MSI.*
  --,OOD.*
  --,CAT.*
  from apps.mtl_system_items_b            msi,
       apps.org_organization_definitions  ood,
       apps.mtl_item_categories_v         cat
 where     1 = 1
       and msi.organization_id = ood.organization_id
       and msi.inventory_item_id = cat.inventory_item_id
       and msi.organization_id = cat.organization_id
       AND (   :P_OPERATING_UNIT IS NULL    OR (OOD.OPERATING_UNIT = :P_OPERATING_UNIT))
       AND (   :P_ORG_NAME IS NULL          OR (UPPER(OOD.ORGANIZATION_NAME) LIKE UPPER('%'||:P_ORG_NAME||'%') ))
       AND (   :P_ORGANIZATION_CODE IS NULL OR (OOD.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
       AND (   :P_ITEM_CODE IS NULL         OR (MSI.SEGMENT1 = :P_ITEM_CODE))
       AND (   :P_ITEM_DESC IS NULL         OR (UPPER(MSI.DESCRIPTION) LIKE UPPER('%'||:P_ITEM_DESC||'%') ))
       AND (   :P_LINE_OF_BUSINESS IS NULL  OR (CAT.SEGMENT1 = :P_LINE_OF_BUSINESS))
       AND (   :P_MAJOR_CATEGORY IS NULL    OR (CAT.SEGMENT2 = :P_MAJOR_CATEGORY))
       AND (   :P_MINOR_CATEGORY IS NULL    OR (CAT.SEGMENT3 = :P_MINOR_CATEGORY))
       AND (   :P_ITEM_CATELOG IS NULL      OR (CAT.SEGMENT4 = :P_ITEM_CATELOG))
       and msi.inventory_item_status_code = 'Active'
       --and organization_code not in ('imo')
       --and organization_code in ('251')
       --and operating_unit in (85)
       --and msi.inventory_item_id in ('7297')
       --and msi.segment1 in ('ft-gp6060-038bk')
       --and msi.segment1 like ('puma%')
       --and msi.description in ('40s1-cotton-100%-ch organic')
       --and msi.primary_uom_code='pcs'
       --and msi.organization_id in (101)
       and cat.category_set_id = 1
       --and cat.category_id='74551'
       --and cat.segment2 not in ('finish goods')
       --and cat.segment2='brnd'
       --and cat.segment3='gift'
       --and to_char(msi.creation_date,'dd-mon-rr')>'05-mar-21'
       and msi.enabled_flag = 'Y';