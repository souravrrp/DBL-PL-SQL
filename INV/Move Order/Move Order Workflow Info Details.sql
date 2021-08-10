/* Formatted on 6/4/2020 12:20:09 PM (QP5 v5.287) */
  SELECT x.header_id,
         x.LINE_ID,
         x.inventory_item_id,
         x.organization_id,
         x.line_number,
         x.date_required,
         x.item_description,
         x.item_code,
         x.quantity,
         x.secondary_quantity,
         x.from_subinventory_code,
         x.from_locator,
         x.to_subinventory_code,
         x.to_locator,
         x.uom_code,
         mck.concatenated_segments item_category,
         xxdbl_item_onhand_pkg.get_cosumption (x.inventory_item_id,
                                               x.organization_id)
            cosumption_qty,
         xxdbl_item_onhand_pkg.get_item_last_po_price (x.inventory_item_id)
            last_po_price,
         xxdbl_item_onhand_pkg.get_onhand_qty (x.inventory_item_id,
                                               x.organization_id,
                                               'N')
            current_stock,
         xxdbl_item_onhand_pkg.get_item_cost (x.inventory_item_id,
                                              x.organization_id)
            item_cost,
         x.cost_center,
         x.cost_center_desc,
         x.natural_account,
         x.natural_account_desc,
         x.safety_stock,
         x.use_area,
         x.specs
    FROM xxdbl_move_order_v x,
         mtl_item_categories mic,
         mtl_categories_kfv mck,
         mtl_category_sets mcs
   WHERE     1 = 1
         AND x.header_id = :mo_header_no   --'596645'-- cp_mo_header_id
         AND x.inventory_item_id = mic.inventory_item_id(+)
         AND x.organization_id = mic.organization_id(+)
         AND mic.category_id = mck.category_id(+)
         AND mic.category_set_id = mcs.category_set_id(+)
         AND mcs.category_set_name = 'Inventory'
ORDER BY x.header_id, x.line_number;