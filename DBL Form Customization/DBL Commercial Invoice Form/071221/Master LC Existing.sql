/* Formatted on 12/7/2021 4:16:57 PM (QP5 v5.365) */
SELECT *
  FROM (SELECT DISTINCT
               rctla.line_number,
               rcta.trx_number,
               rcta.customer_trx_id,
               rctla.customer_trx_line_id,
               ooha.cust_po_number,
               ooha.order_number,
               ooha.header_id,
               oola.ordered_item
                   item_code,
               rctla.description
                   item_desc,
               oola.inventory_item_id,
               msik.primary_unit_of_measure
                   /*oola.order_quantity_uom*/
                   uom,
               oola.ordered_quantity
                   delivery_qty,
               oola.customer_job
                   grey_yarn_fiber_qty,
               oola.unit_selling_price
                   rate,
               oola.ordered_quantity * oola.unit_selling_price
                   line_value,
               xol.delivery_challan_number,
               xol.delivery_date
                   delivery_challan_date,
               xph.proforma_number,
               xph.proforma_header_id,
               xph.proforma_date,
               DECODE (oola.shipped_quantity2,
                       NULL, oola.shipped_quantity,
                       0, oola.shipped_quantity,
                       oola.shipped_quantity2)            /*msik.unit_weight*/
                   net_weight,
               rctla.quantity_invoiced * msik.unit_weight /*msik.unit_volume*/
                   gross_weight,
               oola.line_number || '.' || oola.shipment_number
                   order_line_no
          FROM xxdbl_proforma_headers     xph,
               xxdbl_proforma_lines       xpl,
               xxdbl_bill_stat_lines      xbsl,
               oe_order_lines_all         oola,
               oe_order_headers_all       ooha,
               mtl_system_items_kfv       msik,
               xxdbl_omshipping_line      xol,
               ra_customer_trx_lines_all  rctla,
               ra_customer_trx_all        rcta
         WHERE     1 = 1
               AND xpl.proforma_header_id = xph.proforma_header_id(+)
               AND xph.proforma_number = :pi_control.pi_number_add
               --'PI-100253-000001'
               --:pi_control.pi_number_add
               AND xph.customer_id = :xxdbl_comm_inv_headers.customer_id
               --145328
               --:xxdbl_comm_inv_headers.customer_id
               AND xbsl.bill_stat_header_id = xpl.bill_stat_header_id
               AND xbsl.order_id = oola.header_id
               AND SUBSTR (xbsl.order_line_no,
                           1,
                           (  INSTR (xbsl.order_line_no,
                                     '.',
                                     1,
                                     1)
                            - 1)) = oola.line_number
               AND oola.header_id = ooha.header_id
               AND oola.inventory_item_id = msik.inventory_item_id
               AND oola.ship_from_org_id = msik.organization_id
               AND oola.line_id = xol.order_line_id(+)
               AND xol.omshipping_line_status(+) != 'CANCELLED'
               AND oola.line_id = rctla.interface_line_attribute6(+)
               AND rctla.customer_trx_id = rcta.customer_trx_id(+)
               AND rcta.org_id(+) = :xxdbl_comm_inv_headers.org_id
               --125 --:xxdbl_comm_inv_headers.org_id;
               AND NOT EXISTS
                       (SELECT 'X'
                          FROM xxdbl_comm_inv_headers  xcih,
                               xxdbl_comm_inv_lines    xcil
                         WHERE     1 = 1
                               AND xcih.comm_inv_header_id =
                                   xcil.comm_inv_header_id
                               AND xcih.comm_inv_status != 'CANCELLED'
                               AND xcil.invoice_line_id =
                                   rctla.customer_trx_line_id))
 WHERE     1 = 1
       AND delivery_challan_number IS NOT NULL
       AND trx_number IS NOT NULL