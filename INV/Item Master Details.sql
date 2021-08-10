/* Formatted on 12/17/2019 12:55:41 PM (QP5 v5.287) */
SELECT msi.segment1 item_code,
       msi.description,
       msi.primary_uom_code,
       msi.cycle_count_enabled_flag,
       msi.inspection_required_flag,
       msi.attribute_category item_attribute,
       msi.attribute3 item_attribute3,
       msi.attribute14 legacy_code,
       msi.stock_enabled_flag stockable,
       msi.mtl_transactions_enabled_flag transactable,
       msi.lot_control_code,
       msi.location_control_code,
       msi.purchasing_enabled_flag,
       msi.must_use_approved_vendor_flag,
       msi.buyer_id,
       pap.full_name buyer_name,
       msi.list_price_per_unit,
       (msi.expense_account) expense_account,
       msi.receiving_routing_id,
       misi.secondary_inventory subinventory,
       msi.inventory_item_id inv_item_id,
       msi.organization_id item_organization_id,
       ood.organization_name,
       mcv.segment1 cat_seg1,
       mcv.segment2 cat_seg2,
       mcv.segment3 cat_seg3,
       mcv.segment4 cat_seg4,
       mcv.description item_cat_desc,
       mcs.category_set_name item_category_set,
       mcs.description item_cat_set_desc,
       msi.attribute14 template_name
       --,msi.*
       --,msl.*
       --,mil.*
       --,misi.*
       --,mic.*
       --,mcv.*
       --,mcs.*
  FROM mtl_system_items msi,
       mtl_secondary_locators msl,
       mtl_item_locations mil,
       per_all_people_f pap,
       mtl_item_sub_inventories misi,
       org_organization_definitions ood,
       mtl_item_categories mic,
       mtl_categories_vl mcv,
       mtl_category_sets mcs
 WHERE     msi.inventory_item_id = msl.inventory_item_id(+)
       AND msi.organization_id = msl.organization_id(+)
       AND msl.secondary_locator = mil.inventory_location_id(+)
       AND msl.organization_id = mil.organization_id(+)
       AND pap.person_id(+) = msi.buyer_id
       AND msi.inventory_item_id = misi.inventory_item_id(+)
       AND msi.organization_id = misi.organization_id(+)
       AND ood.organization_id = msi.organization_id
       AND mic.inventory_item_id = msi.inventory_item_id
       AND mic.organization_id = msi.organization_id
       AND mcs.category_set_id = mic.category_set_id
       AND mcs.structure_id = mcv.structure_id
       AND mcv.category_id = mic.category_id
       AND msi.inventory_item_status_code = 'Active'
       and msi.segment1='FT-GP6060-038BK'