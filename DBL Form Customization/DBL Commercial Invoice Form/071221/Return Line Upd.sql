/* Formatted on 12/7/2021 5:06:56 PM (QP5 v5.365) */
SELECT DISTINCT
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
       (-1) * oola.ordered_quantity
           delivery_qty,
       oola.customer_job
           grey_yarn_fiber_qty,
       oola.unit_selling_price
           rate,
       (-1) * oola.ordered_quantity * oola.unit_selling_price
           line_value,
       xol.delivery_challan_number,
       xol.delivery_date
           delivery_challan_date,
       xph.proforma_number,
       xph.proforma_header_id,
       xph.proforma_date,
       DECODE ((-1) * oola.shipped_quantity2,
               NULL, (-1) * oola.shipped_quantity,
               0, (-1) * oola.shipped_quantity,
               (-1) * oola.shipped_quantity2)             /*msik.unit_weight*/
           net_weight,
       (-1) * rctla.quantity_invoiced * msik.unit_weight  /*msik.unit_volume*/
           gross_weight,
       oola.line_number || '.' || oola.shipment_number
           order_line_no
  FROM xxdbl_master_lc_headers        mlh,
       xxdbl_master_lc_line1          mlc,
       xxdbl_proforma_headers         xph,
       xxdbl_proforma_lines           xpl,
       xxdbl_bill_stat_headers        bsh,
       xxdbl_bill_stat_lines          xbsl,
       mtl_item_categories_v          cay,
       apps.oe_order_lines_all        oola,
       apps.oe_order_headers_all      ooha,
       apps.oe_order_headers_all      ohal,
       apps.oe_order_lines_all        olal,
       mtl_system_items_kfv           msik,
       xxdbl.xxdbl_omshipping_line_v  xol,
       ra_customer_trx_lines_all      rctla,
       ra_customer_trx_all            rcta
 WHERE     mlh.master_lc_header_id = mlc.master_lc_header_id
       AND mlc.pi_number = xph.proforma_number
       AND xph.proforma_header_id = xpl.proforma_header_id
       AND xph.proforma_number = bsh.pi_number
       AND xph.proforma_header_id = bsh.pi_id
       AND xpl.bill_stat_number = bsh.bill_stat_number
       AND bsh.bill_stat_header_id = xbsl.bill_stat_header_id
       AND xbsl.order_number = ooha.order_number
       AND oola.header_id = xbsl.order_id
       AND xbsl.item_code = oola.ordered_item
       AND oola.line_number = REGEXP_SUBSTR (xbsl.order_line_no, '[^.]+')
       AND oola.inventory_item_id = cay.inventory_item_id
       AND xbsl.inventory_item_id = cay.inventory_item_id
       AND cay.category_set_name = 'Inventory'
       AND cay.organization_id = 150
       AND mlh.org_id = 125
       AND ohal.header_id = olal.header_id
       AND oola.reference_line_id = olal.line_id
       AND oola.reference_header_id = ohal.header_id
       AND olal.line_id = xol.order_line_id
       AND oola.flow_status_code = 'CLOSED'
       AND mlh.master_lc_status <> 'CANCELLED'
       AND oola.line_category_code = 'RETURN'
       AND xol.omshipping_line_status = 'CLOSED'
       --AND ooha.order_type_id = 1083
       AND oola.line_id = rctla.interface_line_attribute6(+)
       AND rctla.customer_trx_id = rcta.customer_trx_id(+)
       AND rcta.org_id(+) = mlh.org_id        --:xxdbl_comm_inv_headers.org_id
       AND NOT EXISTS
               (SELECT 'X'
                  FROM xxdbl_comm_inv_headers xcih, xxdbl_comm_inv_lines xcil
                 WHERE     1 = 1
                       AND xcih.comm_inv_header_id = xcil.comm_inv_header_id
                       AND xcih.comm_inv_status != 'CANCELLED'
                       AND xcil.invoice_line_id = rctla.customer_trx_line_id)
       AND oola.inventory_item_id = msik.inventory_item_id
       AND oola.ship_from_org_id = msik.organization_id
       AND mlh.amd_no = :p_amd_no
       AND mlh.master_lc_number = :p_lc_number