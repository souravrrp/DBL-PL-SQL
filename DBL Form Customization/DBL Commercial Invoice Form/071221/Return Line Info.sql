/* Formatted on 12/7/2021 4:49:09 PM (QP5 v5.365) */
SELECT DISTINCT
       (xol.delivery_challan_number) || ' / ' || ohal.order_number
           challan_number,
       mlh.customer_name,
       mlh.customer_number,
       oola.ordered_item,
       oola.line_id,
       mlh.master_lc_number
           lc_number,
       mlh.master_lc_received_date
           lc_date,
       mlh.amd_no,
       mlh.attribute6
           amd_date,
       mlc.pi_number,
       ooha.order_number,
       TRUNC (oola.actual_shipment_date)
           challan_date,
       CASE
           WHEN cay.segment3 = 'SEWING THREAD'
           THEN
               oola.shipped_quantity * (-1)
           WHEN cay.segment3 IN ('DYED YARN', 'DYED FIBER')
           THEN
               (  100
                / (100 - oola.cust_model_serial_number)
                * (oola.shipped_quantity)
                * (-1))
       END
           quantity,
       (oola.shipped_quantity * (-1)) * oola.unit_selling_price
           VALUE
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