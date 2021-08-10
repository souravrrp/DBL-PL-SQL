SELECT DISTINCT prha.segment1 pr_no,
                  fur.email_address email,
                  rsh.receipt_num grn_no,
                  MAX (grn.transaction_date) grn_date
    INTO &pr_no,
         &email,
         &grn_no,
         &grn_date
    FROM po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         po_headers_all poh,
         po_lines_all pol,
         po_distributions_all pda,
         rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         rcv_transactions grn,
         fnd_user fur
   WHERE     prha.requisition_header_id = prla.requisition_header_id
         AND prla.requisition_line_id = prda.requisition_line_id
         AND poh.po_header_id = pda.po_header_id
         AND poh.po_header_id = pol.po_header_id
         AND pol.po_line_id = pda.po_line_id
         AND pda.req_distribution_id = prda.distribution_id
         AND prha.created_by = fur.user_id
         AND poh.po_header_id = rsl.po_header_id
         AND pol.po_line_id = rsl.po_line_id
         AND rsl.shipment_header_id = rsh.shipment_header_id
         AND rsl.po_header_id = grn.po_header_id
         AND rsl.po_line_id = grn.po_line_id
         AND pda.po_distribution_id = grn.po_distribution_id
         AND prha.org_id = 131
         AND fur.email_address IS NOT NULL
         AND rsh.ROWID = :ROWID
GROUP BY prha.segment1, fur.email_address, rsh.receipt_num