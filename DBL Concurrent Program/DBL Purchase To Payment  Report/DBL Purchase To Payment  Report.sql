select 
 ou_name,
 org_id,
 organization_name,
 request_number,
 requisition_number,
 PR_Approved_Date,
 po_number,
 ship_num,
 ship_date,
 lc_number,
lc_opening_date,
--currency_code,
 bank_name,
 Approve_Status,
 po_approved_date,
 trunc (po_approved_date)-trunc (PR_Approved_Date) "PR_to_pay_L",
 Supplier_Name,
 item_code,
 item_name,
 item_category_1,
 item_category_2,
 item_category_3,
 item_category_4,
currency_code,
 uom,
 PR_Quantity,
 PR_price,
 PO_Quantity,
 quantity_billed ,
 po_price,
 receipt_num , 
 Grn_date,  
 trunc(grn_date)-trunc (po_approved_date) "GRN Lead_time",
 grn_quantity ,
 invoice_num,  
 voucher_number, 
 invoice_date, 
 trunc(invoice_date) -trunc(grn_date) "Invoice_L",
 payment_voucher, 
 payment_date,
 trunc(invoice_date)-trunc(payment_date) "Inv_Pay_L",
 bank_account_name   
 from
  apps.xxdbl_pr_to_pay
  where (:p_legal is null or legal_entity_id=:p_legal)
  and (:p_org_id is null or org_id=:p_org_id)
  and (:p_requisition_number is null or requisition_number =:p_requisition_number)
  and (:p_po_number is null or po_number=:p_po_number)
  and (:p_lc_number is null or lc_number=:p_lc_number)
  and (:p_supplier is null or supplier_name =:p_supplier)
  and (:p_grn is null or receipt_num=:p_grn)
  and (:p_category is null or item_category_1=:p_category)
  and (:p_category_2 is null or item_category_2=:p_category_2)
  and (:p_category_3 is null or item_category_3=:p_category_3)
  and (:p_inv_vouhcer is null or voucher_number=:p_inv_vouhcer)
  and (:p_pay_voucher is null or payment_voucher=:p_pay_voucher)
  and (:p_pr_date_from is null or  trunc(pr_approved_Date) between trunc(:p_pr_date_from)  and trunc(:p_pr_date_to))
  and (:p_po_date_from is null or  trunc(po_approved_Date) between trunc(:p_po_date_from)  and trunc(:p_po_date_to))
  and (:p_grn_date_from is null or trunc(grn_Date) between trunc(:p_grn_date_from)  and trunc(:p_grn_date_to))
  and (:p_inv_date_from is null or trunc(invoice_Date) between trunc(:p_inv_date_from)  and trunc(:p_inv_date_to))
  and (:p_lc_date_form is null or  trunc(lc_opening_date) between trunc(:p_lc_date_form) and trunc(:p_lc_date_to))
  order by
   org_id,requisition_number,po_number