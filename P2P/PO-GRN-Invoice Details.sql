/* Formatted on 2/27/2020 11:44:06 AM (QP5 v5.287) */
  SELECT pha.org_id,
         msi.ORGANIZATION_ID,
         OOD.ORGANIZATION_CODE,
         prha.segment1 "REQ NO",
         prha.creation_date "REQ DATE",
         SUM (prla.quantity) "REQ QTY",
         pha.po_header_id PO_HRD_ID,
         pla.po_line_id PO_LN_ID,
         pha.segment1 "PO NO",
         pha.creation_date "PO DATE",
         SUM (pda.quantity_ordered) "PO QTY",
         --         pla.quantity,
         rsh.receipt_num,
         rt.transaction_date "RECEIPT DATE",
         rt.quantity "RECEIPT QTY",
         rt.po_unit_price "PO PRICE",
         rt.transaction_type,
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number,
         pla.unit_price "PRICE"
    FROM po_headers_all pha,
         po_lines_all pla,
         po_distributions_all pda,
         po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         rcv_transactions rt,
         --         rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         ap_invoices_all aia,
         ap_invoice_lines_all aila,
         ap_invoice_distributions_all aid,
         ap_invoice_payments_all aip,
         ap_payment_schedules_all apsa,
         ap_checks_all apc,
         APPS.MTL_SYSTEM_ITEMS_B MSI,
         ORG_ORGANIZATION_DEFINITIONS OOD
   WHERE     1 = 1
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND pla.po_line_id = pda.po_line_id(+)
         AND pha.po_header_id = pla.po_header_id(+)
         --AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND pha.po_header_id = RT.po_header_id(+)
         AND pla.po_line_id = RT.po_line_id(+)
         --AND rt.transaction_type = 'RECEIVE'
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND rt.transaction_id = aid.rcv_transaction_id(+)
         AND aid.invoice_id = aila.invoice_id(+)
         AND aila.invoice_id = aia.invoice_id(+)
         AND aia.invoice_id = aip.invoice_id(+)
         AND aia.invoice_id = apsa.invoice_id(+)
         AND aip.check_id = apc.check_id(+)
         AND pla.item_id = msi.inventory_item_id(+)
         AND pda.DESTINATION_ORGANIZATION_ID = msi.ORGANIZATION_ID(+)
         AND msi.ORGANIZATION_ID = OOD.ORGANIZATION_ID(+)
         --and pha.creation_date between '01-JAN-2020' and '26-FEB-2020'
         --         AND ( :P_ITEM_CODE IS NULL OR (MSI.SEGMENT1 = :P_ITEM_CODE))
         --         AND (   :P_ITEM_DESC IS NULL OR (UPPER (MSI.DESCRIPTION) LIKE UPPER ('%' || :P_ITEM_DESC || '%')))
         --AND prha.segment1 = '25111002393'
         --and prla.ITEM_ID='33313'
         AND pha.segment1 = NVL ( :p_po_num, pha.segment1)
--and aia.invoice_num=nvl(:p_invoice_num,aia.invoice_num)
--and rsh.receipt_num=nvl(:p_receipt_num,rsh.receipt_num)
--and      pha.SEGMENT1='7162'
GROUP BY pha.org_id,
         msi.ORGANIZATION_ID,
         OOD.ORGANIZATION_CODE,
         prha.segment1,
         prha.creation_date,
         --         prla.quantity,
         pha.segment1,
         pha.po_header_id,
         pla.po_line_id,
         pha.creation_date,
         --         pla.quantity,
         rsh.receipt_num,
         rt.transaction_date,
         rt.transaction_type,
         rt.quantity,
         rt.po_unit_price,
         aia.invoice_num,
         aia.invoice_date,
         apc.check_date,
         apc.check_number,
         pla.unit_price
ORDER BY pha.segment1;


--------------------------------------------------------------------------------

  SELECT DISTINCT pha.segment1 po_number,
                  --        lc.lc_number,
                  rsh.shipment_num,
                  rsh.receipt_num,
                  rt.transaction_id,
                  rt.transaction_type
    --                  ai.doc_sequence_value Invoice,
    --                  --        ail.cost_center_segment,
    --                  ail.cost_factor_id,
    --                  ppet.price_element_code,
    --                  ail.amount,
    --                  ail.original_amount
    --        ai.cancelled_date
    FROM apps.po_headers_all pha,
         apps.po_lines_all pla,
         apps.rcv_shipment_headers rsh,
         apps.rcv_transactions rt
   --         apps.ap_invoice_lines_all ail,
   --         apps.ap_invoices_all ai,
   --         apps.ap_invoice_distributions_all aid,
   --        apps.xx_lc_details lc,
   --         apps.pon_price_element_types ppet
   WHERE     1 = 1
         AND pha.segment1 IN ('15513000038')
         --        and ai.doc_sequence_value in (217387733)
         AND pha.po_header_id = pla.po_header_id
         AND pha.po_header_id = rt.po_header_id(+)
         AND pla.po_header_id = rt.po_header_id(+)
         AND pla.po_line_id = rt.po_line_id(+)
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND rt.transaction_id = ail.rcv_transaction_id(+)
         AND ai.invoice_id(+) = ail.invoice_id
         AND ai.invoice_id = aid.invoice_id(+)
         AND ail.invoice_id = aid.invoice_id(+)
         AND ai.org_id(+) = ail.org_id
         AND ai.org_id = aid.org_id(+)
         AND ail.org_id = aid.org_id(+)
         AND ail.po_header_id(+) = pha.po_header_id
         AND ail.po_line_id(+) = pla.po_line_id
         --        and pha.po_header_id=lc.po_header_id(+)
         AND ail.cost_factor_id(+) = ppet.price_element_type_id
         AND rsh.receipt_num = '15514300009'
--        and ai.cancelled_date is not null
ORDER BY pha.segment1, rt.transaction_id