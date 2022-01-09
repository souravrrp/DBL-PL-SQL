/* Formatted on 1/8/2022 4:54:27 PM (QP5 v5.374) */
  SELECT                                                            --DISTINCT
         ------------------------------------------------------Organization Info
         NVL (prh.org_id, pha.org_id)
             org_id,
         hou.name
             operating_unit,
         -------------------------------------------------------Item Master Info
         'ITEM---INFO'
             ITEM_INFO,
         msib.inventory_item_id,
         msib.segment1
             item_code,
         NVL (msib.description, prl.item_description)
             item_description,
         -------------------------------------------------------Requisition Info
         'REQ---INFO'
             REQ_INFO,
         prh.segment1
             requisition_number,
         prl.line_num,
         --prh.requisition_header_id,
         --prl.requisition_line_id,
         --prda.distribution_id req_distribution_id,
         TO_CHAR (prh.creation_date, 'DD-MON-RRRR HH12:MI:SS PM')
             req_creation_date,
         prh.authorization_status
             req_status,
         TO_CHAR (prh.approved_date, 'DD-MON-RRRR HH12:MI:SS PM')
             req_approved_date,
         prh.attribute8
             purpose,
         prl.need_by_date
             req_need_by_date,
         prl.unit_meas_lookup_code
             uom,
         prl.quantity
             req_qty,
         (SELECT pf.first_name || ' ' || pf.middle_names || ' ' || pf.last_name
            FROM per_people_f pf
           WHERE     prl.suggested_buyer_id = pf.person_id(+)
                 AND SYSDATE BETWEEN pf.effective_start_date
                                 AND pf.effective_end_date)
             buyer,
         prl.suggested_buyer_id,
         prl.attribute1
             brand,
         prl.attribute2
             orgin,
         prl.attribute3
             make,
         prl.attribute6
             order_no,
         prl.attribute7
             use_of_area,
         LTRIM (
             RTRIM (
                    ppf.first_name
                 || ' '
                 || ppf.middle_names
                 || ' '
                 || ppf.last_name))
             pr_created_by,
         NVL (msi.description, secondary_inventory_name)
             subinv,
         prl.destination_subinventory
             subinventory,
         NVL (hla.description, hla.location_code)
             location_name,
         ----------------------------------------------------Purchase Order Info
         'PO---INFO'
             PO_INFO,
         pda.req_distribution_id
             req_dist_id,
         pha.segment1
             po_number,
         TO_CHAR (pha.creation_date, 'DD-MON-RRRR HH12:MI:SS PM')
             po_creation_date,
         pha.authorization_status
             po_status,
         TO_CHAR (pha.approved_date, 'DD-MON-RRRR HH12:MI:SS PM')
             po_approved_date,
         pla.quantity
             po_qty,
         DECODE (prl.attribute_category,
                 'Item Details', prl.attribute4,
                 prl.attribute4)
             buyer_id,
         ---------------------------------------------------------------GRN Info
         'GRN---INFO'
             GRN_INFO,
         rsh.receipt_num
             grn_no,
         rt.transaction_date
             receipt_date,
         rt.quantity
             receipt_qty,
         rt.po_unit_price
             rcv_po_price,
         rt.transaction_type,
         -----------------------------------------------------------Invoice Info
         'INV---INFO'
             INV_INFO,
         aia.invoice_num
             invoice_number,
         aia.invoice_id,
         aia.invoice_currency_code
             inv_currency_code,
         aia.invoice_amount,
         aia.amount_paid
             amount_paid,
         aia.invoice_type_lookup_code
             invoice_type,
         aia.description,
         aia.payment_method_lookup_code,
         aia.terms_id
             terms_id,
         aia.pay_group_lookup_code,
         aia.org_id
             operating_unit_id,
         aia.gl_date
             gl_date,
         aia.wfapproval_status,
         aila.line_number
             line_number,
         aila.line_type_lookup_code
             line_type,
         aila.amount
             line_amount,
         aida.accounting_date
             dist_inv_acct_date,
         -----------------------------------------------------------Payment Info
         'PAY---INFO'
             PAY_INFO,
         aipa.amount
             payment_amount,
         aipa.invoice_payment_type,
         aipa.accounting_date
             payment_voucher_date,
         -----------------------------------------------------------Project Info
         'PROJECT---INFO'
             PROJECT_INFO,
         apim.project_name
    --,hou.*
    --,ood.*
    --,prh.*
    --,prl.*
    --,prda.*
    --,msi.*
    --,apim.*
    --,hla.*
    --,fu.*
    --,ppf.*
    --,pda.*
    --,pla.*
    --,pll.*
    --,pha.*
    --,rt.*
    --,rsh.*
    --,aila.*
    --,aia.*
    --,aida.*
    --,aipa.*
    --,msi.*
    FROM apps.hr_operating_units          hou,
         apps.org_organization_definitions ood,
         po.po_requisition_headers_all    prh,
         po.po_requisition_lines_all      prl,
         po.po_req_distributions_all      prda,
         inv.mtl_system_items_b           msib,
         apps.all_project_info_master     apim,
         hr.hr_locations_all              hla,
         fnd_user                         fu,
         per_people_f                     ppf,
         po.po_distributions_all          pda,
         po.po_lines_all                  pla,
         po.po_line_locations_all         pll,
         po.po_headers_all                pha,
         po.rcv_transactions              rt,
         po.rcv_shipment_headers          rsh,
         ap.ap_invoice_lines_all          aila,
         ap.ap_invoices_all               aia,
         ap.ap_invoice_distributions_all  aida,
         ap.ap_invoice_payments_all       aipa,
         inv.mtl_secondary_inventories    msi
   WHERE     1 = 1
         AND NVL (prh.org_id, pha.org_id) = hou.organization_id(+)
         AND NVL (prl.destination_organization_id,
                  pda.destination_organization_id) =
             ood.organization_id(+)
         AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND prh.requisition_header_id = prl.requisition_header_id(+)
         AND NVL (prl.item_id, pla.item_id) = msib.inventory_item_id(+)
         AND NVL (prl.destination_organization_id,
                  pda.destination_organization_id) =
             msib.organization_id(+)
         AND prh.attribute4 = apim.project_id(+)
         AND prl.deliver_to_location_id = hla.location_id(+)
         AND prh.created_by = fu.user_id(+)
         AND prl.requisition_line_id = prda.requisition_line_id(+)
         AND prda.distribution_id = pda.req_distribution_id(+)
         AND pda.po_line_id = pla.po_line_id(+)
         AND pda.line_location_id = pll.line_location_id(+)
         AND pll.po_line_id = pla.po_line_id(+)
         AND pll.po_header_id = pha.po_header_id(+)
         AND pda.po_header_id = pha.po_header_id(+)
         AND pll.po_line_id = pla.po_line_id(+)
         AND fu.employee_id = ppf.person_id(+)
         AND prl.destination_subinventory = msi.secondary_inventory_name(+)
         AND prl.destination_organization_id = msi.organization_id(+)
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND ppf.effective_end_date
         AND prl.cancel_date IS NULL
         AND pla.po_header_id = aila.po_header_id(+)
         AND pll.line_location_id = aila.po_line_location_id(+)
         AND pla.po_line_id = aila.po_line_id(+)
         AND pla.org_id = aila.org_id(+)
         --AND rt.transaction_id = aila.rcv_transaction_id(+)
         AND aila.invoice_id = aia.invoice_id(+)
         AND aila.line_type_lookup_code(+) = 'ITEM'
         AND aila.org_id = aia.org_id(+)
         AND aia.invoice_id = aida.invoice_id(+)
         AND aida.line_type_lookup_code(+) = 'ACCRUAL'
         AND aia.invoice_id = aipa.invoice_id(+)
         AND aipa.reversal_flag(+) = 'N'
         AND ( :p_ou_name IS NULL OR (hou.name = :p_ou_name))
         AND (   ( :p_org_id IS NULL)
              OR (NVL (prh.org_id, pha.org_id) = :p_org_id))
         AND ( :p_req_no IS NULL OR (prh.segment1 = :p_req_no))
         AND ( :p_po_no IS NULL OR (pha.segment1 = :p_po_no))
         AND ( :p_grn_no IS NULL OR (rsh.receipt_num = :p_grn_no))
         AND ( :p_invoice_num IS NULL OR (aia.invoice_num = :p_invoice_num))
         AND ( :p_item_code IS NULL OR (msib.segment1 = :p_item_code))
         AND (   :p_item_desc IS NULL
              OR (UPPER (msib.description) LIKE
                      UPPER ('%' || :p_item_desc || '%')))
         AND prl.destination_organization_id =
             NVL ( :p_dest_org_id, prl.destination_organization_id)
         AND prh.authorization_status =
             NVL ( :p_authorization_status, prh.authorization_status)
         AND (   :p_from_creation_date IS NULL
              OR TRUNC (prh.creation_date) BETWEEN :p_from_creation_date
                                               AND :p_to_creation_date)
