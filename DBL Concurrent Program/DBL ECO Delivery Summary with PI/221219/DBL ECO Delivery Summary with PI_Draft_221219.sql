/* Formatted on 11-Dec-19 14:14:08 (QP5 v5.136.908.31019) */
SELECT DISTINCT ola.flow_status_code,olv.omshipping_line_status,
       (olv.delivery_challan_number) challan_number,
       mlh.customer_name,
       mlh.customer_number,
       ola.ordered_item,
       mlh.master_lc_number lc_number,
       mlh.master_lc_received_date lc_date,
       mlh.amd_no,
       mlh.attribute6 amd_date,
       mlc.pi_number,
       olv.order_number,
       --olv.delivery_challan_number challan_number,
       --olv.delivery_date challan_date,
       TRUNC (ola.actual_shipment_date) challan_date,
       --SUM (olv.picking_qty_crt) quantity1,
       --         SUM (
       --            100 / (100 - ola.cust_model_serial_number) * (olv.picking_qty_crt))
       --            quantity,
       CASE
          WHEN cay.segment3 = 'SEWING THREAD'
          THEN
             ola.shipped_quantity
          WHEN cay.segment3 IN ('DYED YARN', 'DYED FIBER')
          THEN
             (  100
              / (100 - ola.cust_model_serial_number)
              * (ola.shipped_quantity))
       END
          quantity,
       ola.shipped_quantity * ola.unit_selling_price VALUE
  FROM xxdbl_master_lc_headers mlh,
       xxdbl_master_lc_line1 mlc,
       xxdbl_proforma_headers ph,
       xxdbl_proforma_lines pl,
       xxdbl_bill_stat_headers bsh,
       xxdbl_bill_stat_lines bsl,
       xxdbl.xxdbl_omshipping_line_v olv,
       mtl_item_categories_v cay,
       apps.oe_order_lines_all ola
 WHERE     mlh.master_lc_header_id = mlc.master_lc_header_id(+)
       AND mlc.pi_number = ph.proforma_number(+)
       AND ph.proforma_header_id = pl.proforma_header_id(+)
       AND ph.proforma_number = bsh.pi_number(+)
       AND ph.proforma_header_id = bsh.pi_id(+)
       AND pl.bill_stat_number = bsh.bill_stat_number
       AND bsh.bill_stat_header_id = bsl.bill_stat_header_id(+)
       AND bsl.order_number = olv.order_number(+)
       AND ola.header_id (+)= bsl.order_id
       AND bsl.item_code = ola.ordered_item(+)
       AND ola.ordered_item(+) = olv.item_code
       AND ola.line_number(+) = REGEXP_SUBSTR (bsl.order_line_no, '[^.]+')
       --AND bsl.ORDER_LINE_NO=olv.ORDER_LINE_NO
       --AND bsl.order_line_id = olv.order_line_id
       AND olv.order_line_id = ola.line_id(+)
       AND ola.inventory_item_id = cay.inventory_item_id(+)
       AND bsl.inventory_item_id = cay.inventory_item_id(+)
       AND cay.category_set_name = 'Inventory'
       AND cay.organization_id = 150
       AND mlh.org_id = 125
       AND olv.org_id = 125
       AND olv.omshipping_line_status not in ('CANCELLED','CLOSED', 'NEW')
       AND ola.flow_status_code = 'AWAITING_SHIPPING'
--       AND mlh.amd_no = :p_amd_no
--       AND mlh.master_lc_number = 'BBCDAK987535'--:p_lc_number    --BBCDAK987535  --BBCDAK987531