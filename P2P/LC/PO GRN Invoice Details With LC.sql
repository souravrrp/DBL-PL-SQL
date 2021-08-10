select  
        distinct 
        rsh.shipment_header_id,
        pha.segment1 po_number,
        lc.lc_number,
        pla.quantity lc_quantity,
        rsh.shipment_num,
        rsh.receipt_num,
        rt.primary_quantity receive_qty,
        rt.transaction_id,
        rt.transaction_type,
        ai.doc_sequence_value Invoice_number,
        --ail.cost_center_segment,
        ail.cost_factor_id,
        ppet.price_element_code,
        pla.unit_price,
        ail.amount,
        ail.original_amount,
        rt.unit_landed_cost average_cost
        --ai.cancelled_date
        --,pha.*
        --,pla.*
        --,rsh.*
        --,rsl.*
        --,rt.*
        --,ai.*
        --,aid.*
        --,ail.*
        --,ppet.*
        --,lc.*
from
        apps.po_headers_all pha,
        apps.po_lines_all pla,
        apps.rcv_shipment_headers rsh,
        apps.rcv_shipment_lines rsl,
        apps.rcv_transactions rt,
        apps.ap_invoices_all ai,
        apps.ap_invoice_lines_all ail,
        apps.ap_invoice_distributions_all aid,
        apps.xx_lc_details lc,
        apps.pon_price_element_types ppet
        ,apps.ap_suppliers aps
        ,apps.ap_supplier_sites_all apsa
where 1=1
        --and pha.segment1 in ('I/SCOU/002151')
        and lc.lc_number='DPCDAK964721'   --DPCDAK966261  --DPCDAK964721
        --and ai.doc_sequence_value in (217387733)
        and pha.po_header_id=pla.po_header_id
        and pha.po_header_id=rt.po_header_id(+)
        and pla.po_header_id=rt.po_header_id(+)
        and pla.po_line_id=rt.po_line_id(+) 
        and rt.shipment_header_id=rsh.shipment_header_id(+)
        and rsh.shipment_header_id=rsl.shipment_header_id(+)
        and rt.shipment_line_id=rsl.shipment_line_id(+)
        and ai.invoice_id=ail.invoice_id
        and ai.invoice_id=aid.invoice_id
        and ail.invoice_id=aid.invoice_id
        and ai.org_id=ail.org_id
        and ai.org_id=aid.org_id
        and ail.org_id=aid.org_id
        and ail.po_header_id(+)=pha.po_header_id
        and ail.po_line_id(+)=pla.po_line_id
        and pha.po_header_id=lc.po_header_id
        and ail.rcv_transaction_id(+)=rt.transaction_id
        and ail.cost_factor_id(+)=ppet.price_element_type_id
        and aps.vendor_id=apsa.vendor_id(+)
        and ai.vendor_id=aps.vendor_id(+)
        and ai.vendor_site_id=apsa.vendor_site_id(+)
        --and ai.cancelled_date is not null
order by pha.segment1,
            rt.transaction_id