/* Formatted on 12/6/2021 4:22:20 PM (QP5 v5.365) */
SELECT ottt.name order_type, ooh.order_number, ooh.ordered_date
  FROM apps.oe_order_headers_all ooh, oe_transaction_types_tl ottt
 WHERE     1 = 1
       AND ooh.order_type_id = ottt.transaction_type_id
       AND ooh.ordered_date BETWEEN '01-JUL-2021' AND '06-DEC-2021'
       AND ottt.name IN
               ('Return Order Sewing Thd Apprv', --'Replacement Order for Sewing',
                                                 'Return Replacement');

  SELECT ooh.org_id,
         ooh.sold_to_org_id                                  customer_id,
         ac.customer_number,
         ac.customer_name,
         ooh.cust_po_number,
         ooh.order_number,
         ooh.header_id,
         ool.line_id,
         ooh.order_type_id,
         ooh.ordered_date,
         ottt.name                                           order_type,
         ooh.demand_class_code                               demand_class,
         ooh.transactional_curr_code                         trans_curr_code,
         ooh.context                                         ord_hdr_context,
         ooh.attribute4                                      ord_hdr_ctxt_val,
         ooh.packing_instructions                            style_number,
         ooh.sales_channel_code                              buyer,
         ooh.salesrep_id                                     salesperson_id,
         ooh.booked_date,
         ooh.header_id,
         ool.line_id,
         ool.inventory_item_id,
         ool.ordered_item                                    item_code,
         msi.description                                     item_description,
         msi.primary_uom_code,
         msi.secondary_uom_code,
         ool.order_quantity_uom                              order_uom_code,
         ooh.flow_status_code                                order_header_status,
         ool.flow_status_code                                order_line_status,
         ool.ordered_quantity,
         ool.ordered_quantity2,
         ool.shipped_quantity,
         ool.invoiced_quantity,
         ool.cancelled_quantity,
         ool.actual_shipment_date,
         ool.unit_selling_price,
         ool.pricing_date,
         ool.price_list_id,
         ool.context,
         ool.attribute1                                      color_or_shade,
         ool.attribute3                                      color_ref_no,
         ool.ship_to_org_id,
         ool.ship_from_org_id                                warehouse_org_id,
         (ool.unit_selling_price * ool.ordered_quantity)     amount
    --,OOH.*
    --,OOL.*
    --,CUST.*
    FROM apps.oe_order_lines_all  ool,
         apps.oe_order_headers_all ooh,
         inv.mtl_system_items_b   msi,
         apps.ar_customers        ac,
         oe_transaction_types_tl  ottt
   WHERE     1 = 1
         AND (( :p_org_id IS NULL) OR (ooh.org_id = :p_org_id))
         AND ooh.header_id = ool.header_id
         AND ( :p_order_number IS NULL OR (ooh.order_number = :p_order_number))
         AND TRUNC (ooh.ordered_date) BETWEEN NVL ( :p_ordered_date_from,
                                                   TRUNC (ooh.ordered_date))
                                          AND NVL ( :p_ordered_date_to,
                                                   TRUNC (ooh.ordered_date))
         AND TRUNC (ool.actual_shipment_date) BETWEEN NVL (
                                                          :p_invoice_date_from,
                                                          TRUNC (
                                                              ool.actual_shipment_date))
                                                  AND NVL (
                                                          :p_invoice_date_to,
                                                          TRUNC (
                                                              ool.actual_shipment_date))
         AND (   :p_customer_number IS NULL
              OR (ac.customer_number = :p_customer_number))
         AND (   :p_cust_name IS NULL
              OR (UPPER (ac.customer_name) LIKE
                      UPPER ('%' || :p_cust_name || '%')))
         AND ooh.order_type_id = ottt.transaction_type_id
         AND ottt.name IN
                 ('Return Order Sewing Thd Apprv', --'Replacement Order for Sewing',
                                                   'Return Replacement')
         AND ool.inventory_item_id = msi.inventory_item_id
         AND ool.ship_from_org_id = msi.organization_id
         AND ac.customer_id = ool.sold_to_org_id
ORDER BY ooh.ordered_date DESC;