--GROUP BY NVL (prh.org_id, pha.org_id),
--         hou.name,
--         prh.requisition_header_id,
--         prh.segment1,
--         prh.creation_date,
--         prh.authorization_status,
--         prh.approved_date,
--         prl.need_by_date,
--         pha.segment1,
--         pha.creation_date,
--         pha.authorization_status,
--         pha.approved_date,
--         prl.line_num,
--         msib.segment1,
--         NVL (msib.description, prl.item_description),
--         prl.unit_meas_lookup_code,
--         prl.quantity,
--         pla.quantity,
--         prl.item_id,
--         --pf.person_id,
--         prl.suggested_buyer_id,
--         apim.project_name,
--         prh.attribute8,
--         prl.attribute1,
--         prl.attribute2,
--         prl.attribute3,
--         prl.attribute6,
--         prl.attribute7,
--         NVL (msi.description, secondary_inventory_name),
--         ppf.first_name,
--         ppf.middle_names,
--         ppf.last_name,
--         prl.destination_subinventory,
--         NVL (hla.description, hla.location_code),
--         prl.attribute6,
--         rsh.receipt_num,
--         rt.transaction_date,
--         rt.quantity,
--         rt.po_unit_price,
--         prl.attribute_category,
--         prl.attribute4,
--         prda.distribution_id,
--         pda.req_distribution_id,
--         ---------inv
--         aia.invoice_num,
--         aia.invoice_id,
--         aia.invoice_currency_code,
--         aia.invoice_amount,
--         aia.amount_paid,
--         aia.invoice_type_lookup_code,
--         aia.description,
--         aia.payment_method_lookup_code,
--         aia.terms_id,
--         aia.pay_group_lookup_code,
--         aia.org_id,
--         aia.gl_date,
--         aia.wfapproval_status,
--         aila.line_number,
--         aila.line_type_lookup_code,
--         aila.amount,
--         aida.accounting_date,
--         ----payment
--         aipa.amount,
--         aipa.invoice_payment_type,
--         aipa.accounting_date
ORDER BY NVL (prh.org_id, pha.org_id),
         prh.segment1,
         prl.line_num,
         pha.segment1;