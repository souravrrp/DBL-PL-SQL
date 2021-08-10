/* Formatted on 3/3/2021 4:48:13 PM (QP5 v5.287) */
SELECT qll.*, qll.operand val, qpa.pricing_attr_value_from item_grade
  --qll.*
  FROM apps.qp_list_headers_vl qlh,
       apps.qp_list_lines qll,
       apps.qp_pricing_attributes qpa,
       apps.mtl_system_items_b msi
 WHERE     1 = 1
       AND qlh.list_header_id = qll.list_header_id
       AND qlh.name = 'Ceramic Discount - Sqft wise'
       AND qll.list_header_id = qpa.list_header_id
       AND qll.list_line_id = qpa.list_line_id
       AND qpa.product_attr_value = '189491'
       AND qpa.pricing_attribute = 'PRICING_ATTRIBUTE19'
       AND TO_CHAR (qpa.product_attr_value) = msi.inventory_item_id
       AND msi.organization_id = 152
       AND TRUNC (SYSDATE) BETWEEN TRUNC (qll.start_date_active)
                               AND TRUNC (qll.end_date_active)