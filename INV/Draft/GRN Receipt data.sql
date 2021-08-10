/* Formatted on 5/10/2021 10:34:56 AM (QP5 v5.354) */
SELECT hou.name
           ou_name,
       ph.segment1
           po_num,
       ph.po_header_id,
       pol.po_line_id,
       pol.line_num,
       order_type.displayed_field
           line_type,
       COALESCE (pd.quantity_ordered, pll.quantity, pol.quantity)
           quantity,
       (pol.unit_price * (pd.quantity_ordered - pd.quantity_cancelled))
           line_amount,
       rsh.receipt_source_code,
       flv_ship_source.meaning
           receipt_source,
       papf.full_name
           received_by,
       rsh.vendor_id,
       aps.vendor_name,
       aps.segment1
           vendor_number,
       assa.vendor_site_id,
       assa.vendor_site_code,
       ph.org_id,
       rsh.shipment_num,
       rsh.receipt_num,
       rsh.ship_to_location_id,
       hl.location_code
           deliver_to,
       rsl.item_description,
       rsl.shipment_line_id,
       rsl.quantity_shipped,
       rsl.quantity_received,
       rsl.unit_of_measure,
       rsl.vendor_item_num,
       flv_shipment.meaning
           shipment_line_status_code,
       flv_inspection.meaning
           inspection_status_code,
       rsl.shipment_line_status_code,
       rct.inspection_status_code,
       flv_tran_type.meaning
           transaction_type,
       rct.transaction_type
           transaction_type_lookup_code,
       rct.transaction_id,
       NVL (rct.source_doc_quantity, 0)
           transaction_qty,
       rct.transaction_date,
       assa.attribute1
           vendor_global_code,
       assa.attribute2
           entity_supplier_code,
       assa.attribute3
           vendor_communication_language,
       pd.attribute1
           company_specific_gl_code,
       pol.attribute2
           sanction_number,
       pol.attribute3
           inspection_required,
       pol.attribute4
           end_user_details,
       rsh.attribute1
           Invoice_number,
       rct.comments
           gre_comments,
       rsh.attribute2
           exchange_rate_information,
       rsh.attribute3
           gst_invoice_amt,
       rsh.attribute4
           gst_exchange_rate,
       rsh.attribute5
           custom_form_no,
       rct.attribute1
           receipt_line_level_tax_rate
  FROM rcv_transactions           rct,
       rcv_shipment_headers       rsh,
       per_all_people_f           papf,
       rcv_shipment_lines         rsl,
       po_distributions_all       pd,
       po_lines_all               pol,
       po_line_locations_all      pll,
       po_headers_all             ph,
       ap_suppliers               aps,
       ap_supplier_sites_all      assa,
       hr_all_organization_units  hou,
       hr_locations               hl,
       fnd_lookup_values          flv_shipment,
       fnd_lookup_values          flv_inspection,
       fnd_lookup_values          flv_tran_type,
       fnd_lookup_values          flv_ship_source,
       po_lookup_codes            order_type,
       po_line_types_b            plt
 WHERE     1 = 1
       AND rct.po_header_id = ph.po_header_id
       AND rct.po_line_location_id = pll.line_location_id
       AND rct.po_line_id = pol.po_line_id
       AND pol.po_line_id = pd.po_line_id
       AND rct.shipment_line_id = rsl.shipment_line_id
       AND rsl.shipment_header_id = rsh.shipment_header_id
       AND rct.po_distribution_id = pd.po_distribution_id
       AND rct.employee_id = papf.person_id
       AND SYSDATE BETWEEN papf.effective_start_date
                       AND papf.effective_end_date
       AND rsh.vendor_id = aps.vendor_id
       AND ph.vendor_site_id = assa.vendor_site_id
       AND hou.organization_id = ph.org_id
       AND rct.deliver_to_location_id = hl.location_id
       AND rsl.shipment_line_status_code = flv_shipment.lookup_code
       AND flv_shipment.lookup_type = 'SHIPMENT LINE STATUS'
       AND flv_shipment.language = USERENV ('LANG')
       AND rct.inspection_status_code = flv_inspection.lookup_code
       AND flv_inspection.lookup_type = 'INSPECTION STATUS'
       AND flv_inspection.language = USERENV ('LANG')
       AND rct.transaction_type = flv_tran_type.lookup_code
       AND flv_tran_type.lookup_type = 'RCV TRANSACTION TYPE'
       AND flv_tran_type.language = USERENV ('LANG')
       AND flv_ship_source.lookup_type = 'SHIPMENT SOURCE TYPE'
       AND flv_ship_source.language = USERENV ('LANG')
       AND flv_ship_source.lookup_code = rsh.receipt_source_code
       AND order_type.lookup_type = 'ORDER TYPE'
       AND order_type.lookup_code = plt.order_type_lookup_code
       AND pol.line_type_id = plt.line_type_id;