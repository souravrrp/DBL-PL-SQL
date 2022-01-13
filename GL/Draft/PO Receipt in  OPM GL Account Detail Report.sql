/* Formatted on 2/27/2020 10:36:16 AM (QP5 v5.287) */
SELECT mmt.TRX_SOURCE_LINE_ID,
       xe.EVENT_ID,
       '60' AS INTERNAL_CODE,
       'OPM-INV' AS internal_module,
       GJH.JE_HEADER_ID,
       TRUNC (mmt.TRANSACTION_DATE) AS DOC_DATE,
       gcc.segment1 AS segment1,
       gcc.segment4 AS segment4,
       aps.vendor_name AS party_name,
       NULL user_name,
       NULL approver_name,
       gcc.code_combination_id,
       aps.vendor_name,
       pha.segment1 po_number,
       gjl.je_line_num AS gl_line_no,
       al.description AS particulars,
       NULL AS doc_no,
       gjh.period_name AS gl_period_name,
       gjh.je_source || ' ' || gjc.user_je_category_name AS gl_source,
       gjh.doc_sequence_value AS gl_doc_no,
       gjh.je_category,
       gjh.status AS gl_jv_status,
       gjh.ledger_id set_of_books_id,
       gjh.default_effective_date AS gl_date,
       gjh.ledger_id,
       gjh.period_name AS gjl_period_name,
          gjc.user_je_category_name
       || '--'
       || gbh.batch_no
       || '--'
       || msi.description
          description,
       NVL (gjl.accounted_dr, 0) AS gl_acc_dr,
       NVL (gjl.accounted_cr, 0) AS gl_acc_cr,
       mmt.transaction_id AS doc_id,
       NVL (al.accounted_dr, 0) AS xla_acc_dr,
       NVL (al.accounted_cr, 0) AS xla_acc_cr,
       -- FND_FLEX_EXT.GET_SEGS('SQLGL', 'GL#',gcc.chart_of_accounts_id,gcc.code_combination_id) SEGMENTS,
       -- GL_FLEXFIELDS_PKG.get_concat_description( gcc.chart_of_accounts_id, gcc.code_combination_id) GCC_NAME,
       gbh.batch_no checkbook_id,
       mtt.TRANSACTION_TYPE_NAME,
       msi.description item_description
  FROM gl_code_combinations gcc,
       gl_je_headers gjh,
       gl_je_lines gjl,
       gl_je_batches gjb,
       gl_je_categories gjc,
       gl_import_references gir,
       gme_batch_header gbh,
       xla_ae_headers xah,
       xla_ae_lines al,
       xla_distribution_links dl,
       xla_events xe,
       --        xla_transaction_entities xte,
       gmf_xla_extract_headers geh,
       gmf_xla_extract_lines gel,
       mtl_system_items msi,
       mtl_material_transactions mmt,
       apps.mtl_transaction_types mtt,
       rcv_transactions rt,
       ap_suppliers aps,
       po_headers_all pha
 --        CM_ACST_LED CCD
 WHERE     gcc.code_combination_id = al.code_combination_id
       AND al.application_id = xe.application_id
       AND xah.event_id = xe.event_id
       --   AND xah.entity_id = xte.entity_id
       AND gjh.je_header_id = gir.je_header_id
       AND gir.je_header_id = gjl.je_header_id
       AND gjh.je_header_id = gjl.je_header_id
       AND gjb.GROUP_ID = xah.GROUP_ID
       AND UPPER (gjh.je_source) = 'INVENTORY'
       --   AND gjh.je_category IN ('RVAL', 'STEP')
       AND gjh.je_category IN ('RELE')
       AND geh.inventory_item_id = msi.inventory_item_id
       AND geh.organization_id = msi.organization_id
       AND gjh.je_category = gjc.je_category_key
       AND gir.je_line_num = gjl.je_line_num
       AND gbh.batch_id = geh.source_document_id
       AND gjb.JE_BATCH_ID = gjh.JE_BATCH_ID
       --AND gjh.JE_HEADER_ID = 743054
       --   AND GJH.JE_HEADER_ID = 1345430
       AND gjb.je_batch_id = gir.je_batch_id
       AND gir.gl_sl_link_id = al.gl_sl_link_id
       AND gir.gl_sl_link_table = al.gl_sl_link_table
       AND al.ae_header_id = xah.ae_header_id
       AND al.ae_header_id = dl.ae_header_id
       AND al.ae_line_num = dl.ae_line_num
       AND dl.event_id = geh.event_id
       AND dl.application_id = 555
       AND dl.source_distribution_type = geh.entity_code
       AND dl.source_distribution_id_num_1 = gel.line_id
       AND geh.header_id = gel.header_id
       AND geh.event_id = gel.event_id
       AND geh.TRANSACTION_ID = mmt.TRANSACTION_ID
       AND msi.ORGANIZATION_ID = mmt.ORGANIZATION_ID
       AND msi.inventory_item_id = mmt.inventory_item_id
       AND gbh.ORGANIZATION_ID = msi.ORGANIZATION_ID
       AND mmt.transaction_source_id = gbh.batch_id
       AND mmt.TRANSACTION_TYPE_ID = mtt.TRANSACTION_TYPE_ID
       --        and ccd.TRANSLINE_ID = mmt.TRX_SOURCE_LINE_ID-
       --        and mmt.ORGANIZATION_ID = ccd.ORGANIZATION_ID
       --        and mmt.INVENTORY_ITEM_ID = ccd.INVENTORY_ITEM_ID
       --       AND gjh.default_effective_date BETWEEN :mFDATE AND :mTODATE
       AND mmt.rcv_transaction_id = rt.transaction_id(+)
       --- AND rt.transaction_type(+) = 'DELIVER'
       AND rt.vendor_id = aps.vendor_id(+)
       AND rt.po_header_id = pha.po_header_id(+)
       AND gbh.batch_no = '12345'