/* Formatted on 9/2/2020 12:50:08 PM (QP5 v5.354) */
  SELECT odd.organization_name,
         sup.vendor_name                     AS "Supplier_Name",
         pha.segment1                        "PO_NUMBER",
         MSI.SEGMENT1                        INV_ITEM,
         MSI.DESCRIPTION                     AS "Item Description",
         cat.segment2                        item_catg,
         cat.segment3                        item_type,
         rt.uom_code                         uom,
         rt.quantity                         PRIMARY_QTY,
         pla.unit_price                      AS unit_price,
         (pla.unit_price * pla.quantity)     PO_AMOUNT,
         rsh.receipt_num                     GRN_NUM,
         rt.transaction_date                 GRN_DATE
    FROM po_headers_all                   pha,
         po_lines_all                     pla,
         apps.xxdbl_company_le_mapping_v  led,
         apps.org_organization_definitions odd,
         apps.hr_operating_units          hou,
         po_distributions_all             pda,
         po_requisition_headers_all       prha,
         po_requisition_lines_all         prla,
         po_req_distributions_all         prda,
         apps.po_line_locations_all       pll,
         apps.po_line_types_b             plt,
         rcv_transactions                 rt,
         --rcv_shipment_lines rsl,
         rcv_shipment_headers             rsh,
         apps.mtl_item_categories_v       cat,
         apps.ap_suppliers                sup,
         apps.ap_supplier_sites_all       sups,
         apps.mtl_txn_request_lines       mtrl,
         apps.mtl_txn_request_headers     mtrh,
         apps.mtl_system_items_b          msi
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
         --AND hou.name LIKE 'J%'
         AND cat.segment2 = 'RAW MATERIAL'
         AND TO_CHAR (TRUNC (rt.TRANSACTION_DATE), 'MON-YY') IN ('JUL-20')
         --AND odd.organization_name = 'JINNAT APPARELS LTD RMG- IO'
         --AND msi.ORGANIZATION_ID = :P_ORGANIZATION_ID
         --AND led.org_id = 131
         AND category_set_id = 1
--AND rt.ORGANIZATION_ID IN (197, 198)
--AND TRUNC (RT.TRANSACTION_DATE) BETWEEN :P_DATE_FROM AND :P_DATE_TO
GROUP BY odd.organization_name,
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
         cat.segment2,
         cat.segment3,
         (pla.unit_price * pla.quantity);