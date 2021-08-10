/* Formatted on 11/14/2020 5:08:50 PM (QP5 v5.287) */
WITH GRN
     AS (  SELECT a.segment1,
                  a.po_header_id,
                  a.vendor_name,
                  a.approved_date,
                  a.receipt_num,
                  a.doc_sequence_value,
                  a.Natural_Account,
                  a.authorization_status,
                  a.currency_code,
                  a.OU,
                  a.lc_number,
                  a.bank_name,
                  a.bank_branch_name,
                  a.lc_opening_date,
                  a.ship_num,
                  a.ship_date,
                  a.name,
                  SUM (Estimated_Amount) AS Estimated_Amount,
                  SUM (Actual_Amount) AS Actual_Amount
             FROM (SELECT pha.segment1,
                          pha.po_header_id,
                          pv.vendor_name,
                          pha.approved_date,
                          pha.authorization_status,
                          pha.currency_code,
                          NULL receipt_num,
                          '128101' Natural_Account,
                          hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )'
                             OU,
                          lc.lc_number,
                          lc.bank_name,
                          lc.bank_branch_name,
                          lc.lc_opening_date,
                          pha.org_id,
                          ish.ship_num,
                          NULL doc_sequence_value,
                          ish.ship_date,
                          ppett.name,
                          (  (allocation_amt)
                           * NVL (icl.currency_conversion_rate, 1))
                             Estimated_Amount,
                          NULL Actual_Amount
                     FROM inl_ship_headers_all ish,
                          inl_ship_lines_all isl,
                          inl_allocations ia,
                          inl_charge_lines icl,
                          pon_price_element_types ppet,
                          pon_price_element_types_tl ppett,
                          po_line_locations_all pll,
                          po_lines_all pla,
                          po_headers_all pha,
                          mtl_system_items_b mis,
                          po_vendors pv,
                          hr_all_organization_units ou,
                          apps.org_organization_definitions ood,
                          XXDBL_COMPANY_LE_MAPPING_V hou,
                          xx_lc_details lc
                    WHERE     ish.ship_header_id = isl.ship_header_id(+)
                          AND isl.ship_header_id = ia.ship_header_id(+)
                          AND isl.ship_line_id = ia.ship_line_id(+)
                          AND ia.from_parent_table_name = 'INL_CHARGE_LINES'
                          AND lc_status = 'Y'
                          AND isl.match_id IS NULL
                          AND ia.from_parent_table_id = icl.charge_line_id(+)
                          AND icl.charge_line_type_id =
                                 ppet.price_element_type_id(+)
                          AND ppet.price_element_type_id =
                                 ppett.price_element_type_id(+)
                          AND pll.line_location_id = isl.ship_line_source_id(+)
                          AND IA.FROM_PARENT_TABLE_ID = ICL.CHARGE_LINE_ID
                          AND IA.ALLOCATION_ID = IA.PARENT_ALLOCATION_ID
                          AND ISL.SHIP_LINE_ID = IA.SHIP_LINE_ID
                          AND pha.segment1 = lc.po_number(+)
                          AND pll.po_line_id = pla.po_line_id
                          AND pla.po_header_id = pha.po_header_id
                          AND pla.item_id = mis.inventory_item_id
                          AND mis.organization_id = pll.ship_to_organization_id
                          AND pha.vendor_id = pv.vendor_id
                          AND pha.org_id = ou.organization_id
                          AND pll.ship_to_organization_id = ood.organization_id
                          AND pha.org_id = hou.org_id
                          --AND (pha.org_id = :p_org_id OR :p_org_id IS NULL)
                          --AND hou.legal_entity_id = :p_legal
                          --and (pha.po_header_id=:p_po_number or :p_po_number is null)
                          --AND (:p_lc_from_creation_date IS NULL OR TRUNC (lc.creation_date) BETWEEN :p_lc_from_creation_date AND :p_lc_to_creation_date)
                          AND (   lc.lc_number = :p_lc_number
                               OR :p_lc_number IS NULL)
                   UNION ALL
                   SELECT po.segment1,
                          po.po_header_id,
                          sup.vendor_name,
                          po.approved_date,
                          po.authorization_status,
                          po.currency_code,
                          rsh.receipt_num,
                          ffv.flex_value_meaning Natural_Account,
                          hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )'
                             OU,
                          lc.lc_number,
                          lc.bank_name,
                          lc.bank_branch_name,
                          lc.lc_opening_date,
                          po.org_id,
                          NULL ship_num,
                          TO_CHAR (ai.doc_sequence_value) || ' -L',
                          ai.gl_date ship_date,
                          ppetv.name,
                          NULL estimated_amount,
                          NVL (AD.BASE_AMOUNT, AD.AMOUNT) Actual_Amount
                     FROM xx_lc_details lc,
                          ap_invoices_all ai,
                          ap_suppliers sup,
                          AP_INVOICE_DISTRIBUTIONS_ALL AD,
                          apps.gl_code_combinations gcc,
                          apps.fnd_flex_values_vl ffv,
                          ap_invoice_lines_all AL,
                          XXDBL_COMPANY_LE_MAPPING_V hou,
                          pon_price_element_types_vl ppetv,
                          PO_HEADERS_All PO,
                          rcv_transactions rt,
                          rcv_shipment_headers rsh
                    WHERE     LC.PO_HEADER_ID = AL.PO_HEADER_ID
                          AND AI.INVOICE_ID = AL.INVOICE_ID
                          AND NVL (AL.discarded_flag, 'N') = 'N'
                          AND AL.invoice_id = AD.invoice_id
                          AND po.vendor_id = sup.vendor_id
                          AND ad.dist_code_combination_id =
                                 gcc.code_combination_id
                          AND gcc.segment5 = ffv.flex_value_meaning
                          AND AL.line_number = AD.invoice_line_number
                          AND NVL (AL.cost_factor_id, 12) =
                                 ppetv.price_element_type_id(+)
                          AND LC.po_header_id = PO.po_header_id
                          AND rt.PO_HEADER_ID = al.PO_HEADER_ID
                          AND po.org_id = hou.org_id
                          AND rt.SHIPMENT_HEADER_ID = rsh.SHIPMENT_HEADER_ID
                          AND rt.transaction_id = ad.rcv_transaction_id
                          AND rt.transaction_type = 'LC'
                          AND ai.invoice_type_lookup_code <> 'PREPAYMENT'
                          AND ai.cancelled_date IS NULL
                          AND lc_status = 'Y'
                          AND al.line_type_lookup_code <> 'ITEM'
                          AND ppetv.name <> 'Document Endorsement'
                          --          and lc_number='DC DAK781891'
                          --          and po.org_id=:p_org_id
                          --AND (po.org_id = :p_org_id OR :p_org_id IS NULL)
                          --AND hou.legal_entity_id = :p_legal
                          --AND (   :p_lc_from_creation_date IS NULL OR TRUNC (lc.creation_date) BETWEEN :p_lc_from_creation_date AND :p_lc_to_creation_date)
                          AND (   lc.lc_number = :p_lc_number
                               OR :p_lc_number IS NULL)
                   UNION ALL
                     SELECT po.segment1,
                            po.po_header_id,
                            sup.vendor_name,
                            po.approved_date,
                            po.authorization_status,
                            po.currency_code,
                            rsh.receipt_num,
                            ffv.flex_value_meaning Natural_Account,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )'
                               OU,
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            po.org_id,
                            NULL ship_num,
                            TO_CHAR (ai.doc_sequence_value) || ' -G',
                            ai.gl_date ship_date,
                            'Document Value' name,
                            SUM (NVL (AD.BASE_AMOUNT, AD.AMOUNT))
                               Estimated_Amount,
                            SUM (NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
                       FROM xx_lc_details LC,
                            ap_invoices_all AI,
                            ap_suppliers sup,
                            ap_invoice_distributions_all ad,
                            ap_invoice_lines_all AL,
                            gl_code_combinations gcc,
                            fnd_flex_values_vl ffv,
                            XXDBL_COMPANY_LE_MAPPING_V hou,
                            PO_HEADERS_All PO,
                            rcv_transactions rt,
                            rcv_shipment_headers rsh
                      WHERE     LC.PO_HEADER_ID = AL.PO_HEADER_ID
                            AND AI.INVOICE_ID = AL.INVOICE_ID
                            AND NVL (AL.discarded_flag, 'N') = 'N'
                            AND AL.invoice_id = AD.invoice_id
                            AND po.vendor_id = sup.vendor_id
                            AND AL.line_number = AD.invoice_line_number
                            AND LC.po_header_id = PO.po_header_id
                            AND rt.PO_HEADER_ID = al.PO_HEADER_ID
                            AND po.org_id = hou.org_id
                            AND rt.SHIPMENT_HEADER_ID = rsh.SHIPMENT_HEADER_ID
                            AND ad.dist_code_combination_id =
                                   gcc.code_combination_id
                            AND gcc.segment5 = ffv.flex_value_meaning
                            AND ffv.flex_value_set_id = 1017040
                            AND rt.transaction_id = ad.rcv_transaction_id
                            AND rt.transaction_type = 'LC'
                            AND ad.line_type_lookup_code = 'ACCRUAL'
                            AND ai.invoice_type_lookup_code <> 'PREPAYMENT'
                            AND ai.cancelled_date IS NULL
                            AND al.line_type_lookup_code = 'ITEM'
                            AND lc_status = 'Y'
                            --          and lc_number='DC DAK779881'
                            --         and po.org_id=:p_org_id
                            --AND (po.org_id = :p_org_id OR :p_org_id IS NULL)
                            --AND hou.legal_entity_id = :p_legal
                            --AND (   :p_lc_from_creation_date IS NULL OR TRUNC (lc.creation_date) BETWEEN :p_lc_from_creation_date AND :p_lc_to_creation_date)
                            AND (   lc.lc_number = :p_lc_number
                                 OR :p_lc_number IS NULL)
                   GROUP BY po.segment1,
                            po.po_header_id,
                            po.approved_date,
                            po.authorization_status,
                            ai.doc_sequence_value,
                            sup.vendor_name,
                            po.currency_code,
                            rsh.receipt_num,
                            ffv.flex_value_meaning,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )',
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            po.org_id,
                            gl_date
                   UNION ALL
                     SELECT po.segment1,
                            po.po_header_id,
                            sup.vendor_name,
                            po.approved_date,
                            po.authorization_status,
                            po.currency_code,
                            NULL receipt_num,
                            ffv.flex_value_meaning Natural_Account,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )'
                               OU,
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            po.org_id,
                            NULL ship_num,
                            TO_CHAR (ai.doc_sequence_value) || ' -D',
                            ai.gl_date ship_date,
                            ad.attribute2 name,
                            NULL Estimated_Amount,
                            SUM (NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
                       FROM xx_lc_details LC,
                            ap_invoices_all AI,
                            ap_suppliers sup,
                            ap_invoice_distributions_all AD,
                            gl_code_combinations gcc,
                            fnd_flex_values_vl ffv,
                            ap_invoice_lines_all AL,
                            XXDBL_COMPANY_LE_MAPPING_V hou,
                            PO_HEADERS_All PO
                      --   rcv_transactions rt,
                      --   rcv_shipment_headers rsh
                      WHERE     lc.lc_id = TO_NUMBER (ad.attribute1)
                            AND ai.invoice_id = al.invoice_id
                            AND NVL (al.discarded_flag, 'N') = 'N'
                            AND al.invoice_id = ad.invoice_id
                            AND po.vendor_id = sup.vendor_id
                            AND al.line_number = ad.invoice_line_number
                            AND ad.dist_code_combination_id =
                                   gcc.code_combination_id
                            AND gcc.segment5 = ffv.flex_value_meaning
                            AND ffv.flex_value_set_id = 1017040
                            AND lc.po_header_id = po.po_header_id
                            AND po.org_id = hou.org_id
                            AND ai.cancelled_date IS NULL
                            AND al.line_type_lookup_code = 'ITEM'
                            AND lc_status = 'Y'
                            AND ad.attribute_category = 'LC Details Information'
                            AND ad.po_distribution_id IS NULL
                            AND al.po_header_id IS NULL
                            AND ad.attribute1 IS NOT NULL
                            AND ai.invoice_type_lookup_code <> 'PREPAYMENT'
                            --   and lc_number='147817020366'
                            --   and po.org_id=:p_org_id
                            --AND (po.org_id = :p_org_id OR :p_org_id IS NULL)
                            --AND hou.legal_entity_id = :p_legal
                            AND (   lc.lc_number = :p_lc_number
                                 OR :p_lc_number IS NULL)
                   --AND (   :p_lc_from_creation_date IS NULL OR TRUNC (lc.creation_date) BETWEEN :p_lc_from_creation_date AND :p_lc_to_creation_date)
                   GROUP BY po.segment1,
                            po.po_header_id,
                            po.approved_date,
                            po.authorization_status,
                            ai.doc_sequence_value,
                            sup.vendor_name,
                            po.currency_code,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )',
                            ffv.flex_value_meaning,
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            po.org_id,
                            gl_date,
                            ad.attribute2
                   UNION ALL
                     SELECT lc.po_number,
                            lc.po_header_id,
                            lc.supplier_name,
                            lc.lc_opening_date approved_date,
                            'APPROVED' authorization_status,
                            UPPER (lc.currency_code) currency_code,
                            NULL receipt_num,
                            ffv.flex_value_meaning Natural_Account,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )'
                               OU,
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            lc.org_id,
                            NULL ship_num,
                            TO_CHAR (ai.doc_sequence_value) || ' -D',
                            ai.gl_date ship_date,
                            ad.attribute2 name,
                            NULL Estimated_Amount,
                            SUM (NVL (AD.BASE_AMOUNT, AD.AMOUNT)) Actual_Amount
                       FROM xx_lc_details LC,
                            ap_invoices_all AI,
                            ap_suppliers sup,
                            gl_code_combinations gcc,
                            fnd_flex_values_vl ffv,
                            ap_invoice_distributions_all AD,
                            ap_invoice_lines_all AL,
                            XXDBL_COMPANY_LE_MAPPING_V hou
                      --  PO_HEADERS_All PO
                      --   rcv_transactions rt,
                      --   rcv_shipment_headers rsh
                      WHERE     lc.lc_id = TO_NUMBER (ad.attribute1)
                            AND ai.invoice_id = al.invoice_id
                            AND NVL (al.discarded_flag, 'N') = 'N'
                            AND al.invoice_id = ad.invoice_id
                            AND ai.vendor_id = sup.vendor_id
                            AND al.line_number = ad.invoice_line_number
                            AND ad.dist_code_combination_id =
                                   gcc.code_combination_id
                            AND gcc.segment5 = ffv.flex_value_meaning
                            AND ffv.flex_value_set_id = 1017040
                            AND ai.invoice_type_lookup_code <> 'PREPAYMENT'
                            --   and lc.po_header_id = po.po_header_id
                            AND ai.org_id = hou.org_id
                            AND ai.cancelled_date IS NULL
                            AND al.line_type_lookup_code = 'ITEM'
                            AND lc_status = 'Y'
                            AND ad.attribute_category = 'LC Details Information'
                            AND ad.po_distribution_id IS NULL
                            AND al.po_header_id IS NULL
                            AND ad.attribute1 IS NOT NULL
                            AND lc.po_number NOT IN (SELECT segment1
                                                       FROM po_headers_all)
                            --   and lc_number='147817020366'
                            --   and (po.org_id=:p_org_id or :p_org_id is null)
                            --   and (:p_lc_from_creation_date is null or  trunc(lc.creation_date) between :p_lc_from_creation_date and :p_lc_to_creation_date)
                            AND (   lc.lc_number = :p_lc_number
                                 OR :p_lc_number IS NULL)
                   GROUP BY lc.po_number,
                            lc.po_header_id,
                            -- po.approved_date,
                            -- po.authorization_status,
                            ai.doc_sequence_value,
                            lc.supplier_name,
                            lc.currency_code,
                            hou.LEGAL_ENTITY_NAME || ' ( ' || unit_name || ' )',
                            ffv.flex_value_meaning,
                            lc.lc_number,
                            lc.bank_name,
                            lc.bank_branch_name,
                            lc.lc_opening_date,
                            lc.org_id,
                            gl_date,
                            ad.attribute2) a
         GROUP BY a.segment1,
                  a.po_header_id,
                  a.vendor_name,
                  a.approved_date,
                  a.authorization_status,
                  a.currency_code,
                  a.receipt_num,
                  a.Natural_Account,
                  a.doc_sequence_value,
                  a.OU,
                  a.lc_number,
                  a.bank_name,
                  a.bank_branch_name,
                  a.lc_opening_date,
                  a.ship_num,
                  a.ship_date,
                  a.name
         ORDER BY a.name DESC, a.ship_num, a.ship_date ASC),
     PO
     AS (SELECT PHA.SEGMENT1,
                PHA.PO_HEADER_ID,
                PV.VENDOR_NAME,
                OOD.ORGANIZATION_ID,
                MIS.SEGMENT1 Item_Code,
                MIS.DESCRIPTION,
                PLA.UNIT_MEAS_LOOKUP_CODE,
                PDA.QUANTITY_ORDERED QUANTITY,
                PLA.UNIT_PRICE,
                PDA.QUANTITY_ORDERED * PLA.UNIT_PRICE TOTAL_PRICE,
                (PDA.QUANTITY_ORDERED * PLA.UNIT_PRICE) * NVL (PHA.RATE, 1)
                   FUNCTIONAL_AMOUNT
           FROM PO_HEADERS_ALL PHA,
                PO_LINES_ALL PLA,
                PO_LINE_LOCATIONS_ALL PLL,
                APPS.PO_DISTRIBUTIONS_ALL PDA,
                PO_VENDORS PV,
                MTL_SYSTEM_ITEMS_B MIS,
                HR_ALL_ORGANIZATION_UNITS OU,
                ORG_ORGANIZATION_DEFINITIONS OOD
          WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
                AND PLA.PO_HEADER_ID = PLL.PO_HEADER_ID
                AND PLA.ITEM_ID = MIS.INVENTORY_ITEM_ID
                AND MIS.ORGANIZATION_ID = PLL.SHIP_TO_ORGANIZATION_ID
                AND PHA.PO_HEADER_ID = PDA.PO_HEADER_ID
                AND PLA.PO_LINE_ID = PDA.PO_LINE_ID
                AND PLL.LINE_LOCATION_ID = PDA.LINE_LOCATION_ID
                AND PHA.VENDOR_ID = PV.VENDOR_ID
                AND PHA.ORG_ID = OU.ORGANIZATION_ID
                AND PLL.SHIP_TO_ORGANIZATION_ID = OOD.ORGANIZATION_ID
                AND PDA.QUANTITY_CANCELLED = 0
                AND NVL (PLA.CANCEL_FLAG, 'N') = 'N'
                AND NVL (PLL.CANCEL_FLAG, 'N') = 'N'
                --AND pha.segment1 = '25113004384'
                --and pha.po_header_id=nvl(:p_po_number, pha.po_header_id)
                --and pha.org_id=nvl(:p_org_id,pha.org_id)
                AND PLL.CANCEL_DATE IS NULL)
SELECT organization_id,
       ou,
       po.segment1 po_number,
       item_code,
       description,
       unit_meas_lookup_code,
       quantity,
       unit_price,
       total_price,
       po.vendor_name,
       approved_date,
       receipt_num,
       doc_sequence_value,
       natural_account,
       authorization_status,
       currency_code,
       lc_number,
       lc_opening_date,
       bank_name,
       bank_branch_name,
       ship_num,
       ship_date,
       name,
       functional_amount,
       estimated_amount,
       actual_amount
  FROM grn, po
 WHERE 1 = 1 AND grn.po_header_id = po.po_header_id(+);