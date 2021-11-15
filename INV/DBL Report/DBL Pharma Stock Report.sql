/* Formatted on 11/11/2021 10:52:35 AM (QP5 v5.365) */
  SELECT ou.ledger_name,
         ou.legal_entity_name,
         pha.org_id,
         hou.name,
         ood.organization_code,
         ood.organization_name,
         mc.segment1
             item_category,
         mc.segment2
             item_type,
         msi.segment1
             item_code,
         pla.item_description
             item_name,
         msi.primary_uom_code
             uom,
         (CASE
              WHEN SUM (pll.quantity) = 0 THEN SUM (prla.quantity)
              ELSE ABS (SUM (prla.quantity) - SUM (pll.quantity))
          END)
             pr_quantity,
         (CASE
              WHEN SUM (pll.quantity_received) = 0 THEN SUM (pll.quantity)
              ELSE ABS (SUM (pll.quantity) - SUM (pll.quantity_received))
          END)
             po_quantity,
         SUM (pll.quantity_received)
             grn_quantity,
         (SELECT SUM (ohqd.primary_transaction_quantity)
            FROM apps.mtl_onhand_quantities_detail ohqd
           WHERE     1 = 1
                 AND EXISTS
                         (SELECT 1
                            FROM apps.mtl_secondary_inventories imsi
                           WHERE     1 = 1
                                 AND imsi.organization_id =
                                     ohqd.organization_id
                                 AND (UPPER (imsi.description) LIKE
                                          '%QUARANTINE%'))
                 AND ohqd.organization_id = msi.organization_id
                 AND ohqd.inventory_item_id = msi.inventory_item_id)
             quarantine_qty,
         apps.xxdbl_fnc_get_onhand_qty (msi.inventory_item_id,
                                        msi.organization_id,
                                        'OHQ')
             onhand_quantity
    FROM po.po_headers_all                pha,
         po.po_lines_all                  pla,
         po.po_line_locations_all         pll,
         po.po_distributions_all          pda,
         inv.mtl_system_items_b           msi,
         inv.mtl_item_categories          mic,
         inv.mtl_categories_b             mc,
         apps.mtl_category_sets           mcs,
         po.po_req_distributions_all      prda,
         po.po_requisition_lines_all      prla,
         po.po_requisition_headers_all    prha,
         apps.hr_operating_units          hou,
         apps.xxdbl_company_le_mapping_v  ou,
         apps.org_organization_definitions ood
   WHERE     1 = 1
         AND ( :p_org_code IS NULL OR (ood.organization_code = :p_org_code))
         AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
         AND ( :p_item_category IS NULL OR (mc.segment1 = :p_item_category))
         AND (   :p_date IS NULL
              OR (TRUNC (pha.approved_date) <= TRUNC ( :p_date)))
         --AND ( :p_org_id IS NULL OR (pha.org_id = :p_org_id))
         --AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no))
         --AND ( :p_req_no IS NULL OR (prha.segment1 = :p_req_no))
         --AND ( :p_item_type IS NULL OR (mc.segment2 = :p_item_type))
         AND msi.inventory_item_id = mic.inventory_item_id(+)
         AND msi.organization_id = mic.organization_id(+)
         AND pla.category_id = mic.category_id(+)
         AND pla.category_id = mc.category_id(+)
         AND mc.structure_id = mcs.structure_id(+)
         AND mic.category_set_id = mcs.category_set_id(+)
         AND (pha.cancel_flag IS NULL OR pha.cancel_flag = 'N')
         AND (pla.cancel_flag IS NULL OR pla.cancel_flag = 'N')
         AND pda.gl_cancelled_date IS NULL
         AND pla.po_header_id = pha.po_header_id
         AND pla.po_header_id = pda.po_header_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pda.po_line_id
         AND pla.po_line_id = pll.po_line_id
         AND pll.line_location_id = pda.line_location_id
         AND pla.item_id = msi.inventory_item_id(+)
         AND ood.organization_id = msi.organization_id(+)
         AND ood.organization_id = pda.destination_organization_id
         AND ood.operating_unit = pha.org_id
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         --AND prha.segment1 IN ('20111007434')
         AND ood.operating_unit = ou.org_id
         AND hou.organization_id = ood.operating_unit
GROUP BY ou.ledger_name,
         ou.legal_entity_name,
         pha.org_id,
         hou.name,
         ood.organization_code,
         ood.organization_name,
         mc.segment1,
         mc.segment2,
         msi.segment1,
         pla.item_description,
         msi.primary_uom_code,
         msi.inventory_item_id,
         msi.organization_id
ORDER BY mc.segment1, mc.segment2, msi.segment1 DESC;