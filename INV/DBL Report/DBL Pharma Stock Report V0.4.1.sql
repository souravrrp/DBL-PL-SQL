/* Formatted on 1/8/2022 5:53:02 PM (QP5 v5.374) */
  SELECT ou.ledger_name,
         ou.legal_entity_name,
         ood.operating_unit,
         hou.name,
         ood.organization_code,
         ood.organization_name,
         cat.segment1             item_category,
         cat.segment2             item_type,
         msi.segment1             item_code,
         msi.description          item_name,
         msi.primary_uom_code     uom,
         SUM (prla.quantity) --(CASE WHEN SUM (pll.quantity) = 0 THEN SUM (prla.quantity) ELSE ABS (SUM (prla.quantity) - SUM (pll.quantity)) END)
                                  pr_quantity
    --         (CASE
    --              WHEN SUM (pll.quantity_received) = 0 THEN SUM (pll.quantity)
    --              ELSE ABS (SUM (pll.quantity) - SUM (pll.quantity_received))
    --          END)
    --             po_quantity,
    --         SUM (pll.quantity_received)
    --             grn_quantity,
    --         (SELECT SUM (ohqd.primary_transaction_quantity)
    --            FROM apps.mtl_onhand_quantities_detail ohqd
    --           WHERE     1 = 1
    --                 AND EXISTS
    --                         (SELECT 1
    --                            FROM apps.mtl_secondary_inventories imsi
    --                           WHERE     1 = 1
    --                                 AND imsi.organization_id =
    --                                     ohqd.organization_id
    --                                 AND imsi.secondary_inventory_name =
    --                                     ohqd.subinventory_code
    --                                 AND (UPPER (imsi.description) LIKE
    --                                          '%QUARANTINE%'))
    --                 AND ohqd.organization_id = msi.organization_id
    --                 AND ohqd.inventory_item_id = msi.inventory_item_id)
    --             quarantine_qty,
    --         apps.xxdbl_fnc_get_onhand_qty (msi.inventory_item_id,
    --                                        msi.organization_id,
    --                                        'OHQ')
    --             onhand_quantity,
    --         (SELECT NVL (SUM (mr.reservation_quantity), 0)
    --            FROM inv.mtl_reservations mr
    --           WHERE     mr.organization_id = msi.organization_id
    --                 AND mr.inventory_item_id = msi.inventory_item_id)
    --             reserve_quantity
    FROM inv.mtl_system_items_b           msi,
         --po.po_headers_all                pha,
         po.po_lines_all                  pla,
         --po.po_line_locations_all         pll,
         po.po_distributions_all          pda,
         apps.mtl_item_categories_v       cat,
         po.po_req_distributions_all      prda,
         po.po_requisition_lines_all      prla,
         po.po_requisition_headers_all    prha,
         apps.hr_operating_units          hou,
         apps.xxdbl_company_le_mapping_v  ou,
         apps.org_organization_definitions ood
   WHERE     1 = 1
         AND ( :p_org_code IS NULL OR (ood.organization_code = :p_org_code))
         AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
         AND ( :p_item_category IS NULL OR (cat.segment1 = :p_item_category))
         --AND (   :p_date IS NULL OR (TRUNC (pha.approved_date) <= TRUNC ( :p_date)))
         --AND ( :p_org_id IS NULL OR (pha.org_id = :p_org_id))
         --AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no))
         --AND ( :p_req_no IS NULL OR (prha.segment1 = :p_req_no))
         --AND ( :p_item_type IS NULL OR (mc.segment2 = :p_item_type))
         --AND pha.po_header_id(+) = pla.po_header_id
         AND pda.po_header_id=pla.po_header_id(+)
         AND pda.po_line_id = pla.po_line_id(+)
         --AND pha.po_header_id = pll.po_header_id(+)
         --AND pla.po_line_id = pll.po_line_id(+)
         --AND pda.line_location_id = pll.line_location_id(+)
         --AND (pha.cancel_flag IS NULL OR pha.cancel_flag = 'N')
         --AND (pla.cancel_flag IS NULL OR pla.cancel_flag = 'N')
         --AND pda.gl_cancelled_date IS NULL
         AND prla.item_id = msi.inventory_item_id(+)
         --AND NVL (prla.item_id, pla.item_id) = msi.inventory_item_id(+)
         AND msi.inventory_item_id = cat.inventory_item_id(+)
         AND msi.organization_id = cat.organization_id(+)
         --AND NVL (prla.destination_organization_id, pda.destination_organization_id) = msi.organization_id(+)
         AND prla.destination_organization_id = msi.organization_id(+)
         AND msi.organization_id = ood.organization_id(+)
         AND prda.distribution_id = pda.req_distribution_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND prha.segment1 IN ('21111003553')
         AND ood.operating_unit = ou.org_id(+)
         AND ood.operating_unit = hou.organization_id(+)
--AND pla.item_id IS NOT NULL
GROUP BY ou.ledger_name,
         ou.legal_entity_name,
         ood.operating_unit,
         hou.name,
         ood.organization_code,
         ood.organization_name,
         cat.segment1,
         cat.segment2,
         msi.segment1,
         msi.description,
         msi.primary_uom_code,
         msi.inventory_item_id,
         msi.organization_id
ORDER BY cat.segment1, cat.segment2, msi.segment1 DESC