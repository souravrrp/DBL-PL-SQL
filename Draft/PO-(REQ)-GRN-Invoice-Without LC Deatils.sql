/* Formatted on 2/3/2020 3:04:44 PM (QP5 v5.287) */
  SELECT 
         led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         pha.org_id,
         prha.segment1 "REQ NO",
         prha.creation_date "REQ DATE",
         --SUM (prla.quantity) "REQ QTY",
         SUM (REQ_LINE_QUANTITY) REQ_QTY,
         pha.po_header_id PO_HRD_ID,
         pla.po_line_id PO_LN_ID,
         pha.segment1 "PO NO",
         pha.creation_date "PO DATE",
         sup.segment1 SUPPLIER_ID,
         sup.vendor_name Supplier_Name,
         SUM (pda.quantity_ordered) "PO QTY",
         --pla.quantity,
         rsh.receipt_num,
         rt.transaction_date "RECEIPT DATE",
         rt.quantity "RECEIPT QTY",
         rt.po_unit_price "PO PRICE",
         rt.transaction_type,
         --ish.ship_num,
         --ish.ship_date,
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number,
         MSI.SEGMENT1 ITEM_CODE,
         MSI.DESCRIPTION,
         cat.segment2 item_category,
         cat.segment3 item_type,
         pll.quantity_billed,
         pla.unit_price "PRICE"
    FROM po_headers_all pha,
         po_lines_all pla,
         apps.xxdbl_company_le_mapping_v led,
         apps.org_organization_definitions odd,
         apps.hr_operating_units hou,
         po_distributions_all pda,
         po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         apps.po_line_locations_all pll,
         apps.po_line_types_b plt,
         rcv_transactions rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         ap_invoices_all aia,
         ap_invoice_lines_all aila,
         ap_invoice_distributions_all aid,
         ap_invoice_payments_all aip,
         ap_payment_schedules_all apsa,
         ap_checks_all apc,
         apps.mtl_item_categories_v cat,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sups,
         apps.mtl_txn_request_lines mtrl,
         apps.mtl_txn_request_headers mtrh,
         apps.mtl_system_items_b msi
   WHERE     1 = 1
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND pla.po_line_id = pda.po_line_id(+)
         AND pha.org_id = led.org_id
         AND pda.destination_organization_id = odd.organization_id
         AND pha.org_id = hou.organization_id
         AND pha.po_header_id = pla.po_header_id(+)
         AND pha.po_header_id = pll.po_header_id(+)
         AND pla.po_line_id = pll.po_line_id(+)
         AND pda.line_location_id = pll.line_location_id(+)
         AND pla.line_type_id = plt.line_type_id(+)
         --AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND pha.po_header_id = RT.po_header_id(+)
         AND pla.po_line_id = RT.po_line_id(+)
         AND pha.type_lookup_code = 'STANDARD'
         AND rt.transaction_type = 'RECEIVE'
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sups.vendor_id
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND rt.transaction_id = aid.rcv_transaction_id(+)
         AND aid.invoice_id = aila.invoice_id(+)
         AND aila.invoice_id = aia.invoice_id(+)
         AND aia.invoice_id = aip.invoice_id(+)
         AND aia.invoice_id = apsa.invoice_id(+)
         AND aip.check_id = apc.check_id(+)
         AND pla.item_id = msi.inventory_item_id(+)
         AND pda.destination_organization_id = msi.organization_id(+)
         AND msi.inventory_item_id = cat.inventory_item_id(+)
         AND msi.organization_id = cat.organization_id(+)
         AND prda.distribution_id = mtrl.attribute14(+)
         AND mtrl.header_id = mtrh.header_id(+)
         --AND prha.segment1 = '25111002393'
         --and prla.ITEM_ID='33313'
         --and pha.SEGMENT1='15513000305'
         AND ( :p_po_num IS NULL OR (pha.segment1 = :p_po_num))
         AND ( :p_receipt_num IS NULL OR (rsh.receipt_num = :p_receipt_num))
         AND ( :p_invoice_num IS NULL OR (aia.invoice_num = :p_invoice_num))
         --AND (:p_item_code is null or (msi.segment1 = :p_item_code))
         --AND (:p_item_desc is null or (upper (msi.description) like upper ('%' || :p_item_desc || '%')))
         AND NOT EXISTS
                (SELECT 1
                   FROM XX_LC_DETAILS LC
                  WHERE pha.segment1 = lc.po_number AND lc_status = 'Y')
         AND NOT EXISTS
                (SELECT 1
                   FROM xxdbl.xx_explc_btb_req_link b2b,
                        xxdbl.xx_explc_btb_mst b2b2
                  WHERE     pha.segment1 = b2b.po_number
                        AND b2b.btb_lc_no = b2b2.btb_lc_no)
GROUP BY pha.org_id,
         prha.segment1,
         prha.creation_date,
         --prla.quantity,
         pha.segment1,
         pha.po_header_id,
         pla.po_line_id,
         pha.creation_date,
         --pla.quantity,
         rsh.receipt_num,
         rt.transaction_date,
         rt.transaction_type,
         rt.quantity,
         rt.po_unit_price,
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number,
         cat.segment2,
         cat.segment3,
         MSI.SEGMENT1,
         MSI.DESCRIPTION,
         pll.quantity_billed,
         sup.segment1,
         sup.vendor_name,
         pla.unit_price
ORDER BY pha.segment1