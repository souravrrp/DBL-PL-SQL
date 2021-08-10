/* Formatted on 1/25/2021 9:50:35 AM (QP5 v5.354) */
  SELECT rsh.shipment_header_id,
         rsh.creation_date          transaction_date,
         pha.segment1               po_number,
         NULL                       lc_number,
         pha.approved_Date,
         sup.vendor_name,
         sup.segment1               vendor_id,
         sus.vendor_site_code,
         rsh.receipt_num            grn_no,
         rsh.attribute3,
         rsh.creation_date,
         rsh.comments               remarks,
         rsh.shipment_num           Shipment_Number,
         NULL                       ship_date,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id     Organization_id,
         NULL                       to_subinventory,
         'NA'                       item_code,
         rsl.item_description,
         rsl.unit_of_measure        uom,
         rsl.quantity_shipped       rcv_qty,
         rsl.quantity_shipped       Ins_qty,
         rsl.quantity_shipped       del_qty,
         NULL                       acctual_qty
    FROM rcv_shipment_headers        rsh,
         rcv_shipment_lines          rsl,
         po_headers_all              pha,
         po_lines_all                pla,
         po_line_locations_all       pll,
         org_organization_definitions ood,
         ap_suppliers                sup,
         ap_supplier_sites_all       sus
   WHERE     rsh.shipment_header_id = rsl.shipment_header_id
         AND pha.po_header_id = rsl.po_header_id
         AND pha.po_header_id = pla.po_header_id
         AND rsl.po_line_id = pla.po_line_id
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pll.po_line_id = rsl.po_line_id
         AND rsl.to_organization_id = ood.organization_id
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sus.vendor_id
         AND rsl.item_id IS NULL
         AND pll.quantity_received <> 0
         --AND pha.segment1 = '21113003363'
         --and receipt_num='10324200129'
         AND rsl.to_organization_id = :p_organization_id
         AND rsh.shipment_header_id BETWEEN NVL ( :p_grn_f,
                                                 rsh.shipment_header_id)
                                        AND NVL ( :p_grn_t,
                                                 rsh.shipment_header_id)
GROUP BY rsh.shipment_header_id,
         rsh.creation_date,
         pha.segment1,
         pha.approved_Date,
         sup.vendor_name,
         sup.segment1,
         sus.vendor_site_code,
         rsh.receipt_num,
         rsh.attribute3,
         rsh.creation_date,
         rsh.comments,
         rsh.shipment_num,
         ood.organization_code,
         ood.organization_name,
         rsl.to_organization_id,
         rsl.item_description,
         rsl.unit_of_measure,
         rsl.quantity_shipped