/* Formatted on 6/8/2021 3:11:46 PM (QP5 v5.287) */
  SELECT aia.invoice_num "Invoice Number",
         aps.vendor_name "Vendor Name", -- get vendor name from ap_suppliers table
         assa.vendor_site_code "Vendor Site Code",
         aia.invoice_id "Invoice ID",
         aia.invoice_currency_code "Currency Code",
         aia.invoice_amount "Invoice Amount",
         aia.amount_paid "Amount Paid",
         aia.invoice_type_lookup_code "Invoice Type", -- values are derived from ap_lookup_codes and lookup_type = 'INVOICE TYPE'. --STANDARD, CREDIT, DEBIT, EXPENSE REPORT, PREPAYMENT, MIXED, RETAINAGE RELEASE are other Invoice Types
         aia.description,
         aia.payment_method_lookup_code, -- values are derived from ap_lookup_codes table and lookup_type = 'PAYMENT METHOD' -- Check, Clearing, Electronic, Wire
         aia.terms_id "Terms ID",        -- get terms name from ap_terms table
         aia.pay_group_lookup_code, -- values are derived from the fnd_lookup_values_vl and lookup_type = 'PAY GROUP'
         aia.org_id "Operating Unit ID", -- values are derived from hr_operating_units table - organization_id column
         aia.gl_date "GL Date",
         aia.wfapproval_status,
         ail.line_number "Line Number",
         ail.line_type_lookup_code "Line Type", -- values are derived from ap_lookup_codes and lookup_type = 'INVOICE LINE TYPE' -- Item, Freigh, Miscellaneous, Tax
         ail.amount "Line Amount",
         aid.dist_code_combination_id "Distribution Code Comb ID", -- segment information can be derived from gl_code_combinations_kfv
         aid.accounting_event_id "Invoice Accounting Event ID", -- will be used to link to SLA tables
         apsa.amount_remaining "Remaining Invoice Amount",
         apsa.due_date "Due Date",
         aipa.accounting_event_id "Payment Accounting Event ID",
         aca.amount "Check Amount",
         aca.check_number "Check Number",
         aca.checkrun_name "Payment Process Request",
         idpa.document_amount "Payment Amount",
         idpa.pay_proc_trxn_type_code "Payment Processing Document",
         idpa.calling_app_doc_ref_number "Invoice Number",
         ipa.paper_document_number "Payment Number",
         ipa.payee_name "Paid to Name",
         ipa.payee_address1 "Paid to Address",
         ipa.payee_city "Paid to City",
         ipa.payee_postal_code "Payee Postal Code",
         ipa.payee_state "Payee State",
         ipa.payee_country "Payee Country",
         ipa.payment_profile_acct_name "Payment Process Profile",
         ipa.int_bank_name "Payee Bank Name",
         ipa.int_bank_number "Payee Bank Number",
         ipa.int_bank_account_name "Payee Bank Account Name",
         ipa.int_bank_account_number "Payee Bank Account Number"
    FROM ap_invoices_all aia,
         ap_invoice_lines_all ail,
         ap_invoice_distributions_all aid,
         ap_suppliers aps,
         ap_supplier_sites_all assa,
         ap_payment_schedules_all apsa,
         ap_invoice_payments_all aipa,
         ap_checks_all aca,
         iby_docs_payable_all idpa,
         iby_payments_all ipa
   WHERE     1 = 1
         AND aia.invoice_id = ail.invoice_id
         AND aia.invoice_id = aid.invoice_id
         AND aia.vendor_id = aps.vendor_id
         AND aps.vendor_id = assa.vendor_id
         AND aia.invoice_id = apsa.invoice_id
         AND aia.invoice_id = aipa.invoice_id
         AND aipa.check_id = aca.check_id
         AND aia.invoice_id = idpa.calling_app_doc_unique_ref2
         AND idpa.calling_app_id = 200
         AND aps.party_id = idpa.payee_party_id
         AND ipa.payment_id = idpa.payment_id
         AND aps.segment1 = ipa.payee_supplier_number
         AND assa.vendor_site_id = ipa.supplier_site_id
         AND assa.org_id = aia.org_id
         AND aca.vendor_site_id = assa.vendor_site_id
         AND ( :p_grn_no IS NULL OR (aia.invoice_num = :p_invoice_num))
GROUP BY aia.invoice_num,
         aps.vendor_name,
         assa.vendor_site_code,
         aia.invoice_id,
         aia.invoice_currency_code,
         aia.invoice_amount,
         aia.amount_paid,
         aia.invoice_type_lookup_code,
         aia.description,
         aia.payment_method_lookup_code,
         aia.terms_id,
         aia.pay_group_lookup_code,
         aia.org_id,
         aia.gl_date,
         aia.wfapproval_status,
         ail.line_number,
         ail.line_type_lookup_code,
         ail.amount,
         aid.dist_code_combination_id,
         aid.accounting_event_id,
         apsa.amount_remaining,
         apsa.due_date,
         aipa.accounting_event_id,
         aca.amount,
         aca.check_number,
         aca.checkrun_name,
         idpa.document_amount,
         idpa.pay_proc_trxn_type_code,
         idpa.calling_app_doc_ref_number,
         ipa.paper_document_number,
         ipa.payee_name,
         ipa.payee_address1,
         ipa.payee_city,
         ipa.payee_postal_code,
         ipa.payee_state,
         ipa.payee_country,
         ipa.payment_profile_acct_name,
         ipa.int_bank_name,
         ipa.int_bank_number,
         ipa.int_bank_account_name,
         ipa.int_bank_account_number;