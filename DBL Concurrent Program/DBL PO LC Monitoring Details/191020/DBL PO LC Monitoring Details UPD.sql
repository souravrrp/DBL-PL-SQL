/* Formatted on 10/19/2020 3:15:28 PM (QP5 v5.354) */
  --------------------------OPM Receving---------------------------------------

  SELECT org.organization_name,
         aps.segment1                    supplier_code,
         aps.vendor_name                 supplier_name,
         --POH.PO_HEADER_ID,
         poh.segment1                    po_number,
         (SELECT lc_number
            FROM xxdbl.xx_lc_details
           WHERE     po_header_id = poh.po_header_id
                 AND ledger_id = xal.ledger_id
                 AND lc_status = 'Y')    lc_number,
         poh.currency_code,
         rcvh.receipt_num                goods_receipt_num,
         -- MST.INVENTORY_ITEM_ID,
         mst.concatenated_segments       concat_item_code,
         mst.description                 inventory_item_name,
         rcvt.uom_code,
         mcb.segment2                    item_category,
         mcb.segment3                    item_type,
         cc.concatenated_segments,
         flex.description                acctdesc,
         gxeh.event_type_code,
         rcvt.primary_quantity,
         SUM (xal.accounted_dr)          accounted_dr,
         SUM (xal.accounted_cr)          accounted_cr
    FROM ap_suppliers                aps,
         rcv_shipment_headers        rcvh,
         rcv_transactions            rcvt,
         po_headers_all              poh,
         po_lines_all                pll,
         gmf_xla_extract_headers     gxeh,
         xla_ae_lines                xal,
         xla_ae_headers              xah,
         fnd_doc_sequence_categories cat,
         gl_code_combinations_kfv    cc,
         fnd_flex_values_vl          flex,
         mtl_system_items_b_kfv      mst,
         org_organization_definitions org,
         mtl_item_categories         mic,
         mtl_categories_b            mcb
   WHERE     aps.vendor_id(+) = rcvh.vendor_id
         AND rcvh.shipment_header_id(+) = rcvt.shipment_header_id
         AND gxeh.source_line_id = rcvt.transaction_id(+)
         AND gxeh.organization_id = rcvt.organization_id(+)
         AND poh.po_header_id = pll.po_header_id
         AND rcvt.po_header_id = pll.po_header_id
         AND rcvt.po_line_id = pll.po_line_id
         AND xah.event_id = gxeh.event_id
         AND xah.ledger_id = gxeh.ledger_id
         AND xal.ae_header_id = xah.ae_header_id
         AND xal.code_combination_id = cc.code_combination_id
         AND xah.je_category_name = cat.code
         AND mic.category_set_id = 1
         AND cat.application_id = 101
         AND cc.segment5 = flex.flex_value_meaning
         AND gxeh.organization_id = mst.organization_id
         AND gxeh.inventory_item_id = mst.inventory_item_id
         AND gxeh.organization_id = org.organization_id
         AND mic.inventory_item_id = mst.inventory_item_id
         AND mic.organization_id = mst.organization_id
         AND mcb.structure_id = 101
         AND mcb.category_id = mic.category_id
         AND org.organization_id = :p_organization_id
         AND gxeh.transaction_date BETWEEN :p_date_from AND :p_date_to
         AND gxeh.entity_code = 'PURCHASING'
GROUP BY xah.ledger_id,
         cc.concatenated_segments,
         flex.description,
         gxeh.event_type_code,
         aps.segment1,
         aps.vendor_name,
         rcvh.receipt_num,
         poh.po_header_id,
         poh.segment1,
         poh.currency_code,
         rcvt.primary_quantity,
         org.organization_name,
         mst.inventory_item_id,
         mst.concatenated_segments,
         mst.description,
         rcvt.uom_code,
         mcb.segment2,
         mcb.segment3,
         xal.ledger_id
