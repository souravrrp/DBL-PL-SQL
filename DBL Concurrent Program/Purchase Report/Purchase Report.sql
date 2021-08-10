SELECT hou.name OU_Name,
          led.legal_entity_id,
          led.legal_entity_name,
          org.organization_name,
          lc.lc_opening_date as "Date",
          NVL (lc.lc_number, btb_lc_no_phy) AS "LC_Number",
          msi.description as "Type",
          sup.vendor_name AS "Party_Name",
          rt.primary_quantity as "Receive_Quantity",
          rsh.receipt_num as "GRN_Number",
          pla.quantity as "LC_Quntity",
          lc.LC_VALUE as "LC_VALUE",
          pla.unit_price as "PI_Rate",
          (lc.LC_VALUE*pha.rate) AS "Value_Actual",
          alloc.charge_line_type_name AS charge_type,
          sum(alloc.estimated_amt) AS estimated_amount,
          sum(alloc.billed_amt) AS actual_amount
     FROM apps.po_headers_all pha,
          apps.xxdbl_company_le_mapping_v led,
          apps.ap_suppliers sup,
          apps.ap_supplier_sites_all sups,
          apps.po_lines_all pla,
          apps.po_line_types_b plt,
          apps.po_line_locations_all pll,
          apps.inl_ship_lines_all isl,
          apps.inl_ship_headers_all ish,
          inl_charge_allocations_v alloc,
          apps.mtl_system_items_b msi,
          apps.mtl_item_categories mic,
          apps.mtl_categories mc,
          apps.org_organization_definitions org,
          apps.hr_operating_units hou,
          apps.po_distributions_all pda,
          apps.po_req_distributions_all prod,
          apps.po_requisition_lines_all prol,
          apps.po_requisition_headers_all prha,
          apps.mtl_txn_request_lines l,
          apps.mtl_txn_request_headers mtrh,
          apps.rcv_transactions rt,
          apps.rcv_shipment_headers rsh,
          apps.ap_invoice_lines_all aila,
          apps.ap_invoices_all ail,
          apps.ap_invoice_payments_all pm,
          apps.ap_checks_all ck,
          xx_lc_details lc,
          xxdbl.xx_explc_btb_req_link b2b,
          xxdbl.xx_explc_btb_mst b2b2
    WHERE     pha.po_header_id = pla.po_header_id
          AND pha.org_id = pla.org_id
          AND pha.org_id = led.org_id
          AND pha.org_id = hou.organization_id
          AND pha.po_header_id = pll.po_header_id
          AND pla.po_line_id = pll.po_line_id
          AND pla.line_type_id = plt.line_type_id
          AND pla.item_id = msi.inventory_item_id
          AND pll.ship_to_organization_id = msi.organization_id
          AND msi.inventory_item_id = mic.inventory_item_id
          AND msi.organization_id = mic.organization_id              
          AND mic.category_id = mc.category_id
          AND mic.category_set_id = 1
          AND pha.vendor_id = sup.vendor_id
          AND sup.vendor_id = sups.vendor_id
          AND pll.ship_to_organization_id = org.organization_id
          AND pha.vendor_site_id = sups.vendor_site_id(+)
          AND pha.type_lookup_code = 'STANDARD'
          AND pha.segment1 = lc.po_number(+)
          AND pha.po_header_id = pda.po_header_id
          AND pla.po_line_id = pda.po_line_id
          AND pll.line_location_id = pda.line_location_id
          AND pll.line_location_id = isl.ship_line_source_id(+)
          AND isl.ship_header_id = ish.ship_header_id(+)
          AND ish.ship_header_id = alloc.ship_header_id(+)
          AND isl.ship_header_id = alloc.ship_header_id(+)
          AND rsh.shipment_header_id=alloc.shipment_header_id(+)
          AND isl.ship_line_id = alloc.ship_line_id(+)
          AND pda.req_distribution_id = prod.distribution_id(+)
          AND prod.requisition_line_id = prol.requisition_line_id(+)
          AND prol.requisition_header_id = prha.requisition_header_id(+)
          AND pha.po_header_id = rt.po_header_id
          AND pla.po_line_id = rt.po_line_id
          AND rt.shipment_header_id = rsh.shipment_header_id
          AND pla.po_header_id = aila.po_header_id
          AND pll.line_location_id = aila.po_line_location_id
          AND pla.po_line_id = aila.po_line_id
          AND l.attribute14(+) = prod.distribution_id
          AND l.header_id = mtrh.header_id(+)
          AND pla.org_id = aila.org_id
          AND aila.invoice_id = ail.invoice_id
          AND aila.org_id = ail.org_id
          AND rt.transaction_id = aila.RCV_TRANSACTION_ID
          AND ail.invoice_id = pm.invoice_id(+)
          AND pm.check_id = ck.check_id(+)
          AND pha.segment1 = b2b.po_number(+)
          AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
          AND rt.transaction_type = 'RECEIVE'
          AND line_type_lookup_code = 'ITEM'
          AND pla.quantity <> 0
          AND pll.quantity_received <> 0
          AND NVL (pla.cancel_flag, 'N') = 'N'
          AND NVL (pll.cancel_flag, 'N') = 'N'
          AND pll.cancel_date IS NULL
          AND ail.CANCELLED_DATE IS NULL
          AND isl.match_id IS NULL
          AND pda.quantity_cancelled = 0
          and lc.lc_status='Y'
          and (:lc_number is null or (lc.lc_number = :lc_number))
          --AND led.legal_entity_id=:legal_entity
          --AND trunc(lc.lc_opening_date) between nvl(:p_date_from,trunc(lc.lc_opening_date)) and nvl(:p_date_to,trunc(lc.lc_opening_date))
          --and (:p_purchase_item is null or (msi.description = :p_purchase_item))
group by
          hou.name,
          led.legal_entity_id,
          led.legal_entity_name,
          org.organization_name,
          lc.lc_opening_date,
          NVL (lc.lc_number, btb_lc_no_phy),
          msi.description,
          sup.vendor_name,
          rt.primary_quantity,
          rsh.receipt_num,
          pla.quantity,
          lc.LC_VALUE,
          pla.unit_price,
          (lc.LC_VALUE*pha.rate),
          alloc.charge_line_type_name
;