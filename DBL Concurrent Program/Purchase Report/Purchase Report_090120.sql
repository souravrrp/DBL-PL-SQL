SELECT led.UNIT_NAME OU_Name,
          led.legal_entity_id,
          led.legal_entity_name,
          lc.lc_opening_date as "Date",
          NVL (lc.lc_number, btb_lc_no_phy) AS "LC_Number",
          pla.Item_description as "Type",
          sup.vendor_name AS "Party_Name",
          rt.primary_quantity as "Receive_Quantity",
          rsh.receipt_num as "GRN_Number",
          pla.quantity as "LC_Quntity",
          lc.LC_VALUE as "LC_VALUE",
          pla.unit_price as "PI_Rate",
          (lc.LC_VALUE*pha.rate) AS "Value_Actual",
          SUM (transport_cost_estd) transport_cost_estd,
         SUM (candf_estd) candf_estd,
         SUM (insurence_estd) insurence_estd,
         SUM (bank_charge_estd) bank_charge_estd,
         SUM (inspection_charge_estd) inspection_charge_estd,
         SUM (lc_openning_estd) lc_openning_estd,
         SUM (transport_cost_actual) transport_cost_actual,
         SUM (candf_actual) candf_actual,
         SUM (insurence_actual) insurence_actual,
         SUM (bank_charge_actual) bank_charge_actual,
         SUM (inspection_charge_actual) inspection_charge_actual,
         SUM (lc_openning_actual) lc_openning_actual
     FROM apps.po_headers_all pha,
          apps.xxdbl_company_le_mapping_v led,
          apps.ap_suppliers sup,
          apps.ap_supplier_sites_all sups,
          apps.po_lines_all pla,
          apps.po_line_types_b plt,
          apps.po_line_locations_all pll,
          (  SELECT po_header_id po_hdr_id,
                    ship_header_id ship_hdr_id,
                    ship_line_id ship_ln_id,
                    shipment_header_id shipment_hdr_id,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Transport Cost'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      transport_cost_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name =
                               'Clearing and Forwarding'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      candf_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'INSURANCE'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      insurence_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Bank Charge-LC'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      bank_charge_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Inspection Charge'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      inspection_charge_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name =
                               'L/C Opening Commission'
                       THEN
                          SUM (NVL (alloc.estimated_amt, 0))
                    END)
                      lc_openning_estd,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Transport Cost'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      transport_cost_actual,
                   (CASE
                       WHEN alloc.charge_line_type_name =
                               'Clearing and Forwarding'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      candf_actual,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'INSURANCE'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      insurence_actual,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Bank Charge-LC'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      bank_charge_actual,
                   (CASE
                       WHEN alloc.charge_line_type_name = 'Inspection Charge'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      inspection_charge_actual,
                   (CASE
                       WHEN alloc.charge_line_type_name =
                               'L/C Opening Commission'
                       THEN
                          SUM (NVL (alloc.billed_amt, 0))
                    END)
                      lc_openning_actual
              FROM inl_charge_allocations_v alloc
             --WHERE 1 = 1 
             --AND po_header_id = --'136048'
          GROUP BY alloc.charge_line_type_name, po_header_id,ship_header_id,shipment_header_id,ship_line_id) allocc,
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
          AND rsh.shipment_header_id=allocc.shipment_hdr_id(+)
          AND pha.po_header_id = allocc.po_hdr_id(+)
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
          --and (:lc_number is null or (lc.lc_number = :lc_number))
          AND led.legal_entity_id=:legal_entity
          AND trunc(lc.lc_opening_date) between nvl(:p_date_from,trunc(lc.lc_opening_date)) and nvl(:p_date_to,trunc(lc.lc_opening_date))
          --and (:p_purchase_item is null or (pla.Item_description = :p_purchase_item))
group by
          led.UNIT_NAME,
          led.legal_entity_id,
          led.legal_entity_name,
          lc.lc_opening_date,
          NVL (lc.lc_number, btb_lc_no_phy),
          pla.Item_description,
          sup.vendor_name,
          rt.primary_quantity,
          rsh.receipt_num,
          pla.quantity,
          lc.LC_VALUE,
          pla.unit_price,
          (lc.LC_VALUE*pha.rate)
          --alloc.charge_line_type_name
;