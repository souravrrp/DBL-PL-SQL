/* Formatted on 7/27/2020 2:53:10 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_CER_INVOICE_DETAILS_V
(
   ORG_ID,
   CUSTOMER_ID,
   CUSTOMER_NUMBER,
   CUSTOMER_NAME,
   CUST_CATEGORY,
   C_TYPE,
   ORDER_TYPE,
   ORDER_NUMBER,
   LINE_ID,
   ORDERED_DATE,
   DELIVERY_DATE,
   PRIORITY,
   FREIGHT,
   FLOW_STATUS_CODE,
   ORDERED_ITEM,
   DESCRIPTION,
   PREFERRED_GRADE,
   ITEM_SIZE,
   PRODUCT_CATEGORY,
   PRODUCT_TYPE,
   ORDERED_QUANTITY,
   ORDER_QUANTITY_UOM,
   UNIT_LIST_PRICE,
   UNIT_SELLING_PRICE,
   ORDERED_QUANTITY2,
   ORDERED_QUANTITY_UOM2,
   DISCOUNT_SFT,
   LINE_DISCOUNT,
   HEADER_DIS_SFT,
   HEADER_DIS_AMT,
   FREIGHT_VALUE,
   TOTAL_DISCOUNT,
   INVOICE_AMOUNT,
   HEADER_LEVEL_DISCOUNT,
   LINE_LEVEL_DISCOUNT_SFT,
   LINE_LEVEL_DISCOUNT_PER,
   CARRYING_COMMISSION,
   AR_INVOICE_VALUE,
   PROVS_FOR_REG_COMM,
   PROVS_FOR_BREAK_COMM,
   INVOICE_NUMBER,
   CHALLAN_NO,
   SALES_PERSON,
   TRANSPOTER,
   VEHICLE_NUMBER,
   VEHICLE_TYPE,
   DRIVER_NAME,
   DRIVER_CONTACT_NO
)
   BEQUEATH DEFINER
AS
   SELECT oha.org_id,
          ac.customer_id,
          ac.customer_number,
          ac.customer_name,
          ac.customer_category_code cust_category,
          ac.customer_type c_type,
          ott.name order_type,
          oha.order_number,
          ola.line_id,
          TRUNC (oha.ordered_date) ordered_date,
          TRUNC (ola.actual_shipment_date) delivery_date,
          oha.shipment_priority_code priority,
          oha.freight_terms_code freight,
          ola.flow_status_code,
          ola.ordered_item,
          msi.description,
          ola.preferred_grade,
          cat.segment2 item_size,
          cat.category_concat_segs product_category,
          cay.segment3 product_type,
          ola.ordered_quantity,
          ola.order_quantity_uom,
          ola.unit_list_price,
          ola.unit_selling_price,
          ola.ordered_quantity2,
          ola.ordered_quantity_uom2,
          (ola.unit_list_price - ola.unit_selling_price + pav.adjusted_amount)
             discount_sft,
            (  ola.unit_list_price
             - ola.unit_selling_price
             + pav.adjusted_amount)
          * ola.ordered_quantity
             line_discount,
          ABS (pav.adjusted_amount) header_dis_sft,
          ABS (pav.adjusted_amount) * ola.shipped_quantity header_dis_amt,
          CASE
             WHEN     ola.freight_terms_code = 'DEALER'
                  AND ott.transaction_type_id NOT IN (1006, 1014)
             THEN
                ola.shipped_quantity * .8
             ELSE
                0
          END
             freight_value,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             total_discount,
          ola.shipped_quantity * ola.unit_selling_price invoice_amount,
          header_level_discount,
          line_level_discount_sft,
          line_level_discount_per,
          carrying_commission,
          ar_invoice_value,
          provs_for_reg_comm,
          provs_for_break_comm,
          ct.trx_number invoice_number,
          olv.delivery_challan_number challan_no,
          rsv.resource_name sales_person,
          olv.transport_name transpoter,
          th.vehicle_no vehicle_number,
          th.delivery_mode_code vehicle_type,
          th.driver_name driver_name,
          th.transporter_no driver_contact_no
     FROM oe_order_headers_all oha,
          oe_order_lines_all ola,
          apps.oe_transaction_types_tl ott,
          inv.mtl_system_items_b msi,
          ar_customers ac,
          mtl_item_categories_v cat,
          mtl_item_categories_v cay,
          ra_customer_trx_all ct,
          ra_customer_trx_lines_all ctl,
          xxdbl.xxdbl_omshipping_line_v olv,
          xxdbl_prov_booking_tbl pbt,
          xxdbl_transpoter_headers th,
          jtf_rs_salesreps sal,
          jtf_rs_defresources_v rsv,
          oe_price_adjustments_v pav
    WHERE     oha.header_id = ola.header_id
          AND oha.org_id = ola.org_id
          AND oha.order_type_id = ott.transaction_type_id
          AND oha.header_id = pav.header_id
          AND ola.line_id = pav.line_id
          AND ola.inventory_item_id = msi.inventory_item_id
          AND ola.ship_from_org_id = msi.organization_id
          AND oha.sold_to_org_id = ac.customer_id
          AND msi.inventory_item_id = cat.inventory_item_id
          AND msi.inventory_item_id = cay.inventory_item_id
          AND pav.adjustment_name = 'SO Header Adhoc Discount'
          AND cat.category_set_name = 'DBL_SALES_CAT_SET'
          AND cay.category_set_name = 'Inventory'
          AND TO_CHAR (oha.order_number) =
                 TO_CHAR (ctl.interface_line_attribute1)
          AND oha.sold_to_org_id = ct.bill_to_customer_id
          AND ct.customer_trx_id = ctl.customer_trx_id
          AND ola.line_id = ctl.interface_line_attribute6
          AND ola.line_id = olv.order_line_id
          AND oha.header_id = pbt.order_header_id(+)
          AND ola.line_id = pbt.order_line_id(+)
          AND ct.customer_trx_id = pbt.customer_trx_id(+)
          AND ola.inventory_item_id = olv.item_id
          AND olv.transport_challan_number = th.transpoter_challan_number(+)
          AND oha.salesrep_id = sal.salesrep_id
          AND sal.resource_id = rsv.resource_id
          AND sal.org_id = oha.org_id
          AND cay.organization_id = cat.organization_id
          AND cat.organization_id = 152
          AND oha.org_id = 126
          AND ola.flow_status_code = 'CLOSED'
          AND olv.omshipping_line_status = 'CLOSED'
   --          --AND oha.order_number=2011020000004
   --          --AND TRUNC (ola.actual_shipment_date) BETWEEN '21-NOV-19' AND '30-NOV-19'
   --          AND oha.org_id = :p_org_id
   --          AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
   --          AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
   --          AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
   --                                                   AND :p_date_to
   UNION ALL
   SELECT oha.org_id,
          ac.customer_id,
          ac.customer_number,
          ac.customer_name,
          ac.customer_category_code cust_category,
          ac.customer_type c_type,
          ott.name order_type,
          oha.order_number,
          ola.line_id,
          TRUNC (oha.ordered_date) ordered_date,
          TRUNC (ola.actual_shipment_date) delivery_date,
          oha.shipment_priority_code priority,
          oha.freight_terms_code freight,
          ola.flow_status_code,
          ola.ordered_item,
          msi.description,
          ola.preferred_grade,
          cat.segment2 item_size,
          cat.category_concat_segs product_category,
          cay.segment3 product_type,
          ola.ordered_quantity * (-1) ordered_quantity,
          ola.order_quantity_uom,
          ola.unit_list_price,
          ola.unit_selling_price,
          ola.ordered_quantity2 * (-1) ordered_quantity2,
          ola.ordered_quantity_uom2,
          (ola.unit_list_price - ola.unit_selling_price) * (-1) discount_sft,
            (  (ola.unit_list_price - ola.unit_selling_price)
             * ola.ordered_quantity)
          * (-1)
             line_discount,
          ABS (pav.adjusted_amount) header_dis_sft,
          (ABS (pav.adjusted_amount) * ola.ordered_quantity) * (-1)
             header_dis_amt,
          CASE
             WHEN     ola.freight_terms_code = 'DEALER'
                  AND ott.transaction_type_id NOT IN (1006, 1014)
             THEN
                ola.shipped_quantity * .8
             ELSE
                0
          END
             freight_value,
          (ola.unit_list_price - ola.unit_selling_price) * (-1)
             total_discount,
          (ola.shipped_quantity * ola.unit_selling_price) * (-1)
             invoice_amount,
          header_level_discount,
          line_level_discount_sft,
          line_level_discount_per,
          carrying_commission,
          ar_invoice_value,
          provs_for_reg_comm,
          provs_for_break_comm,
          ct.trx_number invoice_number,
          NULL challan_no,
          rsv.resource_name sales_person,
          NULL transpoter,
          NULL vehicle_number,
          NULL vehicle_type,
          NULL driver_name,
          NULL driver_contact_no
     FROM oe_order_headers_all oha,
          oe_order_lines_all ola,
          apps.oe_transaction_types_tl ott,
          inv.mtl_system_items_b msi,
          ar_customers ac,
          mtl_item_categories_v cat,
          mtl_item_categories_v cay,
          ra_customer_trx_all ct,
          ra_customer_trx_lines_all ctl,
          xxdbl_prov_booking_tbl pbt,
          jtf_rs_salesreps sal,
          jtf_rs_defresources_v rsv,
          oe_price_adjustments_v pav
    WHERE     oha.header_id = ola.header_id
          AND oha.org_id = ola.org_id
          AND oha.order_type_id = ott.transaction_type_id
          AND oha.header_id = pav.header_id
          AND ola.line_id = pav.line_id
          AND ola.inventory_item_id = msi.inventory_item_id
          AND ola.ship_from_org_id = msi.organization_id
          AND oha.sold_to_org_id = ac.customer_id
          AND msi.inventory_item_id = cat.inventory_item_id
          AND msi.inventory_item_id = cay.inventory_item_id
          AND cat.category_set_name = 'DBL_SALES_CAT_SET'
          AND cay.category_set_name = 'Inventory'
          AND TO_CHAR (oha.order_number) =
                 TO_CHAR (ctl.interface_line_attribute1)
          AND oha.sold_to_org_id = ct.bill_to_customer_id
          AND ct.customer_trx_id = ctl.customer_trx_id
          AND ola.line_id = ctl.interface_line_attribute6
          AND oha.header_id = pbt.order_header_id(+)
          AND ola.line_id = pbt.order_line_id(+)
          AND ct.customer_trx_id = pbt.customer_trx_id(+)
          AND oha.salesrep_id = sal.salesrep_id
          AND sal.resource_id = rsv.resource_id
          AND pav.adjustment_name = 'SO Header Adhoc Discount'
          AND sal.org_id = oha.org_id
          AND cay.organization_id = cat.organization_id
          AND cat.organization_id = 152
          AND oha.org_id = 126
          AND ola.flow_status_code = 'CLOSED'
          AND transaction_type_id IN ('1010', '1008', '1030')
   --          AND oha.org_id = :p_org_id
   --          AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
   --          AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
   --          AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
   --                                                   AND :p_date_to
   UNION ALL
   SELECT oha.org_id,
          ac.customer_id,
          ac.customer_number,
          ac.customer_name,
          ac.customer_category_code cust_category,
          ac.customer_type c_type,
          ott.name order_type,
          oha.order_number,
          ola.line_id,
          TRUNC (oha.ordered_date) ordered_date,
          TRUNC (ola.actual_shipment_date) delivery_date,
          oha.shipment_priority_code priority,
          oha.freight_terms_code freight,
          ola.flow_status_code,
          ola.ordered_item,
          msi.description,
          ola.preferred_grade,
          cat.segment2 item_size,
          cat.category_concat_segs product_category,
          cay.segment3 product_type,
          ola.ordered_quantity,
          ola.order_quantity_uom,
          ola.unit_list_price,
          ola.unit_selling_price,
          ola.ordered_quantity2,
          ola.ordered_quantity_uom2,
          (  ola.unit_list_price
           - ola.unit_selling_price
           + ABS (pav.adjusted_amount))
             discount_sft,
            (  ola.unit_list_price
             - ola.unit_selling_price
             + ABS (pav.adjusted_amount))
          * ola.ordered_quantity
             line_discount,
          ABS (pav.adjusted_amount) header_dis_sft,
          ABS (pav.adjusted_amount) * ola.shipped_quantity header_dis_amt,
          CASE
             WHEN     ola.freight_terms_code = 'DEALER'
                  AND ott.transaction_type_id NOT IN (1006, 1014)
             THEN
                ola.shipped_quantity * .8
             ELSE
                0
          END
             freight_value,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             total_discount,
          ola.shipped_quantity * ola.unit_selling_price invoice_amount,
          header_level_discount,
          line_level_discount_sft,
          line_level_discount_per,
          carrying_commission,
          ar_invoice_value,
          provs_for_reg_comm,
          provs_for_break_comm,
          ct.trx_number invoice_number,
          NULL challan_no,
          rsv.resource_name sales_person,
          NULL transpoter,
          NULL vehicle_number,
          NULL vehicle_type,
          NULL driver_name,
          NULL driver_contact_no
     FROM oe_order_headers_all oha,
          oe_order_lines_all ola,
          apps.oe_transaction_types_tl ott,
          inv.mtl_system_items_b msi,
          ra_customer_trx_all ct,
          ra_customer_trx_lines_all ctl,
          xxdbl_prov_booking_tbl pbt,
          ar_customers ac,
          mtl_item_categories_v cat,
          mtl_item_categories_v cay,
          jtf_rs_salesreps sal,
          jtf_rs_defresources_v rsv,
          oe_price_adjustments_v pav
    WHERE     oha.header_id = ola.header_id
          AND oha.org_id = ola.org_id
          AND oha.order_type_id = ott.transaction_type_id
          AND oha.header_id = pav.header_id
          AND ola.line_id = pav.line_id
          AND ola.inventory_item_id = msi.inventory_item_id
          AND ola.ship_from_org_id = msi.organization_id
          AND oha.sold_to_org_id = ac.customer_id
          AND msi.inventory_item_id = cat.inventory_item_id(+)
          AND msi.inventory_item_id = cay.inventory_item_id
          AND TO_CHAR (oha.order_number) =
                 TO_CHAR (ctl.interface_line_attribute1)
          AND oha.sold_to_org_id = ct.bill_to_customer_id
          AND ct.customer_trx_id = ctl.customer_trx_id
          AND ola.line_id = ctl.interface_line_attribute6
          AND cat.category_set_name = 'DBL_SALES_CAT_SET'
          AND cay.category_set_name = 'Inventory'
          AND pav.adjustment_name = 'SO Header Adhoc Discount'
          AND ott.transaction_type_id NOT IN (1008,
                                              1010,
                                              1030,
                                              1032,
                                              1034)
          AND cay.organization_id = cat.organization_id
          AND cat.organization_id = 152
          AND cay.organization_id = cat.organization_id
          AND oha.org_id = 126
          AND oha.salesrep_id = sal.salesrep_id
          AND sal.resource_id = rsv.resource_id
          AND ola.flow_status_code = 'CLOSED'
          AND oha.header_id = pbt.order_header_id(+)
          AND ola.line_id = pbt.order_line_id(+)
          --          AND oha.org_id = :p_org_id
          --          AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
          --          AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
          --          AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
          --                                                   AND :p_date_to
          AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_omshipping_line_v olv
                   WHERE     ola.line_id = olv.order_line_id
                         AND ola.org_id = olv.org_id
                         AND omshipping_line_status = 'CLOSED')
   UNION ALL
   SELECT oha.org_id,
          ac.customer_id,
          ac.customer_number,
          ac.customer_name,
          ac.customer_category_code cust_category,
          ac.customer_type c_type,
          ott.name order_type,
          oha.order_number,
          ola.line_id,
          TRUNC (oha.ordered_date) ordered_date,
          TRUNC (ola.actual_shipment_date) delivery_date,
          oha.shipment_priority_code priority,
          oha.freight_terms_code freight,
          ola.flow_status_code,
          ola.ordered_item,
          msi.description,
          ola.preferred_grade,
          cat.segment2 item_size,
          cat.category_concat_segs product_category,
          cay.segment3 product_type,
          ola.ordered_quantity,
          ola.order_quantity_uom,
          ola.unit_list_price,
          ola.unit_selling_price,
          ola.ordered_quantity2,
          ola.ordered_quantity_uom2,
          (ola.unit_list_price - ola.unit_selling_price) discount_sft,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             line_discount,
          NULL header_dis_sft,
          NULL header_dis_amt,
          CASE
             WHEN     ola.freight_terms_code = 'DEALER'
                  AND ott.transaction_type_id NOT IN (1006, 1014)
             THEN
                ola.shipped_quantity * .8
             ELSE
                0
          END
             freight_value,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             total_discount,
          ola.shipped_quantity * ola.unit_selling_price invoice_amount,
          header_level_discount,
          line_level_discount_sft,
          line_level_discount_per,
          carrying_commission,
          ar_invoice_value,
          provs_for_reg_comm,
          provs_for_break_comm,
          ct.trx_number invoice_number,
          olv.delivery_challan_number challan_no,
          rsv.resource_name sales_person,
          olv.transport_name transpoter,
          th.vehicle_no vehicle_number,
          th.delivery_mode_code vehicle_type,
          th.driver_name driver_name,
          th.transporter_no driver_contact_no
     FROM oe_order_headers_all oha,
          oe_order_lines_all ola,
          apps.oe_transaction_types_tl ott,
          inv.mtl_system_items_b msi,
          ar_customers ac,
          mtl_item_categories_v cat,
          mtl_item_categories_v cay,
          ra_customer_trx_all ct,
          ra_customer_trx_lines_all ctl,
          xxdbl.xxdbl_omshipping_line_v olv,
          xxdbl_prov_booking_tbl pbt,
          xxdbl_transpoter_headers th,
          jtf_rs_salesreps sal,
          jtf_rs_defresources_v rsv
    WHERE     oha.header_id = ola.header_id
          AND oha.org_id = ola.org_id
          AND oha.order_type_id = ott.transaction_type_id
          AND ola.inventory_item_id = msi.inventory_item_id
          AND ola.ship_from_org_id = msi.organization_id
          AND oha.sold_to_org_id = ac.customer_id
          AND msi.inventory_item_id = cat.inventory_item_id
          AND msi.inventory_item_id = cay.inventory_item_id
          AND cat.category_set_name = 'DBL_SALES_CAT_SET'
          AND cay.category_set_name = 'Inventory'
          AND TO_CHAR (oha.order_number) =
                 TO_CHAR (ctl.interface_line_attribute1)
          AND oha.sold_to_org_id = ct.bill_to_customer_id
          AND ct.customer_trx_id = ctl.customer_trx_id
          AND ola.line_id = ctl.interface_line_attribute6
          AND ola.line_id = olv.order_line_id
          AND oha.header_id = pbt.order_header_id(+)
          AND ola.line_id = pbt.order_line_id(+)
          AND ct.customer_trx_id = pbt.customer_trx_id(+)
          AND ola.inventory_item_id = olv.item_id
          AND olv.transport_challan_number = th.transpoter_challan_number(+)
          AND oha.salesrep_id = sal.salesrep_id
          AND sal.resource_id = rsv.resource_id
          AND sal.org_id = oha.org_id
          AND cay.organization_id = cat.organization_id
          AND cat.organization_id = 152
          AND oha.org_id = 126
          AND ola.flow_status_code = 'CLOSED'
          AND olv.omshipping_line_status = 'CLOSED'
          --          AND oha.org_id = :p_org_id
          --          AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
          --          AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
          --          AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
          --                                                   AND :p_date_to
          AND NOT EXISTS
                 (SELECT 1
                    FROM oe_price_adjustments_v pav
                   WHERE     ola.line_id = pav.line_id
                         AND pav.adjustment_name = 'SO Header Adhoc Discount')
   UNION ALL
   SELECT oha.org_id,
          ac.customer_id,
          ac.customer_number,
          ac.customer_name,
          ac.customer_category_code cust_category,
          ac.customer_type c_type,
          ott.name order_type,
          oha.order_number,
          ola.line_id,
          TRUNC (oha.ordered_date) ordered_date,
          TRUNC (ola.actual_shipment_date) delivery_date,
          oha.shipment_priority_code priority,
          oha.freight_terms_code freight,
          ola.flow_status_code,
          ola.ordered_item,
          msi.description,
          ola.preferred_grade,
          cat.segment2 item_size,
          cat.category_concat_segs product_category,
          cay.segment3 product_type,
          ola.ordered_quantity,
          ola.order_quantity_uom,
          ola.unit_list_price,
          ola.unit_selling_price,
          ola.ordered_quantity2,
          ola.ordered_quantity_uom2,
          (ola.unit_list_price - ola.unit_selling_price) discount_sft,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             line_discount,
          NULL header_dis_sft,
          NULL header_dis_amt,
          CASE
             WHEN     ola.freight_terms_code = 'DEALER'
                  AND ott.transaction_type_id NOT IN (1006, 1014)
             THEN
                ola.shipped_quantity * .8
             ELSE
                0
          END
             freight_value,
            (ola.unit_list_price - ola.unit_selling_price)
          * ola.ordered_quantity
             total_discount,
          ola.shipped_quantity * ola.unit_selling_price invoice_amount,
          header_level_discount,
          line_level_discount_sft,
          line_level_discount_per,
          carrying_commission,
          ar_invoice_value,
          provs_for_reg_comm,
          provs_for_break_comm,
          ct.trx_number invoice_number,
          NULL challan_no,
          rsv.resource_name sales_person,
          NULL transpoter,
          NULL vehicle_number,
          NULL vehicle_type,
          NULL driver_name,
          NULL driver_contact_no
     FROM oe_order_headers_all oha,
          oe_order_lines_all ola,
          apps.oe_transaction_types_tl ott,
          inv.mtl_system_items_b msi,
          ra_customer_trx_all ct,
          ra_customer_trx_lines_all ctl,
          xxdbl_prov_booking_tbl pbt,
          ar_customers ac,
          mtl_item_categories_v cat,
          mtl_item_categories_v cay,
          jtf_rs_salesreps sal,
          jtf_rs_defresources_v rsv
    WHERE     oha.header_id = ola.header_id
          AND oha.org_id = ola.org_id
          AND oha.order_type_id = ott.transaction_type_id
          AND ola.inventory_item_id = msi.inventory_item_id
          AND ola.ship_from_org_id = msi.organization_id
          AND oha.sold_to_org_id = ac.customer_id
          AND msi.inventory_item_id = cat.inventory_item_id(+)
          AND msi.inventory_item_id = cay.inventory_item_id
          AND TO_CHAR (oha.order_number) =
                 TO_CHAR (ctl.interface_line_attribute1)
          AND oha.sold_to_org_id = ct.bill_to_customer_id
          AND ct.customer_trx_id = ctl.customer_trx_id
          AND ola.line_id = ctl.interface_line_attribute6
          AND cat.category_set_name = 'DBL_SALES_CAT_SET'
          AND cay.category_set_name = 'Inventory'
          AND ott.transaction_type_id NOT IN (1008,
                                              1010,
                                              1030,
                                              1032,
                                              1034)
          AND cay.organization_id = cat.organization_id
          AND cat.organization_id = 152
          AND cay.organization_id = cat.organization_id
          AND oha.org_id = 126
          AND oha.salesrep_id = sal.salesrep_id
          AND sal.resource_id = rsv.resource_id
          AND ola.flow_status_code = 'CLOSED'
          AND oha.header_id = pbt.order_header_id(+)
          AND ola.line_id = pbt.order_line_id(+)
          --          AND oha.org_id = :p_org_id
          --          AND ( :p_customer_id IS NULL OR ac.customer_id = :p_customer_id)
          --          AND ( :p_order_number IS NULL OR oha.order_number = :p_order_number)
          --          AND TRUNC (ola.actual_shipment_date) BETWEEN :p_date_from
          --                                                   AND :p_date_to
          AND NOT EXISTS
                 (SELECT 1
                    FROM xxdbl.xxdbl_omshipping_line_v olv
                   WHERE     ola.line_id = olv.order_line_id
                         AND ola.org_id = olv.org_id
                         AND omshipping_line_status = 'CLOSED')
          AND NOT EXISTS
                 (SELECT 1
                    FROM oe_price_adjustments_v pav
                   WHERE     ola.line_id = pav.line_id
                         AND pav.adjustment_name = 'SO Header Adhoc Discount');