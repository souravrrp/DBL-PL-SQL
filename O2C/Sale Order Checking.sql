/* Formatted on 6/15/2021 10:52:00 AM (QP5 v5.354) */
------------------------------Order Details---------------------------------------------------

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
         apps.ar_customers        ac
   WHERE     1 = 1
         AND (( :p_org_id IS NULL) OR (ooh.org_id = :p_org_id))
         AND ooh.header_id = ool.header_id
         AND ( :p_order_number IS NULL OR (ooh.order_number = :p_order_number))
         AND TRUNC (ooh.ordered_date) BETWEEN NVL ( :p_ordered_date_from, TRUNC (ooh.ordered_date)) AND NVL ( :p_ordered_date_to, TRUNC (ooh.ordered_date))
         AND TRUNC (ool.actual_shipment_date) BETWEEN NVL ( :p_invoice_date_from, TRUNC ( ool.actual_shipment_date)) AND NVL ( :p_invoice_date_to, TRUNC ( ool.actual_shipment_date))
         AND (   :p_customer_number IS NULL OR (ac.customer_number = :p_customer_number))
         AND (   :p_cust_name IS NULL OR (UPPER (ac.customer_name) LIKE UPPER ('%' || :p_cust_name || '%')))
         --AND ac.customer_number IN ('187056')
         --AND ooh.order_number IN ('1759890')
         --AND ool.line_number=9
         --AND ool.order_quantity_uom='MTN'
         --AND ool.ordered_item='SCRP.CAN0.0001'
         --AND ool.inventory_item_id='206571'
         --AND ooh.flow_status_code='CLOSED'--'BOOKED'
         --AND ool.flow_status_code='AWAITING_SHIPPING'-- NOT IN ('CLOSED','SHIPPED','CANCELLED','ENTERED','AWAITING_SHIPPING','AWAITING_RETURN_DISPOSITION','AWAITING_RETURN','BOOKED','FULFILLED','RETURNED')
         --AND TRUNC(ooh.booked_date) > '20-Oct-2019'
         --AND TO_CHAR (ooh.ordered_date, 'mon-rr') = 'apr-18'
         --AND TO_CHAR (ooh.ordered_date, 'rrrr') = '2018'
         --AND TO_CHAR (ooh.ordered_date, 'dd-mon-rr') = '17-jun-19'
         --AND ooh.order_type_id=1101
         --AND ooh.ship_from_org_id=1346
         AND ool.inventory_item_id = msi.inventory_item_id
         AND ool.ship_from_org_id = msi.organization_id
         AND ac.customer_id = ool.sold_to_org_id
ORDER BY ooh.ordered_date DESC;

----------------------------------------Invoice Details-------------------------
SELECT *
  FROM apps.ap_invoices_all aia
 WHERE     1 = 1
       AND (( :p_org_id IS NULL) OR (aia.org_id = :p_org_id))
       --AND aia.invoice_num in ()
       AND (   :p_invoice_number IS NULL OR (aia.invoice_num = :p_invoice_number));


---------------------------------Picking Batches--------------------------------
SELECT *
  FROM apps.wsh_picking_batches wpb
 WHERE 1 = 1
--AND wpb.batch_id IN ('12715272')
AND (:p_batch_id IS NULL OR (wpb.batch_id = :p_batch_id));
