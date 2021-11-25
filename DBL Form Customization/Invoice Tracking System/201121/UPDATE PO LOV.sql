/* Formatted on 11/20/2021 2:57:25 PM (QP5 v5.365) */
  SELECT ph.segment1                                              AS po_number,
         aps.vendor_name,
         aps.vendor_id,
         papf.full_name                                           AS buyer_name,
         SUM (NVL (pll.unit_price, 0) * NVL (pll.quantity, 0))    invoice_amount
    FROM po.po_headers_all ph,
         po.po_lines_all  pll,
         ap.ap_suppliers  aps,
         apps.per_people_f papf
   WHERE     ph.po_header_id = pll.po_header_id
         AND aps.vendor_id = ph.vendor_id
         AND papf.person_id = ph.agent_id
         AND SYSDATE BETWEEN papf.effective_start_date
                         AND papf.effective_end_date
         AND (   :xxdbl_invoice_tracking_system.operating_unit_id IS NULL
              OR ph.org_id = :xxdbl_invoice_tracking_system.operating_unit_id)
GROUP BY ph.segment1,
         aps.vendor_name,
         aps.vendor_id,
         papf.full_name
ORDER BY ph.segment1