SELECT xph.proforma_number, xph.proforma_date, xph.proforma_header_id, xph.manual_pi_no,
       NVL ((SELECT SUM (xpl.VALUE)
               FROM xxdbl_proforma_lines xpl
              WHERE xpl.proforma_header_id = xph.proforma_header_id),
            0
           ) total_value
  FROM xxdbl_proforma_headers xph
 WHERE customer_id = :xxdbl_master_lc_headers.customer_id
   AND proforma_status = 'CONFIRMED'
   AND NOT EXISTS (
          SELECT 'X'
            FROM xxdbl_master_lc_headers xmlh, xxdbl_master_lc_line1 xmll1
           WHERE 1 = 1
             AND xmlh.master_lc_header_id = xmll1.master_lc_header_id
             AND xmlh.master_lc_status != 'CANCELLED'
             AND xmll1.pi_id = xph.proforma_header_id
                                                     /*AND xmlh.amd_no =
                                                            (SELECT MAX (NVL (xmlh1.amd_no, 0))
                                                               FROM xxdbl_master_lc_headers xmlh1
                                                              WHERE xmlh.internal_doc_number =
                                                                                             xmlh1.internal_doc_number)*/
       )
       
       
       ------------------------------------------------------------------------
       
       SELECT xph.proforma_number, xph.proforma_date, xph.proforma_header_id,
       NVL ((SELECT SUM (xpl.VALUE)
               FROM xxdbl_proforma_lines xpl
              WHERE xpl.proforma_header_id = xph.proforma_header_id),
            0
           ) total_value
  FROM xxdbl_proforma_headers xph
 WHERE customer_id = :xxdbl_master_lc_headers.customer_id
   AND proforma_status = 'CONFIRMED'
   AND NOT EXISTS (
          SELECT 'X'
            FROM xxdbl_master_lc_headers xmlh, xxdbl_master_lc_line1 xmll1
           WHERE 1 = 1
             AND xmlh.master_lc_header_id = xmll1.master_lc_header_id
             AND xmlh.master_lc_status != 'CANCELLED'
             AND xmll1.pi_id = xph.proforma_header_id
                                                     /*AND xmlh.amd_no =
                                                            (SELECT MAX (NVL (xmlh1.amd_no, 0))
                                                               FROM xxdbl_master_lc_headers xmlh1
                                                              WHERE xmlh.internal_doc_number =
                                                                                             xmlh1.internal_doc_number)*/
       )