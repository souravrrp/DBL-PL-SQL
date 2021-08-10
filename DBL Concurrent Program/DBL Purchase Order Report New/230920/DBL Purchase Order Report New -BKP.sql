/* Formatted on 9/23/2020 2:22:45 PM (QP5 v5.287) */
  SELECT    NVL (pha.attribute1, 'L')
         || '/'
         || NVL (hou.short_code, hou.name)
         || '/'
         || pha.segment1
            segment1,
         pha.po_header_id,
         pha.authorization_status,
         pha.creation_date,
         pha.approved_date,
         pha.currency_code,
         prha.segment1 "Requisition Number",
         sup.vendor_name,
         sups.vendor_site_code,
         LTRIM (
            RTRIM (
                  sups.address_line1
               || ' '
               || address_line2
               || ' '
               || address_line3
               || ' '
               || sups.city
               || ' '
               || sups.state
               || ' '
               || sups.zip))
            supplier_address,
         LTRIM (
            RTRIM (
                  loc.address_line_1
               || ' '
               || loc.address_line_2
               || ' '
               || loc.address_line_3
               || ' '
               || town_or_city
               || ' '
               || loc.postal_code
               || ' '
               || ft.nls_territory))
            ship_to,
         pha.comments,
         msi.segment1,
         NVL (msi.description, pla.item_description) description,
         pha.attribute10,
         pha.attribute11,
         pla.line_num,
         pla.attribute1 brand,
         pla.attribute2 Origin,
         NVL (pla.note_to_vendor, prol.attribute6) specipation,
         pla.unit_meas_lookup_code uom,
         pll.need_by_date,
         pda.quantity_ordered quantity,
         pla.unit_price,
         pda.quantity_ordered * pla.unit_price total_amount,
         --decode (pda.req_header_reference_num,null,xx_p2p_pkg.xx_fnd_requisition_info(pll.attribute1,:p_org_id,pll.attribute2,'RNUM'),  pda.req_header_reference_num) requisition_no
         org.organization_code,
         pay_po.check_number,
         pay_po.amount,
         pay_po.check_date,
         pay_po.invoice_num,
         pay_po.doc_sequence_value,
         pay_po.bank_name,
         ppf.first_name || ' ' || ppf.middle_names || ' ' || ppf.last_name
            global_name,
         NVL (lc.lc_number, btb_lc_no_phy) lc_number,
         NVL (lc.lc_opening_date, btb_open_dt) lc_opening_date,
         NVL (lc.bank_name, short_bank_name) lc_bank
    FROM apps.po_headers_all pha,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sups,
         apps.hr_locations_all loc,
         apps.fnd_territories ft,
         apps.po_lines_all pla,
         apps.po_line_locations_all pll,
         apps.po_distributions_all pda,
         apps.po_req_distributions_all prod,
         apps.po_requisition_lines_all prol,
         apps.po_requisition_headers_all prha,
         apps.mtl_system_items_b msi,
         apps.org_organization_definitions org,
         apps.hr_operating_units hou,
         (SELECT ck.amount,
                 ck.check_number,
                 NVL (ai.po_header_id, quick_po_header_id) po_header_id,
                 ai.quick_po_header_id,
                 ai.vendor_id,
                 ck.check_date,
                 ai.invoice_num,
                 ai.doc_sequence_value,
                 ai.invoice_currency_code,
                 bn.bank_name,
                 ai.org_id,
                 cb.bank_account_name
            FROM ap_invoices_all ai,
                 ap_checks_all ck,
                 ap_invoice_payments_all pm,
                 ce_bank_acct_uses_all cs,
                 ce_bank_accounts cb,
                 ce_bank_branches_v bn
           WHERE     ai.invoice_id = pm.invoice_id(+)
                 AND pm.check_id = ck.check_id(+)
                 AND ai.invoice_type_lookup_code = 'PREPAYMENT'
                 AND NVL (ck.status_lookup_code, 'DBL') <> 'VOIDED'
                 AND cs.bank_acct_use_id = ce_bank_acct_use_id
                 AND cb.bank_id = bn.bank_party_id
                 AND cb.bank_branch_id = bn.branch_party_id
                 --          and ai.po_header_id is not null
                 AND cs.bank_account_id = cb.bank_account_id) pay_po,
         fnd_user fu,
         per_people_f ppf,
         (SELECT po_number,
                 lc_number,
                 lc_opening_date,
                 bank_name
            FROM xx_lc_details lc
           WHERE lc_status = 'Y') lc,
         (SELECT DISTINCT b2b.po_header_id,
                          btb_lc_no_phy,
                          b2b.po_number,
                          short_bank_name,
                          b2b2.btb_open_dt
            FROM xxdbl.xx_explc_btb_mst b2b2,
                 xxdbl.xx_explc_btb_req_link b2b,
                 apps.ce_banks_v ce
           WHERE     b2b.btb_lc_no = b2b2.btb_lc_no
                 AND b2b2.org_bank_id = ce.bank_party_id
                 AND b2b2.btb_status != 'A') b2b
   WHERE     pha.po_header_id = pla.po_header_id
         AND pha.org_id = pla.org_id
         AND pha.org_id = hou.organization_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pha.po_header_id = pda.po_header_id
         AND pla.po_line_id = pda.po_line_id
         AND pll.line_location_id = pda.line_location_id
         AND pda.req_distribution_id = prod.distribution_id(+)
         AND prod.requisition_line_id = prol.requisition_line_id(+)
         AND prol.requisition_header_id = prha.requisition_header_id(+)
         AND pla.item_id = msi.inventory_item_id(+)
         AND pll.ship_to_organization_id = msi.organization_id(+)
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sups.vendor_id
         AND pll.ship_to_organization_id = org.organization_id
         AND pha.vendor_site_id = sups.vendor_site_id(+)
         AND pha.ship_to_location_id = loc.location_id(+)
         AND loc.country = ft.territory_code(+)
         AND pha.type_lookup_code = 'STANDARD'
         AND pha.po_header_id = pay_po.po_header_id(+)
         AND pha.org_id = pay_po.org_id(+)
         AND pha.vendor_id = pay_po.vendor_id(+)
         AND pha.created_by = fu.user_id
         AND fu.employee_id = ppf.person_id(+)
         AND pha.segment1 = lc.po_number(+)
         AND pha.segment1 = b2b.po_number(+)
         AND pha.po_header_id = b2b.po_header_id(+)
         AND NVL (pla.cancel_flag, 'N') = 'N'
         AND NVL (pll.cancel_flag, 'N') = 'N'
         AND pll.cancel_date IS NULL
         AND pda.quantity_cancelled = 0
         -- and lc.lc_status='Y'
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
         AND pha.org_id = :p_org_id
         -- and pha.po_header_id between nvl(:p_po_number,pha.po_header_id)  and nvl(:p_to_po_number,pha.po_header_id)
         AND (   :p_po_number IS NULL
              OR pha.po_header_id BETWEEN :p_po_number AND :p_to_po_number)
         AND TO_NUMBER (pha.vendor_id) =
                NVL (TO_NUMBER ( :p_vendor_id), TO_NUMBER (pha.vendor_id))
         AND (   :p_from_date IS NULL
              OR TRUNC (pha.creation_date) BETWEEN :p_from_date AND :p_to_date)
ORDER BY pla.line_num, pha.po_header_id