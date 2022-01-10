/* Formatted on 12/14/2019 1:43:36 PM (QP5 v5.287) */
  SELECT prha.org_id,
         prha.segment1 "REQ NO",
         prha.creation_date "REQ DATE",
         prla.quantity "REQ QTY",
         pha.segment1 "PO NO",
         pha.creation_date "PO DATE",
         SUM (pla.quantity) "PO QTY",
         pla.unit_price "PRICE",
         rsh.receipt_num,
         rt.transaction_date "RECEIPT DATE",
         rt.quantity "RECEIPT QTY",
         rt.po_unit_price "PO PRICE",
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number
    FROM po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         po_headers_all pha,
         po_lines_all pla,
         po_distributions_all pda,
         rcv_transactions rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         ap_invoices_all aia,
         ap_invoice_lines_all aila,
         ap_invoice_distributions_all aid,
         ap_invoice_payments_all aip,
         ap_payment_schedules_all apsa,
         ap_checks_all apc
         ,APPS.MTL_SYSTEM_ITEMS_B MSI
   WHERE     prha.requisition_header_id = prla.requisition_header_id
         AND prla.requisition_line_id = prda.requisition_line_id
         AND pda.req_distribution_id(+) = prda.distribution_id
         AND pla.po_line_id(+) = pda.po_line_id
         AND pha.po_header_id(+) = pla.po_header_id
         AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND rsh.shipment_header_id(+) = rt.shipment_header_id
         AND rt.transaction_id = aid.rcv_transaction_id(+)
         AND aila.invoice_id(+) = aid.invoice_id
         AND aia.invoice_id(+) = aila.invoice_id
         AND aia.invoice_id = aip.invoice_id(+)
         AND aia.invoice_id = apsa.invoice_id(+)
         AND apc.check_id(+) = aip.check_id
         AND prla.item_id = msi.inventory_item_id(+)
         and prla.destination_organization_id = msi.organization_id(+)
         --AND (   :P_ITEM_CODE IS NULL OR (MSI.SEGMENT1 = :P_ITEM_CODE))
         --AND (:P_ITEM_DESC IS NULL OR (UPPER(MSI.DESCRIPTION) LIKE UPPER('%'||:P_ITEM_DESC||'%') ))
         AND prha.segment1 = '21111002002'
         --and prla.ITEM_ID='33313'
         --and pha.segment1 = nvl (:p_po_num, pha.segment1) 
         --and aia.invoice_num=nvl(:p_invoice_num,aia.invoice_num) 
         --and rsh.receipt_num=nvl(:p_receipt_num,rsh.receipt_num) 
--and      pha.SEGMENT1='7162'
GROUP BY prha.org_id,
         prha.segment1,
         prha.creation_date,
         prla.quantity,
         pha.segment1,
         pha.creation_date,
         pla.quantity,
         pla.unit_price,
         rsh.receipt_num,
         rt.transaction_date,
         rt.quantity,
         rt.po_unit_price,
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number
ORDER BY prha.segment1