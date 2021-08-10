/* Formatted on 12-May-20 12:37:17 (QP5 v5.136.908.31019) */
SELECT qsl.name,
       qsl.description,
       qms.operand,
       qms.arithmetic_operator,
       qms.start_date_active start_date,
       qms.end_date_active end_date,
       qms.product_attr_value item_code,
       msi.description item_description,
       qpa.pricing_attr_value_from grade
  FROM qp_secu_list_headers_vl qsl,
       qp_modifier_summary_v qms,
       qp_pricing_attributes qpa,
       inv.mtl_system_items_b msi
 WHERE     qsl.list_header_id = qms.list_header_id
       AND qsl.list_header_id = qms.list_header_id(+)
       AND qms.list_line_id = qpa.list_line_id(+)
       AND qms.pricing_attribute_id <> qpa.pricing_attribute_id
       AND qms.product_attr_value = msi.segment1
       AND msi.organization_id = 152
       --AND qpa.pricing_attr_value_from='B'
       AND TRUNC (SYSDATE) BETWEEN TRUNC (qms.start_date_active) AND TRUNC (qms.end_date_active)
       --AND TRUNC (qms.start_date_active) BETWEEN :p_start_date AND  :p_end_date
       --AND TRUNC (qms.end_date_active) BETWEEN :p_start_date AND :p_end_date