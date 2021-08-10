/* Formatted on 12/29/2019 5:42:25 PM (QP5 v5.287) */
SELECT --DISTINCT 
       alloc.ship_header_id,
       alloc.adjustment_num,
       sl.ship_line_group_id,
       sl.ship_line_id,
       sl.parent_ship_line_id,
       sl.ship_line_num,
       sh.organization_id,
       sl.inventory_item_id,
       msi.concatenated_segments inv_item,
       sl.primary_qty,
       uom.unit_of_measure,
       DECODE (assoc.from_parent_table_name,
               'INL_CHARGE_LINES', 'CHARGE',
               'INL_TAX_LINES', 'TAX',
               'ITEM PRICE')
          component_type,
       DECODE (assoc.from_parent_table_name,
               'INL_SHIP_HEADERS', 'OTHERS',
               'INL_SHIP_LINES', 'OTHERS',
               'INL_CHARGE_LINES', pe.price_element_code,
               'INL_TAX_LINES', tl.tax_code,
               msi.concatenated_segments)
          component_code,
       DECODE (assoc.from_parent_table_name,
               'INL_SHIP_HEADERS', 'OTHERS',
               'INL_SHIP_LINES', 'OTHERS',
               'INL_CHARGE_LINES', pe.NAME,
               'INL_TAX_LINES', tl.tax_code,
               msi.concatenated_segments)
          component_name,
       cl.charge_line_type_id,
       alloc.allocation_amt allocated_amt,
       alloc.estimated_amt estimated_allocated_amt
  FROM mtl_units_of_measure uom,
       pon_price_element_types_vl pe,
       mtl_system_items_kfv msi,
       inl_charge_lines cl,
       inl_tax_lines tl,
       inl_associations assoc,
       inl_ship_headers_all sh,
       inl_ship_lines_all sl2,
       inl_ship_lines_all sl,
       inl_allocations_v alloc
 WHERE     uom.uom_code = sl.primary_uom_code
       AND pe.price_element_type_id(+) = cl.charge_line_type_id
       AND msi.organization_id = sh.organization_id
       AND msi.inventory_item_id = sl.inventory_item_id
       AND sl2.ship_line_id(+) =
              DECODE (alloc.from_parent_table_name,
                      'INL_SHIP_LINES', alloc.from_parent_table_id,
                      NULL)
       AND cl.charge_line_id(+) =
              DECODE (alloc.from_parent_table_name,
                      'INL_CHARGE_LINES', alloc.from_parent_table_id,
                      NULL)
       AND tl.tax_line_id(+) =
              DECODE (alloc.from_parent_table_name,
                      'INL_TAX_LINES', alloc.from_parent_table_id,
                      NULL)
       AND sl2.ship_header_id(+) = alloc.ship_header_id
       AND assoc.association_id(+) = alloc.association_id
       AND sh.ship_header_id = sl.ship_header_id
       AND sh.ship_header_id = alloc.ship_header_id
       AND sl.ship_header_id = alloc.ship_header_id
       AND sl.ship_line_id = alloc.ship_line_id
       --and sl.ship_line_num='30'
       --AND sh.organization_id='735'
       and sh.ship_header_id='3961'