UNION ALL ------------------------Discrete---------------------------------------
  SELECT org.organization_name,
         aps.segment1                    supplier_code,
         aps.vendor_name                 supplier_name,
         poh.segment1                    po_number,
         (SELECT lc_number
            FROM xxdbl.xx_lc_details
           WHERE     po_header_id = poh.po_header_id
                 AND ledger_id = xal.ledger_id
                 AND lc_status = 'Y')    lc_number,
         poh.currency_code,
         rcvh.receipt_num                goods_receipt_num,
         msi.concatenated_segments       concat_item_code,
         msi.description                 inventory_item_name,
         msi.primary_uom_code,
         mic.segment2                    item_category,
         mic.segment3                    item_type,
         gcc.concatenated_segments,
         flex.description                acctdesc,
         xal.accounting_class_code,
         mmt.primary_quantity,
         SUM (xal.accounted_dr)          accounted_dr,
         SUM (xal.accounted_cr)          accounted_cr
    FROM xla_distribution_links      xdl,
         mtl_transaction_accounts    xta,
         mtl_material_transactions   mmt,
         po_headers_all              poh,
         po_lines_all                pol,
         rcv_shipment_headers        rcvh,
         rcv_transactions            rcvt,
         ap_suppliers                aps,
         xla_ae_lines                xal,
         gl_import_references        gir,
         gl_je_lines                 gjl,
         gl_je_headers               gjh,
         gl_je_batches               gjb,
         gl_code_combinations_kfv    gcc,
         fnd_flex_values_vl          flex,
         mtl_system_items_b_kfv      msi,
         mtl_item_categories_v       mic,
         org_organization_definitions org,
         gl_ledgers                  gl
   WHERE     1 = 1
         AND mmt.transaction_id = xta.transaction_id
         AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
         AND xdl.source_distribution_id_num_1 = xta.inv_sub_ledger_id
         AND xal.ae_header_id = xdl.ae_header_id
         AND xal.ae_line_num = xdl.ae_line_num
         AND gir.gl_sl_link_id = xal.gl_sl_link_id
         AND gir.je_header_id = gjl.je_header_id
         AND gir.je_line_num = gjl.je_line_num
         AND gjl.code_combination_id = gcc.code_combination_id
         AND gir.je_header_id = gjh.je_header_id
         AND gjh.ledger_id = gl.ledger_id
         AND ledger_category_code = 'PRIMARY'
         AND org.organization_id = :p_organization_id
         AND mmt.transaction_date BETWEEN :p_date_from AND :p_date_to
         AND gjh.je_batch_id = gjb.je_batch_id
         AND gjh.status = 'P'
         AND mic.category_set_id = 1
         AND poh.po_header_id = mmt.transaction_source_id
         AND aps.vendor_id = rcvh.vendor_id
         AND pol.po_line_id = rcvt.po_line_id
         AND poh.po_header_id = pol.po_header_id
         AND rcvt.po_header_id = pol.po_header_id
         AND rcvh.shipment_header_id = rcvt.shipment_header_id
         AND mmt.inventory_item_id = pol.item_id
         AND rcvt.transaction_id = mmt.rcv_transaction_id
         AND mmt.inventory_item_id = msi.inventory_item_id
         AND mmt.organization_id = msi.organization_id
         AND mic.inventory_item_id = msi.inventory_item_id
         AND mic.organization_id = msi.organization_id
         AND mmt.organization_id = org.organization_id
         AND gcc.segment5 = flex.flex_value_meaning
GROUP BY xal.ledger_id,
         org.organization_name,
         aps.segment1,
         aps.vendor_name,
         poh.segment1,
         poh.po_header_id,
         poh.currency_code,
         rcvh.receipt_num,
         msi.concatenated_segments,
         msi.description,
         msi.primary_uom_code,
         mic.segment2,
         mic.segment3,
         gcc.concatenated_segments,
         flex.description,
         xal.accounting_class_code,
         mmt.primary_quantity;