/* Formatted on 10/21/2021 10:33:49 AM (QP5 v5.365) */
  SELECT INTERFACE_TRANSACTION_ID,
         GROUP_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         TRANSACTION_TYPE,
         TRANSACTION_DATE,
         PROCESSING_STATUS_CODE,
         PROCESSING_MODE_CODE,
         TRANSACTION_STATUS_CODE,
         INTERFACE_SOURCE_CODE,
         AUTO_TRANSACT_CODE,
         RECEIPT_SOURCE_CODE,
         TO_ORGANIZATION_ID,
         SOURCE_DOCUMENT_CODE,
         PO_HEADER_ID,
         PO_LINE_ID,
         HEADER_INTERFACE_ID,
         DOCUMENT_NUM,
         DOCUMENT_LINE_NUM,
         VALIDATION_FLAG,
         AMOUNT
    --,RTI.*
    FROM RCV_TRANSACTIONS_INTERFACE RTI
   WHERE 1 = 1
ORDER BY CREATION_DATE DESC;


  SELECT HEADER_INTERFACE_ID,
         GROUP_ID,
         PROCESSING_STATUS_CODE,
         RECEIPT_SOURCE_CODE,
         TRANSACTION_TYPE,
         AUTO_TRANSACT_CODE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         VENDOR_ID,
         VENDOR_SITE_ID,
         SHIP_TO_ORGANIZATION_ID,
         EXPECTED_RECEIPT_DATE,
         EMPLOYEE_ID,
         VALIDATION_FLAG,
         ORG_ID
    FROM RCV_HEADERS_INTERFACE RHI
   WHERE 1 = 1
ORDER BY CREATION_DATE DESC;



