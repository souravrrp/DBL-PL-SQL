/* Formatted on 2/6/2021 9:48:00 AM (QP5 v5.354) */
  SELECT prh.org_id,
         hou.name,
         --ou.ledger_name,
         --ou.legal_entity_name,
         msi.organization_id,
         prh.requisition_header_id       req_hdr_id,
         prh.segment1                    requisition_number,
         prh.description                 req_hdr_description,
         prh.type_lookup_code            req_type,
         prh.authorization_status        req_status,
         msi.inventory_item_id,
         msi.segment1                    item_code,
         prl.line_num                    pr_line_num,
         prl.item_description            req_line_desc,
         prl.unit_meas_lookup_code       uom,
         prl.quantity,
         prl.unit_price                  "Unit cost",
         mic.segment1                    line_of_business,
         mic.segment2                    item_micegory,
         mic.segment3                    item_type,
         mic.segment4                    micelog,
         mic.segment1 || '.' || mic.segment2 || '.' || mic.segment3 || '.' || mic.segment4                 item_micegory,
         hou.name                       organization,
         hla.location_code               location,
         prl.destination_subinventory    department,
         prl.currency_code               currency,
         prh.creation_date               req_creation_date,
         prh.approved_date               req_approved_date,
         ppf.employee_number             requestor_id,
         ppf.employee_name               requestor_name,
         prl.suggested_buyer_id,
         prh.preparer_id,
         prh.created_by
    FROM apps.po_requisition_headers_all  prh,
         apps.po_requisition_lines_all    prl,
         apps.mtl_system_items_b          msi,
         apps.mtl_categories_v            mic,
         apps.hr_locations_all            hla,
         apps.hr_operating_units          hou,
         org_organization_definitions     ood,
         xxdbl_company_le_mapping_v       ou,
         apps.xx_employee_info_v          ppf
   WHERE     1 = 1
         AND prl.requisition_header_id = prh.requisition_header_id(+)
         AND prh.org_id = hou.organization_id(+)
         AND ood.operating_unit = ou.org_id(+)
         AND hou.organization_id = ood.operating_unit(+)
         AND prl.destination_organization_id = ood.organization_id(+)
         AND prl.deliver_to_location_id = hla.location_id(+)
         AND prl.item_id = msi.inventory_item_id(+)
         AND prl.destination_organization_id = msi.organization_id(+)
         AND prl.category_id = mic.category_id(+)
         AND NVL (prh.preparer_id, prl.to_person_id) = ppf.person_id(+)
         --AND prh.authorization_status not in ('RETURNED', 'APPROVED')
         --AND NVL (prh2.cancel_flag, 'N') <> 'Y'
         --AND NVL (prl2.cancel_flag, 'N') <> 'Y'
         --AND TRUNC (sysdate) BETWEEN ppf2.effective_start_date(+) AND ppf2.effective_end_date(+)
         AND (( :p_org_id IS NULL) OR (prh.org_id = :p_org_id))
         AND ( :p_req_no IS NULL OR (prh.segment1 = :p_req_no))
         AND (( :p_emp_id IS NULL) OR (ppf.employee_number = :p_emp_id))
         AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
         AND (   :p_item_desc IS NULL OR (UPPER (msi.description) LIKE UPPER ('%' || :p_item_desc || '%')))
ORDER BY prh.segment1, prl.line_num;