CREATE OR REPLACE FORCE VIEW APPS.XXDBL_PR_TO_PAY
(
    OU_NAME,
    LEGAL_ENTITY_ID,
    LEGAL_ENTITY_NAME,
    ORGANIZATION_NAME,
    REQUEST_NUMBER,
    REQUISITION_NUMBER,
    PR_APPROVED_DATE,
    PO_NUMBER,
    PO_TYPE,
    LC_NUMBER,
    LC_OPENING_DATE,
    BANK_NAME,
    APPROVE_STATUS,
    PO_APPROVED_DATE,
    SUPPLIER_ID,
    SUPPLIER_NAME,
    ITEM_CODE,
    ITEM_NAME,
    ITEM_CATEGORY_1,
    ITEM_CATEGORY_2,
    ITEM_CATEGORY_3,
    ITEM_CATEGORY_4,
    UOM,
    PR_QUANTITY,
    PR_PRICE,
    PO_QUANTITY,
    PO_PRICE,
    RATE,
    CURRENCY_CODE,
    SHIP_NUM,
    SHIP_DATE,
    RECEIPT_NUM,
    GRN_DATE,
    GRN_QUANTITY,
    INVOICE_NUM,
    ITN,
    VOUCHER_NUMBER,
    INVOICE_DATE,
    PAYMENT_VOUCHER,
    BANK_ACCOUNT_NAME,
    PAYMENT_DATE,
    ORG_ID,
    QUANTITY_BILLED,
    ORDER_NUMBER,
    BUYER,
    PAYMENT_VOUCHER_DATE,
    PAID_DATE,
    PR_CREATED_BY,
    PO_CREATED_BY,
    INVOICE_CREATED_BY,
    PAYMENT_CREATED_BY,
    RECEIVED_BY
)
BEQUEATH DEFINER
AS
    SELECT hou.name                      OU_Name,
           led.legal_entity_id,
           led.legal_entity_name,
           ood.organization_name,
           mtrh.request_number,
           prh.segment1                  requisition_number,
           prh.approved_date             PR_Approved_Date,
           NULL                          po_number,
           NULL                          po_type,
           NULL                          lc_number,
           NULL                          lc_opening_date,
           NULL                          bank_name,
           prh.authorization_status      Approve_Status,
           NULL                          po_approved_date,
           NULL                          SUPPLIER_ID,
           NULL                          Supplier_Name,
           msi.segment1                  item_code,
           msi.description               item_name,
           mc.segment1                   item_category_1,
           mc.segment2                   item_category_2,
           mc.segment3                   item_category_3,
           mc.segment4                   item_category_4,
           prl.unit_meas_lookup_code     uom,
           prl.quantity                  PR_Quantity,
           prl.unit_price                PR_price,
           NULL                          PO_Quantity,
           NULL                          PO_price,
           NULL                          rate,
           NULL                          CURRENCY_CODE,
           NULL                          ship_num,
           NULL                          ship_date,
           NULL                          receipt_num,
           NULL                          Grn_date,
           NULL                          grn_quantity,
           NULL                          invoice_num,
           NULL                          ITN,
           NULL                          voucher_number,
           NULL                          invoice_date,
           NULL                          payment_voucher,
           NULL                          bank_account_name,                 --
           NULL                          payment_date,
           prh.org_id,
           NULL                          quantity_billed,
           NULL                          order_number,
           NULL                          buyer,
           NULL                          payment_voucher_date,
           NULL                          paid_date,
           ------ NEW FIELD
           prh.CREATED_BY                AS PR_CREATED_BY,
           NULL                          AS PO_CREATED_BY,
           NULL                          AS INVOICE_CREATED_BY,
           NULL                          AS PAYMENT_CREATED_BY,
           NULL                          RECEIVED_BY
      FROM apps.po_requisition_headers_all    prh,
           apps.po_requisition_lines_all      prl,
           apps.po_req_distributions_all      prd,
           apps.mtl_txn_request_lines         l,
           apps.mtl_txn_request_headers       mtrh,
           apps.org_organization_definitions  ood,
           apps.mtl_system_items_b            msi,
           apps.mtl_item_categories           mic,
           apps.mtl_categories                mc,
           apps.hr_operating_units            hou,
           apps.xxdbl_company_le_mapping_v    led
     WHERE     prh.requisition_header_id = prl.requisition_header_id
           AND prl.destination_organization_id = ood.organization_id
           AND prd.requisition_line_id = prl.requisition_line_id
           AND prh.org_id = led.org_id
           AND l.attribute14(+) = prd.distribution_id
           AND l.header_id = mtrh.header_id(+)
           AND prh.org_id = hou.organization_id
           AND prl.item_id = msi.inventory_item_id
           AND prl.destination_organization_id = msi.organization_id
           AND msi.inventory_item_id = mic.inventory_item_id
           AND msi.organization_id = mic.organization_id               --6,457
           AND mic.category_id = mc.category_id
           AND mic.category_set_id = 1
           AND prl.reqs_in_pool_flag = 'Y'
           AND prl.cancel_date IS NULL
           AND prh.authorization_status = 'APPROVED'
    --  and prh.segment1='15511000201'
    -----------PR to PO but Not Received------------ 4,340
    UNION ALL
    SELECT hou.name
               OU_Name,
           led.legal_entity_id,
           led.legal_entity_name,
           org.organization_name,
           mtrh.request_number,
           prha.segment1
               requisition_number,
           prha.approved_date
               PR_Approved_Date,
           pha.segment1
               po_number,
           (SELECT ffv.description
              FROM apps.fnd_flex_values_vl ffv
             WHERE     ffv.enabled_flag = 'Y'
                   AND ffv.flex_value_set_id = '1016921'
                   AND ffv.flex_value = pha.attribute1)
               po_type,
           NVL (lc.lc_number, btb_lc_no_phy)
               lc_number,
           lc_opening_date,
           lc.bank_name,
           pha.authorization_status
               Approve_Status,
           pha.approved_date
               po_approved_date,
           sup.segment1
               SUPPLIER_ID,
           sup.vendor_name
               Supplier_Name,
           msi.segment1
               item_code,
           msi.description
               item_name,
           mc.segment1
               item_category_1,
           mc.segment2
               item_category_2,
           mc.segment3
               item_category_3,
           mc.segment4
               item_category_4,
           pla.unit_meas_lookup_code
               uom,
           prol.quantity
               PR_Quantity,
           prol.unit_price
               PR_price,
           pla.quantity
               PO_Quantity,
           pla.unit_price
               PO_price,
           pha.rate,
           pha.CURRENCY_CODE,
           ish.ship_num,
           ish.ship_date,
           NULL
               receipt_num,
           NULL
               Grn_date,
           NULL
               grn_quantity,
           NULL
               invoice_num,
           NULL
               ITN,
           NULL
               voucher_number,
           NULL
               invoice_date,
           NULL
               payment_voucher,
           NULL
               bank_account_name,
           NULL
               payment_date,
           pha.org_id,
           pll.quantity_billed,
           (SELECT DISTINCT customer_name
              FROM xx_ar_customer_site_v
             WHERE customer_id = pla.attribute5)
               buyer,
           pla.attribute6
               order_number,
           NULL
               payment_voucher_date,
           NULL
               paid_date,
           ------ NEW FIELD
           prha.CREATED_BY
               AS PR_CREATED_BY,
           pha.CREATED_BY
               AS PO_CREATED_BY,
           NULL
               AS INVOICE_CREATED_BY,
           NULL
               AS PAYMENT_CREATED_BY,
           NULL
               RECEIVED_BY
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
             WHERE lc_status = 'Y') lc                                 --4,332
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
           AND msi.organization_id = mic.organization_id               --6,457
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
           AND pha.authorization_status = 'APPROVED'
    -- and  pha.segment1 in ('25113000332') 5,980 6,012 6,025 ,7,172
    UNION ALL
      ------------- PR Created + PO Created + LCM but GRN not Created
      SELECT hou.name
                 OU_Name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1
                 requisition_number,
             prha.approved_date
                 PR_Approved_Date,
             pha.segment1
                 po_number,
             (SELECT ffv.description
                FROM apps.fnd_flex_values_vl ffv
               WHERE     ffv.enabled_flag = 'Y'
                     AND ffv.flex_value_set_id = '1016921'
                     AND ffv.flex_value = pha.attribute1)
                 po_type,
             NVL (lc.lc_number, btb_lc_no_phy)
                 lc_number,
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status
                 Approve_Status,
             pha.approved_date
                 po_approved_date,
             sup.segment1
                 SUPPLIER_ID,
             sup.vendor_name
                 Supplier_Name,
             msi.segment1
                 item_code,
             msi.description
                 item_name,
             mc.segment1
                 item_category_1,
             mc.segment2
                 item_category_2,
             mc.segment3
                 item_category_3,
             mc.segment4
                 item_category_4,
             pla.unit_meas_lookup_code
                 uom,
             SUM (prol.quantity)
                 PR_Quantity,
             SUM (prol.unit_price)
                 PR_price,
             SUM (pla.quantity)
                 PO_Quantity,
             SUM (pla.unit_price)
                 PO_price,
             pha.rate,
             pha.CURRENCY_CODE,
             ish.ship_num,
             ish.ship_date,
             NULL
                 receipt_num,
             NULL
                 Grn_date,
             NULL
                 grn_quantity,
             NULL
                 invoice_num,
             NULL
                 ITN,
             NULL
                 voucher_number,
             NULL
                 invoice_date,
             NULL
                 payment_voucher,
             NULL
                 bank_account_name,
             NULL
                 payment_date,
             pha.org_id,
             SUM (pll.quantity_billed),
             (SELECT DISTINCT customer_name
                FROM xx_ar_customer_site_v
               WHERE customer_id = pla.attribute5)
                 buyer,
             pla.attribute6
                 order_number,
             NULL
                 payment_voucher_date,
             NULL
                 paid_date,
             ------ NEW FIELD
             prha.CREATED_BY
                 AS PR_CREATED_BY,
             pha.CREATED_BY
                 AS PO_CREATED_BY,
             NULL
                 AS INVOICE_CREATED_BY,
             NULL
                 AS PAYMENT_CREATED_BY,
             NULL
                 RECEIVED_BY
        FROM apps.po_headers_all              pha,
             apps.ap_suppliers                sup,
             apps.ap_supplier_sites_all       sups,
             apps.po_lines_all                pla,
             apps.po_line_types_b             plt,
             apps.po_line_locations_all       pll,
             apps.inl_ship_lines_all          isl,
             apps.inl_ship_headers_all        ish,
             apps.mtl_system_items_b          msi,
             apps.mtl_item_categories         mic,
             apps.mtl_categories              mc,
             apps.org_organization_definitions org,
             apps.hr_operating_units          hou,
             apps.po_distributions_all        pda,
             apps.po_req_distributions_all    prod,
             apps.po_requisition_lines_all    prol,
             apps.po_requisition_headers_all  prha,
             apps.mtl_txn_request_lines       l,
             apps.mtl_txn_request_headers     mtrh,
             apps.xxdbl_company_le_mapping_v  led,
             xxdbl.xx_explc_btb_req_link      b2b,
             xxdbl.xx_explc_btb_mst           b2b2,
             -- rcv_shipment_headers rsh,
             (SELECT lc_number,
                     lc_opening_date,
                     lc.bank_name,
                     po_number,
                     lc.bank_branch_name
                FROM xx_lc_details lc
               WHERE lc_status = 'Y') lc
       WHERE     pha.po_header_id = pla.po_header_id
             AND pha.org_id = led.org_id
             AND pha.org_id = pla.org_id
             AND pha.org_id = hou.organization_id
             AND pha.po_header_id = pll.po_header_id
             AND pla.po_line_id = pll.po_line_id
             AND pll.line_location_id = isl.ship_line_source_id(+)
             AND isl.ship_header_id = ish.ship_header_id(+)
             AND pla.line_type_id = plt.line_type_id
             AND pla.item_id = msi.inventory_item_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND msi.organization_id = mic.organization_id             --6,457
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
             AND pll.quantity_received <> 0               --Update 09-SEP-2021
             --AND pll.quantity_billed = 0                    --Update 30-Jan-2020
             AND (pll.quantity_billed = 0)   -- OR rt.quantity_billed IS NULL)
             AND NVL (pla.cancel_flag, 'N') = 'N'
             AND NVL (pll.cancel_flag, 'N') = 'N'
             AND pll.cancel_date IS NULL
             AND isl.match_id IS NULL
             AND pda.quantity_cancelled = 0
             AND pha.authorization_status = 'APPROVED'
             -- and  pha.segment1='10633000114'
             AND NOT EXISTS
                     (SELECT 1
                        FROM apps.rcv_transactions    rt,
                             apps.rcv_shipment_headers rsh
                       WHERE     rt.transaction_type IN
                                     ('RECEIVE', 'RETURN TO VENDOR')
                             AND pha.po_header_id = rt.po_header_id
                             AND pla.po_line_id = rt.po_line_id
                             --AND isl.ship_line_id = rt.lcm_shipment_line_id(+)
                             AND rt.shipment_header_id = rsh.shipment_header_id)
    GROUP BY hou.name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1,
             prha.approved_date,
             pha.segment1,
             pha.attribute1,
             lc.lc_number,
             btb_lc_no_phy,
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status,
             pha.approved_date,
             sup.segment1,
             sup.vendor_name,
             msi.segment1,
             msi.description,
             mc.segment1,
             mc.segment2,
             mc.segment3,
             mc.segment4,
             pla.unit_meas_lookup_code,
             pha.CURRENCY_CODE,
             pha.rate,
             ish.ship_num,
             ish.ship_date,
             pha.org_id,
             pla.attribute6,
             pla.attribute5,
             prha.CREATED_BY,
             pha.CREATED_BY
    ----------- PR Created + PO Created + GRN Create   7,348
    UNION ALL
      SELECT hou.name
                 OU_Name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1
                 requisition_number,
             prha.approved_date
                 PR_Approved_Date,
             pha.segment1
                 po_number,
             (SELECT ffv.description
                FROM apps.fnd_flex_values_vl ffv
               WHERE     ffv.enabled_flag = 'Y'
                     AND ffv.flex_value_set_id = '1016921'
                     AND ffv.flex_value = pha.attribute1)
                 po_type,
             NVL (lc.lc_number, btb_lc_no_phy)
                 lc_number,
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status
                 Approve_Status,
             pha.approved_date
                 po_approved_date,
             sup.segment1
                 SUPPLIER_ID,
             sup.vendor_name
                 Supplier_Name,
             msi.segment1
                 item_code,
             msi.description
                 item_name,
             mc.segment1
                 item_category_1,
             mc.segment2
                 item_category_2,
             mc.segment3
                 item_category_3,
             mc.segment4
                 item_category_4,
             pla.unit_meas_lookup_code
                 uom,
             SUM (prol.quantity)
                 PR_Quantity,
             SUM (prol.unit_price)
                 PR_price,
             SUM (pla.quantity)
                 PO_Quantity,
             SUM (pla.unit_price)
                 PO_price,
             pha.rate,
             pha.CURRENCY_CODE,
             ish.ship_num,
             ish.ship_date,
             rsh.receipt_num,
             rsh.creation_date
                 Grn_date,
             SUM (
                 CASE
                     WHEN rt.transaction_type = 'RETURN TO VENDOR'
                     THEN
                         rt.primary_quantity * -1
                     ELSE
                         rt.primary_quantity
                 END)
                 grn_quantity,                                  ------------18
             NULL
                 invoice_num,
             NULL
                 ITN,
             NULL
                 voucher_number,
             NULL
                 invoice_date,
             NULL
                 payment_voucher,
             NULL
                 bank_account_name,
             NULL
                 payment_date,
             pha.org_id,
             SUM (pll.quantity_billed),
             (SELECT DISTINCT customer_name
                FROM xx_ar_customer_site_v
               WHERE customer_id = pla.attribute5)
                 buyer,
             pla.attribute6
                 order_number,
             NULL
                 payment_voucher_date,
             NULL
                 paid_date,
             ------ NEW FIELD
             prha.CREATED_BY
                 AS PR_CREATED_BY,
             pha.CREATED_BY
                 AS PO_CREATED_BY,
             NULL
                 AS INVOICE_CREATED_BY,
             NULL
                 AS PAYMENT_CREATED_BY,
             rt.CREATED_BY
                 RECEIVED_BY
        FROM apps.po_headers_all              pha,
             apps.ap_suppliers                sup,
             apps.ap_supplier_sites_all       sups,
             apps.po_lines_all                pla,
             apps.po_line_types_b             plt,
             apps.po_line_locations_all       pll,
             apps.inl_ship_lines_all          isl,
             apps.inl_ship_headers_all        ish,
             apps.mtl_system_items_b          msi,
             apps.mtl_item_categories         mic,
             apps.mtl_categories              mc,
             apps.org_organization_definitions org,
             apps.hr_operating_units          hou,
             apps.po_distributions_all        pda,
             apps.po_req_distributions_all    prod,
             apps.po_requisition_lines_all    prol,
             apps.po_requisition_headers_all  prha,
             apps.mtl_txn_request_lines       l,
             apps.mtl_txn_request_headers     mtrh,
             apps.rcv_transactions            rt,
             apps.rcv_shipment_headers        rsh,
             apps.xxdbl_company_le_mapping_v  led,
             xxdbl.xx_explc_btb_req_link      b2b,
             xxdbl.xx_explc_btb_mst           b2b2,
             -- rcv_shipment_headers rsh,
             (SELECT lc_number,
                     lc_opening_date,
                     lc.bank_name,
                     po_number,
                     lc.bank_branch_name
                FROM xx_lc_details lc
               WHERE lc_status = 'Y') lc
       WHERE     pha.po_header_id = pla.po_header_id
             AND pha.org_id = led.org_id
             AND pha.org_id = pla.org_id
             AND pha.org_id = hou.organization_id
             AND pha.po_header_id = pll.po_header_id
             AND pla.po_line_id = pll.po_line_id
             AND pll.line_location_id = isl.ship_line_source_id(+)
             AND isl.ship_header_id = ish.ship_header_id(+)
             AND pla.line_type_id = plt.line_type_id
             AND pla.item_id = msi.inventory_item_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND msi.organization_id = mic.organization_id             --6,457
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
             AND pha.po_header_id = rt.po_header_id
             AND pla.po_line_id = rt.po_line_id
             AND rt.lcm_shipment_line_id = isl.ship_line_id(+) -----Updated By Sourav on 13-JUN-21
             AND rt.shipment_header_id = rsh.shipment_header_id
             AND l.attribute14(+) = prod.distribution_id
             AND l.header_id = mtrh.header_id(+)
             AND pha.segment1 = b2b.po_number(+)
             AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
             AND rt.transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
             AND pla.quantity <> 0
             AND pll.quantity_received <> 0
             --AND pll.quantity_billed = 0                    --Update 30-Jan-2020
             AND (pll.quantity_billed = 0 OR rt.quantity_billed IS NULL)
             AND NVL (pla.cancel_flag, 'N') = 'N'
             AND NVL (pll.cancel_flag, 'N') = 'N'
             AND pll.cancel_date IS NULL
             AND isl.match_id IS NULL
             AND pda.quantity_cancelled = 0
             AND pha.authorization_status = 'APPROVED'
    -- and  pha.segment1='10633000114'
    GROUP BY hou.name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1,
             prha.approved_date,
             pha.segment1,
             pha.attribute1,
             lc.lc_number,
             btb_lc_no_phy,
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status,
             pha.approved_date,
             sup.segment1,
             sup.vendor_name,
             msi.segment1,
             msi.description,
             mc.segment1,
             mc.segment2,
             mc.segment3,
             mc.segment4,
             pla.unit_meas_lookup_code,
             pha.CURRENCY_CODE,
             pha.rate,
             ish.ship_num,
             ish.ship_date,
             rsh.receipt_num,
             rsh.creation_date,
             pha.org_id,
             pla.attribute6,
             pla.attribute5,
             prha.CREATED_BY,
             pha.CREATED_BY,
             rt.CREATED_BY
      HAVING SUM (
                 CASE
                     WHEN rt.transaction_type = 'RETURN TO VENDOR'
                     THEN
                         rt.primary_quantity * -1
                     ELSE
                         rt.primary_quantity
                 END) <>
             0
    -------PR+PO+GRN+Invoice  4,450 4,536  4,784 4,568 11,734 13,222 ,16,525
    UNION ALL
      SELECT hou.name
                 OU_Name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1
                 requisition_number,
             prha.approved_date
                 PR_Approved_Date,
             pha.segment1
                 po_number,
             (SELECT ffv.description
                FROM apps.fnd_flex_values_vl ffv
               WHERE     ffv.enabled_flag = 'Y'
                     AND ffv.flex_value_set_id = '1016921'
                     AND ffv.flex_value = pha.attribute1)
                 po_type,
             NVL (lc.lc_number, btb_lc_no_phy)
                 lc_number,
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status
                 Approve_Status,
             pha.approved_date
                 po_approved_date,
             sup.segment1
                 SUPPLIER_ID,
             sup.vendor_name
                 Supplier_Name,
             msi.segment1
                 item_code,
             msi.description
                 item_name,
             mc.segment1
                 item_category_1,
             mc.segment2
                 item_category_2,
             mc.segment3
                 item_category_3,
             mc.segment4
                 item_category_4,
             pla.unit_meas_lookup_code
                 uom,
             SUM (prol.quantity)
                 PR_Quantity,
             prol.unit_price
                 PR_price,
             pla.quantity
                 PO_Quantity,
             pla.unit_price
                 PO_price,
             pha.rate,
             pha.CURRENCY_CODE,
             ish.ship_num,
             ish.ship_date,
             rsh.receipt_num,
             rsh.creation_date
                 Grn_date,
             rt.primary_quantity
                 grn_quantity,
             ail.invoice_num,
             AIL.TAX_INVOICE_INTERNAL_SEQ
                 ITN,
             ail.doc_sequence_value
                 voucher_number,
             ail.creation_date
                 invoice_date,
             ck.doc_sequence_value
                 payment_voucher,
             ck.bank_account_name,
             ck.check_date
                 payment_date,
             pha.org_id,
             pll.quantity_billed,
             (SELECT DISTINCT customer_name
                FROM xx_ar_customer_site_v
               WHERE customer_id = pla.attribute5)
                 buyer,
             pla.attribute6
                 order_number,
             pm.accounting_date
                 payment_voucher_date,
             ck.cleared_date
                 paid_date,
             ------ NEW FIELD
             prha.CREATED_BY
                 AS PR_CREATED_BY,
             pha.CREATED_BY
                 AS PO_CREATED_BY,
             ail.CREATED_BY
                 AS INVOICE_CREATED_BY,
             pm.CREATED_BY
                 AS PAYMENT_CREATED_BY,
             rt.CREATED_BY
                 RECEIVED_BY
        FROM apps.po_headers_all              pha,
             apps.xxdbl_company_le_mapping_v  led,
             apps.ap_suppliers                sup,
             apps.ap_supplier_sites_all       sups,
             apps.po_lines_all                pla,
             apps.po_line_types_b             plt,
             apps.po_line_locations_all       pll,
             apps.inl_ship_lines_all          isl,
             apps.inl_ship_headers_all        ish,
             apps.mtl_system_items_b          msi,
             apps.mtl_item_categories         mic,
             apps.mtl_categories              mc,
             apps.org_organization_definitions org,
             apps.hr_operating_units          hou,
             apps.po_distributions_all        pda,
             apps.po_req_distributions_all    prod,
             apps.po_requisition_lines_all    prol,
             apps.po_requisition_headers_all  prha,
             apps.mtl_txn_request_lines       l,
             apps.mtl_txn_request_headers     mtrh,
             apps.rcv_transactions            rt,
             apps.rcv_shipment_headers        rsh,
             apps.ap_invoice_lines_all        aila,
             apps.ap_invoices_all             ail,
             apps.ap_invoice_payments_all     pm,
             apps.ap_checks_all               ck,
             (SELECT lc_number,
                     lc.lc_opening_date,
                     lc.bank_name,
                     po_number,
                     lc.bank_branch_name
                FROM xx_lc_details lc
               WHERE lc_status = 'Y') lc,
             xxdbl.xx_explc_btb_req_link      b2b,
             xxdbl.xx_explc_btb_mst           b2b2
       WHERE     pha.po_header_id = pla.po_header_id
             AND pha.org_id = pla.org_id
             AND pha.org_id = led.org_id
             AND pha.org_id = hou.organization_id
             AND pha.po_header_id = pll.po_header_id
             AND pla.po_line_id = pll.po_line_id
             AND pla.line_type_id = plt.line_type_id
             AND pla.item_id = msi.inventory_item_id
             AND pll.ship_to_organization_id = msi.organization_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND msi.organization_id = mic.organization_id             --6,457
             AND mic.category_id = mc.category_id
             AND mic.category_set_id = 1
             AND pha.vendor_id = sup.vendor_id
             AND sup.vendor_id = sups.vendor_id
             AND pll.ship_to_organization_id = org.organization_id
             AND pha.vendor_site_id = sups.vendor_site_id(+)
             AND pha.type_lookup_code = 'STANDARD'
             AND pha.segment1 = lc.po_number(+)
             AND pha.po_header_id = pda.po_header_id
             AND pla.po_line_id = pda.po_line_id
             AND pll.line_location_id = pda.line_location_id
             AND pll.line_location_id = isl.ship_line_source_id(+)
             AND isl.ship_header_id = ish.ship_header_id(+)
             AND pda.req_distribution_id = prod.distribution_id(+)
             AND prod.requisition_line_id = prol.requisition_line_id(+)
             AND prol.requisition_header_id = prha.requisition_header_id(+)
             AND pha.po_header_id = rt.po_header_id
             AND pla.po_line_id = rt.po_line_id
             AND rt.lcm_shipment_line_id = isl.ship_line_id(+) -----Updated By Sourav 13-JUN-21
             AND rt.shipment_header_id = rsh.shipment_header_id
             AND pla.po_header_id = aila.po_header_id
             AND pll.line_location_id = aila.po_line_location_id
             AND pla.po_line_id = aila.po_line_id
             AND l.attribute14(+) = prod.distribution_id
             AND l.header_id = mtrh.header_id(+)
             AND pla.org_id = aila.org_id
             AND aila.invoice_id = ail.invoice_id
             AND aila.org_id = ail.org_id
             AND rt.transaction_id = aila.RCV_TRANSACTION_ID
             AND ail.invoice_id = pm.invoice_id(+)
             AND pm.check_id = ck.check_id(+)
             AND pha.segment1 = b2b.po_number(+)
             AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
             AND rt.transaction_type = 'RECEIVE'
             AND line_type_lookup_code = 'ITEM'
             AND pla.quantity <> 0
             AND pll.quantity_received <> 0
             AND NVL (pla.cancel_flag, 'N') = 'N'
             AND NVL (pll.cancel_flag, 'N') = 'N'
             AND pll.cancel_date IS NULL
             AND ail.CANCELLED_DATE IS NULL
             AND isl.match_id IS NULL
             AND pda.quantity_cancelled = 0
    GROUP BY hou.name,
             led.legal_entity_id,
             led.legal_entity_name,
             org.organization_name,
             mtrh.request_number,
             prha.segment1,
             prha.approved_date,
             pha.segment1,
             pha.attribute1,
             NVL (lc.lc_number, btb_lc_no_phy),
             lc.lc_opening_date,
             lc.bank_name,
             pha.authorization_status,
             pha.approved_date,
             sup.segment1,
             sup.vendor_name,
             msi.segment1,
             msi.description,
             mc.segment1,
             mc.segment2,
             mc.segment3,
             mc.segment4,
             pla.unit_meas_lookup_code,
             prol.unit_price,
             pla.quantity,
             pla.unit_price,
             pha.rate,
             pha.CURRENCY_CODE,
             ish.ship_num,
             ish.ship_date,
             rsh.receipt_num,
             rsh.creation_date,
             rt.primary_quantity,
             ail.invoice_num,
             AIL.TAX_INVOICE_INTERNAL_SEQ,
             ail.doc_sequence_value,
             ail.creation_date,
             ck.doc_sequence_value,
             ck.bank_account_name,
             ck.check_date,
             pha.org_id,
             pll.quantity_billed,
             pla.attribute5,
             pla.attribute6,
             pm.accounting_date,
             ck.cleared_date,
             ------ NEW FIELD
             prha.CREATED_BY,
             pha.CREATED_BY,
             ail.CREATED_BY,
             pm.CREATED_BY,
             rt.CREATED_BY
    --          AND apps.XX_AP_PKG.GET_INVOICE_STATUS (ail.INVOICE_ID) <> 'Cancelled'
    -- and  pha.segment1='15313000208' 17,568 17,568 25,341 25,917 25,452 ,42,913
    UNION ALL                                                      ----Service
    SELECT hou.name
               OU_Name,
           led.legal_entity_id,
           led.legal_entity_name,
           org.organization_name,
           NULL
               request_number,
           NULL
               requisition_number,
           NULL
               PR_Approved_Date,
           pha.segment1
               po_number,
           (SELECT ffv.description
              FROM apps.fnd_flex_values_vl ffv
             WHERE     ffv.enabled_flag = 'Y'
                   AND ffv.flex_value_set_id = '1016921'
                   AND ffv.flex_value = pha.attribute1)
               po_type,
           (lc.lc_number)
               lc_number,
           lc.lc_opening_date,
           lc.bank_name,
           pha.authorization_status
               Approve_Status,
           pha.approved_date
               po_approved_date,
           sup.segment1
               SUPPLIER_ID,
           sup.vendor_name
               Supplier_Name,
           NULL
               item_code,
           NULL
               item_name,
           NULL
               item_category_1,
           NULL
               item_category_2,
           NULL
               item_category_3,
           NULL
               item_category_4,
           pla.unit_meas_lookup_code
               uom,
           NULL
               pr_Quantity,
           NULL
               PR_price,
           pla.quantity
               PO_Quantity,
           pla.unit_price
               PO_price,
           pha.rate,
           pha.CURRENCY_CODE,
           NULL
               ship_num,
           NULL
               ship_date,
           rsh.receipt_num,
           rsh.creation_date
               Grn_date,
           rt.primary_quantity
               grn_quantity,
           ail.invoice_num,
           AIL.TAX_INVOICE_INTERNAL_SEQ
               ITN,
           ail.doc_sequence_value
               voucher_number,
           ail.creation_date
               invoice_date,
           ck.doc_sequence_value
               payment_voucher,
           ck.bank_account_name,
           ck.check_date
               payment_date,
           pha.org_id,
           pll.quantity_billed,
           (SELECT DISTINCT customer_name
              FROM xx_ar_customer_site_v
             WHERE customer_id = pla.attribute5)
               buyer,
           pla.attribute6
               order_number,
           pm.accounting_date
               payment_voucher_date,
           ck.cleared_date
               paid_date,
           ------ NEW FIELD
           NULL
               AS PR_CREATED_BY,
           pha.CREATED_BY
               AS PO_CREATED_BY,
           ail.CREATED_BY
               AS INVOICE_CREATED_BY,
           pm.CREATED_BY
               AS PAYMENT_CREATED_BY,
           rt.CREATED_BY
               RECEIVED_BY
      FROM apps.po_headers_all                pha,
           apps.xxdbl_company_le_mapping_v    led,
           apps.ap_suppliers                  sup,
           apps.ap_supplier_sites_all         sups,
           apps.po_lines_all                  pla,
           apps.po_line_types_b               plt,
           apps.po_line_locations_all         pll,
           apps.org_organization_definitions  org,
           apps.hr_operating_units            hou,
           apps.po_distributions_all          pda,
           apps.rcv_transactions              rt,
           apps.rcv_shipment_headers          rsh,
           apps.ap_invoice_lines_all          aila,
           apps.ap_invoices_all               ail,
           apps.ap_invoice_payments_all       pm,
           apps.ap_checks_all                 ck,
           (SELECT lc_number,
                   lc.lc_opening_date,
                   lc.bank_name,
                   po_number,
                   lc.bank_branch_name
              FROM xx_lc_details lc
             WHERE lc_status = 'Y') lc
     WHERE     pha.po_header_id = pla.po_header_id
           AND pha.org_id = pla.org_id
           AND pha.org_id = led.org_id
           AND pha.org_id = hou.organization_id
           AND pha.po_header_id = pll.po_header_id
           AND pla.po_line_id = pll.po_line_id
           AND pla.line_type_id = plt.line_type_id
           AND pha.vendor_id = sup.vendor_id
           AND sup.vendor_id = sups.vendor_id
           AND pll.ship_to_organization_id = org.organization_id
           AND pha.vendor_site_id = sups.vendor_site_id(+)
           AND pha.type_lookup_code = 'STANDARD'
           AND pha.segment1 = lc.po_number(+)
           AND pha.po_header_id = pda.po_header_id
           AND pla.po_line_id = pda.po_line_id
           AND pll.line_location_id = pda.line_location_id
           AND pha.po_header_id = rt.po_header_id(+)
           AND pla.po_line_id = rt.po_line_id(+)
           AND rt.shipment_header_id = rsh.shipment_header_id(+)
           AND pla.po_header_id = aila.po_header_id(+)
           AND pll.line_location_id = aila.po_line_location_id(+)
           AND pla.po_line_id = aila.po_line_id(+)
           AND pla.org_id = aila.org_id(+)
           AND aila.invoice_id = ail.invoice_id(+)
           AND aila.org_id = ail.org_id(+)
           AND rt.transaction_id(+) = aila.rcv_transaction_id
           AND ail.invoice_id = pm.invoice_id(+)
           AND pm.check_id = ck.check_id(+)
           AND rt.transaction_type(+) = 'RECEIVE'
           AND line_type_lookup_code(+) = 'ITEM'
           AND pla.quantity <> 0
           AND pla.item_id IS NULL
           AND NVL (pla.cancel_flag, 'N') = 'N'
           AND NVL (pll.cancel_flag, 'N') = 'N'
           AND pm.REVERSAL_FLAG(+) = 'N'
           AND aila.DISCARDED_FLAG(+) = 'N'
           AND aila.CANCELLED_FLAG(+) = 'N'
           AND pll.cancel_date IS NULL
           --          AND ail.CANCELLED_DATE IS NULL
           AND pda.quantity_cancelled = 0;


CREATE OR REPLACE SYNONYM APPSRO.XXDBL_PR_TO_PAY FOR APPS.XXDBL_PR_TO_PAY;


GRANT SELECT ON APPS.XXDBL_PR_TO_PAY TO APPSRO;
