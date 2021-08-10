select 
    hou.name ou_name
    ,ai.doc_sequence_value
    ,pda.destination_organization_id
    ,ood.organization_code
    ,ai.invoice_type_lookup_code
    ,aps.segment1 supplier_no
    ,aps.vendor_name
    ,apss.vendor_site_code
    ,ai.gl_date hdr_gl_date
    ,ai.invoice_num
    ,ai.invoice_currency_code currency
    ,ai.exchange_rate
    ,ai.invoice_amount
    ,ai.base_amount
    ,ai.payment_status_flag
    ,ai.amount_paid
    ,ail.line_number inv_line
    ,ail.line_type_lookup_code line_type
    ,pha.segment1 po_number
    --,lc.lc_number
    ,pla.line_num po_line
    ,rsh.shipment_num
    ,rsh.receipt_num
    ,rsl.line_num receipt_line
    ,rt.transaction_type
    ,msi.segment1 item_code
    ,pla.item_description
    ,ail.quantity_invoiced
    ,ail.unit_meas_lookup_code uom
    ,ail.unit_price
    ,ail.accounting_date line_gl_date
    ,ail.cost_factor_id
    ,ppet.price_element_code
    ,ail.amount line_amt
    ,ail.base_amount line_base_amt
    ,aid.distribution_line_number dist_line
    ,aid.line_type_lookup_code dist_type
    ,aid.dist_match_type
    ,aid.accounting_date dist_gl_date
    ,aid.amount dist_amt
    ,aid.base_amount dist_base_amt
    ,decode(aid.base_amount, null, aid.amount, aid.base_amount) functional_amount
    ,gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7||'.'||gcc.segment8||'.'||gcc.segment9 account
--    ,pla.*
    --,aipa.*
    --,ail.*
    ,pla.*
from
    apps.ap_invoices_all ai
    ,apps.hr_operating_units hou
    ,apps.ap_suppliers aps
    ,apps.ap_supplier_sites_all apss
    ,apps.ap_invoice_lines_all ail
    ,apps.po_headers_all pha
    ,apps.po_lines_all pla
    ,apps.po_distributions_all pda
    ,apps.rcv_transactions rt
    ,apps.rcv_shipment_lines rsl
    ,apps.rcv_shipment_headers rsh
    ,apps.mtl_system_items msi
    ,apps.ap_invoice_distributions_all aid
    ,apps.gl_code_combinations gcc
    ,apps.pon_price_element_types ppet
    --,apps.xxakg_lc_details lc
    ,apps.org_organization_definitions ood
    ,ap_invoice_payments_all aipa
where 1=1
    AND ai.invoice_id=aipa.invoice_id(+)
    and ai.doc_sequence_value in (218001791)
    --and ai.invoice_id=15322
--    and pha.segment1 in ('I/RMCOU/000044')
--    and ail.rcv_transaction_id in (2218055)
    and ai.org_id in (107)
    --and aps.segment1 in ('15015')
--    and aid.period_name in ('JAN-19')
--    and pha.attribute1 in ('I')
--    and gcc.segment3 in ('1050102','2050107')
    and ai.org_id =  hou.organization_id
    and ai.vendor_id = aps.vendor_id
    and ai.vendor_site_id = apss.vendor_site_id
    and ai.invoice_id = ail.invoice_id
    and ai.org_id = ail.org_id
    and ail.po_header_id = pha.po_header_id(+)
    and ail.po_line_id = pla.po_line_id(+)
    and ail.rcv_transaction_id = rt.transaction_id(+)
    and ail.rcv_shipment_line_id = rsl.shipment_line_id(+)
    and rsl.shipment_header_id = rsh.shipment_header_id(+)
--    and ail.inventory_item_id = msi.inventory_item_id(+)
    and pla.item_id = msi.inventory_item_id(+)
    and rsh.ship_to_org_id = msi.organization_id(+)
--    and rt.organization_id = ood.organization_id(+)
    and pda.destination_organization_id = ood.organization_id(+)
    and ai.invoice_id = aid.invoice_id
    and ai.org_id = aid.org_id
    and ail.line_number = aid.invoice_line_number
    and aid.dist_code_combination_id=gcc.code_combination_id
    and ail.cost_factor_id=ppet.price_element_type_id(+)
    --and lc.po_header_id(+) = pha.po_header_id
    and pha.po_header_id = pda.po_header_id(+)
    and pla.po_header_id = pda.po_header_id(+)
    and pla.po_line_id = pda.po_line_id(+)
    and (ail.discarded_flag='N' or ail.discarded_flag is null)
    and (ail.cancelled_flag='N' or ail.cancelled_flag is null)
    and (aid.reversal_flag='N' or aid.reversal_flag is null)
    and ai.cancelled_date is null
order by 
    ai.doc_sequence_value
    ,ail.line_number
    ,aid.distribution_line_number
    ;


select * from apps.ap_invoice_lines_all