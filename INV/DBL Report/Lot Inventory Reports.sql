/* Formatted on 7/8/2020 3:09:25 PM (QP5 v5.287) */
  SELECT mp.organization_code ORG_CODE,
         mss.secondary_inventory_name SUBINV,
         msi.concatenated_segments ITEM_NO,
         msi.description ITEM_DESC,
         mln.lot_number LOT,
         mln.origination_date ORIG_DATE,
         mln.expiration_date EXP_DATE,
         mil.concatenated_segments LOCATOR,
         SUM (ohd.primary_transaction_quantity) QTY,
         msi.primary_uom_code UOM,
         SUM (NVL (ohd.secondary_transaction_quantity, 0)) SEC_QTY,
         msi.secondary_uom_code SEC_UOM,
         mms.status_code STATUS,
         mln.grade_code GRADE
    FROM mtl_lot_numbers mln,
         mtl_item_locations_kfv mil,
         mtl_onhand_quantities_detail ohd,
         mtl_material_statuses_vl mms,
         mtl_system_items_kfv msi,
         mtl_secondary_inventories mss,
         mtl_parameters mp
   WHERE     msi.inventory_item_id = mln.inventory_item_id
         AND msi.organization_id = mln.organization_id
         -- for the bug 10236246
         AND ohd.status_id IS NULL
         -- end of the bug 10236246
         AND mln.status_id = mms.status_id(+)
         AND ohd.organization_id = mln.organization_id
         AND ohd.inventory_item_id = mln.inventory_item_id
         AND ohd.lot_number = mln.lot_number
         AND ohd.locator_id = mil.inventory_location_id(+)
         AND ohd.organization_id = mp.organization_id
         AND ohd.subinventory_code = mss.secondary_inventory_name
         AND ohd.organization_id = msi.organization_id
         AND ohd.inventory_item_id = msi.inventory_item_id
GROUP BY mp.organization_code,
         mss.secondary_inventory_name,
         msi.concatenated_segments,
         msi.description,
         mln.lot_number,
         mln.origination_date,
         mln.expiration_date,
         mil.concatenated_segments,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         mms.status_code,
         mln.grade_code
-- For the bug 10236246 query the on hand material status tracked org.
UNION
  SELECT mp.organization_code ORG_CODE,
         mss.secondary_inventory_name SUBINV,
         msi.concatenated_segments ITEM_NO,
         msi.description ITEM_DESC,
         mln.lot_number LOT,
         mln.origination_date ORIG_DATE,
         mln.expiration_date EXP_DATE,
         mil.concatenated_segments LOCATOR,
         SUM (ohd.primary_transaction_quantity) QTY,
         msi.primary_uom_code UOM,
         SUM (NVL (ohd.secondary_transaction_quantity, 0)) SEC_QTY,
         msi.secondary_uom_code SEC_UOM,
         mms.status_code STATUS,
         mln.grade_code GRADE
    FROM mtl_lot_numbers mln,
         mtl_item_locations_kfv mil,
         mtl_onhand_quantities_detail ohd,
         mtl_material_statuses_vl mms,
         mtl_system_items_kfv msi,
         mtl_secondary_inventories mss,
         mtl_parameters mp
   WHERE     msi.inventory_item_id = mln.inventory_item_id
         AND msi.organization_id = mln.organization_id
         AND ohd.status_id IS NOT NULL
         AND ohd.status_id = mms.status_id(+)
         AND ohd.organization_id = mln.organization_id
         AND ohd.inventory_item_id = mln.inventory_item_id
         AND ohd.lot_number = mln.lot_number
         AND ohd.locator_id = mil.inventory_location_id(+)
         AND ohd.organization_id = mp.organization_id
         AND ohd.subinventory_code = mss.secondary_inventory_name
         AND ohd.organization_id = msi.organization_id
         AND ohd.inventory_item_id = msi.inventory_item_id
GROUP BY mp.organization_code,
         mss.secondary_inventory_name,
         msi.concatenated_segments,
         msi.description,
         mln.lot_number,
         mln.origination_date,
         mln.expiration_date,
         mil.concatenated_segments,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         mms.status_code,
         mln.grade_code