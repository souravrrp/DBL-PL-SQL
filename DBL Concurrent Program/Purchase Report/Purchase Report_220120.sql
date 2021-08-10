SELECT * FROM
(
  SELECT led.UNIT_NAME OU_Name,
          led.legal_entity_id,
          led.legal_entity_name,
          lc.lc_opening_date as "Date",
          NVL (lc.lc_number, btb_lc_no_phy) AS LC_NUMBER,
          pla.Item_description as "Type",
          sup.vendor_name AS "Party_Name",
          rt.primary_quantity as "Receive_Quantity",
          rsh.receipt_num as "GRN_Number",
          pla.quantity as "LC_Quntity",
          lc.LC_VALUE as "LC_VALUE",
          pla.unit_price as "PI_Rate",
          (lc.LC_VALUE*pha.rate) AS "Value_Actual"
          ,alloc.charge_line_type_name AS charge_type
          ,alloc.estimated_amt
          ,alloc.billed_amt
     FROM apps.po_headers_all pha,
          apps.xxdbl_company_le_mapping_v led,
          apps.ap_suppliers sup,
          apps.ap_supplier_sites_all sups,
          apps.po_lines_all pla,
          apps.po_line_types_b plt,
          apps.po_line_locations_all pll,
          inl_charge_allocations_v alloc,
          apps.po_distributions_all pda,
          apps.rcv_transactions rt,
          apps.rcv_shipment_headers rsh,
          xx_lc_details lc,
          xxdbl.xx_explc_btb_req_link b2b,
          xxdbl.xx_explc_btb_mst b2b2
    WHERE     pha.po_header_id = pla.po_header_id
          AND pha.org_id = pla.org_id
          AND pha.org_id = led.org_id
          AND pha.po_header_id = pll.po_header_id
          AND pla.po_line_id = pll.po_line_id
          AND pla.line_type_id = plt.line_type_id
          AND pha.vendor_id = sup.vendor_id
          AND sup.vendor_id = sups.vendor_id
          AND pha.vendor_site_id = sups.vendor_site_id(+)
          AND pha.type_lookup_code = 'STANDARD'
          AND pha.segment1 = lc.po_number(+)
          AND pha.po_header_id = pda.po_header_id
          AND pla.po_line_id = pda.po_line_id
          AND pll.line_location_id = pda.line_location_id
          --AND rsh.shipment_header_id=allocc.shipment_hdr_id(+)
          --AND pha.po_header_id = allocc.po_hdr_id(+)
          AND pha.po_header_id = alloc.po_header_id(+)
          AND pha.po_header_id = rt.po_header_id
          AND pla.po_line_id = rt.po_line_id
          AND rt.shipment_header_id = rsh.shipment_header_id
          AND pha.segment1 = b2b.po_number(+)
          AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
          AND rt.transaction_type = 'RECEIVE'
          AND pla.quantity <> 0
          AND pll.quantity_received <> 0
          AND NVL (pla.cancel_flag, 'N') = 'N'
          AND NVL (pll.cancel_flag, 'N') = 'N'
          AND pll.cancel_date IS NULL
          AND pda.quantity_cancelled = 0
          and lc.lc_status='Y'
          and (:lc_number is null or (lc.lc_number = :lc_number))
          --AND led.legal_entity_id=:legal_entity
          --AND trunc(lc.lc_opening_date) between nvl(:p_date_from,trunc(lc.lc_opening_date)) and nvl(:p_date_to,trunc(lc.lc_opening_date))
          --and (:p_purchase_item is null or (pla.Item_description = :p_purchase_item))
)
PIVOT
(
  SUM(estimated_amt) estd_amt,
  SUM(billed_amt) actl_amt
  FOR charge_type IN ('Transport Cost' trans_cst, 'Clearing and Forwarding' candf, 'INSURANCE' insurence,'Bank Charge-LC' bank_charge,'Inspection Charge' inspec_charge,'L/C Opening Commission' lc_open)
)
ORDER BY LC_NUMBER;