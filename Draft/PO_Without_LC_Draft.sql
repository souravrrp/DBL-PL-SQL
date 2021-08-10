/* Formatted on 2/3/2020 3:04:44 PM (QP5 v5.287) */
  SELECT 
         led.UNIT_NAME OU_Name,
         led.legal_entity_id,
         led.legal_entity_name,
         MSI.DESCRIPTION  as "Type",
         sup.vendor_name  AS "Party_Name",
         pla.unit_price as PI_Rate,
         NULL LC_Quntity,
         NULL LC_VALUE,
         NULL Value_Actual,
         null LC_NUMBER,
         NULL LC_OPENING_DATE,
         pha.segment1 "PO_NUMBER",
         rsh.receipt_num SHIP_NUM,
         rt.transaction_date SHIP_DATE,
         ROUND (SYSDATE - rsh.CREATION_DATE) AGING_DAY,
         RT.ORGANIZATION_ID,
         MSI.SEGMENT1 INV_ITEM,
         NULL COMPONENT_NAME,
         rt.quantity PRIMARY_QTY,
         rt.uom_code UNIT_OF_MEASURE,
         (pla.unit_price*pla.quantity) PO_AMOUNT,
         NULL ACTUAL_AMT,
         NULL ESTIMATED_AMT,
         NULL EXCESS_ESTIMATION_AMT,
         NULL EXCESS_ESTIMATION_PER
    FROM po_headers_all pha,
         po_lines_all pla,
         apps.xxdbl_company_le_mapping_v led,
         apps.org_organization_definitions odd,
         apps.hr_operating_units hou,
         po_distributions_all pda,
         po_requisition_headers_all prha,
         po_requisition_lines_all prla,
         po_req_distributions_all prda,
         apps.po_line_locations_all pll,
         apps.po_line_types_b plt,
         rcv_transactions rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers rsh,
         apps.mtl_item_categories_v cat,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sups,
         apps.mtl_txn_request_lines mtrl,
         apps.mtl_txn_request_headers mtrh,
         apps.mtl_system_items_b msi
   WHERE     1 = 1
         AND prla.requisition_header_id = prha.requisition_header_id(+)
         AND prda.requisition_line_id = prla.requisition_line_id(+)
         AND pda.req_distribution_id = prda.distribution_id(+)
         AND pla.po_line_id = pda.po_line_id(+)
         AND pha.org_id = led.org_id
         AND pda.destination_organization_id = odd.organization_id
         AND pha.org_id = hou.organization_id
         AND pha.po_header_id = pla.po_header_id(+)
         AND pha.po_header_id = pll.po_header_id(+)
         AND pla.po_line_id = pll.po_line_id(+)
         AND pda.line_location_id = pll.line_location_id(+)
         AND pla.line_type_id = plt.line_type_id(+)
         --AND pda.po_distribution_id = rt.po_distribution_id(+)
         AND pha.po_header_id = RT.po_header_id(+)
         AND pla.po_line_id = RT.po_line_id(+)
         AND pha.type_lookup_code = 'STANDARD'
         AND rt.transaction_type = 'RECEIVE'
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sups.vendor_id
         AND rt.shipment_header_id = rsh.shipment_header_id(+)
         AND pla.item_id = msi.inventory_item_id(+)
         AND pda.destination_organization_id = msi.organization_id(+)
         AND msi.inventory_item_id = cat.inventory_item_id(+)
         AND msi.organization_id = cat.organization_id(+)
         AND prda.distribution_id = mtrl.attribute14(+)
         AND mtrl.header_id = mtrh.header_id(+)
         AND msi.ORGANIZATION_ID = :P_ORGANIZATION_ID
         AND ( :P_PO_NUMBER IS NULL OR pha.segment1 = :P_PO_NUMBER)
         AND (   :P_DATE_FROM IS NULL
              OR TRUNC (RT.TRANSACTION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO)
         AND NOT EXISTS
                (SELECT 1
                   FROM XX_LC_DETAILS LC
                  WHERE pha.segment1 = lc.po_number AND lc_status = 'Y')
         AND NOT EXISTS
                (SELECT 1
                   FROM xxdbl.xx_explc_btb_req_link b2b,
                        xxdbl.xx_explc_btb_mst b2b2
                  WHERE     pha.segment1 = b2b.po_number
                        AND b2b.btb_lc_no = b2b2.btb_lc_no)
GROUP BY 
         led.UNIT_NAME,
         led.legal_entity_id,
         led.legal_entity_name,
         MSI.DESCRIPTION,
         sup.vendor_name,
         pla.unit_price,
         pha.segment1,
         rsh.receipt_num,
         rt.transaction_date,
         ROUND (SYSDATE - rsh.CREATION_DATE),
         RT.ORGANIZATION_ID,
         MSI.SEGMENT1,
         rt.quantity,
         rt.uom_code,
         (pla.unit_price*pla.quantity)
ORDER BY pha.segment1