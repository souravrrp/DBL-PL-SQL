SELECT hou.name OU_Name,
          led.legal_entity_id,
          led.legal_entity_name,
          org.organization_name,
          lc.lc_opening_date as "Date",
          NVL (lc.lc_number, btb_lc_no_phy) "LC Number",
          msi.description as "Type",
          sup.vendor_name  "Party name",
          rt.primary_quantity as "Receive Quantity",
          rsh.receipt_num as "GRN Number",
          pla.quantity as "LC Quntity",
          lc.LC_VALUE as "LC VALUE",
          pla.unit_price as "PI Rate",
          alloc.charge_line_type_name charge_type,
          alloc.estimated_amt estimated_amount,
          alloc.billed_amt  actual_amount
          -------------------------------
          /*
          ,mtrh.request_number,
          prha.segment1 requisition_number,
          prha.approved_date PR_Approved_Date,
          pha.segment1 po_number,
          lc.bank_name,
          pha.authorization_status Approve_Status,
          pha.approved_date po_approved_date,
          sup.segment1 SUPPLIER_ID,
          msi.segment1 item_code,
          mc.segment1 item_category_1,
          mc.segment2 item_category_2,
          mc.segment3 item_category_3,
          mc.segment4 item_category_4,
          pla.unit_meas_lookup_code uom,
          prol.quantity PR_Quantity,
          prol.unit_price PR_price,
          pla.quantity PO_Quantity,
          pla.unit_price PO_price,
          pha.CURRENCY_CODE,
          ish.ship_num,
          ish.ship_date,
          rsh.creation_date Grn_date,
          ail.invoice_num,
          ail.doc_sequence_value voucher_number,
          ail.creation_date invoice_date,
          ck.doc_sequence_value payment_voucher,
          ck.bank_account_name,
          ck.check_date payment_date,
          pha.org_id,
          pll.quantity_billed
          --,ish.ship_header_id shipheaderid
          --,alloc.allocation_amt allocated_amt
          --,alloc.estimated_amt estimated_allocated_amt
          --,alloc.*
          --,isl.*
          --,lc.*
          */
     FROM apps.po_headers_all pha,
          apps.xxdbl_company_le_mapping_v led,
          apps.ap_suppliers sup,
          apps.ap_supplier_sites_all sups,
          apps.po_lines_all pla,
          apps.po_line_types_b plt,
          apps.po_line_locations_all pll,
          apps.inl_ship_lines_all isl,
          apps.inl_ship_headers_all ish,
          --inl_allocations alloc,
          inl_charge_allocations_v alloc,
          --inl_associations assoc,
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
          AND msi.organization_id = mic.organization_id                --6,457
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
          and rsh.shipment_header_id=alloc.shipment_header_id(+)
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
          and lc.lc_number=:lc_number---'DPCDAK966261'  --DPCDAK966261 --'DPCDAK964721' --DPCDAK966273   --'DCDAK880769'
          --AND apps.XX_AP_PKG.GET_INVOICE_STATUS (ail.INVOICE_ID) <> 'Cancelled'
          --and  pha.segment1='25113002657' --17,568 17,568 25,341 25,917 25,452 ,42,913
;

--/*
select
ptp.lc_opening_date "Date"
,ptp.lc_number lc_no
,ptp.item_name "Type"
,lc.supplier_name "Party name"
,grn_quantity "Received QTY"
,receipt_num grn
,' ' "LC QTY"
,lc.lc_value "LC Value(USD)"
,ptp.po_price "PI  Rate"
,lc.functional_amount "Value (Actual)"
,' ' "Transport (Actual)"
,' ' "Transport (Estimated)"
,' ' "C AND F (Actual)"
,' ' "C AND F (Estimated)"
,' ' "Insurance Actual"
,' ' "Insurance (estimated)"
,' ' "Bank charges actual" 	 
,' ' "Gain/loss" 		    
,' ' "Total"
,' ' "Av. rate"
--,ptp.*
,lc.*
from
xxdbl_pr_to_pay ptp
,xx_lc_details lc
--,xxdbl_proforma_headers pfh 
--,xxdbl_proforma_lines pfl
where 1=1
and ptp.lc_number=lc.lc_number(+)
--AND PTP.LC_NUMBER=PFH.ATTRIBUTE9(+)
--AND PTP.ORG_ID=PFH.ORG_ID(+)
--AND PFH.PROFORMA_HEADER_ID=PFL.PROFORMA_HEADER_ID(+)
--and ptp.legal_entity_id='23280'
--AND PO_NUMBER IS NOT NULL
and ptp.lc_number='DPCDAK966273'    --'DCDAK880769'
--and ptp.lc_number is not null
--and grn_quantity is not null
--and payment_date is not null
--and rownum<=100

--*/