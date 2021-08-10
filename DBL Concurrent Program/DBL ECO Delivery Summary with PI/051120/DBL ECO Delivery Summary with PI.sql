/* Formatted on 03-Jun-20 10:29:32 (QP5 v5.136.908.31019) */
WITH delivery_sum_with_pi
        AS (SELECT DISTINCT
                   (olv.delivery_challan_number) challan_number,
                   mlh.customer_name,
                   mlh.customer_number,
                   ola.ordered_item,
                   ola.line_id,
                   mlh.master_lc_number lc_number,
                   mlh.master_lc_received_date lc_date,
                   mlh.amd_no,
                   mlh.attribute6 amd_date,
                   mlc.pi_number,
                   olv.order_number,
                   TRUNC (ola.actual_shipment_date) challan_date,
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
             WHERE     mlh.master_lc_header_id = mlc.master_lc_header_id
                   AND mlc.pi_number = ph.proforma_number
                   AND ph.proforma_header_id = pl.proforma_header_id
                   AND ph.proforma_number = bsh.pi_number
                   AND ph.proforma_header_id = bsh.pi_id
                   AND pl.bill_stat_number = bsh.bill_stat_number
                   AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
                   AND bsl.order_number = olv.order_number
                   AND ola.header_id = bsl.order_id
                   AND bsl.item_code = ola.ordered_item
                   AND ola.ordered_item = olv.item_code
                   AND ola.line_number =
                         REGEXP_SUBSTR (bsl.order_line_no, '[^.]+')
                   AND olv.order_line_id = ola.line_id
                   AND ola.inventory_item_id = cay.inventory_item_id
                   AND bsl.inventory_item_id = cay.inventory_item_id
                   AND cay.category_set_name = 'Inventory'
                   AND cay.organization_id = 150
                   AND mlh.org_id = 125
                   AND olv.org_id = 125
                   AND olv.omshipping_line_status = 'CLOSED'
                   AND ola.flow_status_code = 'CLOSED'
                   AND mlh.master_lc_status <> 'CANCELLED'
                   AND mlh.amd_no = :p_amd_no
                   AND mlh.master_lc_number = :p_lc_number
            UNION ALL
            SELECT DISTINCT
                      (olv.delivery_challan_number)
                   || ' / '
                   || ohal.order_number
                      challan_number,
                   mlh.customer_name,
                   mlh.customer_number,
                   ola.ordered_item,
                   ola.line_id,
                   mlh.master_lc_number lc_number,
                   mlh.master_lc_received_date lc_date,
                   mlh.amd_no,
                   mlh.attribute6 amd_date,
                   mlc.pi_number,
                   oha.order_number,
                   TRUNC (ola.actual_shipment_date) challan_date,
                   CASE
                      WHEN cay.segment3 = 'SEWING THREAD'
                      THEN
                         ola.shipped_quantity * (-1)
                      WHEN cay.segment3 IN ('DYED YARN', 'DYED FIBER')
                      THEN
                         (  100
                          / (100 - ola.cust_model_serial_number)
                          * (ola.shipped_quantity)
                          * (-1))
                   END
                      quantity,
                   (ola.shipped_quantity * (-1)) * ola.unit_selling_price
                      VALUE
              FROM xxdbl_master_lc_headers mlh,
                   xxdbl_master_lc_line1 mlc,
                   xxdbl_proforma_headers ph,
                   xxdbl_proforma_lines pl,
                   xxdbl_bill_stat_headers bsh,
                   xxdbl_bill_stat_lines bsl,
                   mtl_item_categories_v cay,
                   apps.oe_order_lines_all ola,
                   apps.oe_order_headers_all oha,
                   apps.oe_order_headers_all ohal,
                   apps.oe_order_lines_all olal,
                   xxdbl.xxdbl_omshipping_line_v olv
             WHERE     mlh.master_lc_header_id = mlc.master_lc_header_id
                   AND mlc.pi_number = ph.proforma_number
                   AND ph.proforma_header_id = pl.proforma_header_id
                   AND ph.proforma_number = bsh.pi_number
                   AND ph.proforma_header_id = bsh.pi_id
                   AND pl.bill_stat_number = bsh.bill_stat_number
                   AND bsh.bill_stat_header_id = bsl.bill_stat_header_id
                   AND bsl.order_number = oha.order_number
                   AND ola.header_id = bsl.order_id
                   AND bsl.item_code = ola.ordered_item
                   AND ola.line_number =
                         REGEXP_SUBSTR (bsl.order_line_no, '[^.]+')
                   AND ola.inventory_item_id = cay.inventory_item_id
                   AND bsl.inventory_item_id = cay.inventory_item_id
                   AND cay.category_set_name = 'Inventory'
                   AND cay.organization_id = 150
                   AND mlh.org_id = 125
                   AND ohal.header_id = olal.header_id
                   AND ola.reference_line_id = olal.line_id
                   AND ola.reference_header_id = ohal.header_id
                   AND olal.line_id = olv.order_line_id
                   AND ola.flow_status_code = 'CLOSED'
                   AND mlh.master_lc_status <> 'CANCELLED'
                   AND ola.line_category_code = 'RETURN'
                   AND olv.omshipping_line_status = 'CLOSED'
                   AND oha.order_type_id = 1083
                   AND mlh.amd_no = :p_amd_no
                   AND mlh.master_lc_number = :p_lc_number)
  SELECT challan_number,
         customer_name,
         customer_number,
         lc_number,
         lc_date,
         amd_no,
         amd_date,
         pi_number,
         order_number,
         challan_date,
         SUM (quantity) quantity,
         SUM (VALUE) VALUE
    FROM delivery_sum_with_pi
GROUP BY challan_number,
         customer_name,
         customer_number,
         lc_number,
         lc_date,
         amd_no,
         amd_date,
         pi_number,
         order_number,
         challan_date