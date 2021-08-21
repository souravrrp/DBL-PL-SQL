/* Formatted on 8/21/2021 9:48:09 AM (QP5 v5.354) */
  SELECT pha.org_id,
         apps.xx_com_pkg.get_hr_operating_unit (pha.org_id)
             unit_name,
         pha.segment1
             po_num,
         pha.revision_num,
         pla.line_num
             po_line_num,
         pla.item_description,
         pla.unit_meas_lookup_code
             uom,
         pla.list_price_per_unit,
         pla.quantity
             po_line_quantity,
         NULL
             updated_by,
         MAX (pah.creation_date)
             creation_date,
         NULL
             modified_date,
         'ExistingPO'
             remarks
    FROM po.po_line_locations_archive_all plla,
         po.po_lines_archive_all         pla,
         po.po_headers_archive_all       pha,
         apps.po_vendors                 pv,
         apps.ap_supplier_sites_all      apss,
         po.po_action_history            pah,
         apps.fnd_user                   fu,
         hr.per_all_people_f             papf,
         hr.per_all_assignments_f        paaf,
         hr.per_jobs                     pj
   WHERE     1 = 1
         AND pah.object_id = pha.po_header_id
         AND pah.object_type_code = 'PO'
         AND pah.action_code = 'SUBMIT'
         AND pah.employee_id = fu.employee_id
         AND pla.revision_num = pah.object_revision_num
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND papf.effective_end_date >= SYSDATE
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND paaf.effective_end_date >= SYSDATE
         AND EXISTS
                 (SELECT 1
                    FROM po.po_lines_archive_all pla2
                   WHERE     pla.po_line_id = pla2.po_line_id
                         AND pla.line_num = pla2.line_num
                         AND pla.revision_num < pla2.revision_num)
         AND pla.cancel_flag = 'N'
         AND pla.po_line_id = plla.po_line_id
         AND pha.vendor_id = pv.vendor_id
         AND pha.vendor_site_id = apss.vendor_site_id
         AND pla.po_header_id = plla.po_header_id
         AND pha.po_header_id = pla.po_header_id
         AND pha.vendor_id = '2550'
         --and pha.vendor_site_id = '9873'
         --AND pha.segment1 IN ('10233000799')
         AND pha.revision_num = pla.revision_num
         AND pla.revision_num = plla.revision_num
         AND pha.revision_num = plla.revision_num
         AND TO_CHAR (pha.creation_date, 'MON-RRRR') = 'AUG-2021'
GROUP BY pha.org_id,
         pha.segment1,
         pha.revision_num,
         pla.line_num,
         pla.item_description,
         pla.unit_meas_lookup_code,
         pla.list_price_per_unit,
         pla.quantity