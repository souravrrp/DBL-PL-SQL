/* Formatted on 12/14/2020 4:37:59 PM (QP5 v5.287) */
  SELECT hou.NAME,
         ood.organization_code,
         ood.organization_name,
         pha.po_header_id,
         pha.segment1,
         TRUNC (pha.creation_date) po_date,
         pla.item_id,
         ksiv.concatenated_segments,
         pla.item_description,
         m2.segment1 item_category,
         pll.need_by_date,
         aps.segment1 vendor_number,
         aps.vendor_name,
         pll.quantity quantity,
         pll.quantity_received quantity_received,
         pll.quantity_rejected quantity_rejected,
         pll.quantity_cancelled quantity_cancelled,
         (  pll.quantity
          - NVL (pll.quantity_received, 0)
          - NVL (pll.quantity_rejected, 0)
          - NVL (pll.quantity_cancelled, 0))
            quantity_backordered,
         pha.authorization_status,
         (pll.quantity * pla.unit_price) po_amount
    FROM po_headers_all pha,
         ap_suppliers aps,
         po_lines_all pla,
         po_line_locations_all pll,
         hr_operating_units hou,
         apps.org_organization_definitions ood,
         mtl_categories m2,
         mtl_system_items_kfv ksiv
   WHERE     pha.vendor_id = aps.vendor_id
         AND pha.po_header_id = pla.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pla.po_header_id = pll.po_header_id
         AND pha.org_id = hou.organization_id
         AND ood.operating_unit = hou.organization_id
         AND pll.ship_to_organization_id = ood.organization_id
         AND m2.category_id = pla.category_id
         AND ksiv.inventory_item_id = pla.item_id
         AND ksiv.organization_id = ood.organization_id
         AND PLL.Quantity >
                  NVL (pll.quantity_received, 0)
                + NVL (pll.quantity_cancelled, 0)
--  AND pha.segment1 ='12104722'
ORDER BY aps.vendor_name, pla.item_description;