/* Formatted on 1/19/2020 9:42:13 AM (QP5 v5.287) */
  select prh.org_id,
         hou.name "Operating unit",
         prh.requisition_header_id req_hdr_id,
         prh.segment1 "Requisition Number",
         to_char (prh.creation_date, 'DD-MON-RRRR HH12:MI:SS PM')
            req_creation_date,
         prh.authorization_status  req_status,
         to_char (prh.approved_date, 'DD-MON-RRRR HH12:MI:SS PM')
            req_approved_date,
         prl.need_by_date req_need_by_date,
         pha.segment1 "PO Number",
         to_char (pha.creation_date, 'DD-MON-RRRR HH12:MI:SS PM')
            po_creation_date,
         pha.authorization_status po_status,
         to_char (pha.approved_date, 'DD-MON-RRRR HH12:MI:SS PM')
            po_approved_date,
         prl.line_num req_line_num,
         msi.segment1 item_code,
         nvl (msi.description, prl.item_description) item_description,
         prl.unit_meas_lookup_code uom,
         prl.quantity req_qty,
         pla.quantity po_qty,
         prl.item_id,
         (select pf.first_name || ' ' || pf.middle_names || ' ' || pf.last_name
            from per_people_f pf where     prl.suggested_buyer_id = pf.person_id and sysdate between pf.effective_start_date and pf.effective_end_date)
         buyer,
         prl.suggested_buyer_id,
         --proj.proj_name,
         prh.attribute8 purpose,
         prl.attribute1 brand,
         prl.attribute2 orgin,
         prl.attribute3 make,
         prl.attribute6 order_no,
         prl.attribute7 use_of_area,
         nvl (sub.description, secondary_inventory_name) subinv,
         ltrim (
            rtrim (
                  ppf.first_name
               || ' '
               || ppf.middle_names
               || ' '
               || ppf.last_name))
            global_name,
         prl.destination_subinventory subinventory,
         nvl (hrl.description, hrl.location_code) location,
         prl.attribute6 remarks,
         decode (prl.attribute_category,
                 'Item Details', prl.attribute4,
                 prl.attribute4)
            buyer_id,
         pda.req_distribution_id
    from po_requisition_headers_all prh,
         po_requisition_lines_all prl,
         apps.po_req_distributions_all prod,
         mtl_system_items_b msi,
         --all_proj_info_master proj,
         hr_locations_all hrl,
         fnd_user fu,
         per_people_f ppf,
         apps.po_distributions_all pda,
         apps.po_lines_all pla,
         apps.po_line_locations_all pll,
         apps.po_headers_all pha,
         hr_operating_units hou,
         org_organization_definitions ood,
         mtl_secondary_inventories sub
   where 1 = 1
         and prh.requisition_header_id = prl.requisition_header_id
         and prl.item_id = msi.inventory_item_id(+)
         and prl.destination_organization_id = msi.organization_id(+)
         --AND prh.attribute4 = proj.proj_id(+)
         and prl.deliver_to_location_id = hrl.location_id
         and prh.created_by = fu.user_id(+)
         and prl.requisition_line_id = prod.requisition_line_id
         and prod.distribution_id = pda.req_distribution_id(+)
         and pda.po_line_id = pla.po_line_id(+)
         and pda.line_location_id = pll.line_location_id(+)
         and pll.po_line_id = pla.po_line_id(+)
         and pll.po_header_id = pha.po_header_id(+)
         and pda.po_header_id = pha.po_header_id(+)
         and pll.po_line_id = pla.po_line_id(+)
         and fu.employee_id = ppf.person_id(+)
         and prl.destination_subinventory = sub.secondary_inventory_name(+) ---DESTINATION_SUBINVENTORY
         and prl.destination_organization_id = sub.organization_id(+)
         and sysdate between ppf.effective_start_date and ppf.effective_end_date
         and prh.org_id = hou.organization_id
         and msi.organization_id = ood.organization_id
         and prl.cancel_date is null
         and ( ( :p_org_id is null) or (prh.org_id = :p_org_id))
         and ( :p_req_no is null or (prh.segment1 = :p_req_no))
         and ((:p_emp_id is null ) or (ppf.employee_number=:p_emp_id))
         and ( :p_item_code is null or (msi.segment1 = :p_item_code))
         and (   :p_item_desc is null or (upper (msi.description) like upper ('%' || :p_item_desc || '%')))
         and prl.destination_organization_id = nvl ( :p_dest_org_id, prl.destination_organization_id)
         and prh.authorization_status = nvl ( :p_authorization_status, prh.authorization_status)
         and (   :p_from_creation_date is null or trunc (prh.creation_date) between :p_from_creation_date and :p_to_creation_date)
order by prl.line_num