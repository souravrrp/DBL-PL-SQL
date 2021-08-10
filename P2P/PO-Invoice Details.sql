/* Formatted on 6/8/2021 2:40:16 PM (QP5 v5.287) */
SELECT aia.invoice_num,
       aia.invoice_currency_code,
       DECODE (aia.PAYMENT_STATUS_FLAG,
               'N', 'UnPaid',
               'P', 'Partial Paid',
               'Y', 'Paid')
          PAYMENT_STATUS_FLAG,
       aia.invoice_date,
       aps.vendor_name,
       apss.vendor_site_code,
       aila.line_number,
       aia.invoice_amount,
       aila.amount line_amount,
       pha.segment1 po_number,
       aila.line_type_lookup_code,
       apt.name Term_name,
       gcc.concatenated_segments distributed_code_combinations,
       aca.check_number,
       aipa.amount payment_amount,
       apsa.amount_remaining,
       aipa.invoice_payment_type,
       hou.name operating_unit,
       gl.name ledger_name
  FROM apps.ap_invoices_all aia,
       ap_invoice_lines_all aila,
       ap_invoice_distributions_all aida,
       ap_suppliers aps,
       ap_supplier_sites_all apss,
       po_headers_all pha,
       gl_code_combinations_kfv gcc,
       ap_invoice_payments_all aipa,
       ap_checks_all aca,
       ap_payment_schedules_all apsa,
       ap_terms apt,
       hr_operating_units hou,
       gl_ledgers gl
 WHERE     aia.invoice_id = aila.invoice_id
       AND aila.invoice_id = aida.invoice_id
       AND aila.line_number = aida.invoice_line_number
       AND aia.vendor_id = aps.vendor_id
       AND aia.VENDOR_SITE_ID = APSS.VENDOR_SITE_ID
       AND aps.vendor_id = apss.VENDOR_ID
       AND aia.po_header_id = pha.po_header_id(+)
       AND aida.dist_code_combination_id = gcc.code_combination_id
       AND aipa.invoice_id(+) = aia.invoice_id
       AND aca.check_id(+) = aipa.check_id
       AND apsa.invoice_id = aia.invoice_id
       AND apt.term_id = aia.terms_id
       AND hou.organization_id = aia.org_id
       AND gl.ledger_id = aia.set_of_books_id
       --and aia.invoice_id='400700'
       --AND aia.ORG_ID = :P_ORG_ID--DPCDAK978558
       AND invoice_num = :p_invoice_num;