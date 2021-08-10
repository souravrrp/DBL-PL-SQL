SELECT segment1 pr_no,
         hou.name unit,
         prl.suggested_buyer_id buyer_id,
         pf.email_address
    FROM po_requisition_headers_all prh,
         po_requisition_lines_all prl,
         per_people_f pf,
         hr_operating_units hou
   WHERE     prh.requisition_header_id = prl.requisition_header_id
         AND prl.suggested_buyer_id = pf.person_id
         AND prh.org_id = hou.organization_id
         AND SYSDATE BETWEEN pf.effective_start_date AND pf.effective_end_date
         AND prh.authorization_status = 'APPROVED'
         AND TRUNC (prh.approved_date) BETWEEN '21-JUN-20' AND '21-JUN-20'
--AND segment1 = '20111004912'
--AND pf.email_address is null
GROUP BY segment1,
         pf.employee_number,
         pf.first_name || ' ' || pf.middle_names || ' ' || pf.last_name,
         prl.suggested_buyer_id,
         pf.email_address,
         hou.name
ORDER BY buyer_id