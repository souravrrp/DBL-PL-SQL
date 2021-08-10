select 
 a.segment1,
 a.po_header_id,
 a.vendor_name,
 a.approved_date,
 a.receipt_num,
 a.doc_sequence_value,
 a.Natural_Account,
 a.authorization_status,
 a.currency_code,
 a.OU,
 a.lc_number,
 a.bank_name,
 a.bank_branch_name,
 a.lc_opening_date,
 a.ship_num ,
 a.ship_date ,
 a.name,
 sum(Estimated_Amount),
 sum(Actual_Amount)
 from
(select
 pha.segment1,
 pha.po_header_id,
 pv.vendor_name,
 pha.approved_date,
 pha.authorization_status,
 pha.currency_code,
 null receipt_num,
 '128101' Natural_Account,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )' OU,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 pha.org_id,
 ish.ship_num ,
 null doc_sequence_value,
 ish.ship_date ,
 ppett.name,
 ((allocation_amt)*nvl(icl.currency_conversion_rate,1)) Estimated_Amount,
 null Actual_Amount
FROM 
  inl_ship_headers_all ish ,
  inl_ship_lines_all isl ,
  inl_allocations ia,
  inl_charge_lines icl,
  pon_price_element_types ppet,
  pon_price_element_types_tl ppett,
  po_line_locations_all pll,
  po_lines_all pla,
  po_headers_all pha,
  mtl_system_items_b mis,
  po_vendors pv,
  hr_all_organization_units ou,
  apps.org_organization_definitions ood,
  XXDBL_COMPANY_LE_MAPPING_V hou,
  xx_lc_details lc
where 
 ish.ship_header_id=isl.ship_header_id(+)
 and isl.ship_header_id=ia.ship_header_id(+)
 and isl.ship_line_id=ia.ship_line_id(+)
 and ia.from_parent_table_name='INL_CHARGE_LINES'
 and lc_status='Y'
 and isl.match_id is null
 and ia.from_parent_table_id=icl.charge_line_id(+)
 and  icl.charge_line_type_id = ppet.price_element_type_id(+)
 and ppet.price_element_type_id = ppett.price_element_type_id(+)
 and pll.line_location_id=isl.ship_line_source_id(+)
 AND IA.FROM_PARENT_TABLE_ID   = ICL.CHARGE_LINE_ID
 AND IA.ALLOCATION_ID          = IA.PARENT_ALLOCATION_ID
 AND ISL.SHIP_LINE_ID           = IA.SHIP_LINE_ID
 and pha.segment1=lc.po_number(+)
 and pll.po_line_id=pla.po_line_id
 and pla.po_header_id=pha.po_header_id
 and pla.item_id=mis.inventory_item_id
 and mis.organization_id=pll.ship_to_organization_id
 and pha.vendor_id=pv.vendor_id
 and pha.org_id=ou.organization_id
 and pll.ship_to_organization_id=ood.organization_id
 and pha.org_id=hou.org_id
 and (pha.org_id=:p_org_id or :p_org_id  is null) 
 and hou.legal_entity_id=:p_legal
 and (lc.lc_number=:p_lc_number or :p_lc_number is null)
-- and (pha.po_header_id=:p_po_number or :p_po_number is null)
 and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
 union all
select
po.segment1,
po.po_header_id,
sup.vendor_name,
po.approved_date,
po.authorization_status,
po.currency_code,
rsh.receipt_num,
ffv.flex_value_meaning Natural_Account,
hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )' OU,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 po.org_id,
 null ship_num ,
  to_char(ai.doc_sequence_value)||' -L',
 ai.gl_date ship_date ,
 ppetv.name,
 null Estimated_Amount,
 NVL (AD.BASE_AMOUNT, AD.AMOUNT) Actual_Amount
     FROM XX_LC_DETAILS LC,
          AP_INVOICES_ALL AI,
          ap_suppliers sup,
          AP_INVOICE_DISTRIBUTIONS_ALL AD,
          apps.gl_code_combinations gcc,
          apps.fnd_flex_values_vl ffv,
          ap_invoice_lines_all AL,
          XXDBL_COMPANY_LE_MAPPING_V hou,
          pon_price_element_types_vl ppetv,
          PO_HEADERS_All PO,
          rcv_transactions rt,
          rcv_shipment_headers rsh
    WHERE     LC.PO_HEADER_ID = AL.PO_HEADER_ID
          AND AI.INVOICE_ID = AL.INVOICE_ID
          AND NVL (AL.discarded_flag, 'N') = 'N'
          AND AL.invoice_id = AD.invoice_id
          and po.vendor_id=sup.vendor_id
          and ad.dist_code_combination_id=gcc.code_combination_id
          and gcc.segment5=ffv.flex_value_meaning
          AND AL.line_number = AD.invoice_line_number
          AND NVL (AL.cost_factor_id, 12) = ppetv.price_element_type_id(+)
          AND LC.po_header_id = PO.po_header_id
          AND rt.PO_HEADER_ID = al.PO_HEADER_ID
          and po.org_id=hou.org_id
          AND rt.SHIPMENT_HEADER_ID = rsh.SHIPMENT_HEADER_ID
          AND rt.transaction_id = ad.rcv_transaction_id
          AND rt.transaction_type = 'RECEIVE'
          and ai.invoice_type_lookup_code <>'PREPAYMENT'
           and ai.cancelled_date is null
          and lc_status='Y'
          and al.line_type_lookup_code<>'ITEM'
          and ppetv.name <>'Document Endorsement'
