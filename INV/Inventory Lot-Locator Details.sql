/* Formatted on 9/8/2020 10:37:37 AM (QP5 v5.287) */
  SELECT mp.operating_unit,
         mp.organization_code,
         msib.segment1 item_number,
         msib.description,
         msib.inventory_item_status_code Item_Status,
         mms2.status_code Sub_Status,
         mil.segment1 Locator,
         mms3.status_code location_status,
         mln.lot_number,
         msib.primary_uom_code,
         SUM (mpoq.primary_transaction_quantity) onhand_qty,
         mln.organization_id,
         TO_CHAR (mln.expiration_date, 'DD-MON-RRRR') expiration_date,
         mms1.status_code Lot_status,
         mln.inventory_item_id,
         mil.inventory_location_id
    FROM mtl_system_items_b msib,
         mtl_item_status mis,
         mtl_item_locations mil,
         org_organization_definitions mp,
         mtl_lot_numbers mln,
         mtl_onhand_quantities_detail mpoq,
         mtl_material_statuses_tl mms1,
         mtl_material_statuses_tl mms2,
         mtl_material_statuses_tl mms3,
         mtl_secondary_inventories msi
   WHERE     1 = 1
         AND mln.inventory_item_id = msib.inventory_item_id
         AND mln.organization_id = msib.organization_id
         AND mis.inventory_item_status_code = msib.inventory_item_status_code
         AND msib.organization_id = mp.organization_id
         AND mil.inventory_location_id = mpoq.locator_id
         AND mil.organization_id = mln.organization_id
         AND mln.inventory_item_id = mpoq.inventory_item_id(+)
         AND mln.organization_id = mpoq.organization_id(+)
         AND mln.lot_number = mpoq.lot_number(+)
         AND mpoq.organization_id = msi.organization_id
         AND mpoq.subinventory_code = msi.secondary_inventory_name
         AND mms1.status_id = mln.status_id
         AND mms2.status_id = msi.status_id
         AND mms3.status_id = mil.status_id
         AND mms1.language = USERENV ('LANG')
         AND mms2.language = USERENV ('LANG')
         AND mms3.language = USERENV ('LANG')
         AND (   :P_OPERATING_UNIT IS NULL
              OR (mp.OPERATING_UNIT = :P_OPERATING_UNIT))
         AND (   :P_ORGANIZATION_CODE IS NULL
              OR (mp.ORGANIZATION_CODE = :P_ORGANIZATION_CODE))
         AND (   :P_ORGANIZATION_ID IS NULL
              OR (mp.ORGANIZATION_ID = :P_ORGANIZATION_CODE))
         AND ( :P_LOCATOR_NUMBER IS NULL OR (MIL.SEGMENT1 = :P_LOCATOR_NUMBER))
         AND ( :P_LOT_NUMBER IS NULL OR (MLN.LOT_NUMBER = :P_LOT_NUMBER))
         AND ( :P_ITEM_CODE IS NULL OR (MSIB.SEGMENT1 = :P_ITEM_CODE))
--AND mln.organization_id = :p_organization_id
--AND msib.inventory_item_id = :p_inventory_item_id
GROUP BY mp.organization_code,
         msib.segment1,
         msib.description,
         mln.inventory_item_id,
         mln.organization_id,
         mln.lot_number,
         mil.inventory_location_id,
         msi.secondary_inventory_name,
         msib.inventory_item_status_code,
         msi.attribute6,
         mms1.status_code,
         mms2.status_code,
         mms3.status_code,
         msi.attribute4,
         mil.segment1,
         msib.primary_uom_code,
         (mln.expiration_date - SYSDATE),
         msib.shelf_life_days,
         TO_CHAR (mln.expiration_date, 'DD-MON-RRRR'),
         mln.status_id,
         mpoq.locator_id,
         mp.operating_unit,
         mln.attribute14,
         msi.reservable_type;