SELECT hou.name                                        OU_Name,
       led.legal_entity_id,
       led.legal_entity_name,
       org.organization_name,
       mtrh.request_number,
       prha.segment1                                   requisition_number,
       prha.approved_date                              PR_Approved_Date,
       pha.segment1                                    po_number,
       (SELECT ffv.description
          FROM apps.fnd_flex_values_vl ffv
         WHERE     ffv.enabled_flag = 'Y'
               AND ffv.flex_value_set_id = '1016921'
               AND ffv.flex_value = pha.attribute1)    po_type,
       NVL (lc.lc_number, btb_lc_no_phy)               lc_number,
       lc_opening_date,
       lc.bank_name,
       pha.authorization_status                        Approve_Status,
       pha.approved_date                               po_approved_date,
       sup.vendor_id,
       sup.segment1                                    SUPPLIER_ID,
       sup.vendor_name                                 Supplier_Name,
       sups.vendor_site_id,
       msi.segment1                                    item_code,
       msi.description                                 item_name,
       mc.segment1                                     item_category_1,
       mc.segment2                                     item_category_2,
       mc.segment3                                     item_category_3,
       mc.segment4                                     item_category_4,
       pla.unit_meas_lookup_code                       uom,
       prol.quantity                                   PR_Quantity,
       prol.unit_price                                 PR_price,
       pla.quantity                                    PO_Quantity,
       pla.unit_price                                  PO_price,
       pha.rate,
       pha.CURRENCY_CODE,
       ish.ship_num,
       ish.ship_date,
       NULL                                            receipt_num,
       NULL                                            Grn_date,
       NULL                                            grn_quantity,
       NULL                                            invoice_num,
       NULL                                            ITN,
       NULL                                            voucher_number,
       NULL                                            invoice_date,
       NULL                                            payment_voucher,
       NULL                                            bank_account_name,
       NULL                                            payment_date,
       pha.org_id,
       pll.quantity_billed,
       (SELECT DISTINCT customer_name
          FROM xx_ar_customer_site_v
         WHERE customer_id = pla.attribute5)           buyer,
       pla.attribute6                                  order_number,
       NULL                                            payment_voucher_date,
       NULL                                            paid_date,
       ------ NEW FIELD
       prha.CREATED_BY                                 AS PR_CREATED_BY,
       pha.CREATED_BY                                  AS PO_CREATED_BY,
       NULL                                            AS INVOICE_CREATED_BY,
       NULL                                            AS PAYMENT_CREATED_BY,
       NULL                                            RECEIVED_BY
  FROM apps.po_headers_all                pha,
       apps.ap_suppliers                  sup,
       apps.ap_supplier_sites_all         sups,
       apps.po_lines_all                  pla,
       apps.po_line_types_b               plt,
       apps.po_line_locations_all         pll,
       apps.inl_ship_lines_all            isl,
       apps.inl_ship_headers_all          ish,
       apps.mtl_system_items_b            msi,
       apps.mtl_item_categories           mic,
       apps.mtl_categories                mc,
       apps.org_organization_definitions  org,
       apps.hr_operating_units            hou,
       apps.po_distributions_all          pda,
       apps.mtl_txn_request_lines         l,
       apps.mtl_txn_request_headers       mtrh,
       apps.po_req_distributions_all      prod,
       apps.po_requisition_lines_all      prol,
       apps.po_requisition_headers_all    prha,
       apps.xxdbl_company_le_mapping_v    led,
       xxdbl.xx_explc_btb_req_link        b2b,
       xxdbl.xx_explc_btb_mst             b2b2,
       (SELECT lc_number,
               lc.bank_name,
               po_number,
               lc.lc_opening_date,
               lc.bank_branch_name
          FROM xx_lc_details lc
         WHERE lc_status = 'Y') lc                                     --4,332
 WHERE     pha.po_header_id = pla.po_header_id
       AND pha.org_id = pla.org_id
       AND pha.org_id = led.org_id
       AND pha.org_id = hou.organization_id
       AND pha.po_header_id = pll.po_header_id
       AND pla.po_line_id = pll.po_line_id
       AND pll.line_location_id = isl.ship_line_source_id(+)
       AND pll.org_id = isl.org_id(+)
       AND isl.ship_header_id = ish.ship_header_id(+)
       AND pla.line_type_id = plt.line_type_id
       AND pla.item_id = msi.inventory_item_id
       AND msi.inventory_item_id = mic.inventory_item_id
       AND msi.organization_id = mic.organization_id                   --6,457
       AND mic.category_id = mc.category_id
       AND mic.category_set_id = 1
       AND pll.ship_to_organization_id = msi.organization_id
       AND pha.vendor_id = sup.vendor_id
       AND sup.vendor_id = sups.vendor_id
       AND pll.ship_to_organization_id = org.organization_id
       AND pha.vendor_site_id = sups.vendor_site_id(+)
       AND pha.type_lookup_code = 'STANDARD'
       AND pha.segment1 = lc.po_number(+)
       AND pha.po_header_id = pda.po_header_id
       AND pla.po_line_id = pda.po_line_id
       AND pll.line_location_id = pda.line_location_id
       AND pda.req_distribution_id = prod.distribution_id(+)
       AND prod.requisition_line_id = prol.requisition_line_id(+)
       AND prol.requisition_header_id = prha.requisition_header_id(+)
       AND l.attribute14(+) = prod.distribution_id
       AND l.header_id = mtrh.header_id(+)
       AND pha.segment1 = b2b.po_number(+)
       AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
       AND pla.quantity <> 0
       AND pll.quantity_received = 0
       AND pll.quantity_billed = 0
       AND NVL (pla.cancel_flag, 'N') = 'N'
       AND NVL (pll.cancel_flag, 'N') = 'N'
       AND pll.cancel_date IS NULL
       AND isl.match_id IS NULL
       AND pda.quantity_cancelled = 0
       AND pha.org_id = 126
       --AND ROWNUM < 4
       AND pha.segment1 = '20113009408'
       AND pha.authorization_status = 'APPROVED';