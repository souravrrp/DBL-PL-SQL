/* Formatted on 7/9/2020 10:55:54 AM (QP5 v5.287) */
SELECT hou.name OU_Name,
       led.legal_entity_id,
       led.legal_entity_name,
       org.organization_name,
       mtrh.request_number,
       pha.segment1 po_number,
       NVL (lc.lc_number, btb_lc_no_phy) lc_number,
       lc.lc_opening_date,
       lc.bank_name,
       pha.authorization_status Approve_Status,
       pha.approved_date po_approved_date,
       pah.action_code,
       sup.segment1 SUPPLIER_ID,
       sup.vendor_name Supplier_Name,
       msi.segment1 item_code,
       msi.description item_name,
       mc.segment1 item_category_1,
       mc.segment2 item_category_2,
       mc.segment3 item_category_3,
       mc.segment4 item_category_4,
       pla.unit_meas_lookup_code uom,
       pla.quantity PO_Quantity,
       pla.unit_price PO_price,
       pha.CURRENCY_CODE,
       ish.ship_num,
       ish.ship_date,
       rsh.receipt_num,
       rsh.creation_date Grn_date,
       rt.primary_quantity grn_quantity,
       ail.invoice_num,
       ail.doc_sequence_value voucher_number,
       ail.creation_date invoice_date,
       ck.doc_sequence_value payment_voucher,
       ck.bank_account_name,
       ck.check_date payment_date,
       pha.org_id,
       pll.quantity_billed,
       (SELECT DISTINCT customer_name
          FROM xx_ar_customer_site_v
         WHERE customer_id = pla.attribute5)
          buyer,
       pla.attribute6 order_number,
       pm.accounting_date payment_voucher_date,
       ck.cleared_date paid_date
  FROM apps.po_headers_all pha,
       apps.xxdbl_company_le_mapping_v led,
       apps.ap_suppliers sup,
       apps.ap_supplier_sites_all sups,
       apps.po_lines_all pla,
       apps.po_line_types_b plt,
       apps.po_line_locations_all pll,
       apps.inl_ship_lines_all isl,
       apps.inl_ship_headers_all ish,
       apps.mtl_system_items_b msi,
       apps.mtl_item_categories mic,
       apps.mtl_categories mc,
       apps.org_organization_definitions org,
       apps.hr_operating_units hou,
       apps.po_distributions_all pda,
       apps.mtl_txn_request_lines l,
       apps.mtl_txn_request_headers mtrh,
       apps.rcv_transactions rt,
       apps.rcv_shipment_headers rsh,
       apps.ap_invoice_lines_all aila,
       apps.ap_invoices_all ail,
       apps.ap_invoice_payments_all pm,
       apps.ap_checks_all ck,
       (SELECT lc_number,
               lc.lc_opening_date,
               lc.bank_name,
               po_number,
               lc.bank_branch_name
          FROM xx_lc_details lc
         WHERE lc_status = 'Y') lc,
       xxdbl.xx_explc_btb_req_link b2b,
       xxdbl.xx_explc_btb_mst b2b2,
       po.po_action_history pah
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
       AND pda.req_distribution_id = l.attribute14(+)
       AND pha.po_header_id = rt.po_header_id
       AND pla.po_line_id = rt.po_line_id
       AND rt.shipment_header_id = rsh.shipment_header_id
       AND pla.po_header_id = aila.po_header_id
       AND pll.line_location_id = aila.po_line_location_id
       AND pla.po_line_id = aila.po_line_id
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
       --AND TRUNC(prha.approved_date)=TRUNC(:approved_date)
       AND pah.action_code = 'OPEN'
       AND object_id = pha.po_header_id
       --AND ROWNUM<=2
       --AND pha.segment1 = '15413000492'
       AND pah.object_type_code = 'PO';