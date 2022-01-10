/* Formatted on 1/19/2020 1:58:27 PM (QP5 v5.287) */
  SELECT --DISTINCT
         pha.segment1 "PO Number",
         rsh.receipt_num "GRN Number",
         rt.transaction_id,
         ood.organization_code,
         pla.purchase_basis "Line Type",
         pda.destination_type_code,
         pha.type_lookup_code "PO Type",
         pha.authorization_status,
         TO_CHAR (TRUNC (pha.creation_date), 'DD-MON-RR') CREATION_DATE,
         TO_CHAR (TRUNC (pha.last_update_date), 'DD-MON-RR') LAST_UPDATE_DATE,
         TO_CHAR (TRUNC (pha.approved_date), 'DD-MON-RR') APPROVED_DATE,
         DECODE (pll.match_option,  'R', 'Receipt',  'P', 'PO')
            invoice_match_option,
         pll.receipt_required_flag,
         pda.accrue_on_receipt_flag,
         rsh.shipment_num,
         rt.subinventory,
         rt.transaction_id,
         rt.parent_transaction_id,
         rt.transaction_type,
         rt.quantity rcv_trx_qty,
         TO_CHAR (TRUNC (rsh.creation_date), 'DD-MON-RR') GRN_CREATION,
         TO_CHAR (TRUNC (rt.transaction_date), 'DD-MON-RR') transaction_date,
         ppf.employee_number,
         ppf.full_name,
         --pha.approved_date,
         pv.segment1 "Supplier ID",
         pv.vendor_name "Supplier Name",
         pla.line_num,
         msi.segment1 "Item Code",
         pla.item_description,
         pla.unit_meas_lookup_code "UOM",
         pha.currency_code,
         pla.quantity po_qty,
         pla.unit_price,
         pla.quantity * pla.unit_price amount,
            gcc.segment1
         || '.'
         || gcc.segment2
         || '.'
         || gcc.segment3
         || '.'
         || gcc.segment4
         || '.'
         || gcc.segment5
         || '.'
         || gcc.segment6
         || '.'
         || gcc.segment7
         || '.'
         || gcc.segment8
         || '.'
         || gcc.segment9
            "Natural Accounts"
    FROM apps.po_headers_all pha,
         apps.po_lines_all pla,
         apps.po_distributions_all pda,
         apps.po_line_locations_all pll,
         apps.mtl_system_items_vl msi,
         apps.gl_code_combinations gcc,
         apps.rcv_transactions rt,
         apps.rcv_shipment_headers rsh,
         apps.org_organization_definitions ood,
         apps.ap_suppliers pv,
         apps.fnd_user fu,
         apps.per_people_f ppf
   WHERE 1 = 1 
         AND pha.po_header_id = pla.po_header_id
         AND pla.po_header_id = pda.po_header_id
         AND pla.po_line_id = pda.po_line_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pla.item_id = msi.inventory_item_id(+)
         AND pda.destination_organization_id = msi.organization_id
         AND pda.code_combination_id = gcc.code_combination_id
         AND pla.po_line_id = rt.po_line_id(+)
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         -- and pv.segment1 in (4800)
         -- and rt.transaction_date between '01-JAN-2011' and '16-MAY-2018'
         --AND pha.segment1 IN ('10213000238')
         -- and rsh.receipt_num in (2701)
         -- and rt.shipment_header_id=768930
         -- and ood.organization_name like '%Marble%'
         -- and msi.segment1 in ('PACK.MAT0.0142')
         --'ELEC.ELEC.2716',
         --'ELEC.ELEC.2730',
         --'ELEC.ELEC.2722',
         --'ELEC.ELEC.2722',
         --'ELEC.ELEC.2731',
         --'ELEC.ELEC.2731',
         --'ELEC.ELEC.2716',
         --'ELEC.ELEC.2721',
         --'ELEC.ELEC.2721')
         -- and pla.line_num=1
         -- and rt.transaction_type='RECEIVE'
         AND ood.organization_id = pda.destination_organization_id
         AND pda.destination_organization_id = rsh.ship_to_org_id
         AND pha.vendor_id = pv.vendor_id
         AND (:P_ORG_ID is null or (PHA.ORG_ID = :P_ORG_ID))
         AND (:p_po_no is null or (pha.segment1 = :p_po_no))
         AND (:p_grn_no is null or (rsh.receipt_num = :p_grn_no))
         AND (:P_ITEM_CODE IS NULL OR (MSI.SEGMENT1 = :P_ITEM_CODE))
         AND (:P_ITEM_DESC IS NULL OR (UPPER(MSI.DESCRIPTION) LIKE UPPER('%'||:P_ITEM_DESC||'%') ))
         -- and ood.organization_code='SCS'
         AND rt.created_by = fu.user_id
         AND fu.user_name = ppf.employee_number
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
ORDER BY pla.line_num, rsh.receipt_num, rt.transaction_id;

--------------------------------------------------------------------------------

  SELECT 
         rsh.shipment_num,
         rsh.receipt_num,
         rsh.attribute_category,
         rsh.attribute1,
         rt.transaction_type,
         rt.transaction_date,
         rt.quantity
         --,rt.*
         --,rsh.*
    FROM apps.rcv_shipment_headers rsh, apps.rcv_transactions rt
   WHERE     1 = 1
         AND rsh.receipt_num = 21114100255
         AND rsh.receipt_source_code = 'INVENTORY'
         AND rsh.shipment_header_id = rt.shipment_header_id
         AND rsh.ship_to_org_id = rt.organization_id
ORDER BY rt.transaction_id;


--------------------------------------------------------------------------------

SELECT * FROM apps.rcv_shipment_headers;