--          and lc_number='DC DAK781891'
--          and po.org_id=:p_org_id 
and (po.org_id=:p_org_id or :p_org_id  is null) 
          and hou.legal_entity_id=:p_legal
            and (lc.lc_number=:p_lc_number or :p_lc_number is null)
           and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
 union all
 select 
 po.segment1,
 po.po_header_id,
 sup.vendor_name,
 po.approved_date,
 po.authorization_status,
 po.currency_code,
 rsh.receipt_num ,
 ffv.flex_value_meaning Natural_Account,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )'  OU,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 po.org_id,
 null ship_num ,
 to_char(ai.doc_sequence_value)||' -G',
 ai.gl_date  ship_date ,
 'Document Value' name,
 sum(NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Estimated_Amount,
 sum(NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
from
  xx_lc_details LC,
  ap_invoices_all  AI,
  ap_suppliers sup,
  ap_invoice_distributions_all  ad,
  ap_invoice_lines_all AL,
  gl_code_combinations gcc,
  fnd_flex_values_vl ffv,
  XXDBL_COMPANY_LE_MAPPING_V hou,
   PO_HEADERS_All PO,
   rcv_transactions rt,
   rcv_shipment_headers rsh
    WHERE     LC.PO_HEADER_ID = AL.PO_HEADER_ID
          and AI.INVOICE_ID = AL.INVOICE_ID
          and nvl (AL.discarded_flag, 'N') = 'N'
          and AL.invoice_id = AD.invoice_id
          and po.vendor_id=sup.vendor_id
          and AL.line_number = AD.invoice_line_number
          and LC.po_header_id = PO.po_header_id
          and rt.PO_HEADER_ID = al.PO_HEADER_ID
          and po.org_id=hou.org_id
          and rt.SHIPMENT_HEADER_ID = rsh.SHIPMENT_HEADER_ID
          and ad.dist_code_combination_id=gcc.code_combination_id
          and gcc.segment5=ffv.flex_value_meaning
          and ffv.flex_value_set_id=1017040 
          and rt.transaction_id = ad.rcv_transaction_id
          and rt.transaction_type = 'RECEIVE'
          and ad.line_type_lookup_code='ACCRUAL'
          and ai.invoice_type_lookup_code <>'PREPAYMENT'
          and ai.cancelled_date is null
          and al.line_type_lookup_code='ITEM'
          and lc_status='Y'
--          and lc_number='DC DAK779881'
--         and po.org_id=:p_org_id 
and (po.org_id=:p_org_id or :p_org_id  is null) 
and hou.legal_entity_id=:p_legal
           and (lc.lc_number=:p_lc_number or :p_lc_number is null)
           and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
group by 
 po.segment1,
 po.po_header_id,
 po.approved_date,
 po.authorization_status,
 ai.doc_sequence_value,
 sup.vendor_name,
 po.currency_code,
 rsh.receipt_num ,
 ffv.flex_value_meaning,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )',
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 po.org_id,
 gl_date
 union all
 select 
 po.segment1,
 po.po_header_id,
 sup.vendor_name,
 po.approved_date,
 po.authorization_status,
 po.currency_code,
 null receipt_num ,
 ffv.flex_value_meaning Natural_Account,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )'  OU,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 po.org_id,
 null ship_num ,
 to_char(ai.doc_sequence_value)||' -D',
 ai.gl_date  ship_date ,
 ad.attribute2 name,
 null Estimated_Amount,
 sum(NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
from
  xx_lc_details LC,
  ap_invoices_all  AI,
  ap_suppliers sup,
  ap_invoice_distributions_all  AD,
  gl_code_combinations gcc,
  fnd_flex_values_vl ffv,
  ap_invoice_lines_all AL,
  XXDBL_COMPANY_LE_MAPPING_V hou,
  PO_HEADERS_All PO
--   rcv_transactions rt,
--   rcv_shipment_headers rsh
 where     
   lc.lc_id=to_number(ad.attribute1)
   and  ai.invoice_id = al.invoice_id
   and nvl (al.discarded_flag, 'N') = 'N'
   and al.invoice_id = ad.invoice_id
   and  po.vendor_id=sup.vendor_id
   and al.line_number = ad.invoice_line_number
   and ad.dist_code_combination_id=gcc.code_combination_id
   and gcc.segment5=ffv.flex_value_meaning
   and ffv.flex_value_set_id=1017040 
   and lc.po_header_id = po.po_header_id
   and po.org_id=hou.org_id
   and ai.cancelled_date is null
   and al.line_type_lookup_code='ITEM'
   and lc_status='Y'
   and ad.attribute_category='LC Details Information' 
   and ad.po_distribution_id is  null 
   and al.po_header_id is null
   and ad.attribute1 is not null
   and ai.invoice_type_lookup_code <>'PREPAYMENT'
--   and lc_number='147817020366'
--   and po.org_id=:p_org_id 
and (po.org_id=:p_org_id or :p_org_id  is null)
and hou.legal_entity_id=:p_legal
   and (lc.lc_number=:p_lc_number or :p_lc_number is null)
   and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
group by 
 po.segment1,
 po.po_header_id,
 po.approved_date,
 po.authorization_status,
 ai.doc_sequence_value,
 sup.vendor_name,
 po.currency_code,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )',
 ffv.flex_value_meaning ,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 po.org_id,
 gl_date,
 ad.attribute2 
 union all
 select 
 lc.po_number,
 lc.po_header_id,
 lc.supplier_name,
 lc.lc_opening_date approved_date,
 'APPROVED' authorization_status,
 upper(lc.currency_code)currency_code,
 null receipt_num ,
 ffv.flex_value_meaning Natural_Account,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )'  OU,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 lc.org_id,
 null ship_num ,
 to_char(ai.doc_sequence_value)||' -D',
 ai.gl_date  ship_date ,
 ad.attribute2 name,
 null Estimated_Amount,
 sum(NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
from
  xx_lc_details LC,
  ap_invoices_all  AI,
  ap_suppliers sup,
  gl_code_combinations gcc,
  fnd_flex_values_vl ffv,
  ap_invoice_distributions_all  AD,
  ap_invoice_lines_all AL,
  XXDBL_COMPANY_LE_MAPPING_V hou
--  PO_HEADERS_All PO
--   rcv_transactions rt,
--   rcv_shipment_headers rsh
 where     
   lc.lc_id=to_number(ad.attribute1)
   and  ai.invoice_id = al.invoice_id
   and nvl (al.discarded_flag, 'N') = 'N'
   and al.invoice_id = ad.invoice_id
   and  ai.vendor_id=sup.vendor_id
   and al.line_number = ad.invoice_line_number
   and ad.dist_code_combination_id=gcc.code_combination_id
   and gcc.segment5=ffv.flex_value_meaning
   and ffv.flex_value_set_id=1017040 
   and ai.invoice_type_lookup_code <>'PREPAYMENT'
--   and lc.po_header_id = po.po_header_id
   and ai.org_id=hou.org_id
   and ai.cancelled_date is null
   and al.line_type_lookup_code='ITEM'
   and lc_status='Y'
   and ad.attribute_category='LC Details Information' 
   and ad.po_distribution_id is  null 
   and al.po_header_id is null
   and ad.attribute1 is not null
   and lc.po_number not in (Select segment1 from po_headers_all)
--   and lc_number='147817020366'
--   and (po.org_id=:p_org_id or :p_org_id is null)
   and lc.lc_number=:p_lc_number 
--   and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
group by 
 lc.po_number,
 lc.po_header_id,
-- po.approved_date,
-- po.authorization_status,
 ai.doc_sequence_value,
 lc.supplier_name,
 lc.currency_code,
 hou.LEGAL_ENTITY_NAME||' ( '||unit_name||' )',
 ffv.flex_value_meaning ,
 lc.lc_number,
 lc.bank_name,
 lc.bank_branch_name,
 lc.lc_opening_date,
 lc.org_id,
 gl_date,
 ad.attribute2 
           )a
           group by 
            a.segment1,
 a.po_header_id,
 a.vendor_name,
 a.approved_date,
 a.authorization_status,
 a.currency_code,
 a.receipt_num,
 a.Natural_Account,
 a.doc_sequence_value,
 a.OU,
 a.lc_number,
 a.bank_name,
 a.bank_branch_name,
 a.lc_opening_date,
 a.ship_num ,
 a.ship_date ,
 a.name
 order by   a.name desc,a.ship_num, a.ship_date asc