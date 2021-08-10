/* Formatted on 1/19/2020 3:28:32 PM (QP5 v5.287) */
  SELECT --DISTINCT 
                  pha.segment1 po_number,
                  NVL (lc.lc_number, btb_lc_no_phy) lc_number,
                  --rsh.shipment_num,
                  --rsh.receipt_num,
                  --rt.transaction_id,
                  --rt.transaction_type,
                  ai.doc_sequence_value Invoice,
                  --ail.cost_center_segment,
                  ail.cost_factor_id,
                  ppet.price_element_code,
                  ail.amount,
                  ail.original_amount
                  --ai.cancelled_date
                  ,pha.po_header_id po_hdr_id
                  --,rsh.shipment_header_id shipment_hdr_id
                  --,rsh.*
                  --,pha.*
                  --,rt.*
                  --,ail.*
                  ,aid.*
                  --,lc.*
                  --,ppet.*
                  --,b2b.*
                  --,b2b2.*
    FROM apps.po_headers_all pha,
         apps.po_lines_all pla,
         --apps.rcv_shipment_headers rsh,
         --apps.rcv_transactions rt,
         apps.ap_invoices_all ai,
         apps.ap_invoice_lines_all ail,
         apps.ap_invoice_distributions_all aid,
         apps.xx_lc_details lc,
         xxdbl.xx_explc_btb_req_link b2b,
         xxdbl.xx_explc_btb_mst b2b2,
         apps.pon_price_element_types ppet
   WHERE     1 = 1
         --and pha.segment1 in ('10213000238')
         --and ai.doc_sequence_value in (217387733)
         AND ( :P_ORG_ID IS NULL OR (PHA.ORG_ID = :P_ORG_ID))
         AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no))
         AND pha.po_header_id = pla.po_header_id
         --AND pha.po_header_id = rt.po_header_id(+)
         --AND pla.po_header_id = rt.po_header_id(+)
         --AND pla.po_line_id = rt.po_line_id(+)
         --AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND ai.invoice_id = ail.invoice_id
         AND ai.invoice_id = aid.invoice_id
         AND ail.invoice_id = aid.invoice_id
         AND ai.org_id = ail.org_id
         AND ai.org_id = aid.org_id
         AND ail.org_id = aid.org_id
         AND ail.po_header_id(+) = pha.po_header_id
         AND ail.po_line_id(+) = pla.po_line_id
         AND pha.po_header_id = lc.po_header_id
         --AND rt.transaction_id = ail.rcv_transaction_id(+)
         --AND rt.transaction_id = ail.rcv_transaction_id(+)
         AND ail.cost_factor_id(+) = ppet.price_element_type_id
         AND pha.segment1 = b2b.po_number(+)
         AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
        --and ai.cancelled_date is not null
        --and rt.transaction_id='236398'
        and aid.rcv_transaction_id='236398'
ORDER BY pha.segment1--, rt.transaction_id;